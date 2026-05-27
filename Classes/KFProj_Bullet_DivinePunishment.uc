class KFProj_Bullet_DivinePunishment extends KFProj_BallisticExplosive
	hidedropdown;

var Controller OriginalOwnerController;

var float Radius;
var int RadiusDamage;

var transient ParticleSystemComponent RadiusEffectPSC;
var ParticleSystem RadiusEffect;

// Last hit normal from Touch() or HitWall()
// var vector LastHitNormal;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

	OriginalOwnerController = InstigatorController;
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	local KFPawn_Monster Monster;
	local int TotalDamage;
	local TraceHitInfo HitInfo;

	foreach CollidingActors(class'KFPawn_Monster', Monster, Radius)
	{
    	if( Monster.IsAliveAndWell() )
		{
			if( RadiusDamage > 0 )
			{
				// RadiusEffectPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( RadiusEffect, Monster.Mesh, 'Spine2', true );
				// RadiusEffectPSC.SetAbsolute(false, true, true);

				TotalDamage = RadiusDamage * UpgradeDamageMod;
				Monster.TakeDamage(TotalDamage, OriginalOwnerController, Monster.Mesh.GetBoneLocation('Spine2'), vect(0,0,0), class'KFDT_DivinePunishment_Radial', HitInfo, self); //Monster.Location
			}
		}
	}

    PenetrationPower = 0;

    // if( Role == ROLE_Authority && Physics == PHYS_Projectile )
    // {
    //     // FlameSpawnVel = 0.25f * CalculateResidualFlameVelocity( LastHitNormal, Normal( Velocity ), VSize( Velocity ) );
    //     SpawnResidualFlame( class'KFProj_Grenade_Satellite', Location + (LastHitNormal * 10.f), vect(0,0,-1) ); //FlameSpawnVel
    // }

	super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    PenetrationPower = 0;
    // LastHitNormal = HitNormal;
	super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function bool AllowNuke()
{
    return false;
}

/*
simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}
*/

defaultproperties
{
	Physics=PHYS_Projectile
	MaxSpeed=30000
	Speed=30000
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=20000
    ArmDistSquared=0

	// DamageRadius=0

	// Shrapnel
	// bSpawnShrapnel=true
	// bDebugShrapnel=false

	// NumSpawnedShrapnel=1
	// ShrapnelSpreadWidthEnvironment=0
	// ShrapnelSpreadHeightEnvironment=0
	// ShrapnelSpreadWidthZed=0
	// ShrapnelSpreadHeightZed=0
	// ShrapnelClass = class'KFProj_Orb_DivinePunishment_Shrapnel'
	// ShrapnelSpawnSoundEvent=none
	// ShrapnelSpawnVFX=none

    RadiusEffect=ParticleSystem'Fass_EMIT.FX_Punishment_Puff'
	Radius=800
	RadiusDamage=25

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_NullF'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_NullF'


    bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

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

	// explosion (electric explosion)
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=200 //300
		DamageRadius=800
		DamageFalloffExponent=0.5f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_RPG7'

		// MomentumTransferScale=1
		// bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_DivinePunishment_ARCH.DivinePunishment_Explosion'
		// ExplosionSound=AkEvent'WW_WEP_SA_RPG7.Play_WEP_SA_RPG7_Explosion'
		ExplosionSound=SoundCue'WEP_DivinePunishment_SND.explosion2b3_Cue'

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
}