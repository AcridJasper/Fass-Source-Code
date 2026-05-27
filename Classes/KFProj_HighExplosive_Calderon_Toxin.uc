class KFProj_HighExplosive_Calderon_Toxin extends KFProj_BallisticExplosive
	config(Fass);

var() config float GasDamage, GasDamageRadius, GasCloudEffectDuration, GasCloudDamageInterval, GasExplosionOffsetZ;
var class<KFExplosionActorLingering> GasExplosionActorClass;
var KFGameExplosion GasExplosionTemplate;

var() config float ExplosionDamage, ExplosionRadius;

var vector LastHitNormal;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    if( ExplosionTemplate != none )
    {
        ExplosionTemplate.Damage = ExplosionDamage * UpgradeDamageMod;
        ExplosionTemplate.DamageRadius = ExplosionRadius;
    }
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    LastHitNormal = HitNormal;
    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated protected function StopSimulating()
{
	local KFExplosionActorLingering ExploActor;

    if( Role == ROLE_Authority )
    {
	    if( GasExplosionTemplate != none )
	    {
	        // Explode using the given template
	        ExploActor = Spawn(GasExplosionActorClass, self,, Location + (LastHitNormal * GasExplosionOffsetZ), rotator(vect(0,0,1)),, true);
	        if( ExploActor != None )
	        {
	            ExploActor.Instigator = Instigator;
	            ExploActor.InstigatorController = Instigator.Controller;
				ExploActor.MaxTime = GasCloudEffectDuration;
				ExploActor.Interval = GasCloudDamageInterval;

	            GasExplosionTemplate.bIgnoreInstigator = true;
	            GasExplosionTemplate.Damage = GasDamage;
	            GasExplosionTemplate.DamageRadius = GasDamageRadius;

	            ExploActor.Explode(GasExplosionTemplate);
	        }
	    }
    }

    Super.StopSimulating();
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

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Toxin'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Toxin'

	// bCanDisintegrate=false
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    // GasDamage=17
    // GasDamageRadius=550
	// GasExplosionOffsetZ=25
	// GasCloudEffectDuration=10.0f
	// GasCloudDamageInterval=0.5f
	GasExplosionActorClass=class'KFExplosion_Toxin_Calderon'

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

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		// Damage=25
		// DamageRadius=350
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Seeker6'

        MomentumTransferScale=0
		bIgnoreInstigator=true

		// Damage Effects
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

    // Lingering gas cloud
    Begin Object Class=KFGameExplosion Name=GasExplosion
        // Damage=17 //25
        // DamageRadius=550
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_GasImpact'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0  
        // ExplosionEffects=KFImpactEffectInfo'ARCH'
        ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_GasDrum_Cloud'
        ExplosionSound=AkEvent'WW_WEP_MEL_MedicBat.Play_WEP_MedicBat_Smoke_Explode'

        // Camera Shake
        CamShake=none
    End Object
    GasExplosionTemplate=GasExplosion
}