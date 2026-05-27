class KFProj_Rocket_InstaGibCrowbar extends KFProj_BallisticExplosive
	hidedropdown;

simulated event Tick( float DeltaTime )
{
    super.Tick( DeltaTime );
    
    if( Physics == PHYS_Projectile && Velocity != vect(0,0,0) )
        SetRotation( rotator(Velocity) );
}

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=650 //5000
	MaxSpeed=650
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=50000.0f
	ArmDistSquared=0
    
	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Projectile'

	bCanDisintegrate=false
    // ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Projectile'
  	AmbientSoundStopEvent=AkEvent'WW_WEP_Seeker_6.Stop_WEP_Seeker_6_Projectile'

	// Grenade explosion light
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
		Damage=160	// 125
		DamageRadius=350    //1000 //250 // 250
		DamageFalloffExponent=2  //3
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_Seeker6'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_SeekerSix_ARCH.FX_SeekerSix_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=500
		CamShakeFalloff=3.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}