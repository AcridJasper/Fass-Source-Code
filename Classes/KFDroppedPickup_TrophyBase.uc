class KFDroppedPickup_TrophyBase extends KFDroppedPickup;

var class<KFDamageType> HealingDamageType;
var private int HealingValue;
var int ArmorAmount;
var int DoshAmount;
var int AmmoAmount, NoMagAmmoAmount;
var int GrenadeAmount;
// var int SpecificAmmoCountPrimaryAmount;
// var int SpecificAmmoCountSecondaryAmount;
// var int SpecificSpareAmmoAmount;

// Healing boosts
var bool PlayAllHealingBoosts;
var bool PlayHealingSpeedBoost;
var bool PlayHealingDamageBoost;
var bool PlayHealingShieldBoost;

// In ZED functions
var bool PlayAirBorneAgent;
var bool PlaySacrificeExplode;

var bool PlayPowerUp;
var class<KFPowerUp> PowerUpType;

var bool DropActiveWeapon;

// Misc
var bool BlowUpOnPickup;
var KFGameExplosion PickupExplosionTemplate;
// var KFPawn_Human Pickupey;
// var KFGameExplosion AAExplosionTemplate;

var bool HurtPlayer;
var float HurtDamage;
var vector HurtMomentum;
var class<KFDamageType> HurtDamageType;

// Particle system
var ParticleSystem TrophyFX;
var	transient ParticleSystemComponent TrophyPSC;

// Point light
var bool bEnableGlowLight;
// var float LightFadeStartTime;
var transient float LightFadePerSecond;
var PointLightComponent GlowLight;
var LightPoolPriority GlowLightPriority;

var AkEvent	PickupSound;

simulated function PostBeginPlay()
{
	if( TrophyFX != none )
		StartTrophyFX();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	    LightFadePerSecond = GlowLight.Brightness;

	// Set its light if it has one
	if( bEnableGlowLight )
	{
	    if( GlowLight != None )
	    {
	        AttachComponent(GlowLight);
	        `LightPool.RegisterPointLight(GlowLight, GlowLightPriority);
	    }
	}

    super.PreBeginPlay();
}

function GiveTo( Pawn P )
{
	local KFPawn_Human KFPH;
	local KFPlayerReplicationInfo KFPRI;
	local KFPlayerController KFPC;
	local KFWeapon KFW;

	KFPH = KFPawn_Human(P);
	if( KFPH != none && KFPH.IsAliveAndWell() )
	{
		// Heals player when you pickup the drop
		KFPH.HealDamage(HealingValue, Instigator.Controller, HealingDamageType);

		// Gives armor when you pickup the drop
		KFPH.AddArmor(ArmorAmount);
		// KFPawn_Human(P).AddArmor(ArmorAmount);

		// Gives dosh when you pickup the drop
		KFPRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);
		if( KFPRI != none )
			KFPRI.AddDosh(DoshAmount);

		// Gives ammo
    	ForEach P.InvManager.InventoryActors(class'KFWeapon', KFW)
    	{
    		if( KFW != none)
				KFW.AddAmmo(AmmoAmount);
			else if( KFW.bNoMagazine == true )
				KFW.AddAmmo(NoMagAmmoAmount);

			// Sets ammo parameters to specific values (so if you have x amount of ammo, it will change to the values you define)
        	// KFW.AmmoCount[0] = SpecificAmmoCountPrimaryAmount;
        	// KFW.AmmoCount[1] = SpecificAmmoCountSecondaryAmount;
			// KFW.SpareAmmoCount[0] = SpecificSpareAmmoAmount;
    	}

		// Gives grenades
		KFInventoryManager(P.InvManager).AddGrenades(GrenadeAmount);

		// Plays medic syringe boosts
		if( PlayAllHealingBoosts )
		{
			KFPH.UpdateHealingSpeedBoost();
			KFPH.UpdateHealingDamageBoost();
			KFPH.UpdateHealingShield();
		}
		if( PlayHealingSpeedBoost )
			KFPH.UpdateHealingSpeedBoost();
		if( PlayHealingDamageBoost )
			KFPH.UpdateHealingDamageBoost();
		if( PlayHealingShieldBoost )
			KFPH.UpdateHealingShield();

		// Why is this even in the KFPawn_Human (oh yea)
		if( PlayAirBorneAgent )
			KFPH.StartAirBorneAgentEvent();

		// BOOM!
		if( PlaySacrificeExplode )
			KFPH.SacrificeExplode();

		// Gives any powerup (even custom made one)
		if( PlayPowerUp )
			KFPC = KFPlayerController(P.Owner);
		    if( KFPC != none )
		        KFPC.ReceivePowerUp(PowerUpType);

		// le trollage
		if( DropActiveWeapon )
			KFPH.ThrowActiveWeapon();

		if( BlowUpOnPickup )
			TriggerExplosion();

		if( HurtPlayer )
			KFPH.TakeDamage(HurtDamage, KFPC, KFPH.Location, HurtMomentum, HurtDamageType);
	}

	bForceNetUpdate = true;
	P.PlaySoundBase(PickUpSound);

	PickedUpBy(P);
}

auto state Pickup
{
	// Allow instigator to pick up dosh thrown at feet
	event OnSleepRBPhysics()
	{
		local Pawn P;

		Global.OnSleepRBPhysics();

		foreach TouchingActors(class'Pawn', P)
		{
			if( P == Instigator )
				Touch( P, None, Location, vect(0,0,1) );
		}
	}
}

simulated function StartTrophyFX()
{
	TrophyPSC = new(self) class'ParticleSystemComponent';
	TrophyPSC.SetTemplate( TrophyFX );
	AttachComponent(TrophyPSC);
	TrophyPSC.SetAbsolute(false, true, true);
}

simulated function StopTrophyFX()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && TrophyPSC != none )
        TrophyPSC.DeactivateSystem();
}

// sets the pickups mesh and makes it the collision component so we can run rigid body physics on it
simulated function SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	Super.SetPickupMesh(NewPickupMesh);

	// Collide with other dosh! (just while they are both awake)
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Pickup, TRUE);
}

simulated function TriggerExplosion()
{
	local KFExplosionActorReplicated PickupExplosionActor;

	if( PickupExplosionTemplate != none )
	{
		PickupExplosionActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( PickupExplosionActor != None )
		{
			PickupExplosionActor.Instigator = Instigator;
			PickupExplosionActor.InstigatorController = Instigator.Controller;
			PickupExplosionActor.bIgnoreInstigator = true;
			PickupExplosionActor.Explode(PickupExplosionTemplate);
		}
	}
	
	if( PickupExplosionActor != none )
		PickupExplosionActor.Destroy();
}

/*
simulated function AATriggerExplosion()
{
	local KFExplosion_AirborneAgent AAExplosionActor;

	if( AAExplosionTemplate != none )
	{
		// AAExplosionActor = Spawn(class'KFExplosion_AirborneAgent', self,, Location, Rotation,, true);
		AAExplosionActor = Spawn( class'KFExplosion_AirborneAgent', self,, Location );
		if( AAExplosionActor != None )
		{
			AAExplosionActor.Instigator = Instigator;
			AAExplosionActor.InstigatorController = Instigator.Controller;
			AAExplosionActor.bIgnoreInstigator = true;
			AAExplosionActor.MyPawn = Pickupey;
			AAExplosionActor.SetBase( Pickupey,, Pickupey.Mesh );
			AAExplosionActor.Explode(AAExplosionTemplate);
		}
	}
	
	if( AAExplosionActor != none )
		AAExplosionActor.Destroy();
}
*/

// simulated function Destroying()
// {
// 	Destroyed();
// }

event Destroyed()
{
    // super.Destroyed();
	
    // Do NOT destroy the inventory item
	// Inventory = none;
}

State FadeOut
{
	function Tick(float DeltaTime)
	{
		local float NewBrightness;

		// if( LifeSpan < default.LifeSpan - LightFadeStartTime )
		// {
			// Fade out gradually
	    	if ( GlowLight != None && GlowLight.bAttached )
	    	{
				if( GlowLight.Brightness > 0 )
				{
					NewBrightness = FMax( 0.01, GlowLight.Brightness - (LightFadePerSecond * DeltaTime) );
					GlowLight.SetLightProperties( NewBrightness );
				}
	    	}
		// }

		TrophyPSC.SetScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
		
		Global.Tick(DeltaTime);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;

		// SetTimer(2.0, false, nameof(StopTrophyFX));
		// SetTimer(2.0, false, nameof(StopSkullRallingFX));
		SetTimer(2.0, false, nameof(Died)); // Fully kill off all effects
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function Died()
{
    SetDrawScale(0);
	// Destroying();
    StopTrophyFX();
    TrophyPSC.SetScale(0);
	DetachComponent(GlowLight);
}

DefaultProperties
{
	LifeSpan=60
	bUseLowHealthDelay=FALSE
	PickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Ammo'
	// WW_UI_PlayerCharacter.Play_UI_Pickup_Dosh

	HealingDamageType=class'KFDT_Healing'
	// HealingValue=5
	// ArmorAmount=20
	// DoshAmount=20

	// AmmoAmount=50
	// NoMagAmmoAmount=5
	// GrenadeAmount=1
	// SpecificAmmoCountPrimaryAmount=4
	// SpecificAmmoCountSecondaryAmount-2
	// SpecificSpareAmmoAmount=5
	
	// Healing buffs
	PlayAllHealingBoosts=false
	PlayHealingSpeedBoost=false
	PlayHealingDamageBoost=false
	PlayHealingShieldBoost=false

	PlayAirBorneAgent=false
	PlaySacrificeExplode=false

	PlayPowerUp=false
	PowerUpType=class'KFPowerUp_HellishRage_NoCostHeal'

	DropActiveWeapon=false

	HurtPlayer=false
	HurtDamage=5
	HurtDamageType=class'KFDT_Falling'

	// BOOM
	BlowUpOnPickup=false

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
		Damage=160
		DamageRadius=800 //600
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
	PickupExplosionTemplate=ExploTemplate0

/*
	Begin Object Class=KFGameExplosion Name=ExploTemplate1
		Damage=50
		DamageRadius=800
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Seeker6'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.Medic_Perk_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Explosion'

		// Camera Shake
		CamShake=none
	End Object
	AAExplosionTemplate=ExploTemplate1
*/

	// TrophyFX=ParticleSystem'Fass_EMIT.FX_Trophy'

	bEnableGlowLight=false
	Begin Object Class=PointLightComponent Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        FalloffExponent=3.0f
        CastShadows=FALSE
        CastStaticShadows=false
        CastDynamicShadows=false
        bCastPerObjectShadows=false
        bEnabled=true
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object
    GlowLight=PointLight0
    GlowLightPriority=LPP_High
}