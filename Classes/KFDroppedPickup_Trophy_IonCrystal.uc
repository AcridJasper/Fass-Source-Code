class KFDroppedPickup_Trophy_IonCrystal extends KFDroppedPickup;

var bool Destructible;
var int Health;

var ParticleSystem ParticleFX;
var	transient ParticleSystemComponent ParticlePSC;

// var float LightFadeStartTime;
var transient float LightFadePerSecond;

var bool bEnableGlowLight;
var PointLightComponent GlowLight;
var LightPoolPriority GlowLightPriority;

// var KFPawn_Monster Target;
// var float TargetRadius;

// var transient ParticleSystemComponent ParticleEffectPSC;
// var ParticleSystem ParticleEffect;

var KFGameExplosion ExplosionTemplate;

var int MaxNumberOfZedsZapped;
var int MaxDistanceToBeZapped;
var float ZapInterval;
var float TimeToZap;
var int ZapDamage;

var KFPawn_Monster oZedCurrentlyBeingSprayed;

var ParticleSystem BeamPSCTemplate;

var string EmitterPoolClassPath;
var EmitterPool vBeamEffects;

struct BeamZapInfo
{
	var ParticleSystemComponent oBeam;
	var KFPawn_Monster oAttachedZed;
	var Actor oSourceActor;
	var float oControlTime;
};

var array<BeamZapInfo> CurrentZapBeams;

var AkComponent ZapSFXComponent;
var AkEvent ZapSFX;

var Controller oOriginalOwnerController;

simulated event PreBeginPlay()
{
	local class<EmitterPool> PoolClass;
	
    super.PreBeginPlay();

	oOriginalOwnerController = Instigator.Controller;

	PoolClass = class<EmitterPool>(DynamicLoadObject(EmitterPoolClassPath, class'Class'));
	if (PoolClass != None)
		vBeamEffects = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
}

simulated function PostBeginPlay()
{
	if( ParticleFX != none )
		StartParticleFX();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	    LightFadePerSecond = GlowLight.Brightness;

	// Set its light if it has one
	if( bEnableGlowLight )
	{
	    if( GlowLight != None )
	    {
	        AttachComponent(GlowLight);
	        `LightPool.RegisterPointLight(GlowLight, GlowLightPriority);
	    }
	}

	if( Destructible )
		bCanBeDamaged=true;
	else
		bCanBeDamaged=false;


    super.PreBeginPlay();
}

simulated function StartParticleFX()
{
	ParticlePSC = new(self) class'ParticleSystemComponent';
	ParticlePSC.SetTemplate( ParticleFX );
	AttachComponent(ParticlePSC);
	ParticlePSC.SetAbsolute(false, true, true);
}

// sets the pickups mesh and makes it the collision component so we can run rigid body physics on it
simulated function SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	Super.SetPickupMesh(NewPickupMesh);

	// Collide with other dosh! (just while they are both awake)
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Pickup, TRUE);
}

// simulated function Destroying()
// {
// 	Destroyed();
// }

event Destroyed()
{
    // super.Destroyed();

    // Inventory.Destroy();
	// Inventory = none;

	MaxDistanceToBeZapped = 0;
	MaxNumberOfZedsZapped = 0;
}

State FadeOut
{
	function Tick(float DeltaTime)
	{
		local float NewBrightness;

		// if( LifeSpan < default.LifeSpan - LightFadeStartTime )
		// {
			// Fade out gradually
			if ( GlowLight != None && GlowLight.bAttached )
			{
				if( GlowLight.Brightness > 0 )
				{
					NewBrightness = FMax( 0.01, GlowLight.Brightness - (LightFadePerSecond * DeltaTime) );
					GlowLight.SetLightProperties( NewBrightness );
				}
			}
		// }

		ParticlePSC.SetScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));

		Global.Tick(DeltaTime);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		local float NewBrightness;

		bFadeOut = true;
		LifeSpan = 1.0;
		// Destroyed();
		// Destroying();
		StopParticleFX();
		MaxDistanceToBeZapped = 0;
		MaxNumberOfZedsZapped = 0;

		if( Destructible )
		{
			// Destroying();
			TriggerExplosion();
			SetDrawScale(0);
			ParticlePSC.SetScale(0);
			MaxDistanceToBeZapped = 0;
			MaxNumberOfZedsZapped = 0;

			if ( GlowLight != None && GlowLight.bAttached )
	    	{
				if( GlowLight.Brightness > 0 )
				{
					NewBrightness = float(0);
					GlowLight.SetLightProperties( NewBrightness );
				}
	    	}
		}
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function StopParticleFX()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && ParticlePSC != none )
	{
        ParticlePSC.DeactivateSystem();
	   	DetachComponent(GlowLight);
	}
}

simulated function TriggerExplosion()
{
	local KFExplosionActorReplicated ExploActor;

	if( ExplosionTemplate != none )
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

simulated event Tick( float DeltaTime )
{
	Local int i;
	local vector BeamEndPoint;

	// super.Tick( DeltaTime );

	if(CurrentZapBeams.length > 0)
	{
		for(i=0 ; i<CurrentZapBeams.length ; i++)
		{
			CurrentZapBeams[i].oControlTime -= DeltaTime;
			if(CurrentZapBeams[i].oControlTime > 0 && CurrentZapBeams[i].oAttachedZed.IsAliveAndWell())
			{
				BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');
				if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Location;

				CurrentZapBeams[i].oBeam.SetBeamSourcePoint(0, CurrentZapBeams[i].oSourceActor.Location, 0);
				CurrentZapBeams[i].oBeam.SetBeamTargetPoint(0, BeamEndPoint, 0);
			}
			else
			{
				CurrentZapBeams[i].oBeam.DeactivateSystem();
				CurrentZapBeams.RemoveItem(CurrentZapBeams[i]);
				i--;
			}
		}
	}

	TimeToZap += DeltaTime;
	if(TimeToZap > ZapInterval)
	{
		if(ZapFunction(self))
			TimeToZap = 0;
	}

	// Radial(DeltaTime);
}

/*
simulated function Radial( float DeltaTime )
{
	foreach VisibleCollidingActors(class'KFPawn_Monster', Target, TargetRadius, Location)
	{
    	if( Target.IsAliveAndWell() )
			ParticleEffectPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( ParticleEffect, Target.Mesh, 'Head', true );
			ParticleEffectPSC.SetAbsolute(false, true, true);
	}
}
*/

// Notification that a direct impact has occurred
event ProcessDirectImpact()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(oOriginalOwnerController);
    if( KFPC != none )
        KFPC.AddShotsHit(1);
}

simulated function FinalEffectHandling()
{
	Local int i;

	if(CurrentZapBeams.length > 0)
	{
		for(i=0 ; i<CurrentZapBeams.length ; i++)
			CurrentZapBeams[i].oBeam.DeactivateSystem();
	}
}

simulated function bool ZapFunction(Actor _TouchActor)
{
	local vector BeamEndPoint;
	local KFPawn_Monster oMonsterPawn;
	local int iZapped;
	local ParticleSystemComponent BeamPSC;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
	{
		if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != _TouchActor)
		{
			if( VSizeSQ(oMonsterPawn.Location - _TouchActor.Location) < Square(MaxDistanceToBeZapped) )
			{
				if(FastTrace(_TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false)
					continue;

				if(WorldInfo.NetMode != NM_DedicatedServer)
				{
					BeamPSC = vBeamEffects.SpawnEmitter(BeamPSCTemplate, _TouchActor.Location, _TouchActor.Rotation);

					BeamEndPoint = oMonsterPawn.Mesh.GetBoneLocation('Spine1');
					if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = oMonsterPawn.Location;

					BeamPSC.SetBeamSourcePoint(0, _TouchActor.Location, 0);
					BeamPSC.SetBeamTargetPoint(0, BeamEndPoint, 0);
					
					BeamPSC.SetAbsolute(false, false, false);
					BeamPSC.bUpdateComponentInTick = true;
					BeamPSC.SetActive(true);

					StoreBeam(BeamPSC, oMonsterPawn);
					ZapSFXComponent.PlayEvent(ZapSFX, true);
				}

				if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_StandAlone ||  WorldInfo.NetMode == NM_ListenServer )
					ChainedZapDamageFunction(oMonsterPawn, _TouchActor);

				++iZapped;
			}
		}

		if(iZapped >= MaxNumberOfZedsZapped) break;
	}

	if(iZapped > 0) 
		return true;
	else
		return false;
}

simulated function StoreBeam(ParticleSystemComponent Beam, KFPawn_Monster Monster)
{
	local BeamZapInfo BeamInfo;
	BeamInfo.oBeam = Beam;
	BeamInfo.oAttachedZed = Monster;
	BeamInfo.oSourceActor = self;
	BeamInfo.oControlTime = ZapInterval;
	CurrentZapBeams.AddItem(BeamInfo);
}

function ChainedZapDamageFunction(Actor _TouchActor, Actor _OriginActor)
{
	//local float DistToHitActor;
	local vector Momentum;
	local TraceHitInfo HitInfo;
	local Pawn TouchPawn;
 
	if( _OriginActor != none )
		Momentum = _TouchActor.Location - _OriginActor.Location;

	//DistToHitActor = VSize(Momentum);
	//Momentum *= (MomentumScale / DistToHitActor);
	if( ZapDamage > 0 )
	{
		TouchPawn = Pawn(_TouchActor);
		// Let script know that we hit something
		if (TouchPawn != none)
			ProcessDirectImpact();
		
		_TouchActor.TakeDamage(ZapDamage, oOriginalOwnerController, _TouchActor.Location, Momentum, class'KFDT_EMP_HVStormCannon', HitInfo, self);
	}
}

// Capture damage so that human players can destroy the krystal
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	// Don't blow up other crystals
	if( DamageCauser.class == class'KFDroppedPickup_Trophy_IonCrystal' /*|| DamageType == ExplosionTemplate.MyDamageType || Physics != PHYS_None */)
		return;

	if( Health > 0 && inDamage > 0 )
	{
		Health -= inDamage;
		if( Health <= 0 )
			GotoState('FadeOut');
	}
}

DefaultProperties
{
	LifeSpan=10 //8

	ParticleFX=ParticleSystem'Fass_EMIT.FX_IonCrystal'

	// TargetRadius=300
    // ParticleEffect=ParticleSystem''
    
    Destructible=true
	Health=35 //40

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=40
		CollisionHeight=40
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.IonCrystal_PM'
		Translation=(X=0,Y=0,Z=0)
	End Object

	// Zapping
  	Begin Object Class=AkComponent name=ZapOneShotSFX
    	BoneName=dummy // need bone name so it doesn't interfere with default PlaySoundBase functionality
    	bStopWhenOwnerDestroyed=true
    End Object
    ZapSFXComponent=ZapOneShotSFX
    Components.Add(ZapOneShotSFX)

    ZapSFX=AkEvent'WW_DEV_TestTones.Play_Beep_WeaponAtten' //ww_wep_hrg_energy.Play_WEP_HRG_Energy_1P_Shoot
    BeamPSCTemplate = ParticleSystem'Fass_EMIT.FX_IonCrystal_Beam'
	EmitterPoolClassPath="Engine.EmitterPool"

	MaxNumberOfZedsZapped=1
	MaxDistanceToBeZapped=600 //800
	ZapInterval=0.8 //0.2
	TimeToZap=100
	ZapDamage=30

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=1500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=25 //100
		DamageRadius=700   //600
		DamageFalloffExponent=1  //2
		DamageDelay=0.f
		MyDamageType=class'KFDT_EMP_EMPGrenade'

		// Damage Effects
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.EMPGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	bEnableGlowLight=true
	Begin Object Class=PointLightComponent Name=PointLight0
        LightColor=(R=0,G=90,B=255,A=255)
        Brightness=3.5f
        Radius=85.f
        FalloffExponent=3.0f
        CastShadows=FALSE
        CastStaticShadows=false
        CastDynamicShadows=false
        bCastPerObjectShadows=false
        bEnabled=true
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object
    GlowLight=PointLight0
    GlowLightPriority=LPP_High
}