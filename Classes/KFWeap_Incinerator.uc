class KFWeap_Incinerator extends KFWeap_FlameBase
	config(Fass);

// ****************************** Heat ring ******************************
var() config bool EanbleHeatRingTriggerDistance;
var() config float HeatRingTriggerRadius, HeatRingSpawnOffsetZ;
var() config float FireballLaunchDelay, FireBallHalfCone, FireBallSpawnSpeed;
var() config int NapalmCanisterSpawnAmount, FireBallSpawnAmount, FireBallSpawnOffsetZ, MinFillUpMeter, MaxFillUpMeter;
var() KFGameExplosion HeatRingExplosionTemplate;
var KFPawn_Monster Monster;
var KFProj_HighExplosive_Incinerator InciProjectile;

// ****************************** Perk passive ******************************
var() config float SplashFireSpawnDelay, SplashFireHalfCone, SplashFireSpawnSpeed, SplashFireOffsetZ;

// ****************************** Fire Shrapnel ******************************
var bool DrawHudPassive1;

// ****************************** Napalm Canister ******************************
var bool DrawHudPassive2;
var() config float NapalmCanisterDropChance;
var() config int NapalmCanisterSpawnOffsetZ;
var() config int NapalmCanisterSpawnSpeed;
var() config int NapalmCanisterHalfConeAngle;
var PrimitiveComponent NapalmCanisterMesh;
// var transient int CurrentUpgradeLevel;
// var	Array< class<KFProjectile> > ProjectileClassByUpgrade;

// ****************************** Floating ******************************

// var bool bFlightIsActive;

// var() float ShieldConsumptionPerSecond;
// var() float ShieldRechargePerSecond;
// var /*protected transient*/ bool bCanRechargeShield;
// var /*protected transient*/ float ShieldRechargeIncrement;
// var /*protected transient*/ float ShieldConsumptionIncrement;

// ****************************** Flamethrower stuff ******************************
// Effect for the pilot light
var() protected KFParticleSystemComponent PSC_SpineLights[4];
// Socket to attach the pilot light to
var() name SpineLightSocketNames[4];

// ****************************** Motion projectiles ******************************
// var float TimeBeforeMotionProjectileSpawn, MotionProjectileHalfCone, MotionProjectileSpeed, MotionProjectileOffSet;
// var AkEvent SolarIgnitionAkEvent;
// var KFPawn_Monster NearByZEDs;

// ****************************** Misc ******************************
// Reduction for the amount of damage dealt to the weapon owner (including damage by the explosion)
var() float SelfDamageReductionValue;

var float SuperSecretMessageChance;

// ****************************** Stuff bellow ******************************
// simulated event PostBeginPlay()
// {
// 	Super.PostBeginPlay();
// }

/*
simulated function int GetSecondaryAmmoForHUD()
{
	// return int(UltimateCharge)$"%";
	// return UltimateCharge;
	return AmmoCount[ALTFIRE_FIREMODE];
}

simulated event bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if( FireModeNum == ALTFIRE_FIREMODE )
		return IsFullyCharged();

	return super.HasAmmo(FireModeNum, Amount);
}
*/

// simulated function ConsumeAmmo( byte FireModeNum )
// {
// 	super.ConsumeAmmo(FireModeNum);

// 	if( WorldInfo.NetMode != NM_DedicatedServer )
// 	{
// 		if( FireModeNum == ALTFIRE_FIREMODE && IsFullyCharged() )
// 	}
// }

// ****************************** Shield ******************************

/*
var repnotify byte ShieldAmmo;

replication
{
	if (bNetDirty && Role == ROLE_Authority && bAllowClientAmmoTracking)
		ShieldAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == nameof(ShieldAmmo) )
		AmmoCount[ALTFIRE_FIREMODE] = ShieldAmmo;
	else
		Super.ReplicatedEvent(VarName);
}

simulated function AltFireMode()
{
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
		return;

	// if we're a client, synchronize server
	// if( Role < Role_Authority )
	// 	UseShield();

	// CustomFire();
}

// reliable server function UseShield()
// {
// 	CustomFire();
// }

// simulated function CustomFire()
// {
// 	if( AmmoCount[ALTFIRE_FIREMODE] == 0 )
// 		return;
// }
*/

// simulated event PostBeginPlay()
// {
// 	Super.PostBeginPlay();
// 	if( Role == ROLE_Authority )
// }

// ****************************** Flamethrower stuff ******************************

simulated protected function TurnOnPilot()
{
    local int i;
    local float OwnerMeshFOV;

	if (bPilotLightOn)
		return;

    OwnerMeshFOV = MySkelMesh.FOV;

    // Attach and start up the pilot light
    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		MySkelMesh.AttachComponentToSocket( PSC_SpineLights[i], SpineLightSocketNames[i] );

    		PSC_SpineLights[i].ActivateSystem();

    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    		PSC_SpineLights[i].SetFOV(OwnerMeshFOV);
    	}
	}

    super.TurnOnPilot();
}

simulated protected function TurnOffPilot()
{
    local int i;

    Super.TurnOffPilot();

    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    		PSC_SpineLights[i].DeActivateSystem();
	}
}

simulated protected function TurnOnFireSpray()
{
    local int i;

	if (!bFireSpraying)
	{
        // Attach and start up the pilot light
        for (i = 0; i < 4; i++)
        {
        	if( PSC_SpineLights[i] != None )
        	{
        		// Turn off the low flame, turn on the high flame
        		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 0.0);
        		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 1.0);
        	}
    	}
	}

	Super.TurnOnFireSpray();
}

simulated protected function TurnOffFireSpray()
{
    local int i;

    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    	}
	}

	Super.TurnOffFireSpray();
}

// Adjust the FOV for the first person weapon and arms
simulated event SetFOV( float NewFOV )
{
    local int i;
	// local KFPawn_Human You;

    Super.SetFOV(NewFOV);

	// You = KFPawn_Human(Instigator);
	// if( You != none )
	// 	You.SetPhysics(PHYS_Walking);

	// if( Instigator.Physics == PHYS_Walking  )
    // 	bFlightIsActive = false;

    // Set the light emitter to the same FOV as the weapon mesh
    if( MySkelMesh != none )
    {
        for (i = 0; i < 4; i++)
        {
        	if( PSC_SpineLights[i] != None )
        		PSC_SpineLights[i].SetFOV(MySkelMesh.FOV);
    	}
	}
}

// ****************************** Floating ******************************

/*
simulated event Tick( float DeltaTime )
{
	if( Role == Role_Authority )
	{
    	if( bUsingSights )
    		bFlightIsActive = true;

		if( bFlightIsActive )
			ConsumeShield(DeltaTime);
		else if( bCanRechargeShield && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
			RechargeShield(DeltaTime);
		else
		{
			bFlightIsActive = false;
			OnDepleted();
		}
	}

	super.Tick( DeltaTime );
}

function ConsumeShield(float DeltaTime)
{
	local KFPawn_Human You;
	local int Charge;

	if( Role == ROLE_Authority )
	{
		You = KFPawn_Human(Instigator);
		if( You != none )
			You.SetPhysics(PHYS_Flying);

		if( AmmoCount[ALTFIRE_FIREMODE] == 0 )
			OnDepleted();

		ShieldRechargeIncrement = 0.0f;
		ShieldConsumptionIncrement += ShieldConsumptionPerSecond * DeltaTime;
		
		if( ShieldConsumptionIncrement >= 1.0f && AmmoCount[ALTFIRE_FIREMODE] > 0 )
		{
			Charge = int(ShieldConsumptionIncrement);
			AmmoCount[ALTFIRE_FIREMODE] = Max(AmmoCount[ALTFIRE_FIREMODE] - Charge, 0);
			ShieldConsumptionIncrement -= Charge;

			ShieldAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

function RechargeShield(float DeltaTime)
{
	local int Charge;

	if (Role == ROLE_Authority)
	{
		ShieldConsumptionIncrement = 0.0f;
		ShieldRechargeIncrement += ShieldRechargePerSecond * DeltaTime;
		if( ShieldRechargeIncrement >= 1.0f && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
		{
			Charge = int(ShieldRechargeIncrement);
			AmmoCount[ALTFIRE_FIREMODE] = Min(AmmoCount[ALTFIRE_FIREMODE] + Charge, MagazineCapacity[ALTFIRE_FIREMODE]);
			ShieldRechargeIncrement    -= Charge;

			ShieldAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

simulated function OnDepleted()
{
	local KFPawn_Human You;

  	bFlightIsActive = false;

		SetIronSights(false);

	You = KFPawn_Human(Instigator);
	if( You != none )
		You.SetPhysics(PHYS_Walking);
}

// Update HUD ammo icon
simulated function int GetSecondaryAmmoForHUD()
{
	return AmmoCount[ALTFIRE_FIREMODE];
}

// Update HUD ammo icon
simulated function string GetSpecialAmmoForHUD()
{
	return UltimateCharge$"%";
}
*/

// simulated event Tick( float DeltaTime )
// {
// 	super.Tick( DeltaTime );
// }

// ****************************** Motion projectiles ******************************

/*simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		if( Role == ROLE_Authority )
			SetTimer(TimeBeforeMotionProjectileSpawn, true, 'SpawnMotionProjectile');
	}
}*/

/*
simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		foreach VisibleCollidingActors(class'KFPawn_Monster', NearByZEDs, 1000)
		{
			if( Role == Role_Authority )
			{
				if( NearByZEDs.IsAliveAndWell() )
					SetTimer(TimeBeforeMotionProjectileSpawn, true, 'SpawnMotionProjectile');
				else
					ClearTimer(nameof(SpawnMotionProjectile));
			}
		}
	}
}

function SpawnMotionProjectile()
{
    local KFProj_Explosive_MotionProjectile Grenade;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    if( Role == ROLE_Authority )
    {
		PlaySoundBase( SolarIgnitionAkEvent );

    	SpawnLocation = Instigator.Location;
	    SpawnRotation = Rotator(DirectionUp);
	    DirectionUp = Vect(0,0,1);
	    Direction = VRandCone( DirectionUp, MotionProjectileHalfCone * DegToRad ); //aim upwards in cone

    	Grenade = Spawn(class'KFProj_Explosive_MotionProjectile', self,, SpawnLocation, SpawnRotation);
	    if( Grenade != none && !Grenade.bDeleteMe )
	    {
            Grenade.Instigator = Instigator;
            Grenade.InstigatorController = Instigator.Controller;
	        Grenade.Velocity = Direction * MotionProjectileSpeed;
	    }
    }
}

simulated state WeaponPuttingDown
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

	    if( Role == ROLE_Authority )
			ClearTimer(nameof(SpawnMotionProjectile));
	}
}

simulated state Inactive
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

	    if( Role == ROLE_Authority )
			ClearTimer(nameof(SpawnMotionProjectile));
	}
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	if( Role == ROLE_Authority)
		ClearTimer(nameof(SpawnMotionProjectile));

	super.DropFrom(StartLocation, StartVelocity);
}
*/

// ****************************** Projectile upgrades ******************************

/*simulated function class<KFProjectile> GetKFProjectileClass()
{
    if( CurrentFireMode == DEFAULT_FIREMODE || CurrentFireMode == ALTFIRE_FIREMODE )
        return ProjectileClassByUpgrade[CurrentUpgradeLevel];

    return super.GetKFProjectileClass();
}*/

// ****************************** Napalm/Fireball upgrades ******************************

// Spawn projectile is called once for each projectile fired
simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
    if( CurrentFireMode == DEFAULT_FIREMODE )
	{
		InciProjectile = KFProj_HighExplosive_Incinerator( super.SpawnProjectile( class<KFProjectile>(WeaponProjectiles[CurrentFireMode]), RealStartLoc, AimDir) );
		if( InciProjectile != none )
		{
			InciProjectile.Instigator = Instigator; // failsafe ?
			if( DrawHudPassive1 )
				InciProjectile.ImpactExplosionUpgrade = true;
			if( DrawHudPassive2 )
				InciProjectile.CanisterUpgrade = true;
		}

		return InciProjectile;
	}

   	return super.SpawnProjectile( KFProjClass, RealStartLoc, AimDir );
}

function SpawnNapalmCanister()
{
    local KFDroppedPickup_Incinerator_NapalmCanister Drink;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Location + vect(0,0,1) * NapalmCanisterSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, NapalmCanisterHalfConeAngle * DegToRad ); //aim upwards in cone

        Drink = Spawn(class'KFDroppedPickup_Incinerator_NapalmCanister',,, SpawnLocation, SpawnRotation,, false);
        if( Drink != None )
        {
            Drink.SetPhysics(PHYS_Falling);
            Drink.Velocity = Direction * NapalmCanisterSpawnSpeed;
            Drink.Instigator = Instigator;
            Drink.SetPickupMesh(NapalmCanisterMesh);
        }
    }
}

// ****************************** Heat ring ******************************

simulated function ConsumeAmmo( byte FireModeNum )
{
	local int i;

	super.ConsumeAmmo(FireModeNum);

	// if( Role == ROLE_Authority )
	// {
	// 	// MinFillUpMeter++;
	// 	if( MinFillUpMeter >= MaxFillUpMeter )
	// 		MinFillUpMeter = MaxFillUpMeter;
	// }

	// if( WorldInfo.NetMode != NM_DedicatedServer )
	if( Role == ROLE_Authority )
	{
		if( EanbleHeatRingTriggerDistance )
		{
			foreach VisibleCollidingActors(class'KFPawn_Monster', Monster, HeatRingTriggerRadius)
			{
				if( Monster.IsAliveAndWell() )
				{
					if( MinFillUpMeter >= MaxFillUpMeter )
					{
						MinFillUpMeter=0; //reset meter
			    		SpawnHeatRing();
			    		if( DrawHudPassive1 )
		    				SetTimer(FireBallLaunchDelay, false, 'DelayedSpawnFireball'); // delay fireballs abit
				    	if( DrawHudPassive2 )
				    	{
					    	for( i = 0; i < NapalmCanisterSpawnAmount; i++ )
					    		SpawnNapalmCanister();
						}
					}
				}
			}
		}
		else
		{
			if( MinFillUpMeter >= MaxFillUpMeter )
			{
				MinFillUpMeter=0; //reset meter
		    	SpawnHeatRing();
		    	if( DrawHudPassive1 )
    				SetTimer(FireBallLaunchDelay, false, 'DelayedSpawnFireball'); // delay fireballs abit
			    if( DrawHudPassive2 )
			    {
			    	for( i = 0; i < NapalmCanisterSpawnAmount; i++ )
			    		SpawnNapalmCanister();
			    }
			}
		}
	}
}

//Reduce the damage received and apply it to the shield
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	local int i;

    super.AdjustDamage(InDamage, DamageType, DamageCauser);
	
	// if( DrawHudPassive2 )
	// {
	// 	if( KFPawn_Monster(DamageCauser) != none && FRand() >= 0.33f )
	// 	{
    // 		for(i = 0; i < 8; i++)
	// 			SpawnMotionProjectile();
	// 	}
	// }

    // if( Instigator != none )
    if( KFPawn_Monster(DamageCauser) != none )
    {
		if( MinFillUpMeter >= MaxFillUpMeter )
		{
	    	SpawnHeatRing();
	    	MinFillUpMeter=0; //reset meter
	    	if( DrawHudPassive1 )
	    		SetTimer(FireBallLaunchDelay, false, 'DelayedSpawnFireBall'); // delay fireballs abit
	    	if( DrawHudPassive2 )
	    	{
	    		for( i = 0; i < NapalmCanisterSpawnAmount; i++ )
	    			SpawnNapalmCanister();
	    	}
	    }
	}
	
	if( Instigator != none && DamageCauser.Instigator == Instigator )
		InDamage *= SelfDamageReductionValue;
}

function SpawnHeatRing()
{
	local KFExplosionActorReplicated ExploActor;
	local vector SpawnLocation;

	if( HeatRingExplosionTemplate != none )
	{
		SpawnLocation = Instigator.Location + vect(0,0,1) * HeatRingSpawnOffsetZ;

		ExploActor = Spawn(class'KFExplosionActorReplicated',,, SpawnLocation, rotator(vect(0,0,1)),, true);
		if( ExploActor != None )
		{
			ExploActor.Instigator = Instigator;
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.bReplicateInstigator = true;

			HeatRingExplosionTemplate.bIgnoreInstigator = false;

			ExploActor.Explode(HeatRingExplosionTemplate);
		}

		// `log( GetItemName(string(Self))@"- Spawned Healing ring" );
	}
}

function DelayedSpawnFireBall()
{
	local int i;
	for( i = 0; i < FireBallSpawnAmount; i++ )
	    SpawnFireBall();
}

function SpawnFireBall()
{
    local KFProj_Explosive_Incinerator_FireBall FireBall;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    if( Role == ROLE_Authority )
    {
    	SpawnLocation = Instigator.Location + vect(0,0,1) * FireBallSpawnOffsetZ;
	    SpawnRotation = Rotator(DirectionUp);
	    DirectionUp = Vect(0,0,1);
	    Direction = VRandCone( DirectionUp, FireBallHalfCone * DegToRad ); //aim upwards in cone

    	FireBall = Spawn(class'KFProj_Explosive_Incinerator_FireBall', self,, SpawnLocation, SpawnRotation);
	    if( FireBall != none && !FireBall.bDeleteMe )
	    {
            FireBall.Instigator = Instigator;
            FireBall.InstigatorController = Instigator.Controller;
	        FireBall.Velocity = Direction * FireBallSpawnSpeed;
	    }
    }
}

// ****************************** Perk passive ******************************

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		if( Role == ROLE_Authority )
			SetTimer(SplashFireSpawnDelay, true, 'SpawnSplashFireProjectile');
	}
}

simulated state WeaponPuttingDown
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if( Role == ROLE_Authority )
			ClearTimer('SpawnSplashFireProjectile');
	}
}

simulated state WeaponAbortEquip
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		if( Role == ROLE_Authority )
			SetTimer(SplashFireSpawnDelay, true, 'SpawnSplashFireProjectile');
	}
}

function SpawnSplashFireProjectile()
{
    local KFProj_FlareGunSplash SplashFire;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    if( Role == ROLE_Authority )
    {
		SpawnLocation = Instigator.Location + vect(0,0,1) * SplashFireOffsetZ;
		SpawnRotation = Rotator(DirectionUp);
		DirectionUp = Vect(0,0,-1);
		Direction = VRandCone( DirectionUp, SplashFireHalfCone * DegToRad ); //aim downawrds in cone

		SplashFire = Spawn(class'KFProj_FlareGunSplash', self,, SpawnLocation, SpawnRotation);
		if( SplashFire != none && !SplashFire.bDeleteMe )
		{
		    SplashFire.Instigator = Instigator;
		    SplashFire.InstigatorController = Instigator.Controller;
		    SplashFire.Velocity = Direction * SplashFireSpawnSpeed;
		}
    }
}

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1 = true;
	if( CurrentWeaponUpgradeIndex >= 2 )
	{
		// CurrentUpgradeLevel = 1;
		DrawHudPassive2 = true;
	}
}

simulated function DrawHUD( HUD H, Canvas C )
{
    local Texture2D AbilityIcon, AbilityDescriptionImage, Passive1Icon, Passive2Icon;
    local float FillUpMeterBar;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
		return;

    // The Ability icon ( Heat Ring )
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Heat_Ring_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description ( Heat Ring )
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Heat_Ring_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	FillUpMeterBar = FMin(float(MinFillUpMeter) / float(MaxFillUpMeter), 100);
	// Black box behind timer bar
	C.SetDrawColor(0,0,0,140);
	C.SetPos(C.SizeX * 0.85, C.SizeY * 0.845);
	C.DrawRect(C.ClipY * 0.09, C.ClipY * 0.025);
	// Timer bar
	if( MinFillUpMeter > MaxFillUpMeter - 1 )
	    C.SetDrawColor(0,255,0,255);
	else if( MinFillUpMeter > MaxFillUpMeter - 5 )
	    C.SetDrawColor(255,255,0,255);
	else
	    C.SetDrawColor(255,0,0,255);
	C.SetPos(C.SizeX * 0.852, C.SizeY * 0.848);
	C.DrawRect(C.ClipY * 0.0825 * FillUpMeterBar, C.ClipY * 0.0175);

	if( DrawHudPassive1 )
	{
		// Passive ( Fire Shrapnel )
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Fire_Shrapnel_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}

	if( DrawHudPassive2 )
	{
		// Passive ( Napalm Canister )
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Napalm_Canister_Icon';
		C.SetPos(C.SizeX * 0.73f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive2Icon, C.ClipY/1350);
	}
}

// Partial Zedternal support (look bro it's cheat, you can just cheat i don't fucking care lmao)
exec function TZS()
{
    local KFPlayerController KFPC;

	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Bring out the HEAT !!!", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
}

// ****************************** Misc ******************************

static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage/*, DoTDamage*/;
	// local class<KFDamageType> DamageType;

	BaseDamage = default.InciProjectile.Damage;

	// DamageType = default.FlameSprayArchetype.MyDamageType;
	// if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
		// DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);

	// Return projectiles explosion damage
	return BaseDamage/* + DoTDamage*/;
}

defaultproperties
{
	Begin Object Class=PointLightComponent Name=HeatRingPointLight
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

	Begin Object Class=KFGameExplosion Name=HeatRing
		Damage=100
		DamageRadius=600
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_MolotovGrenade'

		MomentumTransferScale=0
		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=500.0
		ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_HeatRing_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Mid'

        // Dynamic Light
        ExploLight=HeatRingPointLight
        ExploLightStartFadeOutTime=0.4
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=KFCameraShake'FX_CameraShake_Arch.Grenades.Molotov'
		CamShakeInnerRadius=250
		CamShakeOuterRadius=400
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	HeatRingExplosionTemplate=HeatRing

    Begin Object Class=SkeletalMeshComponent Name=PickupThatCan
        SkeletalMesh=SkeletalMesh'Fass_MESH.NapalmCanister'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.NapalmCanister_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    NapalmCanisterMesh=PickupThatCan

	// CurrentUpgradeLevel=0
    // ProjectileClassByUpgrade(0)=class'KFProj_HighExplosive_Incinerator'
    // ProjectileClassByUpgrade(1)=class'KFProj_HighExplosive_IncineratorFreeze'

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=80

    // TimeBeforeMotionProjectileSpawn=2
	// MotionProjectileHalfCone=80
    // MotionProjectileSpeed=1200
    // MotionProjectileOffSet=60.f
	// SolarIgnitionAkEvent=AkEvent'WW_WEP_Lazer_Cutter.Play_WEP_LazerCutter_Beam_Charge_RampUP_3P'

	// Content
	PackageKey="Incinerator"
	FirstPersonMeshName="WEP_1P_Flamethrower_MESH.Wep_1stP_Flamethrower_Rig"
	FirstPersonAnimSetNames(0)="WEP_Incinerator_ARCH.Wep_1stP_Incinerator_anim"
	PickupMeshName="WEP_Incinerator_MESH.Wep_Incinerator_Pickup"
	AttachmentArchetypeName="WEP_Incinerator_ARCH.WEP_Incinerator_3P"
	MuzzleFlashTemplateName="WEP_Incinerator_ARCH.WEP_Incinerator_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

   	// Zooming/Position
	PlayerViewOffset=(X=3.0,Y=9,Z=-3)
	IronSightPosition=(X=3,Y=6,Z=-1)

	// Ammo
	MagazineCapacity[0]=50
	SpareAmmoCapacity[0]=325 //300
	InitialSpareMags[0]=2 //1
	AmmoPickupScale[0]=0.4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=150
	minRecoilPitch=115
	maxRecoilYaw=115
	minRecoilYaw=-115
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

    // Inventory
	InventorySize=7 //8
	GroupPriority=21 // funny number
	WeaponSelectTexture=Texture2D'WEP_Incinerator_MAT.UI_WeaponSelect_Incinerator'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Flamethrower'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring // WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_HighExplosive_Incinerator'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Fire_Incinerator'
	InstantHitDamage(DEFAULT_FIREMODE)=100
	FireInterval(DEFAULT_FIREMODE)=0.4 // 70 RPM
	Spread(DEFAULT_FIREMODE)=0.007
	AmmoCost(DEFAULT_FIREMODE)=5
	FireOffset=(X=30,Y=4.5,Z=-5)
	// MinAmmoConsumed=1

	SelfDamageReductionValue=0.08f;

	// ALT_FIREMODE
    // SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	// FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
    WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	// FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
    // WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile //EWFT_None
	// WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_HighExplosive_Incinerator'
	// InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_CenterfireMB464'
	// FireInterval(ALTFIRE_FIREMODE)=0.4 // 70 RPM
	// Spread(ALTFIRE_FIREMODE)=0.007
	// AmmoCost(ALTFIRE_FIREMODE)=5

	// Shield	
	// MagazineCapacity[1]=100
	// SpareAmmoCapacity[1]=0
	// bCanRefillSecondaryAmmo=false

	// FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	// WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_HighExplosive_Incinerator'
	// WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	// AmmoCost(ALTFIRE_FIREMODE)=0
	// FireInterval(ALTFIRE_FIREMODE)=0.01f
    // SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'

	// bFlightIsActive=false
	// bCanRechargeShield=true
	// ShieldConsumptionPerSecond=10.0f //3.0f
	// ShieldRechargePerSecond=8.0f //10.0f //15.0f
	// ShieldRechargeIncrement=0.0f;
	// ShieldConsumptionIncrement=0.0f

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Flamethrower'
	InstantHitDamage(BASH_FIREMODE)=28

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Husk_Cannon.Play_WEP_Husk_Cannon_1P_Fire', FirstPersonCue=AkEvent'WW_WEP_Husk_Cannon.Play_WEP_Husk_Cannon_1P_Fire')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	FireAnim=ShootLoop_End
	FireSightedAnims[0]=ShootLoop_End

 	// AI Warning
 	bWarnAIWhenFiring=true

   	AssociatedPerkClasses(0)=class'KFPerk_Firebug'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Weak_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Weight, Add=2)))

// ****************************** Flamethrower stuff ******************************

	Begin Object Name=PilotLight0
		Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
	End Object

	PilotLightSocketName=FXPilot1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight0
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
        DepthPriorityGroup=SDPG_Foreground
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(0)=SpineLight0

	Begin Object Class=KFParticleSystemComponent Name=SpineLight1
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
        DepthPriorityGroup=SDPG_Foreground
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(1)=SpineLight1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight2
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
        DepthPriorityGroup=SDPG_Foreground
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(2)=SpineLight2

	Begin Object Class=KFParticleSystemComponent Name=SpineLight3
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
        DepthPriorityGroup=SDPG_Foreground
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(3)=SpineLight3

    SpineLightSocketNames(0)=FXPilot2
    SpineLightSocketNames(1)=FXPilot3
    SpineLightSocketNames(2)=FXPilot4
    SpineLightSocketNames(3)=FXPilot5

	PilotLightPlayEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_PilotLight_Loop'
	PilotLightStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_PilotLight_Loop'

	// Muzzle Flash point light
	// want this light to illuminate characters only, so Marcus gets the glow
    Begin Object Class=PointLightComponent Name=PilotPointLight0
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=0.25f
		FalloffExponent=4.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

    Begin Object Class=PointLightComponent Name=PilotPointLight1
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=3.f
		FalloffExponent=8.f
		Radius=32.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	PilotLights(0)=(Light=PilotPointLight0,FlickerIntensity=1.5f,FlickerInterpSpeed=0.5f,LightAttachBone=FXPilot1)
	PilotLights(1)=(Light=PilotPointLight1,FlickerIntensity=4.f,FlickerInterpSpeed=3.f,LightAttachBone=FXPilot3)

	SuperSecretMessageChance=0.01
}