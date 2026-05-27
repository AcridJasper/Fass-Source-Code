class KFProj_HighExplosive_Calderon extends KFProj_BallisticExplosive
	config(Fass);
	// hidedropdown;

var() config float ExplosionDamage, ExplosionRadius;

var() config float NukeExplosionChance;
var KFGameExplosion NukeExplosionTemplate;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    if( ExplosionTemplate != none )
    {
        ExplosionTemplate.Damage = ExplosionDamage * UpgradeDamageMod;
        ExplosionTemplate.DamageRadius = ExplosionRadius;
    }
}

simulated protected function StopSimulating()
{
    if( Role == ROLE_Authority )
    {
        if( FRand() <= NukeExplosionChance )
			TriggerNukeExplosion();
    }

	Super.StopSimulating();
}

// simulated protected function StopFlightEffects()
// {
// 	Super.StopFlightEffects();

// 	if( Role == ROLE_Authority )
//     {
//         if( FRand() <= NukeExplosionChance )
//             TriggerNukeExplosion();
//     }
// }

function TriggerNukeExplosion()
{
    local KFExplosion_Nuke ExploActor;

    if( NukeExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosion_Nuke', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            NukeExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(NukeExplosionTemplate);
        }
    }
}

simulated protected function PrepareExplosionTemplate()
{
    super.PrepareExplosionTemplate();
    NukeExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150
	GravityScale=0.5
    MomentumTransfer=50000
    ArmDistSquared=150000 // 4.0 meters
    LifeSpan=25.0f

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile'

	ProjDudTemplate=ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_Dud'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	// AltExploEffects=KFImpactEffectInfo'WEP_M79_ARCH.M79Grenade_Explosion_Concussive_Force'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Projectile_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_M79.Stop_WEP_SA_M79_Projectile_Loop'

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
		// Damage=225
		// DamageRadius=850
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_M79'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_M79_ARCH.M79Grenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

    // Nuke explosion
    Begin Object Class=KFGameExplosion Name=NukeExplosion
        Damage=65 //45
        DamageRadius=450
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_DemoNuke'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Nuke_Impact_Explosion'
        ExplosionSound=AkEvent'WW_GLO_Runtime.Play_WEP_Nuke_Explo'

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    NukeExplosionTemplate=NukeExplosion
}