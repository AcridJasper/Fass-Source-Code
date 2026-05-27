class KFDroppedPickup_Trophy_NapalmCanister extends KFDroppedPickup;

var float Health;

// Flare
var int NumResidualFlames;
var float FlareSpawnOffsetZ;
var float FlareSpawnSpeed;
var int HalfConeAngle;

var ParticleSystem ParticleFX;
var	transient ParticleSystemComponent ParticlePSC;

var KFGameExplosion ExplosionTemplate;

simulated function PostBeginPlay()
{
	if( ParticleFX != none )
		StartParticleFX();

    super.PreBeginPlay();
}

simulated function StartParticleFX()
{
	ParticlePSC = new(self) class'ParticleSystemComponent';
	ParticlePSC.SetTemplate( ParticleFX );
	AttachComponent(ParticlePSC);
	ParticlePSC.SetAbsolute(false, true, true);
}

// sets the pickups mesh and makes it the collision component so we can run rigid body physics on it
simulated function SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	Super.SetPickupMesh(NewPickupMesh);

	// Collide with other dosh! (just while they are both awake)
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Pickup, TRUE);
}

event Destroyed()
{
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
}

State FadeOut
{
	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		Destroyed();
		StopParticleFX();
		TriggerExplosion();
		ParticlePSC.SetScale(0);
		SetDrawScale(0);
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
	local int i;
	local KFExplosionActorReplicated ExploActor;

	if( ExplosionTemplate != none )
	{
		for( i = 0; i < NumResidualFlames; ++i )
			SpawnFlares();

		// explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			
            ExplosionTemplate.bIgnoreInstigator = true;

			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

simulated function SpawnFlares()
{
    local KFProj_MolotovSplash_Rot Flare;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    SpawnLocation = Location;
    SpawnLocation.Z += FlareSpawnOffsetZ;
    SpawnRotation = Rotator(Direction);
    DirectionUp = vect(0,0,1);
    Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone
    // Direction += VRand(); // aims anywere
	Flare = Spawn(class'KFProj_MolotovSplash_Rot', self,, SpawnLocation, SpawnRotation);

    if( Flare != none )
        Flare.Velocity = Direction * FlareSpawnSpeed;
}

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

DefaultProperties
{
	LifeSpan=20 //40

	NumResidualFlames=3 //4
    FlareSpawnOffsetZ=15
    FlareSpawnSpeed=1200
    HalfConeAngle=20

	Health=60

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=40
		CollisionHeight=40
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.ExplosiveBarrel_PM'
		Translation=(X=0,Y=0,Z=0)
	End Object

	Begin Object Class=PointLightComponent Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=3.f
		Radius=700.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=65 //75
		DamageRadius=500
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_MolotovGrenade'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.NapalmCanister_Explosion'
		ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

        // Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=0.4
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=KFCameraShake'FX_CameraShake_Arch.Grenades.Molotov'
		CamShakeInnerRadius=250
		CamShakeOuterRadius=400
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}