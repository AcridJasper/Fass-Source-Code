class KFProj_Trophy_Dynamite extends KFProj_Grenade
	hidedropdown;

/** Ambient sound to play */
var AkEvent FuseEvent;

/** Dynamic light */
var PointLightComponent FuseLight;

simulated function PostBeginPlay()
{
	PlaySoundBase( FuseEvent, true,, true );

	Super.PostBeginPlay();
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	super.TriggerExplosion( HitLocation, HitNormal, HitActor );

	FuseLight.SetEnabled( false );
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
	class'KFPerk_Demolitionist'.static.PrepareExplosive( Instigator, self );

	GetRadialDamageValues(ExplosionTemplate.Damage, ExplosionTemplate.DamageRadius, ExplosionTemplate.DamageFalloffExponent);

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;

    // super.PrepareExplosionTemplate();
}

simulated protected function SetExplosionActorClass()
{
   local KFPlayerReplicationInfo InstigatorPRI;

    if( WorldInfo.TimeDilation < 1.f && Instigator != none )
    {
       InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
        if( InstigatorPRI != none )
        {
            if( InstigatorPRI.bNukeActive && class'KFPerk_Demolitionist'.static.ProjectileShouldNuke( self ) )
            {
                ExplosionActorClass = class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass();
            }
        }
    }

    super.SetExplosionActorClass();
}

defaultproperties
{
	Speed=1500
	TossZ=400

	FuseTime=1.2

	bWarnAIWhenFired=true

	LandedTranslationOffset=(X=-8)

	DampenFactor=0.200000
   DampenFactorParallel=0.300000

	FuseEvent=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Fuse_LP'

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Dynamite_Indicator'
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	WeaponSelectTexture=Texture2D'wep_ui_dynamite_tex.UI_WeaponSelect_Dynamite'
	AssociatedPerkClass=class'KFPerk_Demolitionist'

	AltExploEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion_Concussive_Force'

	ExplosionActorClass=class'KFExplosionActor'

	// fuse light
	Begin Object Class=PointLightComponent Name=FusePointLight
	    LightColor=(R=255,G=200,B=63,A=255)
		Brightness=1.f
		Radius=300.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		Translation=(Z=6)

		// light anim
        AnimationType=1 // LightAnim_Flicker
        AnimationFrequency=2.f
        MinBrightness=0.5f
        MaxBrightness=1.5f
	End Object
	FuseLight=FusePointLight
	Components.Add(FusePointLight);

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=300  //400
		DamageRadius=400  //900
		DamageFalloffExponent=2  //3
		DamageDelay=0.f

		bIgnoreInstigator = true

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_DynamiteGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Explosion'

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

	GlassShatterType=FMGS_ShatterNone
}