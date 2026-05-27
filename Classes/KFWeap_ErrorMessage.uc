class KFWeap_ErrorMessage extends KFWeap_RifleBase
	config(Fass);

// ****************************** Missile Tracer ******************************
var bool bLockOnActive;
var bool DrawTargetingHUD;
var KFPawn TargetPawn;

var Texture2D LockedOnIcon;
var() config LinearColor LockedIconColor;
var() config Color CrosshairColorNeutral, CrosshairColorFriendly, CrosshairColorLocked, CrosshairColorEmpty;

var KFProj_MicroRocket_ErrorMessage Rocket;
var() config float MicroRocketChance;
var() config int MicroRocketSpawnOffsetZ;
var() config int MicroRocketSpawnSpeed;
var() config int HalfConeAngle;
var WeaponFireSndInfo MicroRocketSound;

var() config float LockOnDisatance;
var() config float MaxTargetAngle;
var transient float CosTargetAngle;

// ****************************** Perk passive ******************************
var() config float TremorsExplosionChance;

// ****************************** Return Chamber ******************************
var bool DrawHudPassive1;
var() config float AmmoChance;
var AkEvent AmmoGetSound;

// ****************************** Reload Master ******************************
var bool DrawHudPassive2;
var() config float ReloadAnimRateModifier, ReloadAnimRateModifierElite;

// ****************************** Satellite ******************************
var bool DrawHudPassive3;
var bool SpawnSatellite;
var() config float SatelliteChance;
var AkEvent SatelliteSpawnSound;

// ****************************** Misc ******************************
var float SuperSecretMessageChance;

// Custom font for texts
var Font FuroreFont;

/*replication
{
	// Bible fucking length rep wtf
	if( bNetDirty && Role == ROLE_Authority )
		TremorsExplosionChance,
		ReloadAnimRateModifier,
		ReloadAnimRateModifierElite, SatelliteChance,
		MicroRocketChance, MicroRocketSpawnOffsetZ,
		MicroRocketSpawnSpeed,
		HalfConeAngle,
		LockOnDisatance,
		MaxTargetAngle;
}*/

// Called immediately after gameplay begins
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	CosTargetAngle = Cos(MaxTargetAngle * DegToRad);

	// if( Role == ROLE_Authority )

	FuroreFont = Font(DynamicLoadObject("Fass_MAT.Fass_Font", class'Font'));
}

// ****************************** Return Chamber / Satellite ******************************

// Handles pawn penetration
simulated function bool PassThroughDamage(Actor HitActor)
{
	super.PassThroughDamage(HitActor);

	// if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
	{
	    if( KFPawn_Monster(HitActor) != none && KFPawn_Monster(HitActor).IsAliveAndWell() && CurrentFireMode == DEFAULT_FIREMODE )
	    {
	    	// Return Chamber
			if( DrawHudPassive1 )
			{
				if( FRand() <= AmmoChance )
				{
					AmmoCount[0]++;
					PlaySoundBase(AmmoGetSound, true, true);
					PlaySoundBase(AmmoGetSound, true, true);
				}
			}

			// Satellite
			if( DrawHudPassive3 )
			{
				if( FRand() <= SatelliteChance )
				{
					SpawnSatellite = true;
					PlaySoundBase(SatelliteSpawnSound, true, true);
					PlaySoundBase(SatelliteSpawnSound, true, true);
				}
			}
	    }
	}

	return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')
		|| HitActor.IsA('InteractiveFoliageActor') || HitActor.IsA('KFWaterMeshActor')));
}

// ****************************** Missile Tracer ******************************

simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo(FireModeNum);

	// if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
	{
		if( FindTarget(TargetPawn) && FRand() <= MicroRocketChance )
		{
			SpawnMicroRocket();
			KFPawn(Instigator).SetWeaponAmbientSound(MicroRocketSound.DefaultCue, MicroRocketSound.FirstPersonCue);
		}
	}
}

function SpawnMicroRocket()
{
    // local KFProj_MicroRocket_ErrorMessage Rocket;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;

    if( Role == ROLE_Authority )
    {
    	FindTarget(TargetPawn);

		SpawnLocation = Location;
		SpawnLocation.Z += MicroRocketSpawnOffsetZ;
		SpawnRotation = Rotator(Direction);
		DirectionUp = vect(0,0,1);
		Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone
		// Direction += VRand(); // aims anywere

	    Rocket = Spawn(class'KFProj_MicroRocket_ErrorMessage', self,, SpawnLocation, SpawnRotation);
	    if( Rocket != none && !Rocket.bDeleteMe )
	    {
			Rocket.Instigator = Instigator;
	        Rocket.Velocity = Direction * MicroRocketSpawnSpeed;
	        Rocket.SetLockedTarget(TargetPawn);	        
	    }
    }
}

// Given an potential target TA determine if we can lock on to it.  By default only allow locking onto pawns.
simulated function bool CanLockOnTo(Actor TA)
{
	Local KFPawn PawnTarget;

	PawnTarget = KFPawn(TA);

	// Make sure the pawn is legit, isn't dead, is cloaked and isn't already at full health
	if( (TA == None) || !TA.bProjTarget || TA.bDeleteMe || (PawnTarget == None) || (TA == Instigator) || PawnTarget.bIsCloaking || (PawnTarget.Health <= 0) || !HasAmmo(DEFAULT_FIREMODE) )
		return false;

	// Make sure and only lock onto players on the same team
	return !WorldInfo.GRI.OnSameTeam(Instigator, TA);
}

// Finds a new lock on target
simulated function bool FindTarget( out KFPawn RecentlyLocked )
{
	local KFPawn P, BestTargetLock;
	local byte TeamNum;
	local vector AimStart, AimDir, TargetLoc, Projection, DirToPawn, LinePoint;
	local Actor HitActor;
	local float PointDistSQ, Score, BestScore, TargetSizeSQ;

	TeamNum   = Instigator.GetTeamNum();
	AimStart  = GetSafeStartTraceLocation();
	AimDir    = vector( GetAdjustedAim(AimStart) );
	BestScore = 0.f;

	// foreach WorldInfo.AllPawns( class'KFPawn', P )
	foreach VisibleCollidingActors(class'KFPawn', P, LockOnDisatance) // Range limit
	{
		if( !CanLockOnTo(P) )
			continue;

		// Want alive pawns and ones we already don't have locked
		if( P != none && P.IsAliveAndWell() && P.GetTeamNum() != TeamNum )
		{
			TargetLoc  = GetLockedTargetLoc( P );
			Projection = TargetLoc - AimStart;
			DirToPawn  = Normal( Projection );

			// Filter out pawns too far from center
			if( AimDir dot DirToPawn < CosTargetAngle )
				continue;

			// Check to make sure target isn't too far from center
            PointDistToLine( TargetLoc, AimDir, AimStart, LinePoint );
            PointDistSQ = VSizeSQ( LinePoint - P.Location );

			TargetSizeSQ = P.GetCollisionRadius() * 2.f;
			TargetSizeSQ *= TargetSizeSQ;

            // Make sure it's not obstructed
            HitActor = class'KFAIController'.static.ActorBlockTest(self, TargetLoc, AimStart,, true, true);
            if( HitActor != none && HitActor != P )
            	continue;

            // Distance from target has much more impact on target selection score
            Score = VSizeSQ( Projection ) + PointDistSQ;
            if( BestScore == 0.f || Score < BestScore )
            {
            	BestTargetLock = P;
            	BestScore = Score;
            }
		}
	}

	if( BestTargetLock != none )
	{
		RecentlyLocked = BestTargetLock;

		return true;
	}

	RecentlyLocked = none;

	return false;
}

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		// local KFPlayerController KFPC;
		// local KFPawn_Human Player;

		super.BeginState(PreviousStateName);

		// KFPC = KFPlayerController(Instigator.Controller);
		// Player = KFPawn_Human(Instigator);
	    // if( Player != none && Player.Health < 50 )
	    // {
		// 	KFPC.bPerkEffectIsActive = true;
		// 	KFPC.GameplayPostProcessEffectMIC.SetScalarParameterValue(KFPC.EffectZedTimeSepiaParamName, 1.f);
		// 	KFPC.GameplayPostProcessEffects.bShowInGame = true;
	    // }

		// Re-enables target lock-on
		bLockOnActive = true; // enable HUD functionality
		DrawTargetingHUD = true; // enable HUD visuals
	}
}

simulated state WeaponPuttingDown
{
	simulated function BeginState(name PreviousStateName)
	{
		// local KFPlayerController KFPC;

		Super.BeginState(PreviousStateName);

		// KFPC = KFPlayerController(Instigator.Controller);
		// if( KFPC != none )
		// {
		// 	KFPC.bPerkEffectIsActive = false;
		// 	KFPC.GameplayPostProcessEffectMIC.SetScalarParameterValue(KFPC.EffectZedTimeSepiaParamName, 0.f);
		// 	KFPC.GameplayPostProcessEffects.bShowInGame = false;
		// }

		// Disables target lock-on
		bLockOnActive = false; // disable HUD functionality
		DrawTargetingHUD = false; // disable HUD visuals
	}
}

simulated function DetachWeapon()
{
	// Failsafe (idk lol)
	// if( WorldInfo.NetMode != NM_DedicatedServer )
    // if( Role == ROLE_Authority )
	// {
		bLockOnActive 	 = false;
		DrawTargetingHUD = false;
	// }

    Super.DetachWeapon();
}

// Adjusts our destination target impact location
static simulated function vector GetLockedTargetLoc( Pawn P )
{
	// Go for the chest, but just in case we don't have something with a chest bone we'll use collision and eyeheight settings
	if( P.Mesh.SkeletalMesh != none && P.Mesh.bAnimTreeInitialised )
	{
		if( P.Mesh.MatchRefBone('Spine2') != INDEX_NONE )
			return P.Mesh.GetBoneLocation( 'Spine2' );
		else if( P.Mesh.MatchRefBone('Spine1') != INDEX_NONE )
			return P.Mesh.GetBoneLocation( 'Spine1' );
		
		return P.Mesh.GetPosition() + ((P.CylinderComponent.CollisionHeight + (P.BaseEyeHeight  * 0.5f)) * vect(0,0,1));
	}

	// General chest area, fallback
	return P.Location + ( vect(0,0,1) * P.BaseEyeHeight * 0.75f );	
}

// ****************************** Perk passive ******************************

simulated function ANIMNOTIFY_SpawnTremorsExplosionOnReload()
{
	local KFPawn KFP;
	local KFWeapAttach_ErrorMessage KFWeapAttach;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
		if( FRand() <= TremorsExplosionChance )
		{
			KFP = KFPawn_Human(Instigator); //Owner
			KFWeapAttach = KFWeapAttach_ErrorMessage(KFP.WeaponAttachment);
			if( KFWeapAttach != none )
				KFWeapAttach.PlayTremorsExplosion(KFP);
		}
	}

/*
	local KFPawn_Human P;
	
	if( bUseAltFireMode )
	{
		if( FRand() <= TremorsExplosionChance )
		{
			KFP = KFPawn_Human(Instigator); //Owner
			KFWeapAttach = KFWeapAttach_ErrorMessage(KFP.WeaponAttachment);
			if( KFWeapAttach != none )
				KFWeapAttach.PlayTremorsExplosion(KFP);
		}
	}
	// else
	// {
	// }
	
	P = KFPawn_Human(Instigator);
	if( P != none )
	{
		P.SetUsingAltFireMode( bUseAltFireMode, true );
		P.bNetDirty = true;
	}
*/
}

// ****************************** Reload Master ******************************

simulated function float GetReloadRateScale()
{
	local float ModdedReloadSpeed;

	ModdedReloadSpeed = UseTacticalReload() ? ReloadAnimRateModifierElite : ReloadAnimRateModifier;

	// Modded reload speed that replaces base (Rate = GetUpgradedReloadRateScale)
	if( DrawHudPassive2 )
		return super.GetReloadRateScale() * ModdedReloadSpeed;
	else
		return super.GetReloadRateScale();
}

// ****************************** HUD ******************************

// We need to update our locked targets every frame and make sure they're within view and not dead
simulated event Tick( float DeltaTime )
{
	// Trace
	local vector TraceHitLocation, TraceHitNormal, TraceStart, TraceEnd;
	local rotator TraceAimDir;
	local float TraceDist;
	// local Actor TraceHitActor;
	// local TraceHitInfo HitInfo;
	local float FreeAimSeekStrength;
	local vector FreeAimSDirToTarget;

	super.Tick( DeltaTime );

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1 = true;
	if( CurrentWeaponUpgradeIndex >= 2 )
		DrawHudPassive2 = true;
	if( CurrentWeaponUpgradeIndex >= 3 )
		DrawHudPassive3 = true;

	if( bLockOnActive )
	{
    	if( Instigator != none && Instigator.IsLocallyControlled() )
    	{
	    	if( TargetPawn != none && TargetPawn.IsAliveAndWell() )
		        FindTarget(TargetPawn);

			// Weapon trace
			TraceDist = 1500000;
			TraceStart = GetSafeStartTraceLocation();
			TraceAimDir = GetAdjustedAim(TraceStart);
			TraceEnd = TraceStart + Vector(TraceAimDir) * TraceDist; // TraceAimDir
			/*TraceHitActor =*/ Trace( TraceHitLocation, TraceHitNormal, TraceEnd, TraceStart, true, vect(0,0,0), /*HitInfo*/, 1 ); //TRACEFLAG_Bullet
			if( Rocket != None )
			{
				// Laser guided rocket when target that was locked-on but killed by shot (otherwise rocket would just fly upwards, so this is better then nothing)
				FreeAimSeekStrength = 115000.0f;
				Rocket.Speed = VSize( Rocket.Velocity );
				FreeAimSDirToTarget = Normal( TraceHitLocation - Rocket.Location );
				Rocket.Velocity = Normal( Rocket.Velocity + (FreeAimSDirToTarget * (FreeAimSeekStrength * DeltaTime)) ) * Rocket.Speed;
			}
    	}
    }
}

simulated function DrawHUD( HUD H, Canvas C )
{
	local Texture2D AbilityIcon, AbilityDescriptionImage, Passive1Icon, Passive2Icon, Passive3Icon, CrosshairTexture, AmmoIcon;
    local float IconSize, IconScale;
	local int AmmoInt, MagInt;
	local float AmmoIntScale;
    local vector WorldPos, ScreenPos;

    // Trace
    local vector TraceHitLocation, TraceHitNormal, TraceStart, TraceEnd;
    local rotator TraceAimDir;
    local float TraceDist;
	local Actor	TraceHitActor;
	// local TraceHitInfo HitInfo;

    // local Texture2D HCIcon;
    local float AmmoPercentage, AmmoBarHeight, AmmoBarPosY;
    // local float HealerChargePercentage, HealerChargeHeight, HealerChargePosY;
    // local float HealthPercentage, HealthBarHeight, HealthBarPosY;
    // local float ArmorPercentage, ArmorBarHeight, ArmorBarY;

	// local Canvas Text, Passive1, Passive2, Passive3, Target, CrosshairCanvas/*, AmmoCounterCanvas, SliderBar*/;
	local KFPlayerController KFPC;
	local KFPawn_Human Player;
	local KFInventoryManager KFIM;

	// this is for adding another canvas texture
	// AmmoCounterCanvas = C;
	// SliderBar = C;

	Player = KFPawn_Human(Instigator);
	KFIM = KFInventoryManager(Instigator.InvManager);

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
        return;

	// The Ability icon ( Missile Tracer )
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Missile_Tracer_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description ( Missile Tracer )
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Missile_Tracer_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	if( DrawHudPassive1 )
	{	
		// Passive ( Return chamber )
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Return_Chamber_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}

	if( DrawHudPassive2 )
	{	
		// Passive ( Reload Master )
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Reload_Master_Icon';
		C.SetPos(C.SizeX * 0.73f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive2Icon, C.ClipY/1350);
	}

	if( DrawHudPassive3 )
	{	
		// Passive ( Satellite )
		Passive3Icon = Texture2D'Fass_MAT.Passive_Icons.Satellite_Icon';
		C.SetPos(C.SizeX * 0.675f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive3Icon, C.ClipY/1350);
	}

	// Targeting icon
	if( FindTarget(TargetPawn) )
	{
		// Project world pos to canvas
		WorldPos = GetLockedTargetLoc( TargetPawn );
		ScreenPos = C.Project( WorldPos ); // WorldToCanvas(Canvas, WorldPos);

		// calculate scale based on resolution and distance
		IconScale = FMin( float(C.SizeX) / 1024.f, 1.f );
		// Scale down up to 40 meters away, with a clamp at 20% size
		IconScale *= FClamp( 1.f - VSize(WorldPos - Instigator.Location) / 4000.f, 0.2f, 1.f );
		
		// Apply size scale
		IconSize = 125.f * IconScale;
		ScreenPos.X -= IconSize / 2.f;
		ScreenPos.Y -= IconSize / 2.f;

		// Off-screen check
		if( ScreenPos.X < 0 || ScreenPos.X > C.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > C.SizeY )
		    return;

		C.SetPos( ScreenPos.X, ScreenPos.Y );
		C.DrawTile( LockedOnIcon, IconSize, IconSize, 0, 0, LockedOnIcon.SizeX, LockedOnIcon.SizeY, LockedIconColor );
	}

   	if( bLockOnActive )
   	{
   		if( DrawTargetingHUD )
   		{
   			// ******* Crosshair *******

			C.Font = FuroreFont;

	   		// Weapon trace
	   		TraceDist = 1500000;
	    	TraceStart = GetSafeStartTraceLocation();
			TraceAimDir = GetAdjustedAim(TraceStart);
	    	TraceEnd = TraceStart + Vector(TraceAimDir) * TraceDist; // TraceAimDir
	    	TraceHitActor = Trace( TraceHitLocation, TraceHitNormal, TraceEnd, TraceStart, true, vect(0,0,0), /*HitInfo*/, 1 ); //TRACEFLAG_Bullet

			C.SetPos( C.SizeX * 0.2865, C.SizeY * 0.12 );
			if( KFPawn_Human(TraceHitActor) != none && KFPawn_Human(TraceHitActor).IsAliveAndWell() )
				C.DrawColor = CrosshairColorFriendly;
			else if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			CrosshairTexture = Texture2D'Fass_MAT.Fass_Targeting_HUD';
			C.DrawTexture( CrosshairTexture, C.ClipY/1350 );

			// ******* Health/Armor/Healer charge counters *******

			C.SetPos(C.SizeX * 0.25, C.SizeY * 0.6);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawText("AP:" @ int(Player.Armor),, C.ClipY/1200, C.ClipY/1200);
			C.SetPos(C.SizeX * 0.25, C.SizeY * 0.621);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawText("HP:" @ Instigator.Health,, C.ClipY/1200, C.ClipY/1200);
			C.SetPos(C.SizeX * 0.25, C.SizeY * 0.645);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawText("HC:" @ KFIM.HealerWeapon.AmmoCount[0],, C.ClipY/1200, C.ClipY/1200);

			// ******* Magazine and spare ammo counters *******

			AmmoInt = AmmoCount[0];
			MagInt = SpareAmmoCount[0];
			AmmoIntScale = C.ClipY/1200;
			
			// Current magazine counter
			C.SetPos(C.SizeX * 0.69, C.SizeY * 0.615);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawText(AmmoInt,, AmmoIntScale, AmmoIntScale);

			// Spare ammo counter
			C.SetPos(C.SizeX * 0.69, C.SizeY * 0.645);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawText(MagInt,, AmmoIntScale, AmmoIntScale);

			// Ammo counter icon
			AmmoIcon = Texture2D'UI_Menus.UpgradeV2TraderMenu_SWF_I10B';
			C.SetPos(C.SizeX * 0.69, C.SizeY * 0.587);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawTexture(AmmoIcon, C.ClipY/8600);

			// ******* Ammo slider *******

			AmmoPercentage = FMin(float(AmmoCount[0]) / float(MagazineCapacity[0]), 100);
			// Ammo bar black box
			C.SetPos(C.SizeX * 0.69, C.SizeY * 0.325);
			C.SetDrawColor(0,0,0,68);
			C.DrawRect(C.ClipY * 0.02, C.ClipY * 0.255);
			// Ammo bar
	    	AmmoBarHeight = C.ClipY * 0.244; //loooong
	    	AmmoBarPosY = (C.SizeY * 0.33) + (AmmoBarHeight * (1.0 - AmmoPercentage)); //start
			C.SetPos(C.SizeX * 0.692, AmmoBarPosY);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawRect(C.ClipY * 0.0135, AmmoBarHeight * AmmoPercentage);


			// ************** ammo sliders and counters **************
			// health and armor fmin or atan don't work no good leimao
	/*
			// ******* Ammo counters *******
			// Ammo Magazine settings
			AmmoInt = AmmoCount[0];
			MagInt = SpareAmmoCount[0];
			AmmoIntScale = C.ClipY/1200;

			// Current magazine counter
			AmmoCounterCanvas.Font = FuroreFont;
			AmmoCounterCanvas.SetPos(C.SizeX * 0.69, C.SizeY * 0.615);
			if( FindTarget(TargetPawn) )
				AmmoCounterCanvas.SetDrawColor(255,0,0,255);
			else if( AmmoCount[0] == 0 )
				AmmoCounterCanvas.SetDrawColor(255,0,0,255);
			else
				AmmoCounterCanvas.SetDrawColor(255,255,255,255);
			AmmoCounterCanvas.DrawText(AmmoInt,, AmmoIntScale, AmmoIntScale);
			// Spare ammo counter
			AmmoCounterCanvas.SetPos(C.SizeX * 0.69, C.SizeY * 0.645);
			if( FindTarget(TargetPawn) )
				AmmoCounterCanvas.SetDrawColor(255,0,0,255);
			else if( AmmoCount[0] == 0 )
				SliderBar.SetDrawColor(255,0,0,255);
			else
				AmmoCounterCanvas.SetDrawColor(255,255,255,255);
			AmmoCounterCanvas.DrawText(MagInt,, AmmoIntScale, AmmoIntScale);
			// Ammo counter icon
			AmmoIcon = Texture2D'UI_Menus.UpgradeV2TraderMenu_SWF_I10B';
			AmmoCounterCanvas.SetPos(C.SizeX * 0.69, C.SizeY * 0.59);
			AmmoCounterCanvas.DrawTexture(AmmoIcon, C.ClipY/8600);

			// ******* Ammo slider *******
			AmmoPercentage = FMin(float(AmmoCount[0]) / float(MagazineCapacity[0]), 100);

			// Ammo bar black box
			SliderBar.SetPos(C.SizeX * 0.69, C.SizeY * 0.325);
			SliderBar.SetDrawColor(0,0,0,68);
			SliderBar.DrawRect(C.ClipY * 0.02, C.ClipY * 0.255);
			// Ammo bar
	    	AmmoBarHeight = C.ClipY * 0.244; //loooong
	    	AmmoBarPosY = (C.SizeY * 0.33) + (AmmoBarHeight * (1.0 - AmmoPercentage)); //start
			SliderBar.SetPos(C.SizeX * 0.692, AmmoBarPosY);
			if( FindTarget(TargetPawn) )
				SliderBar.SetDrawColor(255,0,0,255);
			else if( AmmoCount[0] == 0 )
				SliderBar.SetDrawColor(255,0,0,255);
			else
				SliderBar.SetDrawColor(255,255,255,255);
			SliderBar.DrawRect(C.ClipY * 0.0135, AmmoBarHeight * AmmoPercentage);

			// ******* Healer charge slider *******
			HealerChargePercentage = FMin(float(KFIM.HealerWeapon.AmmoCount[0]) / float(KFIM.HealerWeapon.MagazineCapacity[0]), 100);

			// Healer charge black box
			SliderBar.SetPos(C.SizeX * 0.295, C.SizeY * 0.325);
			SliderBar.SetDrawColor(0,0,0,68);
			SliderBar.DrawRect(C.ClipY * 0.02, C.ClipY * 0.28);
			// Healer charge bar
	    	HealerChargeHeight = C.ClipY * 0.27; //loooong
	    	HealerChargePosY = (C.SizeY * 0.33) + (HealerChargeHeight * (1.0 - HealerChargePercentage)); //start
			SliderBar.SetPos(C.SizeX * 0.297, HealerChargePosY);
			SliderBar.SetDrawColor(255,255,255,255);
			SliderBar.DrawRect(C.ClipY * 0.0135, HealerChargeHeight * HealerChargePercentage);
			// Healer charge icon
			SliderBar.SetPos(C.SizeX * 0.285, C.SizeY * 0.615);
			SliderBar.SetDrawColor(255,255,255,255);
			HCIcon = Texture2D'UI_HUD.InGameHUD_SWF_I214';
			SliderBar.DrawTexture(HCIcon, C.ClipY/9400);

			// og values
	    	// HealerChargeWidth = (C.SizeY * 0.358) + (HealerChargeHeight * (1.0 - HealerChargePercentage));
			// SliderBar.SetPos(C.SizeX * 0.3, C.SizeY * 0.35);
			// SliderBar.DrawRect(C.ClipY * 0.01, C.ClipY * 0.3);

			// ******* Health slider *******
			HealthPercentage = FMin(float(Instigator.Health) / float(Instigator.HealthMax), 100);
			// HealthPercentage = ATan(float(Instigator.Health) / float(Instigator.HealthMax));

			// Health black box
			SliderBar.SetPos(C.SizeX * 0.2765, C.SizeY * 0.325);
			SliderBar.SetDrawColor(0,0,0,68);
			SliderBar.DrawRect(C.ClipY * 0.02, C.ClipY * 0.28);
			// Health charge bar
	    	HealthBarHeight = C.ClipY * 0.27; //loooong
	    	HealthBarPosY = (C.SizeY * 0.33) + (HealthBarHeight * (1.0 - HealthPercentage)); //start
			SliderBar.SetPos(C.SizeX * 0.278, HealthBarPosY);
			SliderBar.SetDrawColor(255,0,0,255);
			SliderBar.DrawRect(C.ClipY * 0.014, HealthBarHeight * HealthPercentage);
			// Health text
			SliderBar.SetPos(C.SizeX * 0.275, C.SizeY * 0.615);
			SliderBar.SetDrawColor(255,255,255,255);
			SliderBar.DrawText("HP",, C.ClipY/1500, C.ClipY/1500);

			// ******* Armor slider *******
			if( Player.Armor > 1 )
			{
				ArmorPercentage = FMin(float(Player.Armor) / float(Player.MaxArmor), 100);
				// ArmorPercentage = ATan(float(Player.Armor) / float(Player.MaxArmor));

				// Armor black box
				SliderBar.SetPos(C.SizeX * 0.2565, C.SizeY * 0.325);
				SliderBar.SetDrawColor(0,0,0,68);
				SliderBar.DrawRect(C.ClipY * 0.02, C.ClipY * 0.28);
				// Armor bar
		    	ArmorBarHeight = C.ClipY * 0.27; //loooong
		    	ArmorBarY = (C.SizeY * 0.33) + (ArmorBarHeight * (1.0 - ArmorPercentage)); //start
				SliderBar.SetPos(C.SizeX * 0.2585, ArmorBarY);
				SliderBar.SetDrawColor(255,185,0,255);
				SliderBar.DrawRect(C.ClipY * 0.014, ArmorBarHeight * ArmorPercentage);
				// Armor text
				SliderBar.SetPos(C.SizeX * 0.254, C.SizeY * 0.615);
				SliderBar.SetDrawColor(255,255,255,255);
				SliderBar.DrawText("AP",, C.ClipY/1500, C.ClipY/1500);	
			}
			else
				return;
*/
   		}
	}
}

// Partial Zedternal support
exec function TZS()
{
	local KFPlayerController KFPC;
    
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Check your logs...", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
    DrawHudPassive3 = !DrawHudPassive3;
}

// Toggleble UI (Setbind H ToggleWeaponHUD)
exec function ToggleWeaponHUD()
{
    DrawTargetingHUD = !DrawTargetingHUD;
}

// ****************************** HUD color change in-game ******************************

exec function ChangeCrosshairColorNeutral(float Red, float Green, float Blue)
{
	CrosshairColorNeutral.R = Red;
	CrosshairColorNeutral.G = Green;
	CrosshairColorNeutral.B = Blue;
	SaveConfig();
}
exec function ChangeCrosshairColorFriendly(float Red, float Green, float Blue)
{
	CrosshairColorFriendly.R = Red;
	CrosshairColorFriendly.G = Green;
	CrosshairColorFriendly.B = Blue;
	SaveConfig();
}
exec function ChangeCrosshairColorLocked(float Red, float Green, float Blue)
{
	CrosshairColorLocked.R = Red;
	CrosshairColorLocked.G = Green;
	CrosshairColorLocked.B = Blue;
	SaveConfig();
}
exec function ChangeLockedIconColor(float Red, float Green, float Blue)
{
	LockedIconColor.R = Red;
	LockedIconColor.G = Green;
	LockedIconColor.B = Blue;
	SaveConfig();
}
exec function ChangeCrosshairColorEmpty(float Red, float Green, float Blue)
{
	CrosshairColorEmpty.R = Red;
	CrosshairColorEmpty.G = Green;
	CrosshairColorEmpty.B = Blue;
	SaveConfig();
}

// ****************************** Misc ******************************

// Overriden to use instant hit vfx.Basically, calculate the hit location so vfx can play
simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local vector DirA, DirB;
	local Quat Q;
	local class<KFProjectile> MyProjectileClass;

    MyProjectileClass = GetKFProjectileClass();

	StartTrace = GetSafeStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));

	RealStartLoc = GetPhysicalFireStartLoc(AimDir);

	EndTrace = StartTrace + AimDir * GetTraceRange();
	TestImpact = CalcWeaponFire( StartTrace, EndTrace );
	
	if( Instigator != None )
		Instigator.SetFlashLocation( Self, CurrentFireMode, TestImpact.HitLocation );

	if( Role == ROLE_Authority || (MyProjectileClass.default.bUseClientSideHitDetection
        && MyProjectileClass.default.bNoReplicationToInstigator && Instigator != none
        && Instigator.IsLocallyControlled()) )
	{
		if( StartTrace != RealStartLoc )
		{	
            DirB = AimDir;

			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);

    		DirA = AimDir;

    		if( (DirA dot DirB) < MaxAimAdjust_Cos )
    		{
    			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), MaxAimAdjust_Angle);
    			AimDir = QuatRotateVector(Q,DirB);
    		}
		}

		return SpawnAllProjectiles(MyProjectileClass, RealStartLoc, AimDir);
	}

	return None;
}

defaultproperties
{
	// Missile Tracer
	// LockOnDisatance=3000 // 30 meters
	// MaxTargetAngle=30
	// MicroRocketChance=0.20f
	// MicroRocketSpawnOffsetZ=55
	// MicroRocketSpawnSpeed=3500 //4000
    LockedOnIcon=Texture2D'Fass_MAT.Wep_1stP_Fass_Target' // Fass_MAT.MK_Target_Icon
    // LockedIconColor=(R=1.f,G=0.f,B=0.f,A=0.8f)
	MicroRocketSound=(DefaultCue=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Fire_1P')
	// Missile Tracer Passive
	// TremorsExplosionChance=0.08f

	// Return Chamber
	// AmmoChance=0.12f
	AmmoGetSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Mag_Out'

	// Reload Master
	// ReloadAnimRateModifier=1.0f
	// ReloadAnimRateModifierElite=1.0f

	// Satellite
	SpawnSatellite=false
	// SatelliteChance=0.08f
	SatelliteSpawnSound=AkEvent'WW_UI_Menu.Play_AAR_PERSONALBEST_ITEM_TEXT'
	
	// Inventory / Grouping
	InventorySize=5
	GroupPriority=21 // funny number
	WeaponSelectTexture=Texture2D'WEP_ErrorMessage_MAT.UI_WeaponSelect_ErrorMessage'
   	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

    // FOV
    MeshFOV=75
	MeshIronSightFOV=40
    PlayerIronSightFOV=65

	// Content
	PackageKey="ErrorMessage"
	FirstPersonMeshName="WEP_ErrorMessage_MESH.Wep_1stP_ErrorMessage_Rig"
	FirstPersonAnimSetNames(0)="WEP_ErrorMessage_ARCH.Wep_1stP_ErrorMessage_Anim"
	PickupMeshName="WEP_ErrorMessage_MESH.Wep_ErrorMessage_Pickup"
	AttachmentArchetypeName="WEP_ErrorMessage_ARCH.WEP_ErrorMessage_3P"
	MuzzleFlashTemplateName="WEP_ErrorMessage_ARCH.Wep_ErrorMessage_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

/*
	// Particle system
	Begin Object Class=KFParticleSystemComponent Name=BasePSC0
		TickGroup=TG_PostUpdateWork
	End Object
	ParticlePSC=BasePSC0
	ParticleFXTemplate=ParticleSystem'Fass_EMIT.FX_Targeting_Laser'
	ParticleEffectSocket=LaserPointer
*/

	// Ammo
	MagazineCapacity[0]=10
	SpareAmmoCapacity[0]=70
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=false

	// Zooming/Position
	PlayerViewOffset=(X=11.0,Y=8,Z=-2) //x7
	IronSightPosition=(X=10,Y=0,Z=0) //x0

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=500
	minRecoilPitch=400
	maxRecoilYaw=150
	minRecoilYaw=-150
	RecoilRate=0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1250
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.6
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile //EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_ErrorMessage'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_CenterfireMB464'
	InstantHitDamage(DEFAULT_FIREMODE)=110 //165
	FireInterval(DEFAULT_FIREMODE)=0.4 //0.45
	Spread(DEFAULT_FIREMODE)=0.007
	PenetrationPower(DEFAULT_FIREMODE)=1.5
	FireOffset=(X=25,Y=3.0,Z=-2.5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_CenterfireMB464'
	InstantHitDamage(BASH_FIREMODE)=25

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_Centerfire_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_Centerfire_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Handling_DryFire'
	EjectedShellForegroundDuration=1.5f

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty=(RW_Hammer)
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false
	bHasLaserSight=true
	LaserSightTemplate=KFLaserSightAttachment'FX_LaserSight_ARCH.LaserSight_WithAttachment_1P'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.45f), (Stat=EWUS_Weight, Add=3)))

	SuperSecretMessageChance=0.01
}