class KFProj_Grenade_MartyrMulti extends KFProj_Grenade 
	hidedropdown;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// fuze starts at rest
	ClearTimer(nameof(ExplodeTimer));
}

simulated event GrenadeIsAtRest()
{
	super.GrenadeIsAtRest();

	if( Role == ROLE_Authority )
		SetTimer(FuseTime, false, 'ExplodeTimer');
}

defaultproperties
{
    LandedTranslationOffset=(X=2)
    FuseTime=0.15 //0.5

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_MartyrMulti_Grenade'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_MartyrMulti_Grenade'

	WeaponSelectTexture=Texture2D'WEP_UI_LN2_Grenade_TEX.UI_WeaponSelect_SharpshooterGrenade'
	AssociatedPerkClass=class'KFPerk_Sharpshooter'

	bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	ExplosionActorClass=class'KFExplosion_MartyrMulti'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
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

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=25
		DamageRadius=400 //300
		DamageFalloffExponent=1
		DamageDelay=0.f
		MyDamageType=class'KFDT_Freeze_FreezeGrenade'

		MomentumTransferScale=1

		// Damage Effects
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.MartyrMulti_Explosion'
		ExplosionSound=AkEvent'WW_WEP_SA_DragonsBreath.Play_Bullet_DragonsBreathImpact_Rubber'

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