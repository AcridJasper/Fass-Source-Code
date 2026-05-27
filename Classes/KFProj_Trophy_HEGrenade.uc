class KFProj_Trophy_HEGrenade extends KFProj_Grenade
	hidedropdown;

var() float FuseTimeMin, FuseTimeMax;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	RandSpin(100000);

	// Turn fuze time into fuze time min lol
	FuseTime = FuseTimeMin;

	if( Role == ROLE_Authority )
	   SetTimer(RandRange(FuseTimeMin, FuseTimeMax), false, 'ExplodeTimer');

	AdjustCanDisintigrate();
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
	// FuseTime=1.2
    FuseTimeMin=0.7
    FuseTimeMax=1.2

	bWarnAIWhenFired=true

    LandedTranslationOffset=(X=2)

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_HEGrenade_Indicator'
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MK3_Grenade'
	AssociatedPerkClass=class'KFPerk_Commando'

	ExplosionActorClass=class'KFExplosionActor'

	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=300  //300
		DamageRadius=700  //800
		DamageFalloffExponent=2.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_HEGrenade'

		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0	
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HEGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_HE.Play_WEP_EXP_Grenade_HE_Explosion'

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