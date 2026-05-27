class KFProj_Explosive_Incinerator_FireBall extends KFProj_BallisticExplosive
	hidedropdown;

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( Physics == PHYS_Falling && Velocity != vect(0,0,0) )
		SetRotation( rotator(Velocity) );
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
	Speed=1000
	MaxSpeed=1000
	TossZ=0
	GravityScale=1.0
    ArmDistSquared=0
	LifeSpan=+7.0f

	// Begin Object Name=CollisionCylinder
	// 	CollisionRadius=5
	// 	CollisionHeight=5
	// End Object

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Incinerator_FireBall'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Incinerator_FireBall'

	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=3.f
		Radius=800.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=50
		DamageRadius=200
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_Incinerator'

		MomentumTransferScale=10000
		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.MotionProjectile_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_Warthog.Play_WEP_HRG_Warthog_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}