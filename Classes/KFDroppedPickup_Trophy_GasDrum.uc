class KFDroppedPickup_Trophy_GasDrum extends KFDroppedPickup;

var float Health;

var int HalfConeAngle;

var KFGameExplosion ExplosionTemplate;

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
		// Destroyed();
		TriggerExplosion();
		SetDrawScale(0);
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function TriggerExplosion()
{
	local KFExplosion_GasDrum ExploActor;

	if( ExplosionTemplate != none )
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosion_GasDrum', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
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
	LifeSpan=35

	Health=80

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
		Damage=25
		DamageRadius=500
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_PlayerCrawlerSuicide'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_RPG7_ARCH.RPG7_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_EXP_Grenade_Frag_Explosion'

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