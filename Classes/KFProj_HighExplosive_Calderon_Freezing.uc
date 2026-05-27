class KFProj_HighExplosive_Calderon_Freezing extends KFProj_BallisticExplosive
	config(Fass);

var() config float FreezeExplosionDamage, FreezeExplosionRadius;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    if( ExplosionTemplate != none )
    {
        ExplosionTemplate.Damage = FreezeExplosionDamage * UpgradeDamageMod;
        ExplosionTemplate.DamageRadius = FreezeExplosionRadius;
    }
}

/*simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}*/

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150
	GravityScale=1.0
    ArmDistSquared=0
	LifeSpan=+8.0f

	bWarnAIWhenFired=true

	// Begin Object Name=CollisionCylinder
	// 	CollisionRadius=5
	// 	CollisionHeight=5
	// End Object

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Freezing'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Freezing'

	// bCanDisintegrate=false
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=1500.f //1500
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		// Damage=35
		// DamageRadius=900
		DamageFalloffExponent=1  //2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Freeze_FreezeGrenade'

        MomentumTransferScale=1

		// Damage Effects
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Calderon_ARCH.Calderon_Freeze_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Freeze_Grenade.Play_Freeze_Grenade_Explo'

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
}