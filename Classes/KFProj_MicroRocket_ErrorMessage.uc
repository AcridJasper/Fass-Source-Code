class KFProj_MicroRocket_ErrorMessage extends KFProj_BallisticExplosive
	hidedropdown;

// Last hit normal from Touch() or HitWall()
// var vector LastHitNormal;

// Our intended target actor
var private KFPawn LockedTarget;
// How much 'stickyness' when seeking toward our target. Determines how accurate rocket is
var const float SeekStrength;

replication
{
	if( bNetInitial )
		LockedTarget;
}

function SetLockedTarget( KFPawn NewTarget )
{
	LockedTarget = NewTarget;
}

simulated event Tick( float DeltaTime )
{
	local vector TargetImpactPos, DirToTarget;

	super.Tick( DeltaTime );

	// Skip the first frame, then start seeking
	if( !bHasExploded
		&& LockedTarget != none
		&& Physics == PHYS_Projectile
		&& Velocity != vect(0,0,0)
		&& LockedTarget.IsAliveAndWell()
		&& `TimeSince(CreationTime) > 0.03f ) //0.6
	{
		// Grab our desired relative impact location from the weapon class
		TargetImpactPos = class'KFWeap_ErrorMessage'.static.GetLockedTargetLoc( LockedTarget );

		// Seek towards target
		Speed = VSize( Velocity );
		DirToTarget = Normal( TargetImpactPos - Location );
		Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;
	}

	// Aim rotation towards velocity every frame
	if( Physics == PHYS_Projectile && Velocity != vect(0,0,0) )
		SetRotation( rotator(Velocity) );
}

/*
simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	// if( WorldInfo.NetMode != NM_DedicatedServer )
    // {
    	if( Role == ROLE_Authority && Physics == PHYS_Projectile )
		 	SpawnResidualFlame( class'KFProj_Grenade_Satellite', Location + (LastHitNormal * 10.f), vect(0,0,-1) );
    // }
		 
    LastHitNormal = HitNormal;
	super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	LastHitNormal = HitNormal;
	Super.ProcessTouch(Other, HitLocation, HitNormal);
}
*/

simulated function bool AllowNuke()
{
    return false;
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=4000
	MaxSpeed=4000
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=50000.0f
	ArmDistSquared=0
    
    SeekStrength=200000.0f //228000.0f

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_MicroRocket_Fass'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_MicroRocket_Fass'

	// bCanDisintegrate=false
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

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
		Damage=180 //200
		DamageRadius=600 //350
		DamageFalloffExponent=1.5  //2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Seeker6'

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
}