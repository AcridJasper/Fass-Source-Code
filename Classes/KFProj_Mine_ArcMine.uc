class KFProj_Mine_ArcMine extends KFProj_Grenade
	hidedropdown;

var bool StartZapping;

// Zapping
var int ZapDamage, MaxNumberOfZedsZapped, MaxDistanceToBeZapped;
var float ZapInterval;
var float TimeToZap;

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
    if( PoolClass != None )
        vBeamEffects = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

    StartZapping = false;

	// fuze starts when homan touches the MineTriggerRadius
	ClearTimer(nameof(FuseTime));
}

simulated event Tick( float DeltaTime )
{
    Local int i;
    local vector BeamEndPoint;

    // super.Tick( DeltaTime );

    if( CurrentZapBeams.length > 0 )
    {
        for( i=0 ; i<CurrentZapBeams.length ; i++ )
        {
            CurrentZapBeams[i].oControlTime -= DeltaTime;
            if( CurrentZapBeams[i].oControlTime > 0 && CurrentZapBeams[i].oAttachedZed.IsAliveAndWell() )
            {
                BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');
                if( BeamEndPoint == vect(0,0,0) )
                    BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Location;

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

    if( StartZapping )
    {
    	TimeToZap += DeltaTime;
	    if(TimeToZap > ZapInterval)
	    {
	        if( ZapFunction(self) )
	            TimeToZap = 0;
	    }	
    }
}

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

    if( CurrentZapBeams.length > 0 )
    {
        for( i=0 ; i<CurrentZapBeams.length ; i++ )
			CurrentZapBeams[i].oBeam.DeactivateSystem();
    }
}

simulated function bool ZapFunction(Actor TouchActor)
{
    local vector BeamEndPoint;
    local KFPawn_Monster oMonsterPawn;
    local int iZapped;
    local ParticleSystemComponent BeamPSC;

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
    {
        if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != TouchActor)
        {
            if( VSizeSQ(oMonsterPawn.Location - TouchActor.Location) < Square(MaxDistanceToBeZapped) )
            {
                if( FastTrace(TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false )
                    continue;

                if( WorldInfo.NetMode != NM_DedicatedServer )
                {
                    BeamPSC = vBeamEffects.SpawnEmitter(BeamPSCTemplate, TouchActor.Location, TouchActor.Rotation);

                    BeamEndPoint = oMonsterPawn.Mesh.GetBoneLocation('Spine1');
                    if( BeamEndPoint == vect(0,0,0) )
                        BeamEndPoint = oMonsterPawn.Location;

                    BeamPSC.SetBeamSourcePoint(0, TouchActor.Location, 0);
                    BeamPSC.SetBeamTargetPoint(0, BeamEndPoint, 0);
                    
                    BeamPSC.SetAbsolute(false, false, false);
                    BeamPSC.bUpdateComponentInTick = true;
                    BeamPSC.SetActive(true);

                    StoreBeam(BeamPSC, oMonsterPawn);
                    ZapSFXComponent.PlayEvent(ZapSFX, true);
                }

                if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_StandAlone ||  WorldInfo.NetMode == NM_ListenServer )
                    ChainedZapDamageFunction(oMonsterPawn, TouchActor);

                ++iZapped;
            }
        }

        if( iZapped >= MaxNumberOfZedsZapped )
            break;
    }

    if( iZapped > 0 ) 
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

function ChainedZapDamageFunction(Actor TouchActor, Actor OriginActor)
{
    //local float DistToHitActor;
    local vector Momentum;
    local TraceHitInfo HitInfo;
    local Pawn TouchPawn;
 
    if( OriginActor != none )
        Momentum = TouchActor.Location - OriginActor.Location;

    //DistToHitActor = VSize(Momentum);
    //Momentum *= (MomentumScale / DistToHitActor);
    if( ZapDamage > 0 )
    {
        TouchPawn = Pawn(TouchActor);
        // Let script know that we hit something
        if( TouchPawn != none )
            ProcessDirectImpact();
        
        TouchActor.TakeDamage(ZapDamage, oOriginalOwnerController, TouchActor.Location, Momentum, class'KFDT_EMP', HitInfo, self);
    }
}

function ExplodeTimer()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    // Set these so that it doesn't zap when projectile explodes on uneven time
    MaxDistanceToBeZapped = 0;
    MaxNumberOfZedsZapped = 0;

    GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);
    TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function Destroyed()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    // Set these so that it doesn't zap when projectile explodes on uneven time
    MaxDistanceToBeZapped = 0;
    MaxNumberOfZedsZapped = 0;

    // Final Failsafe check for explosion effect
    if( !bHasExploded && !bHasDisintegrated )
    {
        GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);
        TriggerExplosion(HitLocation, HitNormal, HitActor);
    }

    super.Destroyed();
}

simulated event GrenadeIsAtRest()
{
	local vector HitLocation, HitNormal;
	local rotator StuckRotation;

	super.GrenadeIsAtRest();

    StartZapping = true;

    // Modify the collision so it can be detonated by the player
    CylinderComponent.SetTraceBlocking( true, true );
	CylinderComponent.SetActorCollision( true, false );
	bCollideComplex = false;
	bBounce = false;

	// Optimize for network
	NetUpdateFrequency = 0.25f;
	bOnlyDirtyReplication = true;
	bForceNetUpdate = true;

	// Set rotation
	Trace( HitLocation, HitNormal, Location - vect(0,0,50), Location + vect(0,0,5), false,,, TRACEFLAG_Bullet );
	if( !IsZero(HitLocation) )
		StuckRotation = rotator( HitNormal );

	SetRotation( StuckRotation );
}

simulated function bool Bounce( vector HitNormal, Actor BouncedOff )
{
	local vector VNorm;

	// Avoid crazy bouncing
	if( CheckRepeatingTouch(BouncedOff) )
		bCanDisintegrate=true;

	if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        // do the impact effects
    	`ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, GrenadeBounceEffectInfo, true );
    }

    // Reflect off BouncedOff w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
    Speed = VSize(Velocity);

	// also done from ProcessDestructibleTouchOnBounce. update LastBounced to solve problem with bouncing rapidly between world/non-world geometry
	LastBounced.Actor = BouncedOff;
	LastBounced.Time = WorldInfo.TimeSeconds;

	return true;
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed=800 //1000
	MaxSpeed=800
    TossZ=150
    GravityScale=1.0

    FuseTime=10
	LifeSpan=0
	PostExplosionLifetime=1

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_ArcTrap'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'

	bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	// Mine functionality
	bBounce=true
	bNetTemporary=false

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

    // DampenFactor=0.125f
    // DampenFactorParallel=0.175f
	// LandedFXOffset=(X=0,Y=0,Z=-11)
    LandedTranslationOffset=(X=-7)

/*
	Begin Object Name=CollisionCylinder
		CollisionRadius=100.f
		CollisionHeight=10.f
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'ARCH'
	End Object
	// Since we're still using an extent cylinder, we need a line at 0
	// ExtraLineCollisionOffsets.Add(())
*/

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

    StartZapping=false
	MaxNumberOfZedsZapped=2
	MaxDistanceToBeZapped=600 //800
	ZapInterval=0.2 //0.8
	TimeToZap=100
	ZapDamage=12

	ExplosionActorClass=class'KFExplosionActor'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=1000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=125
		DamageRadius=600 //900
		DamageFalloffExponent=1.f //0.5
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_FragGrenade'

		MomentumTransferScale=10000
		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.FragGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_EXP_Grenade_Frag_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}