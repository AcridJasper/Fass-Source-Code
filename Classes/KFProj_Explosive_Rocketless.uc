class KFProj_Explosive_Rocketless extends KFProj_BallisticExplosive
	hidedropdown;

var KFPawn_Monster LockedTarget;
// How much 'stickyness' when seeking toward our target. Determines how accurate rocket is
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
			TargetImpactPos = LockedTarget.Mesh.GetBoneLocation('Spine1');
		
			// Seek towards target
			Speed = VSize( Velocity );
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
	LifeSpan=+10.0f

	MaxDistanceToLockOn=1000
    SeekStrength=4000.0f //8000.0f

	Begin Object Name=CollisionCylinder
		CollisionRadius=5
		CollisionHeight=5
	End Object

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Rocketless_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Rocketless_Projectile'

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
		Damage=70
		DamageRadius=350
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Seeker6'

		bIgnoreInstigator=true
		// MomentumTransferScale=0

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