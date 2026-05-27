class KFProj_HighExplosive_Incinerator extends KFProj_BallisticExplosive
	config(Fass);

// var bool ImpactGroundFire;
// var int ResidualFlareAmount;
var bool bSplashFire;
var ParticleSystem ProjFlightSplashFX;
var	transient ParticleSystemComponent SplashPSC;
var KFImpactEffectInfo NormalExplosionTemplate, SplashExplosionTemplate;
var ParticleSystem ProjFlightTemplateNormal;

// Fire Shrapnel
var bool ImpactExplosionUpgrade;
var() config float FireBallChance, FireBallSpawnOffset, FireBallSpawnSpeed;
var() config int FireBallAmount, FireBallHalfConeAngle;

// Napalm Canister
var bool CanisterUpgrade;
var() config int NapalmCanisterAmount;
var() config float NapalmCansiterChance;

// var float HitDamage;
var vector LastHitNormal;

// var Actor Impacte;
// var bool bImpactExplosion;
// var float SolarIgnitionExplosionFuseTime, SolarIgnitionChance;
// var KFGameExplosion SolarIgnitionExplosionTemplate;
// var ParticleSystem SolarIgnitionParticleTemplate;
// var transient ParticleSystemComponent SolarIgnitionParticlePSC;
// var AkEvent SolarIgnitionAkEvent;

// var() config float MotionProjectileAmount, MotionProjectileHalfCone, MotionProjectileSpeed, MotionProjectileOffSet;
// var vector LastHitNormal;

// var float HitDamage;

// replication
// {
// 	if( bNetDirty && Role == Role_Authority)
// 		bImpactExplosion;
// }

simulated function PostBeginPlay()
{
	local KFPlayerReplicationInfo InstigatorPRI;

	if( Instigator != none )
	{
		InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
		if( InstigatorPRI != none )
			bSplashFire = InstigatorPRI.bSplashActive;
	}
	else
		bSplashFire = false;

	if( bSplashFire )
	{
		ProjFlightTemplate = ProjFlightSplashFX;
		ProjFlightTemplateZedTime = ProjFlightSplashFX;
	}
	else
		ProjFlightSplashFX = ProjFlightTemplateNormal;

	super.PostBeginPlay();
}

/*simulated function SpawnFlightEffects()
{
	super.SpawnFlightEffects();

	if(ProjEffects != None)
	{
		if( bSplashFire )
		{
			ProjFlightTemplate = ProjFlightSplashFX;
			ProjFlightTemplateZedTime = ProjFlightSplashFX;
		}
		else
			ProjFlightSplashFX = ProjFlightTemplateNormal;
	}
}*/

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( Physics == PHYS_Falling && Velocity != vect(0,0,0) )
		SetRotation( rotator(Velocity) );
}

/*simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    LastHitNormal = HitNormal;
    HitDamage = ExplosionTemplate.Damage;
    Super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    LastHitNormal = HitNormal;
    HitDamage = ExplosionTemplate.Damage;
    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}*/

/*simulated protected function StopSimulating()
{
	// local int i;
	// local KFPawn_Human KFPH;
	// local KFPlayerController KFPC;

    if( Role == ROLE_Authority )
    {
		if( bImpactExplosion )
		{
			if( FRand() > SolarIgnitionChance )
			{
				PlaySoundBase( SolarIgnitionAkEvent );
				SolarIgnitionParticlePSC = WorldInfo.MyEmitterPool.SpawnEmitter(SolarIgnitionParticleTemplate, Location, rotator(vect(0,1,0)), self,,, true);
				SetTimer(SolarIgnitionExplosionFuseTime, false, 'TriggerSolarIgnitionExplosion');

    			// for(i = 0; i < MotionProjectileAmount; i++)
				// 	SpawnMotionProjectile();
			}
		}

		// KFPH = KFPawn_Human(Instigator);
		// KFPC = KFPlayerController(InstigatorController);
	    // if( KFPawn_Monster(ImpactedActor) != none && KFPawn_Monster(ImpactedActor).IsAliveAndWell() && (KFPawn_Monster(ImpactedActor).Health - HitDamage) <= 0 )
	    // {
	    // 	if( KFPH != none && KFPC != None )
	    //     	KFPH.HealDamage( 10, KFPC, class'KFDT_Healing');
	    // }
	}

    Super.StopSimulating();
}

function TriggerSolarIgnitionExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( SolarIgnitionExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

			SolarIgnitionExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(SolarIgnitionExplosionTemplate);
        }
    }
}*/

/*function SpawnMotionProjectile()
{
    local KFProj_Explosive_MotionProjectile Grenade;
    local Vector SpawnLocation, Direction;
    local Rotator SpawnRotation;
    
    if( Role == ROLE_Authority )
    {
    	SpawnLocation = Location;
	    SpawnRotation = Rotator(Direction);
	    Direction = VRandCone( LastHitNormal, MotionProjectileHalfCone * DegToRad ); //aim upwards in cone
	    // Direction += VRand(); // aims anywere

    	Grenade = Spawn(class'KFProj_Explosive_MotionProjectile', self,, SpawnLocation + (LastHitNormal * MotionProjectileOffSet), SpawnRotation);
	    if( Grenade != none && !Grenade.bDeleteMe )
	    {
	    	if( Grenade.InstigatorController == none )
				Grenade.InstigatorController = InstigatorController;
			if( Grenade.Instigator == none )
				Grenade.Instigator = Instigator;

	        Grenade.Velocity = Direction * MotionProjectileSpeed;
	    }
    }
}*/

/*simulated function Destroyed()
{
	if( SolarIgnitionParticlePSC != none )
		SolarIgnitionParticlePSC.DeactivateSystem();

	ClearTimer( nameOf(TriggerSolarIgnitionExplosion) );
	super.Destroyed();
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// if( ExplosionTemplate != none )
	// {
	// 	// Since bIgnoreInstigator is transient, its value must be defined here
	// 	ExplosionTemplate.bIgnoreInstigator = true;
	// }

	if( SolarIgnitionExplosionTemplate != none )
		SolarIgnitionExplosionTemplate.bIgnoreInstigator = true;
}*/

// simulated function SpawnFlightEffects()
// {
// 	Super.SpawnFlightEffects();

// 	if( bSplashFire )
// 		StartSplashFX();
// }

// simulated function StartSplashFX()
// {
// 	SplashPSC = new(self) class'ParticleSystemComponent';
// 	SplashPSC.SetTemplate( ProjFlightSplashFX );
// 	AttachComponent(SplashPSC);
// 	SplashPSC.SetAbsolute(false, true, true);
// }

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	LastHitNormal = HitNormal;
	// HitDamage = FireExplosionTemplate.Damage;
	Super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    local int i;
    local KFWeap_Incinerator Cannon;

	// HitDamage = FireExplosionTemplate.Damage;

    // Fire Shrapnel 
    if( KFPawn_Monster(HitActor) != none ) // && KFPawn_Monster(HitActor).IsAliveAndWell()
		LastHitNormal = vect(0,0,1); // instead, aim upwards on hitting pawn or corpse
	else
		LastHitNormal = HitNormal;

	if( bSplashFire )
		ExplosionTemplate.ExplosionEffects = SplashExplosionTemplate;
	else
		ExplosionTemplate.ExplosionEffects = NormalExplosionTemplate;

    if( Role == ROLE_Authority )
    {
        if( ImpactExplosionUpgrade )
        {
            for( i = 0; i < FireBallAmount; i++ )
				SpawnFireBall();
        }

        Cannon = KFWeap_Incinerator(Owner);
	    if( Cannon != none )
	    {
	    	// Fill up meter
			Cannon.MinFillUpMeter++;
			if( Cannon.MinFillUpMeter >= Cannon.MaxFillUpMeter )
				Cannon.MinFillUpMeter = Cannon.MaxFillUpMeter;

	    	if( CanisterUpgrade )
	    	{
	    		if( FRand() <= NapalmCansiterChance )
	    		{
		            for( i = 0; i < NapalmCanisterAmount; i++ )
						Cannon.SpawnNapalmCanister();
	    		}
	    	}
	    }
	}

	Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

function SpawnFireBall()
{
    local KFProj_Explosive_Incinerator_FireBall FireBall;
    local Vector SpawnLocation, Direction;
    local Rotator SpawnRotation;
    
    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Location;
        SpawnRotation = Rotator(Direction);
        Direction = VRandCone( LastHitNormal, FireBallHalfConeAngle * DegToRad ); //aim based on HitNormal in cone

        FireBall = Spawn(class'KFProj_Explosive_Incinerator_FireBall', self,, SpawnLocation + (LastHitNormal * FireBallSpawnOffset), SpawnRotation);
        if( FireBall != none )
        {
            FireBall.Instigator = Instigator;
            FireBall.InstigatorController = Instigator.Controller;
            FireBall.Velocity = Direction * FireBallSpawnSpeed;
        }
    }
}

/*simulated protected function StopSimulating()
{
    local int i;
	local vector FlameSpawnVel;

    if( Role == ROLE_Authority && Physics == PHYS_Falling )
    {
		if( ImpactGroundFire )
		{
           	for( i = 0; i < ResidualFlareAmount; i++ )
			{
				FlameSpawnVel = 0.25f * CalculateResidualFlameVelocity( LastHitNormal, Normal( Velocity ), VSize( Velocity ) );
				SpawnResidualFlame( class'KFProj_FlareGunSplash', Location + (LastHitNormal * 10.f), FlameSpawnVel );
			}
		}
	}

	// if( WorldInfo.NetMode != NM_DedicatedServer && SplashPSC != none )
        // SplashPSC.DeactivateSystem();

	Super.StopSimulating();
}*/

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150
	GravityScale=0.5
    MomentumTransfer=50000.0
    ArmDistSquared=0
    LifeSpan=8.0f //10.0f

    // ImpactGroundFire=false
    // ResidualFlareAmount=1

    ImpactExplosionUpgrade=false
    // FireBallChance=0.3f
    // FireBallAmount=3
    // FireBallHalfConeAngle=30
    // FireBallSpawnOffset=50 // 50 centimeters
    // FireBallSpawnSpeed=800 //1200

    CanisterUpgrade=false
    // NapalmCanisterAmount=1
	// NapalmCansiterChance=0.01f

	// bImpactExplosion=false
    // SolarIgnitionChance=0.33
	// SolarIgnitionExplosionFuseTime=1 //after 1 second
	// SolarIgnitionParticleTemplate=ParticleSystem'Fass_EMIT.FX_SolarIgnition_Flare'
	// SolarIgnitionAkEvent=AkEvent'WW_WEP_Lazer_Cutter.Play_WEP_LazerCutter_Beam_Charge_RampUP_3P'

	// MotionProjectileAmount=8
	// MotionProjectileHalfCone=80
    // MotionProjectileSpeed=1200
    // MotionProjectileOffSet=60.f

	bWarnAIWhenFired=true

	ProjFlightSplashFX=ParticleSystem'Fass_EMIT.FX_Incinerator_Projectile_Splash'
	ProjFlightTemplateNormal=ParticleSystem'Fass_EMIT.FX_Incinerator_Projectile'
	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Incinerator_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Incinerator_Projectile'

	SplashExplosionTemplate=KFImpactEffectInfo'WEP_Incinerator_ARCH.Incinerator_Explosion_Splash'
	NormalExplosionTemplate=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'

	bCanDisintegrate=false
    // ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

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
		Damage=75 //120
		DamageRadius=600
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_Incinerator'

        MomentumTransferScale=0
		bIgnoreInstigator=true

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
	// Solar ignition explosion light
	Begin Object Class=PointLightComponent Name=SolarIgnitionExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
		Radius=1000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// Solar ignition explosion
    Begin Object Class=KFGameExplosion Name=SolarIgnition
		Damage=55
		DamageRadius=500
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_Incinerator'

		bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'
		ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

        // Dynamic Light
        ExploLight=SolarIgnitionExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
    End Object
    SolarIgnitionExplosionTemplate=SolarIgnition
*/
}