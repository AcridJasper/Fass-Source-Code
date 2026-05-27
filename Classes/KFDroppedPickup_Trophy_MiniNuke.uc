class KFDroppedPickup_Trophy_MiniNuke extends KFDroppedPickup;

var float Health;

// var AkEvent BeepSound;
var SoundCue BeepSound;

var ParticleSystem ParticleFX;
var	transient ParticleSystemComponent ParticlePSC;

var KFGameExplosion ExplosionTemplate;

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	SetTimer(27.0, false, nameof(BeforeDetonation));
}

simulated function BeforeDetonation()
{
	if( ParticleFX != none )
		StartParticleFX();

	if( BeepSound != None )
		// PlaySoundBase(BeepSound, true,, true); // AKEvent
		PlaySound(BeepSound, true,, true); // SoundCue
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

event Destroyed()
{
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
}

State FadeOut
{
	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		Destroyed();
		StopParticleFX();
		TriggerExplosion();
		ParticlePSC.SetScale(0);
		SetDrawScale(0);
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function StopParticleFX()
{
	if( ParticlePSC != none )
        ParticlePSC.DeactivateSystem();
}

simulated function TriggerExplosion()
{
	local KFExplosion_Nuke ExploActor; //KFExplosionActorReplicated

	if( ExplosionTemplate != none )
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosion_Nuke', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

// Capture damage so that human players can destroy the krystal
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	if( Health > 0 && inDamage > 0 )
	{
		Health -= inDamage;
		if( Health <= 0 )
		{
			GotoState('FadeOut');

			if( IsTimerActive(nameof(BeforeDetonation)) )
				ClearTimer(nameof(BeforeDetonation));
		}
	}
}

DefaultProperties
{
	LifeSpan=30

    // BeepSound=AkEvent'WW_ZED_Patriarch.Play_Mortar_Beeps'
	BeepSound=SoundCue'Fass_ARCH.fo4minebeep_Cue'
	ParticleFX=ParticleSystem'Fass_EMIT.FX_MiniNuke_Indicator'

	Health=100

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

	Begin Object Name=CollisionCylinder
		// CollisionRadius=25.f
		// CollisionHeight=25.f
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.ExplosiveBarrel_PM'
	End Object

	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=45 //15
		DamageRadius=450
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_DemoNuke'

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.Nuke_Explosion'
		ExplosionSound=AkEvent'WW_GLO_Runtime.Play_WEP_Nuke_Explo'
		MomentumTransferScale=1.f

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