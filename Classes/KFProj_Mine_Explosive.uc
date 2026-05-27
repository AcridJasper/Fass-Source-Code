class KFProj_Mine_Explosive extends KFProj_Grenade
	hidedropdown;

// Cached team number, because players can switch teams
// var byte TeamNum;

// How much damage the projectile can take before exploding
var int Health;

// Trigger fuse time
var float TriggerFuseTime;

// Radius checking
var KFPawn_Human Victim;
var float MineTriggerRadius;

// Mine visuals
var bool GrenadeFullyLanded;
var AkEvent TriggeredEvent;

// This is the effect indicator that is played for the current user
var(Projectile) ParticleSystem ProjIndicatorTemplate;
var ParticleSystemComponent	ProjIndicatorEffects;
var bool IndicatorActive;

simulated function PostBeginPlay()
{
	// Cache team num
	// TeamNum = GetTeamNum();

	super.PostBeginPlay();

	// fuze starts when homan touches the MineTriggerRadius
	ClearTimer(nameof(FuseTime));
}

simulated event GrenadeIsAtRest()
{
	local vector HitLocation, HitNormal, StuckNormal;
	local rotator StuckRotation;

	super.GrenadeIsAtRest();

	GrenadeFullyLanded=true;

    // Modify the collision so it can be detonated by the player
    CylinderComponent.SetTraceBlocking( true, true );
	SetCollisionSize(50,15);
	CylinderComponent.SetActorCollision( true, false );
	bCollideComplex = false;
	bBounce = false;

	// Optimize for network
	NetUpdateFrequency = 0.25f;
	bOnlyDirtyReplication = true;
	bForceNetUpdate = true;

	// Set rotation
	Trace( HitLocation, HitNormal, Location - vect(0,0,50), Location + vect(0,0,5), false,,, TRACEFLAG_Bullet );
	if( !IsZero(HitLocation) )
		StuckRotation = rotator( HitNormal );
	else
		StuckRotation = rotator( StuckNormal );

	SetRotation( StuckRotation );
}

// Arms the bomb within the radius
simulated event Tick( float DeltaTime )
{
	if(GrenadeFullyLanded)
	{
		foreach VisibleCollidingActors(class'KFPawn_Human', Victim, MineTriggerRadius, Location)
		{
			// Don't retrigger this when walking into MineTriggerRadius again
			GrenadeFullyLanded=false;

			if (Role == ROLE_Authority)
			{
				ApplyWarningFX();
				ClearTimer(nameof(FuseTime)); // clear og timer
				SetTimer(TriggerFuseTime, false, 'ExplodeTimer'); // and set up trigger timer
				PlaySoundBase( TriggeredEvent );
				ProjIndicatorEffects.SetFloatParameter( 'Warning' , 0.75f );
			}
		}
	}
}

function ApplyWarningFX()
{
    if(!IndicatorActive && Instigator != None)
	{
		IndicatorActive = true;

		if(WorldInfo.NetMode == NM_Standalone || Instigator.Role == Role_AutonomousProxy ||
		 (Instigator.Role == ROLE_Authority && WorldInfo.NetMode == NM_ListenServer && Instigator.IsLocallyControlled() ))
		{
			if( ProjIndicatorTemplate != None )
			    ProjIndicatorEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjIndicatorTemplate);

			if(ProjIndicatorEffects != None)
			{
				ProjIndicatorEffects.SetAbsolute(false, true, true);
				ProjIndicatorEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
				ProjIndicatorEffects.bUpdateComponentInTick = true;
				AttachComponent(ProjIndicatorEffects);
			}
		}
	}
}

simulated protected function StopSimulating()
{
	super.StopSimulating();

	if (ProjIndicatorEffects!=None)
	{
        ProjIndicatorEffects.DeactivateSystem();
		// IndicatorActive = false;
	}
}

/*
// Capture damage so that human players can destroy the mine
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	// Don't blow up when mines blow each other up, no matter what team
	// if( DamageCauser.class == class || DamageType == ExplosionTemplate.MyDamageType || Physics != PHYS_None )
	// 	return;

	// only specific projectile can hit this
	// if( DamageCauser.class == class'KFProjectile')

	// if( Health > 0 && inDamage > 0 && TeamNum == 0 )
	if( Health > 0 && inDamage > 0 && InstigatedBy != none && InstigatedBy.GetTeamNum() != TeamNum )
	{
		Health -= inDamage;
		if( Health <= 0 )
			TriggerExplosion( Location, vect(0,0,1), none );
	}
}
*/
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	if( Health > 0 && inDamage > 0 )
	{
		Health -= inDamage;
		if( Health <= 0 )
			TriggerExplosion( Location, vect(0,0,1), none );
	}
}

simulated function bool Bounce( vector HitNormal, Actor BouncedOff )
{
	local vector VNorm;

	// Avoid crazy bouncing
	if( CheckRepeatingTouch(BouncedOff) )
		bCanDisintegrate=true;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        // do the impact effects
    	`ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, GrenadeBounceEffectInfo, true );
    }

    // Reflect off BouncedOff w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
    Speed = VSize(Velocity);

	// also done from ProcessDestructibleTouchOnBounce. update LastBounced to solve problem with bouncing rapidly between world/non-world geometry
	LastBounced.Actor = BouncedOff;
	LastBounced.Time = WorldInfo.TimeSeconds;

	return true;
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed=800 //1000
	MaxSpeed=800
    TossZ=150
    GravityScale=1.0

    TeamNum=128 // 0 player team / 128 neutral / 255 zed team

    FuseTime=30 //80
    TriggerFuseTime=1.0
	LifeSpan=0
	PostExplosionLifetime=1

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Minetest'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'

	bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    // When the mine wants to explode
	MineTriggerRadius=300 //500
	IndicatorActive=false
	ProjIndicatorTemplate=ParticleSystem'Fass_EMIT.FX_Mine_Explosive_Indicator'
	TriggeredEvent=AkEvent'WW_ZED_Patriarch.Play_Mortar_Beeps'

	GrenadeFullyLanded=false

	// Mine functionality
	// bUpdateSimulatedPosition=true
	// bUseClientSideHitDetection=true

	bBounce=true
	bNetTemporary=false

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

    // DampenFactor=0.125f
    // DampenFactorParallel=0.175f
	// LandedFXOffset=(X=0,Y=0,Z=-11)
    LandedTranslationOffset=(X=-7)

	Health=50 //25 500

	Begin Object Name=CollisionCylinder
		// CollisionRadius=7.f
		// CollisionHeight=2.f
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.Mine_Explosive_PM'
	End Object
	// Since we're still using an extent cylinder, we need a line at 0
	// ExtraLineCollisionOffsets.Add(())

	ExplosionActorClass=class'KFExplosionActor'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=1000.f
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
		Damage=14 //20
		DamageRadius=500 //900
		DamageFalloffExponent=1.f //0.5
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_FragGrenade'

		MomentumTransferScale=10000

		// Shards
		// ShardClass=class'KFProj_GrenadeShard'
		// NumShards=4 //10

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.FragGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_EXP_Grenade_Frag_Explosion'

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