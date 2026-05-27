class KFProj_HighExplosive_Calderon_Heat extends KFProj_BallisticExplosive
	config(Fass);

var() config float NapalmExplosionDamage, NapalmExplosionRadius;
/*
var bool bSpawnGroundFire;
var() config float HeatDamage, HeatDamageRadius, HeatEffectDuration, HeatDamageInterval, HeatExplosionOffsetZ;
var class<KFExplosionActorLingering> HeatExplosionActorClass;
var KFGameExplosion HeatExplosionTemplate;

var vector LastHitNormal;

replication
{
	if( bNetInitial )
		bSpawnGroundFire;
}
*/
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( ExplosionTemplate != none )
    {
        ExplosionTemplate.Damage = NapalmExplosionDamage * UpgradeDamageMod;
        ExplosionTemplate.DamageRadius = NapalmExplosionRadius;
    }
}
// simulated event PreBeginPlay()
// {
//     super.PreBeginPlay();

//     if( ExplosionTemplate != none )
//     {
//         ExplosionTemplate.Damage = NapalmExplosionDamage;
//         ExplosionTemplate.DamageRadius = NapalmExplosionRadius;
//     }
// }
/*
simulated function PostBeginPlay()
{
	local KFWeap_Calderon Cannon;

	if(Role == ROLE_Authority)
	{
		Cannon = KFWeap_Calderon(Owner);
		if( Cannon != none)
			bSpawnGroundFire = true;
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if( ClassIsChildOf(Other.class, class'KFPawn') )
		bSpawnGroundFire = false;

	super.ProcessTouch(Other, HitLocation, HitNormal);
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
    	if( LastHitNormal.Z < -0.95)
			bSpawnGroundFire = false;
		else if( LastHitNormal.Z < 0.05 )
			bSpawnGroundFire = false;

    	if( bSpawnGroundFire )
    	{
		    if( HeatExplosionTemplate != none )
		    {
		        // Explode using the given template
		        ExploActor = Spawn(HeatExplosionActorClass, self,, Location + (LastHitNormal * HeatExplosionOffsetZ), rotator(vect(0,1,0)),, true);
		        if( ExploActor != None )
		        {
		            ExploActor.Instigator = Instigator;
		            ExploActor.InstigatorController = Instigator.Controller;
					ExploActor.MaxTime = HeatEffectDuration;
					ExploActor.Interval = HeatDamageInterval;

		            HeatExplosionTemplate.bIgnoreInstigator = true;
		            HeatExplosionTemplate.Damage = HeatDamage;
		            HeatExplosionTemplate.DamageRadius = HeatDamageRadius;

		            ExploActor.Explode(HeatExplosionTemplate);
		        }
		    }
		}
    }

    Super.StopSimulating();
}
*/
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

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Heat'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Heat'

	// bCanDisintegrate=false
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	// Dynamic light while airborne
	Begin Object Class=PointLightComponent Name=FlightPointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=2.f
		Radius=400.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	Components.Add(FlightPointLight)

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
		// Damage=100 //120
		// DamageRadius=600
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_Incinerator'

        MomentumTransferScale=0

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'
		ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

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
/*
	HeatExplosionActorClass=class'KFExplosion_Heat_Calderon'

	// Lingering heat field
    Begin Object Class=KFGameExplosion Name=HeatField
        // Damage=17 //25
        // DamageRadius=550
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Fire_Ground_MolotovGrenade'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0  
        // ExplosionEffects=KFImpactEffectInfo'ARCH'
        // ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Heat_Groundfire'
        // ExplosionSound=AkEvent'WW_WEP_MEL_MedicBat.Play_WEP_MedicBat_Smoke_Explode'

        // Camera Shake
        CamShake=none
    End Object
    HeatExplosionTemplate=HeatField
*/
}