class KFProj_Explosive_MotionProjectile extends KFProj_BallisticExplosive
	hidedropdown;

var KFPawn_Monster LockedTarget;
var float SeekStrength;

var int MaxDistanceToLockOn;

replication
{
	if( bNetInitial )
		LockedTarget;
}

simulated event Tick( float DeltaTime )
{
	local vector TargetImpactPos, DirToTarget;

	super.Tick(DeltaTime);

	foreach VisibleCollidingActors(class'KFPawn_Monster', LockedTarget, MaxDistanceToLockOn)
	{
		if( !bHasExploded && LockedTarget.IsAliveAndWell() && `TimeSince(CreationTime) > 0.08f )
		{
			TargetImpactPos = LockedTarget.Location;
		
			// Seek towards target
			// Speed = VSize( Velocity );
			DirToTarget = Normal( TargetImpactPos - Location );
			Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;
		}
	}

	// Aim rotation towards velocity every frame
	if( Physics == PHYS_Projectile && Velocity != vect(0,0,0) )
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
	Physics=PHYS_Projectile
	Speed=1000
	MaxSpeed=1000
	TossZ=0
	GravityScale=1.0
    ArmDistSquared=0
	LifeSpan=+7.0f

	MaxDistanceToLockOn=1000
    SeekStrength=4000.0f //8000.0f

	Begin Object Name=CollisionCylinder
		CollisionRadius=5
		CollisionHeight=5
	End Object

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_MotionProjectile'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_MotionProjectile'

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
		Damage=35 //30
		DamageRadius=200 //150 //120
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_HRG_Boomy'

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