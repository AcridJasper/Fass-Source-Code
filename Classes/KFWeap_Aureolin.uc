class KFWeap_Aureolin extends KFWeap_PistolBase
	config(Fass);

// ****************************** Combustion Rounds ******************************
var bool StartPerkAction;
// Muzzle ParticleFX
var KFParticleSystemComponent ParticlePSC;
var ParticleSystem ParticleFXTemplate;
var name ParticleEffectSocket;
// Light that attaches to socket
var PointLightComponent IdleLight;
var Name LightAttachBone;
var AKEvent PingReadySound;

// ****************************** Perk passive ******************************
var() config bool PassiveHealUser;
var() config int PassiveAddArmor, PassiveHealAmount;

// ****************************** Return Chamber ******************************
// Return Chamber
var bool DrawHudPassive1;
var() config float AmmoChance;
var AkEvent AmmoGetSound;

// ****************************** Fire Clip ******************************
var bool DrawHudPassive2;
var	class<DamageType> UpgradedDamageType;

// ****************************** Fire Trap ******************************
var bool LineEmUpActive;

// ****************************** Misc ******************************
// Secret :) (VerySecret™)
var bool VerySecretMessage;
var string VerySecretText;

var float SuperSecretMessageChance;

// struct DamageMultiplierByZed
// {
// 	var Name ZedClassName;
// 	var float DamageMultiplier;
// };

// var array<DamageMultiplierByZed> DamageMultiplierByZedArray;

// simulated event PostBeginPlay()
// {
	// Super.PostBeginPlay();
	// if( Role == ROLE_Authority )
// }

// ****************************** Combustion Rounds / Perk passive ******************************

// Handles pawn penetration
simulated function bool PassThroughDamage(Actor HitActor)
{
	local KFPawn_Human KFPH;
	// local int IndexDamageMultiplierByZed;

	super.PassThroughDamage(HitActor);

	// if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
	{
	    if( KFPawn_Monster(HitActor) != none && KFPawn_Monster(HitActor).IsAliveAndWell() )
	    {
			// IndexDamageMultiplierByZed = DamageMultiplierByZedArray.Find('ZedClassName', HitActor.Class.Name);
			// if( IndexDamageMultiplierByZed != INDEX_NONE )
				// InstantHitDamage[CurrentFireMode] *= DamageMultiplierByZedArray[IndexDamageMultiplierByZed].DamageMultiplier;

	    	// Combustion Rounds
			if( AmmoCount[0] == 1 )
				StartPerkAction = true;

			// Gives armor on hit (Perk Passive)
			KFPH = KFPawn_Human(Instigator);
			if( KFPH != none )
			{
				KFPH.AddArmor(PassiveAddArmor);
				if( PassiveHealUser )
					KFPH.HealDamage(PassiveHealAmount, Instigator.Controller, class'KFDT_Healing');
			}

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
	    }
	}

	return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')
		|| HitActor.IsA('InteractiveFoliageActor') || HitActor.IsA('KFWaterMeshActor')));
}

/*simulated function ProcessInstantHitEx( byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
	local KFPawn_Human KFPH;

	if( Role == ROLE_Authority )
	{
		if( Impact.HitActor != None && KFPawn_Monster(Impact.HitActor) != None && KFPawn_Monster(Impact.HitActor).IsAliveAndWell() )
		{
			// Combustion Rounds
			if( AmmoCount[0] < 1 )
				StartPerkAction = true;

			// Gives armor on hit (Perk Passive)
			KFPH = KFPawn_Human(Instigator);
			if( KFPH != none )
				KFPH.AddArmor(PassiveAddArmor);

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
		}
	}

	super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}*/

simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo(FireModeNum);

	// if( WorldInfo.NetMode != NM_DedicatedServer )
	if( Role == ROLE_Authority )
	{
		if( AmmoCount[0] == 0 )
			ANIMNOTIFY_ClearVFX();
	}
}

simulated function ANIMNOTIFY_ClearStacks()
{
	// Clear stacks inside of animation instead of reload function
	// if( WorldInfo.NetMode != NM_DedicatedServer )
	if( Role == ROLE_Authority )
		StartPerkAction = false; // Disable main perk
}

simulated state Active
{
	simulated event BeginState(Name PreviousStateName)
	{
		// Clear auto loading
		// ClearTimer('AutoLoadingHolster');

		// Clear VFX when entering the state to avoid dublicated vfx
		ANIMNOTIFY_ClearVFX();
		if( AmmoCount[0] == 1 )
		{
			// ReattachComponent(ParticlePSC);
			// ANIMNOTIFY_ClearVFX();
			ActivatePSC(ParticlePSC, ParticleFXTemplate, ParticleEffectSocket);

			if( MySkelMesh != none )
			{
				MySkelMesh.AttachComponentToSocket(IdleLight, LightAttachBone);
				IdleLight.SetEnabled(true);
			}
		}

		// do this last so the above code happens before any state changes
		Super.BeginState(PreviousStateName);
	}

	// simulated event Tick(float DeltaTime)
	// {
	// 	// Caution - Super will skip our global, but global will skip super's state function!
	// 	Global.Tick(DeltaTime);
		
	// 	if( Instigator != none && Instigator.IsLocallyControlled() )
	// 	{
	// 	}
	// }
}

simulated function ActivatePSC(out KFParticleSystemComponent OutPSC, ParticleSystem ParticleEffect, name SocketName)
{
	if (MySkelMesh != none)
	{
		MySkelMesh.AttachComponentToSocket(OutPSC, SocketName);
		OutPSC.SetFOV(MySkelMesh.FOV);
	}
	else
	{
		AttachComponent(OutPSC);
	}

	OutPSC.ActivateSystem();

	if (OutPSC != none)
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
	// when holstered, dropped, destroyed, etc
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		ANIMNOTIFY_ClearVFX();

		LineEmUpActive = false;

		// O_o (my slugcat when red lizard spawns hUH!?)
		VerySecretMessage = false;

		// Auto reloads ammunition straight into magazine
		// SetTimer(5.0, false, 'AutoLoadingHolster');
	}
}

simulated function DetachWeapon()
{
	// Failsafe (idk lol)
	// if( WorldInfo.NetMode != NM_DedicatedServer )
	// if( Role == ROLE_Authority )
	// {
		StartPerkAction = false; // Disable main perk
		LineEmUpActive 	= false;
	// }

    Super.DetachWeapon();
}

simulated function ANIMNOTIFY_ClearVFX()
{
	if( ParticlePSC != none )
		ParticlePSC.DeactivateSystem();

	IdleLight.SetEnabled(false);
}

simulated function ANIMNOTIFY_PlayPingSound()
{
	if( AmmoCount[0] == 1 )
	{
		PlaySoundBase(PingReadySound, true, true);
		PlaySoundBase(PingReadySound, true, true);
		PlaySoundBase(PingReadySound, true, true);
	}
}

/*
// WIP Auto loading holster (missing hella checks)
simulated function AutoLoadingHolster()
{
	AmmoCount[0] = MagazineCapacity[0];
	SpareAmmoCount[0] -= MagazineCapacity[0];
	if( MagazineCapacity[0] < 0 )
		ClearTimer('AutoLoadingHolster');

	if( AmmoCount[0] <= -1 )
	{
		AmmoCount[0] = 0;
		MagazineCapacity[0] = 0;
		ClearTimer('AutoLoadingHolster');
	}

	if( EmptyMagBlendNode != none && BonesToLockOnEmpty.Length > 0 && AmmoCount[GetAmmoType(0)] == 0 )
		EmptyMagBlendNode.SetBlendTarget( 0, 0 );

	PlaySoundBase(AmmoGetSound, true, true);
}
*/

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	local KFPerk_Gunslinger Perk;

	super.Tick( DeltaTime );

	if( Role == Role_Authority )
	{
		Perk = KFPerk_Gunslinger(GetPerk());
		if( Perk != none && Perk.IsPenetrationActive() )
			LineEmUpActive = true; // HUD
		else
			LineEmUpActive = false; // HUD

		if( AmmoCount[0] == 1 )
		{
			// VerySecret™
			if( Perk != none
				// Quick Draw
				&& Perk.IsQuickSwitchActive()
				// Rack em up
				&& Perk.IsRhythmMethodActive()
				// Speedloader
				&& Perk.IsSpeedReloadActive()
				// Skullcracker
				&& Perk.IsSkullCrackerActive()
				// Fan Fire
				&& Perk.IsFanfareActive() )
				VerySecretMessage = true;
		}
		else
			VerySecretMessage = false;
	}

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1=true;
	if( CurrentWeaponUpgradeIndex >= 2 )
	{
		DrawHudPassive2=true;
        InstantHitDamageTypes[0] = UpgradedDamageType;
	}
}

simulated function DrawHUD( HUD H, Canvas C )
{
    local Texture2D AbilityIcon, AbilityDescriptionImage, Passive1Icon, Passive2Icon, Talent1Icon;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
        return;

    // The Ability icon (Combustion Rounds)
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Combustion_Rounds_Perk_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description (Combustion Rounds)
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Combustion_Rounds_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	if( DrawHudPassive1 )
	{
		// Passive (Return chamber)
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Return_Chamber_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}

	if( DrawHudPassive2 )
	{	
		// Passive (Fire Clip)
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Fire_Clip_Icon';
		C.SetPos( C.SizeX * 0.73f, C.SizeY * 0.85f );
		C.SetDrawColor( 255,255,255,255 );
		C.DrawTexture( Passive2Icon, C.ClipY/1350 );
	}

	if( LineEmUpActive )
	{		
		// Passive if Line-Em Up is active (Fire Trap)
		Talent1Icon = Texture2D'Fass_MAT.Talent_Passive_Icons.Fire_Trap_Icon';
		C.SetPos(C.SizeX * 0.935f, C.SizeY * 0.655f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Talent1Icon, C.ClipY/1500);
	}

	// VerySecret™
	if( VerySecretMessage )
	{
		C.SetPos(C.SizeX * 0, C.SizeY * 0);
		C.SetDrawColor(255,255,255,255);
    	C.DrawText(VerySecretText,, C.ClipY/1200, C.ClipY/1200);
	}
}

// Partial Zedternal support
exec function TZS()
{
	local KFPlayerController KFPC;
    
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Rupture bodies", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
}

// ************** Misc **************

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
	// Combustion Rounds
	StartPerkAction=false
	PingReadySound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Charge_Once'

	//PassiveAddArmor=2

	// Particle system
	Begin Object Class=KFParticleSystemComponent Name=BasePSC0
		TickGroup=TG_PostUpdateWork
	End Object
	ParticlePSC=BasePSC0
	ParticleFXTemplate=ParticleSystem'Fass_EMIT.FX_Aureolin_ParticleFX'
	ParticleEffectSocket=Particle

	// Point light
    Begin Object Class=PointLightComponent Name=IdlePointLight
		LightColor=(R=255,G=70,B=0,A=255)
		Brightness=1.5f //0.125f
		FalloffExponent=4.f
		Radius=250.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)

		// light anim
        // AnimationType=1 // 2 > LightAnim_Blink
        // AnimationFrequency=0.2f
        // MinBrightness=0.f
        MaxBrightness=1.5f
	End Object
	IdleLight=IdlePointLight
	LightAttachBone=Particle

	// Return Chamber
	// AmmoChance=0.12f
	AmmoGetSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Mag_Out'

	// Fire Clip
	UpgradedDamageType=class'KFDT_Ballistic_Aureolin_FireClip';

	// DamageMultiplierByZedArray(0)=(ZedClassName="KFPawn_ZedClot_Cyst", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(1)=(ZedClassName="KFPawn_ZedClot_Alpha", 		DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(2)=(ZedClassName="KFPawn_ZedClot_Slasher", 		DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(3)=(ZedClassName="KFPawn_ZedCrawler", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(4)=(ZedClassName="KFPawn_ZedGorefast", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(5)=(ZedClassName="KFPawn_ZedStalker", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(6)=(ZedClassName="KFPawn_ZedScrake", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(7)=(ZedClassName="KFPawn_ZedFleshpound", 		DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(8)=(ZedClassName="KFPawn_ZedFleshpoundMini", 	DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(9)=(ZedClassName="KFPawn_ZedBloat", 				DamageMultiplier=50.0)
	// DamageMultiplierByZedArray(10)=(ZedClassName="KFPawn_ZedSiren", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(11)=(ZedClassName="KFPawn_ZedHusk", 				DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(12)=(ZedClassName="KFPawn_ZedClot_AlphaKing", 	DamageMultiplier=1.0) //elite clot
	// DamageMultiplierByZedArray(13)=(ZedClassName="KFPawn_ZedCrawlerKing", 		DamageMultiplier=1.0) //elite crawler
	// DamageMultiplierByZedArray(14)=(ZedClassName="KFPawn_ZedGorefastDualBlade", DamageMultiplier=1.0) //elite gorefast
	// DamageMultiplierByZedArray(15)=(ZedClassName="KFPawn_ZedDAR_EMP", 			DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(16)=(ZedClassName="KFPawn_ZedDAR_Laser", 		DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(17)=(ZedClassName="KFPawn_ZedDAR_Rocket", 		DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(18)=(ZedClassName="KFPawn_ZedBloatKingSubspawn", DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(19)=(ZedClassName="KFPawn_ZedHans", 			 	DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(20)=(ZedClassName="KFPawn_ZedPatriarch", 	 	DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(21)=(ZedClassName="KFPawn_ZedFleshpoundKing", 	DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(22)=(ZedClassName="KFPawn_ZedBloatKing", 	 	DamageMultiplier=1.0)
	// DamageMultiplierByZedArray(23)=(ZedClassName="KFPawn_ZedMatriarch", 	 	DamageMultiplier=1.0)

    // FOV
	MeshFOV=86
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Zooming/Position
	PlayerViewOffset=(X=14.0,Y=10,Z=-4)
	IronSightPosition=(X=11,Y=0,Z=0)

	// Content
	PackageKey="Aureolin"
	FirstPersonMeshName="WEP_Aureolin_MESH.Wep_1stP_Aureolin_Rig"
	FirstPersonAnimSetNames(0)="WEP_Aureolin_ARCH.Wep_1st_Aureolin_Anim"
	PickupMeshName="WEP_Aureolin_MESH.Wep_Aureolin_Pickup"
	AttachmentArchetypeName="WEP_Aureolin_ARCH.Wep_Aureolin_3P"
	MuzzleFlashTemplateName="WEP_Aureolin_ARCH.Wep_Aureolin_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

	// Ammo
	MagazineCapacity[0]=7
	SpareAmmoCapacity[0]=105
	InitialSpareMags[0]=5
	AmmoPickupScale[0]=2.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=650
	minRecoilPitch=550
	maxRecoilYaw=150
	minRecoilYaw=-150
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1250
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Aureolin'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Aureolin'
	FireInterval(DEFAULT_FIREMODE)=+0.2
	InstantHitDamage(DEFAULT_FIREMODE)=91.0
	// PenetrationPower(DEFAULT_FIREMODE)=0.0
	Spread(DEFAULT_FIREMODE)=0.01
	FireOffset=(X=20,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Deagle'
	InstantHitDamage(BASH_FIREMODE)=22

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Inventory
	InventorySize=2
	GroupPriority=21 // funny number
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_Aureolin_MAT.UI_WeaponSelect_Aureolin'
	bIsBackupWeapon=false
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	// DualClass=class'KFWeap_Pistol_DualDeagle'

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3, Guncheck_v4)

	bHasFireLastAnims=true

	BonesToLockOnEmpty=(RW_Slide, RW_Bullets1)

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))

	// Don't look here
	VerySecretText = "Craig :D"
	SuperSecretMessageChance=0.01 // different secret lmao
}