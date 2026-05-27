class KFProj_Grenade_Satellite extends KFProj_Grenade
	hidedropdown;

var SoundCue AfterExplosionSND, LaserSND;

var(Projectile) ParticleSystem ProjIndicatorTemplate;
var ParticleSystemComponent	ProjIndicatorEffects;
var bool IndicatorActive;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// fuze starts at rest
	ClearTimer(nameof(ExplodeTimer));
}

simulated event GrenadeIsAtRest()
{
	local rotator RandRot;

	SetPhysics(PHYS_None);

	super.GrenadeIsAtRest();

	if( Role == ROLE_Authority )
		SetTimer(FuseTime, false, 'ExplodeTimer');

	GotoState('BeaconState');
	PlaySoundBase( LaserSND );

	RotationRate.Yaw = 0;
	RotationRate.Pitch = 0;
	RotationRate.Roll = 0;

	// Apply some random yaw
	SetRelativeRotation( RandRot );
	RandRot.Pitch = Rand( 0 ); //65535
}

state BeaconState
{
	simulated event Tick(float DeltaTime)
	{
		TryActivateIndicator();
	}
}

simulated function TryActivateIndicator()
{
	if(!IndicatorActive && Instigator != None)
	{
		IndicatorActive = true;

		if(WorldInfo.NetMode == NM_Standalone || Instigator.Role == Role_AutonomousProxy ||
		 (Instigator.Role == ROLE_Authority && WorldInfo.NetMode == NM_ListenServer && Instigator.IsLocallyControlled() ))
		{
			if( ProjIndicatorTemplate != None )
			{
			    ProjIndicatorEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjIndicatorTemplate);
			}

			if(ProjIndicatorEffects != None)
			{
				ProjIndicatorEffects.SetAbsolute(false, true, true);
				ProjIndicatorEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
				ProjIndicatorEffects.bUpdateComponentInTick = true;
				AttachComponent(ProjIndicatorEffects);
			}
		}
	}
}

simulated protected function StopSimulating()
{
	super.StopSimulating();

	PlaySoundBase( AfterExplosionSND );

	if (ProjIndicatorEffects!=None)
	{
        ProjIndicatorEffects.DeactivateSystem();
		// IndicatorActive = false;
	}
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
	Speed=3000
	MaxSpeed=3000
	TossZ=150
    GravityScale=1.5

	// ProjFlightTemplate=ParticleSystem'DROW_Grenades_EMIT.FX_Tesla_Grenade_Projectile'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'
	
	bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Survivalist'
	WeaponSelectTexture=Texture2D'DROW_Grenades_MAT.UI_WeaponSelect_Beacon'

	IndicatorActive=false
	ProjIndicatorTemplate=ParticleSystem'Fass_EMIT.FX_Satellite_Ion_Cannon'

    LandedTranslationOffset=(X=0)

    LaserSND=SoundCue'Fass_SND.lasershort_Cue'
    FuseTime=3.2
    AfterExplosionSND=SoundCue'Fass_SND.expaftersnd_Cue'

	Begin Object Class=AkComponent name=AmbientAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.25f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

	bAutoStartAmbientSound=true
	bAmbientSoundZedTimeOnly=false
	bImportantAmbientSound=true
	bStopAmbientSoundOnExplode=true

	AmbientSoundPlayEvent=AkEvent'WW_ENV_Airship.Play_ENV_Airship_Electric_Panel_Buzz'
  	AmbientSoundStopEvent=None

	ExplosionActorClass=class'KFExplosionActor'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=8.f
		Radius=10000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=250 //400
		DamageRadius=1000
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Satellite'

		MomentumTransferScale=10000
		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=0.0
		FracturePartVel=0.0
		ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Satellite_Explosion'
		ExplosionSound=SoundCue'Fass_SND.Satellite_Explosion_Cue'
		// ExplosionSound=AkEvent'WW_ENV_Outpost.Play_Outpost_OBJ_EndCinematic_EXP_Small'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=400
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}