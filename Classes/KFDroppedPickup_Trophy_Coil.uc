class KFDroppedPickup_Trophy_Coil extends KFDroppedPickup;

/*
var SkeletalMesh 		 SkeletalMesh;
var SkeletalMeshComponent AttachedToSkelComponent;

var SkeletalMeshActor RandomWeaponBoxMesh;
var SkeletalMeshComponent RandomWeaponBoxMesh;
var AnimSet TraderAnimSet;
var name OpenAnim;
*/

// var float Health;

var ParticleSystem ParticleFX;
var	transient ParticleSystemComponent ParticlePSC;

var KFGameExplosion ExplosionTemplate;
var float RepeatTimer;

var int RocketlessSpawned;
var int RocketlessToSpawn;
var float RocketlessSpawnOffsetZ;
var float RocketlessSpawnSpeed;
var float HalfConeAngle;

var KFImpactEffectInfo ImpactEffects;

simulated function PostBeginPlay()
{
/*
	if( WorldInfo.NetMode != NM_DedicatedServer)
	{
		if( RandomWeaponBoxMesh != None )
		{
			AttachComponent(RandomWeaponBoxMesh);
			if( TraderAnimSet != None )
			{
				RandomWeaponBoxMesh.AnimSets[0] = TraderAnimSet;
				RandomWeaponBoxMesh.PlayAnim(OpenAnim);
				RandomWeaponBoxMesh.UpdateAnimations();
			}
		}
	}
*/

	if( ParticleFX != none )
		StartParticleFX();

    if( Role == ROLE_Authority )
    {
        RocketlessSpawned = 0;
        RocketlessToSpawn = 10;
	    SetTimer(3.0, false, 'StartFlying');
    }

    super.PreBeginPlay();
}

simulated function StartParticleFX()
{
	ParticlePSC = new(self) class'ParticleSystemComponent';
	ParticlePSC.SetTemplate( ParticleFX );
	AttachComponent(ParticlePSC);
	ParticlePSC.SetAbsolute(false, true, true);
}

State FadeOut
{
	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		LifeSpan = 1.0;
		StopParticleFX();
		TriggerExplosion();
		ParticlePSC.SetScale(0);
		SetDrawScale(0);
    	ClearTimer(nameof(RepeatTimer));
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function StopParticleFX()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && ParticlePSC != none )
        ParticlePSC.DeactivateSystem();
}

simulated function TriggerExplosion()
{
	local KFExplosionActorReplicated ExploActor;

	if( ExplosionTemplate != none )
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.bIgnoreInstigator = true;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

simulated function StartFlying()
{
	local vector DirectionUp;

    // Looped timer
	SetTimer(RepeatTimer, true, nameof(TriggerExplosion));
	SetTimer(1.0, true, 'SpawnRocketless');

	SetPhysics(PHYS_Projectile);
	DirectionUp = vect(0,0,1);
	Velocity = DirectionUp * float(600);
	// RotationRate.Yaw = 150000;
	SetTimer(0.5, false, nameof(Rotate));
}

simulated function Rotate()
{
	SetPhysics(PHYS_Rotating);
	RotationRate.Yaw = 150000;
}

/*
simulated function Crushfy()
{
	local vector Direction;
	
	Direction = vect(0,0,-1);
	SetPhysics(PHYS_Projectile);
	Velocity = Direction * float(1200);
}

function PlayCollisionSound()
{
    if( WorldInfo.NetMode != NM_DedicatedServer )
        `ImpactEffectManager.PlayImpactEffects(Location, Instigator, vect(0,0,1), ImpactEffects, true );
}

simulated function Rigidfy()
{
	SetPhysics(PHYS_RigidBody);
}

simulated function Fallfy()
{
	local vector Direction;

	SetPhysics(PHYS_Falling);

	// if (Role == ROLE_Authority)
	// {
	// 	if( Physics == PHYS_Falling )
	// 		SetPhysics(PHYS_RigidBody);
	// }

   	// DirectionUp = vect(0,0,1);
    // Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone
    // Direction += VRand(); // aims anywere
	Direction = vect(0,1,5);
	Velocity = Direction * float(200);
}

simulated function Speenfy()
{
	SetPhysics(PHYS_Rotating);
	RotationRate.Yaw = 150000;
}

*/
	// local vector Direction;
    // Direction = vect(0,0,1); // aim upwards
    // Velocity = Direction * float(800);

// simulated function Rotate()
// {
// 	RotationRate.Yaw=80000;
// 	SetPhysics(PHYS_Rotating);
// }

	// if( PHYS_Projectile )
		// velocity = DirectionUp * float(800);

simulated function SpawnRocketless()
{
    local KFProj_Explosive_Rocketless Rocket;
    local Vector Pos, Direction, DirectionUp;
    local rotator Rot;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
    	Pos = Location + DirectionUp * RocketlessSpawnOffsetZ;
        Rot = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        // Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone
    	Direction += VRand(); // aims anywere

        Rocket = Spawn(class'KFProj_Explosive_Rocketless',,, Pos, Rot,, false);
	    if( Rocket != none )
	        Rocket.Velocity = Direction * RocketlessSpawnSpeed;

	    // disables projectile spawning after x projectiles been spawned
	    if(RocketlessSpawned >= RocketlessToSpawn)
	    {
	        ClearTimer('SpawnRocketless');
	        return;
	    }

    	RocketlessSpawned++;
    }
}

event Destroyed()
{
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
}

/*
// Capture damage so that human players can destroy the krystal
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	if( Health > 0 && inDamage > 0 )
	{
		Health -= inDamage;
		if( Health <= 0 )
			GotoState('FadeOut');
	}
}
*/

DefaultProperties
{
	LifeSpan=20
	RepeatTimer=6

/*
    Begin Object Class=SkeletalMeshComponent Name=SkelMesh0
        SkeletalMesh=SkeletalMesh'ENV_Trader_MESH.TraderPod_Rig_Master'
        PhysicsAsset=PhysicsAsset'ENV_Trader_PHYS.TraderPod_Rig_Master_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    RandomWeaponBoxMesh=SkelMesh0
	TraderAnimSet=AnimSet'ENV_Trader_ANIM.TraderPod_Anim_Master'
	OpenAnim=Open
*/

	ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Heavy_bullet_impact'

	ParticleFX=ParticleSystem'Fass_EMIT.FX_Coil_Indicator'

	HalfConeAngle=25 //20
	RocketlessSpawnOffsetZ=100
   	RocketlessSpawnSpeed=800

/*
	Health=8000

	bMovable=true
	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

	Begin Object NAME=CollisionCylinder
		CollisionRadius=40
		CollisionHeight=40
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.ExplosiveBarrel_PM'
		Translation=(X=0,Y=0,Z=0)
	End Object
*/

	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=1500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=25  //100
		DamageRadius=700   //600
		DamageFalloffExponent=1  //2
		DamageDelay=0.f
		MyDamageType=class'KFDT_EMP_EMPGrenade'

		// Damage Effects
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.EMPGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}