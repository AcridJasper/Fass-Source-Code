class KFDroppedPickup_Trophy_Fumo extends KFDroppedPickup;

var KFGameExplosion ExplosionTemplate;

// Ambient/loop SoundCue component to cut off
var AudioComponent AmbientCue;
var SoundCue AmbientSoundCue;
var SoundCue AmbientSoundCueNo;

simulated function StartAmbientSoundCue()
{
    if ( Role == ROLE_Authority )
    {
        AmbientCue = new (self) class'Engine.AudioComponent';
        AttachComponent(AmbientCue);
        AmbientCue.SoundCue = AmbientSoundCue;
        AmbientCue.Play();
    }
}

simulated function StopAmbientSound()
{
    AmbientCue.Stop();
}

simulated function PostBeginPlay()
{
    if( Role == ROLE_Authority )
    {
	    SetTimer(3, true, 'Speen');
	    StartAmbientSoundCue();
    }

    super.PreBeginPlay();
}

State FadeOut
{
	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		LifeSpan = 1.0;
		TriggerExplosion();
		SetDrawScale(0);

		if ( Role == ROLE_Authority )
	    {
	        // Detach sound cue ?
	        AmbientCue.Stop();
	        DetachComponent(AmbientCue);
	        AmbientCue.SoundCue = AmbientSoundCueNo;
	        StopAmbientSound();

	        AmbientCue.Stop();
	    }
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
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
			ExploActor.bIgnoreInstigator = true;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

simulated function Speen()
{
	RotationRate.Yaw=150000;
	SetPhysics(PHYS_Rotating);
}

event Destroyed()
{
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
}

DefaultProperties
{
	LifeSpan=15

	AmbientSoundCue=SoundCue'ZED_Fumo_ARCH.fumo_ambient_Cue'

	// Explosion light
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

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=200  //225
		DamageRadius=900  //800
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_FragGrenade'
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

		// Shards
		ShardClass=class'KFProj_GrenadeShard'
		NumShards=10
	End Object
	ExplosionTemplate=ExploTemplate0
}