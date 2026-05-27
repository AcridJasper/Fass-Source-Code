class KFWeap_EarthSplitter extends KFWeap_SMGBase
	config(Fass);

// ****************************** Crystal Spawn ******************************
var bool DrawHudPassive1;
var() config float CrystalSpawnOffsetZ;

// var int BonusDamage;

// ****************************** Stunner ******************************
var bool DrawHudPassive2;
var() config float StunExplosionChance, StunExplosionDamage, StunExplosionRadius, StunExplosionOffsetZ;
var class<KFExplosionActor> ExplosionActorClass;
var() KFGameExplosion ExplosionTemplate;

// var transient KFParticleSystemComponent ParticlePSC;
// var const ParticleSystem ParticleTemplate;
// var name ParticleSocket;

// ****************************** Target lock-on ******************************
// Lock on functions
var bool bLockOnActive;
var bool DrawTargetingHUD;
var KFPawn TargetPawn;

var Texture2D LockedOnIcon;
var() config LinearColor LockedIconColor;
var(CrosshairColors) config Color CrosshairColorNeutral, CrosshairColorLocked, CrosshairColorEmpty;
var() config float LockOnDisatance;
var() config float MaxTargetAngle;
var transient float CosTargetAngle;

// ****************************** Plasma grenade (Perk passive) ******************************
const NadeThrowAnim = 'Nade_Throw';
// Holds an offest for spawning nades
var(Positioning) vector	NadeFireOffset;

// How many Alt ammo to recharge per second
var float AltFullRechargeSeconds;
var transient float AltRechargePerSecond;
var transient float AltIncrement;
var repnotify byte AltAmmo;

// ****************************** Misc ******************************
// var bool bApplyVel;
// var float ApplyMomentum;
var Font FassFont;
var() config float SelfDamageReductionValue;
var float SuperSecretMessageChance;

// ****************************** Plasma grenade ******************************

replication
{
	if( bNetDirty && Role == ROLE_Authority )
		AltAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == nameof(AltAmmo) )
		AmmoCount[ALTFIRE_FIREMODE] = AltAmmo;
	else
		Super.ReplicatedEvent(VarName);
}

// Called immediately before gameplay begins
simulated event PreBeginPlay()
{
	super.PreBeginPlay();

	// Start ammo regen
	StartAltRecharge();

	// if( Role == ROLE_Authority )
	FassFont = Font(DynamicLoadObject("Fass_MAT.Fass_Font", class'Font'));
}

// Called immediately after gameplay begins
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	CosTargetAngle = Cos(MaxTargetAngle * DegToRad);
}

// ****************************** Plasma grenade ******************************

function StartAltRecharge()
{
	// local KFPerk InstigatorPerk;
	local float UsedAltRechargeTime;

	// begin ammo recharge on server
	if( Role == ROLE_Authority )
	{
		UsedAltRechargeTime = AltFullRechargeSeconds;
	    AltRechargePerSecond = MagazineCapacity[ALTFIRE_FIREMODE] / UsedAltRechargeTime;
		AltIncrement = 0;
	}
}

function RechargeAlt(float DeltaTime)
{
	if( Role == ROLE_Authority )
	{
		AltIncrement += AltRechargePerSecond * DeltaTime;
		if( AltIncrement >= 1.0 && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
		{
			AmmoCount[ALTFIRE_FIREMODE]++;
			AltIncrement -= 1.0;
			AltAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

// Overridden to call StartHealRecharge on server
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	super.GivenTo( thisPawn, bDoNotActivate );

	if( Role == ROLE_Authority && !thisPawn.IsLocallyControlled() )
		StartAltRecharge();
}

/*simulated event Tick( FLOAT DeltaTime )
{
	// Ammo regen
    if( AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
        RechargeAlt(DeltaTime);

	Super.Tick(DeltaTime);
}*/

// Alt doesn't count as ammo for purposes of inventory management (e.g. switching) 
simulated function bool HasAnyAmmo()
{
	return HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE);
}

simulated function bool ShouldAutoReload(byte FireModeNum)
{
	if( FireModeNum == ALTFIRE_FIREMODE )
		return false;
	
	return super.ShouldAutoReload(FireModeNum);
}

// Allow reloads for primary weapon to be interupted by firing secondary weapon
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	if( FireModeNum == ALTFIRE_FIREMODE )
		return true;
	
	return Super.CanOverrideMagReload(FireModeNum);
}

// Instead of a toggle, immediately fire alternate fire
simulated function AltFireMode()
{
	// LocalPlayer Only
	if( !Instigator.IsLocallyControlled() )
		return;

	StartFire(ALTFIRE_FIREMODE);
}

simulated state NadeThrowing extends WeaponSingleFiring
{
	simulated function bool TryPutDown() { return false; }
	simulated function bool AllowIronSights() { return false; }
	simulated function AltFireMode(){}
	simulated function AltFireModeRelease(){}

	// Overriden to not call FireAmmunition right at the start of the state
    simulated event BeginState( Name PreviousStateName )
	{
        local KFPerk InstigatorPerk;

		`LogInv("PreviousStateName:" @ PreviousStateName);

		// Force exit ironsights (affects IS toggle key bind)
		if( bUsingSights )
			SetIronSights(false);

        InstigatorPerk = GetPerk();
        if( InstigatorPerk != none )
            SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );

		ConsumeAmmo(CurrentFireMode);

		// set timer for spawning projectile and play animation
		PlayNadeThrowAnim();
		TimeWeaponFiring(CurrentFireMode);
		ClearPendingFire(CurrentFireMode);

		NotifyBeginState();
	}

 	// This function returns the world location for spawning the visual effects
 	// Overridden to use a special offset for throwing grenades
    simulated event vector GetMuzzleLoc()
    {
        local Rotator ViewRotation;

		if( Instigator != none )
		{
			ViewRotation = Instigator.GetViewRotation();

			// Add in the free-aim rotation
			if( KFPlayerController(Instigator.Controller) != None )
				ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;

			return Instigator.GetPawnViewLocation() + (NadeFireOffset >> ViewRotation);
		}

		return Location;
    }

	// thirdperson anim doesn't play instantly
	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();

		// Spawn projectile
		// (don't use FireAmmunition because that causes FireAnim to be played again)
		ProjectileFire();
		NotifyWeaponFired(CurrentFireMode);
	}
}

simulated function PlayNadeThrowAnim()
{
    local name WeaponFireAnimName;

    if( Instigator != none && Instigator.IsFirstPerson() )
    {
    	WeaponFireAnimName = GetNadeThrowAnim();
    	if( WeaponFireAnimName != '' )
    		PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName),,FireTweenTime);
    }
}

simulated function name GetNadeThrowAnim()
{
	return NadeThrowAnim;
}

// ************************** Crystal Spawn **************************

// Crystal Spawn
simulated function ANIMNOTIFY_SpawnCrystalOnReload()
{
    // if( Role == ROLE_Authority )
    // {
	// 	InstantHitDamage[DEFAULT_FIREMODE] += BonusDamage;
	// 	SetTimer(2.0, false, 'ResetReactiveReload');
    // }

	if( DrawHudPassive1 )
		SpawnCrystal();
}

// simulated function ResetReactiveReload()
// {
//     if( Role == ROLE_Authority )
// 		InstantHitDamage[DEFAULT_FIREMODE] -= BonusDamage;
// }

function SpawnCrystal()
{
    local KFProj_EarthSplitter_Crystal Crystal;
    local Vector SpawnLocation;

    if( Role == ROLE_Authority )
    {
		SpawnLocation = Instigator.Location + vect(0,0,1) * CrystalSpawnOffsetZ;

	    Crystal = Spawn(class'KFProj_EarthSplitter_Crystal',,, SpawnLocation, rotator(vect(0,1,0)));
	    if( Crystal != none )
	    {
			// if( Crystal.Instigator == none )
			Crystal.Instigator = Instigator;
			Crystal.InstigatorController = Instigator.Controller;
	    }

		// `log( GetItemName(string(Self))@"- Crystal has spawned" );
    }
}

// ****************************** Target Lock-on / Perks ******************************

// Spawn projectile is called once for each rocket fired. In burst mode it will cycle through targets until it runs out
simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProj_Bullet_EarthSplitter Projectile;

    if( CurrentFireMode == DEFAULT_FIREMODE )
	{
		FindTarget(TargetPawn);

		Projectile = KFProj_Bullet_EarthSplitter( super.SpawnProjectile( class<KFProjectile>(WeaponProjectiles[CurrentFireMode]), RealStartLoc, AimDir) );
		if( Projectile != none )
		{
			if( TargetPawn != none)
				Projectile.SetLockedTarget( TargetPawn );

			// if( DrawHudPassive2 )
				// Projectile.ImpactExplosionUpgrade = true;
		}

		return Projectile;
	}

   	return super.SpawnProjectile( KFProjClass, RealStartLoc, AimDir );
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

// ****************************** Playing ******************************

// Re-enables target lock-on
simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		// ActivatePSC(ParticlePSC, ParticleTemplate, ParticleSocket);

		bLockOnActive = true; // enable HUD functionality
		DrawTargetingHUD = true; // enable HUD visuals
	}
}

/*
simulated function ActivatePSC(out KFParticleSystemComponent OutPSC, ParticleSystem ParticleEffect, name SocketName)
{
	if( MySkelMesh != none )
	{
		MySkelMesh.AttachComponentToSocket(OutPSC, SocketName);
		OutPSC.SetFOV(MySkelMesh.FOV);
	}
	else
	{
		AttachComponent(OutPSC);
	}

	OutPSC.ActivateSystem();

	if( OutPSC != none )
	{
		OutPSC.SetTemplate(ParticleEffect);
		OutPSC.SetDepthPriorityGroup(SDPG_Foreground);
		// OutPSC.SetAbsolute(false, false, false);
	}
}

simulated event SetFOV( float NewFOV )
{
	super.SetFOV(NewFOV);

	if( ParticlePSC != none )
		ParticlePSC.SetFOV(NewFOV);
}

simulated state Inactive
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		if( ParticlePSC != none )
			ParticlePSC.DeactivateSystem();
	}
}
*/

// exec function Flying()
// {
// 	bApplyVel = !bApplyVel;
// }

// Disables target lock-on
simulated state WeaponPuttingDown
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		bLockOnActive = false; // disable HUD functionality
		DrawTargetingHUD = false; // disable HUD visuals
	}
}

simulated function DetachWeapon()
{
	// Failsafe (idk lol)
	bLockOnActive 	 = false;
	DrawTargetingHUD = false;

    Super.DetachWeapon();
}

// ****************************** Stunner ******************************

//Reduce the damage received from self attacks
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
    super.AdjustDamage(InDamage, DamageType, DamageCauser);
	
	if( DrawHudPassive2 )
	{
		if( KFPawn_Monster(DamageCauser) != none && FRand() <= StunExplosionChance )
			SpawnStunExplosion();
	}

	if( Instigator != none && DamageCauser.Instigator == Instigator )
		InDamage *= SelfDamageReductionValue;
}

function SpawnStunExplosion()
{
	local KFExplosionActor ExploActor;
    local Vector SpawnLocation;

	if( Role == ROLE_Authority )
	{
		SpawnLocation = Instigator.Location + vect(0,0,1) * StunExplosionOffsetZ;

		// Explode using the given template
		ExploActor = Spawn(ExplosionActorClass, self,, SpawnLocation, rotator(vect(0,0,1)),, true);
		if( ExploActor != None )
		{
			ExploActor.Instigator = Instigator;
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.bReplicateInstigator = true;
			KFExplosionActorReplicated(ExploActor).bIgnoreInstigator = false;
			
			ExplosionTemplate.bIgnoreInstigator = true;
			ExplosionTemplate.Damage = StunExplosionDamage;
			ExplosionTemplate.DamageRadius = StunExplosionRadius;
			
			ExploActor.Explode( ExplosionTemplate );
		}

		// `log( GetItemName(string(Self))@"- AdjustDamage has spawned Explosion" );
	}
}

// ****************************** Grunt ******************************

// exec function TestStunnerExplosion()
// {
// 	SpawnStunExplosion();
// }

/*
exec function BuyGrunt()
{
	SpawnGrunt(300);
}

function SpawnGrunt(optional float Distance = 0.f)
{
    local KFPawn_Glenn Grunt;
    local vector SpawnLoc;
    local rotator SpawnRot;

    SpawnLoc = Instigator.Location;
    SpawnLoc += Distance * vector(Rotation) + vect(0,0,1); // offset the spawn
    SpawnRot.Yaw = Rotation.Yaw + 0;

    Grunt = Spawn( class'KFPawn_Grunt',,, SpawnLoc, SpawnRot,, true );
    if( Grunt != None )
    {
        Grunt.bReplicateInstigator = true;
		Grunt.Instigator = Instigator;
        Grunt.SetPhysics(PHYS_Falling);
        Grunt.SpawnDefaultController();
    }
}
*/

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	// local vector UsedMomentum;

    if( AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
        RechargeAlt(DeltaTime);

	super.Tick( DeltaTime );

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1 = true;
	if( CurrentWeaponUpgradeIndex >= 2 )
		DrawHudPassive2 = true;

	if( bLockOnActive )
	{
    	if( Instigator != none && Instigator.IsLocallyControlled() )
    	{
	    	if( TargetPawn != none && TargetPawn.IsAliveAndWell() )
		        FindTarget(TargetPawn);
    	}
    }

	// if( Instigator != none )
	// {
	// 	UsedMomentum.Z = -ApplyMomentum;
    // 	if( bApplyVel )
	// 		Instigator.AddVelocity( UsedMomentum, Instigator.Location, none );
	// }
}

simulated function DrawHUD( HUD H, Canvas C )
{
	local Texture2D AbilityIcon, AbilityDescriptionImage, Passive1Icon, Passive2Icon, CrosshairTexture, AmmoIcon;
	// local Texture2D CoordYIcon;
	local vector WorldPos, ScreenPos;
    local float IconSize, IconScale;
	local int AmmoInt, MagInt;
	local float AmmoIntScale;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
        return;

	// The Ability icon (Needle Rounds)
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Needle_Rounds_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description (Needle Rounds)
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Needle_Rounds_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	// CoordYIcon = Texture2D'Fass_MAT.CoordY';
	// C.SetPos(C.SizeX * 0.2865, C.SizeY * 0);
	// C.SetDrawColor(255,255,255,255);
    // C.DrawTile( CoordYIcon, C.ClipY/1, C.ClipY/1, 0, 0 + KFPC.WeaponBufferRotation.Pitch, CoordYIcon.SizeX, CoordYIcon.SizeY );

	if( DrawHudPassive1 )
	{	
		// Passive ( Crystal Spawn )
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Spawn_Crystal_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}
	
	if( DrawHudPassive2 )
	{	
		// Passive ( Stunner )
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Stunner_Icon';
		C.SetPos(C.SizeX * 0.73f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive2Icon, C.ClipY/1350);
	}

	// Targeting icon
	if( FindTarget(TargetPawn) )
	{
	    // Project world pos to canvas
	    WorldPos = GetLockedTargetLoc( TargetPawn );
	    ScreenPos = C.Project( WorldPos );//WorldToCanvas(Canvas, WorldPos);

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

	// bro really wrapped two booleans in, ok so this looks messy but it let's you configure colors in Fass.ini file
   	if( bLockOnActive )
   	{
   		if( DrawTargetingHUD )
   		{
   			// Crosshair
			CrosshairTexture = Texture2D'Fass_MAT.Fass_Targeting_HUD';
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.SetPos(C.SizeX * 0.2865, C.SizeY * 0.12);
			C.DrawTexture(CrosshairTexture, C.ClipY/1350);

			// Ammo Magazine settings
			AmmoInt = AmmoCount[0];
			MagInt = SpareAmmoCount[0];
			AmmoIntScale = C.ClipY/1200;

			// Current magazine counter
		   	C.Font = FassFont;
			C.SetPos(C.SizeX * 0.25, C.SizeY * 0.645);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
		   	C.DrawText(AmmoInt,, AmmoIntScale, AmmoIntScale);

		   	// Spare ammo counter
			C.SetPos(C.SizeX * 0.28, C.SizeY * 0.645);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
		   	C.DrawText(MagInt,, AmmoIntScale, AmmoIntScale);

		   	// Alt fire ammo counter
			C.SetPos(C.SizeX * 0.28, C.SizeY * 0.58);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
		   	C.DrawText(AltAmmo,, AmmoIntScale, AmmoIntScale);

		   	// Ammo counter icon
			AmmoIcon = Texture2D'UI_Menus.UpgradeV2TraderMenu_SWF_I10B';
			C.SetPos(C.SizeX * 0.281, C.SizeY * 0.62);
			if( FindTarget(TargetPawn) )
				C.DrawColor = CrosshairColorLocked;
			else if( AmmoCount[0] == 0 )
				C.DrawColor = CrosshairColorEmpty;
			else
				C.DrawColor = CrosshairColorNeutral;
			C.DrawTexture(AmmoIcon, C.ClipY/8600);
   		}
   	}
}

// Partial Zedternal support
exec function TZS()
{
    local KFPlayerController KFPC;
    
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("The Shrimp Shooter", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
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

defaultproperties
{
	// Needle Rounds
	// LockOnDisatance=3000 // 30 meters
	// MaxTargetAngle=30
    LockedOnIcon=Texture2D'Fass_MAT.Wep_1stP_Fass_Target'
	// CrosshairColorNeutral=(R=255,G=255,B=255,A=255) // Neutral crosshair color
	// LockedIconColor=(R=1.f,G=0.f,B=0.f,A=0.8f) // Icon that is drawn onto locked target in your targeting HUD
	// CrosshairColorLocked=(R=255,G=0,B=0,A=255) // Crosshair color when locked on
	// CrosshairColorEmpty=(R=255,G=0,B=0,A=255) // Crosshair color when out of ammo
    
	// CrystalSpawnOffsetZ=0

	// Create all these particle system components off the bat so that the tick group can be set
	// fixes issue where the particle systems get offset during animations
	// Begin Object Class=KFParticleSystemComponent Name=BasePSC0
	// 	TickGroup=TG_PostUpdateWork
	// End Object
	// ParticlePSC=BasePSC0
	// ParticleTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_ParticleFX'
	// ParticleSocket=Particle

	// StunExplosionOffsetZ=0

    // ApplyMomentum=-25

    // Stun explosion
    // StunExplosionChance=0.33
	// ExplosionTemplate=KFGameExplosion'WEP_EarthSplitter_ARCH.Wep_EarthSplitter_Explosion_Template'
	ExplosionActorClass=class'KFExplosionActorReplicated'
	
	// Stun exposion
	Begin Object Class=KFGameExplosion Name=StunExplosion
		// Damage=30 //40
        // DamageRadius=400 //600
		DamageFalloffExponent=2.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_HRG_Stunner'

		MomentumTransferScale=10000
		bIgnoreInstigator=true
        ActorClassToIgnoreForDamage=class'KFPawn_Human'

		// Damage Effects
		KnockDownStrength=150
		FractureMeshRadius=200
		FracturePartVel=500
		ExplosionEffects=KFImpactEffectInfo'WEP_EarthSplitter_ARCH.EarthSplitter_Stun_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_Stunner.Play_WEP_HRG_Stunner_Alt_Fire_Explosion'

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=StunExplosion

	// Inventory
	InventorySize=4
	GroupPriority=21 // funny number
	WeaponSelectTexture=Texture2D'WEP_EarthSplitter_MAT.UI_WeaponSelect_EarthSplitter'

	// FOV
	MeshFOV=75
	MeshIronSightFOV=60
	PlayerIronSightFOV=75

	// Zooming/Position
	IronSightPosition=(X=15.f,Y=0,Z=0)
	PlayerViewOffset=(X=18.f,Y=8,Z=-5.0) //(X=17.f,Y=8,Z=-3.0)

	// Content
	PackageKey="EarthSplitter"
	FirstPersonMeshName="WEP_EarthSplitter_MESH.Wep_1stP_EarthSplitter_Rig"
	FirstPersonAnimSetNames(0)="WEP_EarthSplitter_ARCH.WEP_1P_EarthSplitter_ANIM"
	PickupMeshName="WEP_EarthSplitter_MESH.Wep_EarthSplitter_Pickup"
	AttachmentArchetypeName="WEP_EarthSplitter_ARCH.WEP_EarthSplitter_3P"
	MuzzleFlashTemplateName="WEP_EarthSplitter_ARCH.Wep_EarthSplitter_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

	// Ammo
	MagazineCapacity[0]=32 //40
	SpareAmmoCapacity[0]=284 //384 //320
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=60
	minRecoilPitch=40
	maxRecoilYaw=50
	minRecoilYaw=-50
	RecoilRate=0.06
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=550 //900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.6
	WalkingRecoilModifier=1.1
	JoggingRecoilModifier=1.2

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_EarthSplitter'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_EarthSplitter'
	InstantHitDamage(DEFAULT_FIREMODE)=12 //26
	FireInterval(DEFAULT_FIREMODE)=+.067 // 900 RPM
	Spread(DEFAULT_FIREMODE)=0.12
	FireOffset=(X=30,Y=4.5,Z=-5)

	// BonusDamage=300
	// SelfDamageReductionValue=0.08f;

	// ALTFIRE_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'Fass_MAT.UI_FireModeSelect_FassPercentage'
	FiringStatesArray(ALTFIRE_FIREMODE)=NadeThrowing
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Grenade_EarthSplitter'
	FireInterval(ALTFIRE_FIREMODE)=0.60
	NadeFireOffset=(X=0,Y=-25)

	AltAmmo=100
	MagazineCapacity[1]=100
	AmmoCost(ALTFIRE_FIREMODE)=100
	AltFullRechargeSeconds=14 //15
	bCanRefillSecondaryAmmo=false;
    SecondaryAmmoTexture=Texture2D'Fass_MAT.UI_FireModeSelect_FassPercentage'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Mac10'
	InstantHitDamage(BASH_FIREMODE)=24.0

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Mac_10.Play_Mac_10_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_Mac_10.Play_Mac_10_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_DEV_TestTones.Play_Beep_WeaponAtten', FirstPersonCue=AkEvent'WW_DEV_TestTones.Play_Beep_WeaponAtten')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_DEV_TestTones.Play_Beep_WeaponAtten'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireSnd(2)=(DefaultCue=AkEvent'WW_WEP_Mac_10.Play_Mac_10_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_Mac_10.Play_Mac_10_Fire_1P_EndLoop')
	SingleFireSoundIndex=2

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_Firebug'
	// AssociatedPerkClasses(1)=class'KFPerk_SWAT'

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

	SuperSecretMessageChance=0.01
}