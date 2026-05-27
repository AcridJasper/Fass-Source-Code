class KFWeap_Calderon extends KFWeap_GrenadeLauncher_Base
	config(Fass);

// ****************************** Select Score ******************************
var bool DrawRandomizerHUD, DrawCompactRandomizerHUD, DrawCrosshairHUD;
var bool EnableProjectileRandomizer;
var transient int CurrentProjectileIndex;
var	array< class<KFProjectile> > ProjectileClassByIndex;
var() config LinearColor GlowColorDefault, GlowColorHeat, GlowColorFreeze, GlowColorToxin, GlowColorElectric;

// ****************************** Projectile Array ******************************
var bool DrawHudPassive1;
var() config int ProjectileArrayCount;

// ****************************** Elemental Orb ******************************
var bool DrawHudPassive2;
var() config float ElementalPickupChance, ElementSpawnOffsetZ, ElementHalfConeAngle, ElementSpawnSpeed;
var int ElementalNum;
var PrimitiveComponent ElementalPickupMesh;

// ****************************** Misc ******************************
// Reduction for the amount of damage dealt to the weapon owner (including damage by the explosion)
var() config float SelfDamageReductionValue;

var Font BahnschriftFont;

var float SuperSecretMessageChance;

var() config string CanOnlyText;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	// CanOnlyText = "Can only toggle this if EnableProjectileRandomizer is OFF";
	BahnschriftFont = Font(DynamicLoadObject("Fass_MAT.Bahnschrift_Font", class'Font'));
}

// ****************************** Select Score ******************************

simulated function UpdateGlowColors()
{
	// Update colors
	if( CurrentProjectileIndex == 0 )
		WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorHeat);
	if( CurrentProjectileIndex == 1 )
		WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorFreeze);
	if( CurrentProjectileIndex == 2 )
		WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorToxin);
	if( CurrentProjectileIndex == 3 )
		WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorElectric);
	if( CurrentProjectileIndex == 4 )
		WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorDefault);
}

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		UpdateGlowColors();
	}
}

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		UpdateGlowColors();
	}
}

simulated state WeaponPuttingDown
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		UpdateGlowColors();
	}
}

simulated state WeaponAbortEquip
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		UpdateGlowColors();
	}
}

simulated state Reloading
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		UpdateGlowColors();
	}

	simulated function ReloadComplete()
	{
		Super.ReloadComplete();
		UpdateGlowColors();
	}

	simulated function AbortReload()
	{
		Super.AbortReload();
		UpdateGlowColors();
	}
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo(FireModeNum);

	UpdateGlowColors();

	// Projectile Array
	if( DrawHudPassive1 )
		NumPellets[0] = ProjectileArrayCount;
	else
		NumPellets[0] = 1;

	// Elemental Orb
	if( DrawHudPassive2 )
	{
		ElementalNum = rand(4);
		if( FRand() <= ElementalPickupChance )
			SpawnElementalPickup();
	}
}

function SpawnElementalPickup()
{
    local KFDroppedPickup_TrophyBase Element;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Instigator.Location + vect(0,0,1) * ElementSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, ElementHalfConeAngle * DegToRad ); //aim upwards in cone

        if( ElementalNum == 0 )
        	Element = Spawn(class'KFDroppedPickup_Calderon_Heat',,, SpawnLocation, SpawnRotation,, false);
        if( ElementalNum == 1 )
        	Element = Spawn(class'KFDroppedPickup_Calderon_Freeze',,, SpawnLocation, SpawnRotation,, false);
        if( ElementalNum == 2 )
        	Element = Spawn(class'KFDroppedPickup_Calderon_Toxin',,, SpawnLocation, SpawnRotation,, false);
        if( ElementalNum == 3 )
        	Element = Spawn(class'KFDroppedPickup_Calderon_Electric',,, SpawnLocation, SpawnRotation,, false);
        
        if( Element != None )
        {
            Element.SetPhysics(PHYS_Falling);
            Element.Velocity = Direction * ElementSpawnSpeed;
            Element.Instigator = Instigator;
            Element.SetPickupMesh(ElementalPickupMesh);
        }
    }
}

simulated function class<KFProjectile> GetKFProjectileClass()
{
    if( CurrentFireMode == DEFAULT_FIREMODE || CurrentFireMode == ALTFIRE_FIREMODE )
        return ProjectileClassByIndex[CurrentProjectileIndex];

    return super.GetKFProjectileClass();
}

// Toggles randomizer live in game cuz why not lmao
exec function ToggleProjectileRandomizer()
{
	EnableProjectileRandomizer = !EnableProjectileRandomizer;

	// Randomize projectile again when user toggles this back ON
	if( EnableProjectileRandomizer )
	{
		CurrentProjectileIndex = rand(4);
		UpdateGlowColors();
	}
	else
	{
		CurrentProjectileIndex = 4; // return to default projectile when this is OFF
		UpdateGlowColors();
	}
}

// Default
exec function SelectProjectileExplosive()
{
    local KFPlayerController KFPC;
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && EnableProjectileRandomizer )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage(CanOnlyText, "FF0000");
    else
    {
		CurrentProjectileIndex = 4;
		UpdateGlowColors();
    }
}

exec function SelectProjectileHeat()
{
    local KFPlayerController KFPC;
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && EnableProjectileRandomizer )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage(CanOnlyText, "FF0000");
    else
    {
		CurrentProjectileIndex = 0;
		UpdateGlowColors();
    }
}

exec function SelectProjectileFreezing()
{
    local KFPlayerController KFPC;
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && EnableProjectileRandomizer )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage(CanOnlyText, "FF0000");
	else
	{
		CurrentProjectileIndex = 1;
		UpdateGlowColors();
	}
}

exec function SelectProjectileToxin()
{
    local KFPlayerController KFPC;
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && EnableProjectileRandomizer )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage(CanOnlyText, "FF0000");
	else 
	{
		CurrentProjectileIndex = 2;
		UpdateGlowColors();
	}
}

exec function SelectProjectileElectric()
{
    local KFPlayerController KFPC;
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && EnableProjectileRandomizer )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage(CanOnlyText, "FF0000");
	else
	{
		CurrentProjectileIndex = 3;
		UpdateGlowColors();
	}
}

simulated function ANIMNOTIFY_SwitchAmmo()
{
	// local KFPawn Pawn;
	// local KFWeapAttach_Calderon KFWeapAttach;

	if( EnableProjectileRandomizer )
	{
		// Pawn = KFPawn_Human(Instigator);
		// KFWeapAttach = KFWeapAttach_Calderon(Pawn.WeaponAttachment);

		CurrentProjectileIndex = rand(4);
	    switch( CurrentProjectileIndex )
	    {
	    case 0:
			// KFWeapAttach.UpdateMaterials();
			UpdateGlowColors();
	        CurrentProjectileIndex = 0;
	        break;
	    case 1:
			// KFWeapAttach.UpdateMaterials();
			UpdateGlowColors();
	        CurrentProjectileIndex = 1;
	        break;
	    case 2:
			// KFWeapAttach.UpdateMaterials();
			UpdateGlowColors();
	        CurrentProjectileIndex = 2;
	        break;
	    case 3:
			// KFWeapAttach.UpdateMaterials();
			UpdateGlowColors();
	        CurrentProjectileIndex = 3;
	        break;
	    }
	}
	else
	{
	    // CurrentProjectileIndex = 4;
	    // WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorDefault);
		return;
	}
}

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	// if( EnableProjectileRandomizer == false )
	// {
	//     CurrentProjectileIndex = 4;
	//     WeaponMICs[0].SetVectorParameterValue('Vector_GlowColor', GlowColorDefault);
	// }

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1 = true;
	if( CurrentWeaponUpgradeIndex >= 2 )
		DrawHudPassive2 = true;
}

simulated function DrawHUD( HUD H, Canvas C )
{
    local Texture2D AbilityIcon, AbilityDescriptionImage, Passive1Icon, Passive2Icon;
    local Texture2D RandomizerReticleIcon, RandomizerSelectBoxIcon, CrosshairIcon, NonElemIcon;
	local float RandomizerSelectBoxScale;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
		return;

    // The Ability icon ( Select Score )
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Select_Score_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description ( Select Score )
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Select_Score_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	if( DrawHudPassive1 )
	{
		// Passive ( Projectile Array )
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Projectile_Array_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}

	if( DrawHudPassive2 )
	{
		// Passive ( Elemental Orb )
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Elemental_Orb_Icon';
		C.SetPos(C.SizeX * 0.73f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive2Icon, C.ClipY/1350);
	}

	if( DrawCrosshairHUD )
	{
		C.SetPos( C.SizeX * 0.2865, C.SizeY * 0.12 );
		C.SetDrawColor(255,255,255,180);
		CrosshairIcon = Texture2D'Fass_MAT.Calderon_Trajectory_Crosshair';
		C.DrawTexture(CrosshairIcon, C.ClipY/1350);
	}
	if( DrawRandomizerHUD )
	{
		// Randomizer reticle
		C.SetPos(C.SizeX * 0.14, C.SizeY * -0.14);
		C.SetDrawColor(255,255,255,255);
		RandomizerReticleIcon = Texture2D'Fass_MAT.RandomizerReticle';
		C.DrawTexture(RandomizerReticleIcon, C.ClipY/800);

		RandomizerSelectBoxIcon = Texture2D'Fass_MAT.RandomizerSelectBox';
		RandomizerSelectBoxScale = C.ClipY/2048;
		// Top box
		C.SetPos(C.SizeX * 0.55, C.SizeY * 0.42);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
		// Middle top box
		C.SetPos(C.SizeX * 0.55, C.SizeY * 0.455);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
		// Middle bottom box
		C.SetPos(C.SizeX * 0.55, C.SizeY * 0.485);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
		// Bottom box
		C.SetPos(C.SizeX * 0.55, C.SizeY * 0.52);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);

		// Projectile names
		C.Font = BahnschriftFont;
		C.SetPos(C.SizeX * 0.59, C.SizeY * 0.436);
		C.SetDrawColor(255,255,255,255);
		C.DrawText('Heat',, C.ClipY/1600, C.ClipY/1600);
		C.SetPos(C.SizeX * 0.59, C.SizeY * 0.472);
		C.SetDrawColor(255,255,255,255);
		C.DrawText('Freezing',, C.ClipY/1600, C.ClipY/1600);
		C.SetPos(C.SizeX * 0.59, C.SizeY * 0.503);
		C.SetDrawColor(255,255,255,255);
		C.DrawText('Toxin',, C.ClipY/1600, C.ClipY/1600);
		C.SetPos(C.SizeX * 0.59, C.SizeY * 0.537);
		C.SetDrawColor(255,255,255,255);
		C.DrawText('Electric',, C.ClipY/1600, C.ClipY/1600);
		if( CurrentProjectileIndex == 4 )
		{
			C.Font = BahnschriftFont;
			C.SetDrawColor(0,255,0,255);
			C.SetPos(C.SizeX * 0.565, C.SizeY * 0.56);
			C.DrawText('Using Non-Elemental',, C.ClipY/1600, C.ClipY/1600);
			// Non elemental icon
			C.SetPos(C.SizeX * 0.545, C.SizeY * 0.56);
			C.SetDrawColor(255,255,255,255);
			NonElemIcon = Texture2D'Fass_MAT.NonEleml_Icon';
			C.DrawTexture(NonElemIcon, C.ClipY/3900);
		}

		// Top box
	    if( CurrentProjectileIndex == 0 )
			C.SetDrawColor(0,255,0,255);
		else
			C.SetDrawColor(255,0,0,255);
		C.SetPos(C.SizeX * 0.554, C.SizeY * 0.446);
		C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
		// Middle top box
		if( CurrentProjectileIndex == 1 )
			C.SetDrawColor(0,255,0,255);
		else
			C.SetDrawColor(255,0,0,255);
		C.SetPos(C.SizeX * 0.554, C.SizeY * 0.481);
		C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
		// Middle bottom box
		if( CurrentProjectileIndex == 2 )
			C.SetDrawColor(0,255,0,255);
		else
			C.SetDrawColor(255,0,0,255);
		C.SetPos(C.SizeX * 0.554, C.SizeY * 0.512);
		C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
		// Bottom box
		if( CurrentProjectileIndex == 3 )
			C.SetDrawColor(0,255,0,255);
		else
			C.SetDrawColor(255,0,0,255);
		C.SetPos(C.SizeX * 0.554, C.SizeY * 0.547);
		C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
	}
	else
	{
		if( DrawCompactRandomizerHUD )
		{
			RandomizerSelectBoxIcon = Texture2D'Fass_MAT.RandomizerSelectBox';
			RandomizerSelectBoxScale = C.ClipY/2048;
			// Top box
			C.SetPos(C.SizeX * 0.3415, C.SizeY * 0.832);
			C.SetDrawColor(255,255,255,255);	
			C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
			// Middle top box
			C.SetPos(C.SizeX * 0.3415, C.SizeY * 0.855);
			C.SetDrawColor(255,255,255,255);
			C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
			// Middle bottom box
			C.SetPos(C.SizeX * 0.3415, C.SizeY * 0.879);
			C.SetDrawColor(255,255,255,255);
			C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);
			// Bottom box
			C.SetPos(C.SizeX * 0.3415, C.SizeY * 0.904);
			C.SetDrawColor(255,255,255,255);
			C.DrawTexture(RandomizerSelectBoxIcon, RandomizerSelectBoxScale);

			// Projectile names
			C.Font = BahnschriftFont;
			C.SetPos(C.SizeX * 0.38, C.SizeY * 0.85);
			C.SetDrawColor(255,255,255,255);
			C.DrawText('Heat',, C.ClipY/1600, C.ClipY/1600);
			C.SetPos(C.SizeX * 0.38, C.SizeY * 0.872);
			C.SetDrawColor(255,255,255,255);
			C.DrawText('Freezing',, C.ClipY/1600, C.ClipY/1600);
			C.SetPos(C.SizeX * 0.38, C.SizeY * 0.896);
			C.SetDrawColor(255,255,255,255);
			C.DrawText('Toxin',, C.ClipY/1600, C.ClipY/1600);
			C.SetPos(C.SizeX * 0.38, C.SizeY * 0.922);
			C.SetDrawColor(255,255,255,255);
			C.DrawText('Electric',, C.ClipY/1600, C.ClipY/1600);
			if( CurrentProjectileIndex == 4 )
			{
				C.Font = BahnschriftFont;
				C.SetDrawColor(0,255,0,255);
				C.SetPos(C.SizeX * 0.358, C.SizeY * 0.944);
				C.DrawText('Using Non-Elemental',, C.ClipY/1600, C.ClipY/1600);
				// Non elemental icon
				C.SetPos(C.SizeX * 0.34, C.SizeY * 0.944);
				C.SetDrawColor(255,255,255,255);
				NonElemIcon = Texture2D'Fass_MAT.NonEleml_Icon';
				C.DrawTexture(NonElemIcon, C.ClipY/4096);
			}

			// Top box
		    if( CurrentProjectileIndex == 0 )
				C.SetDrawColor(0,255,0,255);
			else
				C.SetDrawColor(255,0,0,255);
			C.SetPos(C.SizeX * 0.345, C.SizeY * 0.858);
			C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
			// Middle top box
			if( CurrentProjectileIndex == 1 )
				C.SetDrawColor(0,255,0,255);
			else
				C.SetDrawColor(255,0,0,255);
			C.SetPos(C.SizeX * 0.345, C.SizeY * 0.881);
			C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
			// Middle bottom box
			if( CurrentProjectileIndex == 2 )
				C.SetDrawColor(0,255,0,255);
			else
				C.SetDrawColor(255,0,0,255);
			C.SetPos(C.SizeX * 0.345, C.SizeY * 0.905);
			C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
			// Bottom box
			if( CurrentProjectileIndex == 3 )
				C.SetDrawColor(0,255,0,255);
			else
				C.SetDrawColor(255,0,0,255);
			C.SetPos(C.SizeX * 0.345, C.SizeY * 0.931);
			C.DrawRect(C.ClipY * 0.049, C.ClipY * 0.01);
		}
	}
}

// Toggleble UI (Setbind H ToggleWeaponHUD)
exec function ToggleWeaponHUD()
{
    DrawRandomizerHUD = !DrawRandomizerHUD;
}

exec function ToggleCompactWeaponHUD()
{
    DrawCompactRandomizerHUD = !DrawCompactRandomizerHUD;
}

exec function ToggleCrosshairHUD()
{
	DrawCrosshairHUD = !DrawCrosshairHUD;
}

// Partial Zedternal support
exec function TZS()
{
    local KFPlayerController KFPC;

	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Super Calamity", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
}

// ****************************** HUD color change in-game ******************************

/*exec function ChangeCurrentElementColor(float Red, float Green, float Blue)
{
	if( CurrentProjectileIndex == 4 )
	{
		GlowColorDefault.R = Red;
		GlowColorDefault.G = Green;
		GlowColorDefault.B = Blue;
	}
	if( CurrentProjectileIndex == 0 )
	{
		GlowColorHeat.R = Red;
		GlowColorHeat.G = Green;
		GlowColorHeat.B = Blue;
	}
	if( CurrentProjectileIndex == 1 )
	{
		GlowColorFreeze.R = Red;
		GlowColorFreeze.G = Green;
		GlowColorFreeze.B = Blue;
	}
	if( CurrentProjectileIndex == 2 )
	{
		GlowColorToxin.R = Red;
		GlowColorToxin.G = Green;
		GlowColorToxin.B = Blue;
	}
	if( CurrentProjectileIndex == 3 )
	{
		GlowColorElectric.R = Red;
		GlowColorElectric.G = Green;
		GlowColorElectric.B = Blue;
	}
}*/

exec function ChangeDefaultGlowColor(float Red, float Green, float Blue)
{
	GlowColorDefault.R = Red;
	GlowColorDefault.G = Green;
	GlowColorDefault.B = Blue;
	SaveConfig();
}
exec function ChangeHeatGlowColor(float Red, float Green, float Blue)
{
	GlowColorHeat.R = Red;
	GlowColorHeat.G = Green;
	GlowColorHeat.B = Blue;
	SaveConfig();
}
exec function ChangeFreezeGlowColor(float Red, float Green, float Blue)
{
	GlowColorFreeze.R = Red;
	GlowColorFreeze.G = Green;
	GlowColorFreeze.B = Blue;
	SaveConfig();
}
exec function ChangeToxinGlowColor(float Red, float Green, float Blue)
{
	GlowColorToxin.R = Red;
	GlowColorToxin.G = Green;
	GlowColorToxin.B = Blue;
	SaveConfig();
}
exec function ChangeElectricGlowColor(float Red, float Green, float Blue)
{
	GlowColorElectric.R = Red;
	GlowColorElectric.G = Green;
	GlowColorElectric.B = Blue;
	SaveConfig();
}

// ****************************** Misc ******************************

function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
    super.AdjustDamage(InDamage, DamageType, DamageCauser);

	//Reduce the damage received from self attacks
	if( Instigator != none && DamageCauser.Instigator == Instigator )
		InDamage *= SelfDamageReductionValue;
}

defaultproperties
{
	DrawCrosshairHUD=false
	DrawRandomizerHUD=true
	DrawCompactRandomizerHUD=true
	EnableProjectileRandomizer=true // never touch this one lmao
	// CurrentProjectileIndex=0
    ProjectileClassByIndex(0)=class'KFProj_HighExplosive_Calderon_Heat'
    ProjectileClassByIndex(1)=class'KFProj_HighExplosive_Calderon_Freezing'
    ProjectileClassByIndex(2)=class'KFProj_HighExplosive_Calderon_Toxin'
    ProjectileClassByIndex(3)=class'KFProj_HighExplosive_Calderon_Electric'
    ProjectileClassByIndex(4)=class'KFProj_HighExplosive_Calderon'

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh0
        SkeletalMesh=SkeletalMesh'Fass_MESH.EmptyArmatrure'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Elemental_SM_Physics' // Fass_PHYS.HealingOrb_SM_Physics
        BlockNonZeroExtent=false
        CastShadow=false
        // Scale=1.5f
    End Object
    ElementalPickupMesh=PickupMesh0

	// Inventory
	InventoryGroup=IG_Secondary
	GroupPriority=21 // funny number
	InventorySize=4
	WeaponSelectTexture=Texture2D'WEP_Calderon_MAT.UI_WeaponSelect_Calderon'
   	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'
   	AssociatedPerkClasses(1)=class'KFPerk_Demolitionist'
   	AssociatedPerkClasses(2)=class'KFPerk_Firebug'

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=73

	// Zooming/Position
	PlayerViewOffset=(X=13.0,Y=13,Z=-4)
	IronSightPosition=(X=0,Y=0,Z=0)
	FastZoomOutTime=0.2

	// Content
	PackageKey="Calderon"
	FirstPersonMeshName="WEP_Calderon_MESH.Wep_1stP_Calderon_Rig"
	FirstPersonAnimSetNames(0)="WEP_Calderon_ARCH.Wep_1stP_Calderon_Anim"
	PickupMeshName="WEP_Calderon_MESH.WEP_Calderon_Pickup"
	AttachmentArchetypeName="WEP_Calderon_ARCH.Wep_Calderon_3P" // WEP_Calderon_ARCH.WEP_Calderon_G_3P
	MuzzleFlashTemplateName="WEP_HX25_Pistol_ARCH.Wep_HX25_Pistol_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=29
	InitialSpareMags[0]=17
	AmmoPickupScale[0]=3.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.04
	RecoilBlendOutRatio=0.35
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.8
	FallingRecoilModifier=1.5
	HippedRecoilModifier=1.05

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_ExplosiveSubMunition_HX25'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_M79Impact'
	InstantHitDamage(DEFAULT_FIREMODE)=150
	Spread(DEFAULT_FIREMODE)=0.05 //0.1
	FireInterval(DEFAULT_FIREMODE)=0.25
	NumPellets(DEFAULT_FIREMODE)=1
	FireOffset=(X=23,Y=4.0,Z=-3)
	ForceReloadTime=0.3f

	// SelfDamageReductionValue=0.1f;

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HX25'
	InstantHitDamage(BASH_FIREMODE)=24

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_HX25.Play_WEP_SA_HX25_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_HX25.Play_WEP_SA_HX25_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))

	SuperSecretMessageChance=0.01
}