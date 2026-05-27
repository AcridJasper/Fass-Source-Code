class KFDroppedPickup_EvilAssCheese extends KFDroppedPickup;

var float Health;

var KFGameExplosion ExplosionTemplate;

// event Destroyed()
// {
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
// }

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
	local KFExplosionActorReplicated ExploActor;

	if( ExplosionTemplate != none )
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( ExploActor != None )
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.Explode(ExplosionTemplate);
		}
	}
}

// Capture damage so that human players can destroy the fucking evil ass cheese wtf lmao
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
	LifeSpan=6
	
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
		CollisionRadius=20.f
		CollisionHeight=20.f
		CollideActors=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit without this
		BlockNonZeroExtent=true
		PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.ExplosiveBarrel_PM'
	End Object

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
		Damage=600
		DamageRadius=1000
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Seeker6'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_RPG7_ARCH.RPG7_Explosion'
		ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

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