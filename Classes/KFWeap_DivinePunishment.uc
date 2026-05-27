class KFWeap_DivinePunishment extends KFWeap_RifleBase
	config(Fass);

struct WeaponSoundCueFireSoundInfo
{
	var() SoundCue ThirdpersonSoundCue;
	var() SoundCue FirstPersonSoundCue;
};

var(Sounds) array<WeaponSoundCueFireSoundInfo> WeaponSoundCueFireSound;
var float ThirdPersonSoundCueVolumeMultiplier, FirstPersonSoundCueVolumeMultiplier;

// ****************************** Divine Favor ******************************
var bool bIsClockActive;
var() config int MinClock, MinClockH, MaxClock;
var Texture2D TimerIcon1;
var class<KFExplosion_DivinePunishment> ExplosionActorClass;
var() KFGameExplosion HealingExplosionTemplate;
var() config int ExplosionDamage, ExplosionRadius, HealingAmount, ArmorRepairAmount, HealingRingSpawnOffsetZ;
// var transient ParticleSystemComponent HealingExplosionPSC;
// var ParticleSystem HealingExplosionEffect;

// ****************************** Swiftess Speed ******************************
var bool DrawHudPassive1;
var() config float SwiftessSpeedRange, SwiftessSpeedChance;
var() config int SwiftessSpeedAmount;

// ****************************** Shield ******************************
// Shield settings
// var int MinHitsTaken, MaxHitsTaken;
// var bool StartBlocking;
// var float DamageReductionValue;
// var float BlockAngle;
// var transient float BlockAngleCos;
// var KFGameExplosion ShatterExplosionTemplate; //GameExplosion
// var AkEvent BlockSound;

// Particle FX (shield lol just didn't rename it like wtf)
// var KFParticleSystemComponent ParticlePSC;
// var ParticleSystem ParticleFXTemplate;
// var name ParticleEffectSocket;

// ****************************** Misc ******************************
var float LastFireInterval;

var AkEvent AmbientSoundPlayEvent;
var AkEvent AmbientSoundStopEvent;
var() name AmbientSoundSocketName;

// Reduction for the amount of damage dealt to the weapon owner (including damage by the explosion)
var() config float SelfDamageReductionValue;

var float SuperSecretMessageChance;

var Font FuroreFont;
var Font BahnschriftFont;

replication
{
	if( bNetDirty && Role == ROLE_Authority )
		MinClock, MinClockH, MaxClock;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// if( bIsClockActive )
	// {
	// 	SetTimer( 1, true, 'Timer' );
	// 	MinClock = MaxClock;
	// }

	// if( Role == ROLE_Authority )

	FuroreFont = Font(DynamicLoadObject("Fass_MAT.Fass_Font", class'Font'));
	BahnschriftFont = Font(DynamicLoadObject("Fass_MAT.Bahnschrift_Font", class'Font'));
}

// Return true if this weapon should play the fire last animation for this shoot animation
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
    return false;
}

simulated function StartAmbientSound()
{
	if( Instigator != none && Instigator.IsLocallyControlled() && Instigator.IsFirstPerson() )
        PostAkEventOnBone(AmbientSoundPlayEvent, AmbientSoundSocketName, false, false);
}

simulated function StopAmbientSound()
{
    PostAkEventOnBone(AmbientSoundStopEvent, AmbientSoundSocketName, false, false);
}

// ****************************** Divine Favor ******************************

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
    	// if( StartBlocking )
    	// {
		// 	DamageReductionValue = 0.12f;
		// 	ActivatePSC(ParticlePSC, ParticleFXTemplate, ParticleEffectSocket);
    	// }

		super.BeginState(PreviousStateName);
        StartAmbientSound();

        bIsClockActive = true;
        if( bIsClockActive )
		{
			SetTimer( 1.0, true, 'Timer' ); // looped timer
			// MinClock = MaxClock;
		}
	}
}

simulated function Timer()
{
	MinClock++;
	if( MinClock == MaxClock + 1 )
		MinClock = MinClockH;
}

simulated state WeaponPuttingDown
{
	simulated event BeginState(Name PreviousStateName)
	{
		// if( ParticlePSC != none )
		// 	ParticlePSC.DeactivateSystem();

		super.BeginState(PreviousStateName);

		StopAmbientSound();
	}
}

simulated state WeaponAbortEquip
{
	simulated event BeginState(Name PreviousStateName)
	{
    	// if( StartBlocking )
    	// {
		// 	DamageReductionValue = 0.12f;
		// 	ActivatePSC(ParticlePSC, ParticleFXTemplate, ParticleEffectSocket);
    	// }

		super.BeginState(PreviousStateName);
		
		StopAmbientSound();
	}
}

simulated function DetachWeapon()
{
    StopAmbientSound();
    
	// DamageReductionValue = 1.0f;
	// if( ParticlePSC != none )
	// 	ParticlePSC.DeactivateSystem();

    Super.DetachWeapon();
}

simulated event Destroyed()
{
	// DamageReductionValue = 1.0f;
	// if( ParticlePSC != none )
	// 	ParticlePSC.DeactivateSystem();

    StopAmbientSound();

	super.Destroyed();
}

// when holstered, dropped, destroyed, etc
simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		// DamageReductionValue = 1.0f;
		// if( ParticlePSC != none )
		// 	ParticlePSC.DeactivateSystem();

		Super.BeginState(PreviousStateName);
		StopAmbientSound();

		if( Role == ROLE_Authority)
		{
			bIsClockActive = false;
			ClearTimer(nameof(ExplosionTimer));
			ClearTimer(nameof(Timer));
		}	
	}
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	if( Role == ROLE_Authority)
	{
		bIsClockActive = false;
		ClearTimer(nameof(ExplosionTimer));
		ClearTimer(nameof(Timer));
	}

	super.DropFrom(StartLocation, StartVelocity);
}

simulated function ExplosionTimer()
{
	// local int i;
	// local KFPawn_Human KFPH;

	// if( WorldInfo.NetMode != NM_DedicatedServer )
	if( Role == ROLE_Authority)
	{
		// KFPH = KFPawn_Human(Instigator);
		// for( i = 0; i < SwiftessSpeedAmount; i++ )
		// 	KFPH.UpdateHealingShield();

		PlayHealingExplosion();
		ClearTimer(nameof(ExplosionTimer));
	}
}

function PlayHealingExplosion()
{
	local KFExplosion_DivinePunishment ExploActor;
	local vector SpawnLocation;

	if( HealingExplosionTemplate != none )
	{
		SpawnLocation = Instigator.Location + vect(0,0,1) * HealingRingSpawnOffsetZ;

		ExploActor = Spawn(ExplosionActorClass,,, SpawnLocation, rotator(vect(0,0,1)),, true);
		if( ExploActor != None )
		{
			ExploActor.Instigator = Instigator;
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.bReplicateInstigator = true;
			ExploActor.HealingValue = HealingAmount;
			ExploActor.ArmorRepairValue = ArmorRepairAmount;

			HealingExplosionTemplate.bIgnoreInstigator = false;
			HealingExplosionTemplate.Damage = ExplosionDamage;
			HealingExplosionTemplate.DamageRadius = ExplosionRadius;
			// HealingExplosionTemplate.HealingAmount = HealingAmount;

			ExploActor.Explode(HealingExplosionTemplate);
		}

		// `log( GetItemName(string(Self))@"- Spawned Healing ring" );
	}

	// if( WorldInfo.NetMode != NM_DedicatedServer )
	// {
	// 	// This used for changing ring size based on ExplosionRadius in configs
	// 	if( HealingExplosionEffect != None )
	// 	{
	// 		HealingExplosionPSC = WorldInfo.MyEmitterPool.SpawnEmitter( HealingExplosionEffect, Instigator.Location, rotator(vect(0,1,0)) );
	// 		HealingExplosionPSC.ActivateSystem();
	// 	}
	// }
}

// ****************************** Swiftess Speed ******************************

function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	local int i;
	local KFPawn_Human KFPH;

    super.AdjustDamage(InDamage, DamageType, DamageCauser);
	
	if( DrawHudPassive1 )
	{
		if( KFPawn_Monster(DamageCauser) != none && FRand() <= SwiftessSpeedChance )
		{
			// KFPH = KFPawn_Human(Instigator);
			foreach VisibleCollidingActors(class'KFPawn_Human', KFPH, SwiftessSpeedRange)
			{
				for( i = 0; i < SwiftessSpeedAmount; i++ )
					KFPH.UpdateHealingSpeedBoost();
			}
		}
	}

	//Reduce the damage received from self attacks
	if( Instigator != none && DamageCauser.Instigator == Instigator )
		InDamage *= SelfDamageReductionValue;
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	local int i;
	local KFPawn_Human KFPH;

	super.ConsumeAmmo(FireModeNum);

	if( DrawHudPassive1 )
	{
		if( FRand() <= SwiftessSpeedChance )
		{
			foreach VisibleCollidingActors(class'KFPawn_Human', KFPH, SwiftessSpeedRange)
			{
				for( i = 0; i < SwiftessSpeedAmount; i++ )
					KFPH.UpdateHealingSpeedBoost();
			}
		}
	}
}

// ****************************** Shield ******************************

/*
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
		OutPSC.SetAbsolute(false, true, true);
	}
}

simulated event SetFOV( float NewFOV )
{
	super.SetFOV(NewFOV);

	if( ParticlePSC != none )
		ParticlePSC.SetFOV(NewFOV);
}

//Reduce the damage received and apply it to the shield
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	local float DmgCauserDot;

    super.AdjustDamage(InDamage, DamageType, DamageCauser);

    MinHitsTaken++;
    if( MinHitsTaken >= MaxHitsTaken )
    {
		DamageReductionValue = 1.0f;
    	StartBlocking=false;
		if( ParticlePSC != none )
			ParticlePSC.DeactivateSystem();
    }
    if( MinHitsTaken == 8 )
    	PlayShatterExplosion();

    if( StartBlocking )
    {
    	if (ClassIsChildOf(DamageCauser.class, class'Projectile'))
			DmgCauserDot = Normal(DamageCauser.Instigator.Location - DamageCauser.Location) dot vector(Instigator.Rotation);
		else
			DmgCauserDot = Normal(DamageCauser.Location - Instigator.Location) dot vector(Instigator.Rotation);

    	if( DmgCauserDot > BlockAngleCos )
		{
	    	InDamage *= DamageReductionValue;
			PlaySoundBase(BlockSound, true,, true);
			PlaySoundBase(BlockSound, true,, true);
		}	
    }
	
	if( Instigator != none && DamageCauser.Instigator == Instigator )
		InDamage *= SelfDamageReductionValue;
}

function PlayShatterExplosion()
{
	local KFExplosionActorReplicated ShatterExplosionActor;

	if( ShatterExplosionTemplate != none )
	{
		ShatterExplosionActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if( ShatterExplosionActor != None )
		{
			ShatterExplosionActor.Instigator = Instigator;
			ShatterExplosionActor.InstigatorController = Instigator.Controller;
			ShatterExplosionActor.bIgnoreInstigator = true;

			ShatterExplosionActor.Explode(ShatterExplosionTemplate);
		}
	}
}
*/

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	// Update Passive perks UI when upgraded
	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1 = true;
	
	if( MinClock >= MaxClock )
	{
		if( Role == ROLE_Authority )
			SetTimer(0.1, false, 'ExplosionTimer');
	}

	// if( HealingExplosionPSC != None && HealingExplosionPSC.bIsActive)
	// {
	// 	HealingExplosionPSC.SetFloatParameter( name("RingSize"), ExplosionRadius );
	// 	ExplosionRadius = FMax(0.1, ExplosionRadius);
	// }
}

simulated function DrawHUD( HUD H, Canvas C )
{
	local Texture2D AbilityIcon, Passive1Icon; // AbilityDescriptionImage
	local float ClockPercentage, ADTextScale;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
        return;

	// The Ability icon ( Divine Favor )
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Divine_Favor_Icon';
	C.SetPos( C.SizeX * 0.16f, C.SizeY * 0.85f );
	C.SetDrawColor( 255,255,255,255 );
	C.DrawTexture( AbilityIcon, C.ClipY/1250 );

	// Ability description ( Divine Favor )
	// AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Divine_Favor_Text';
	// C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	// C.SetDrawColor(255,255,255,255);
	// C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	ADTextScale = C.ClipY/2000;

	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.84f);
	C.SetDrawColor(255,255,255,255);
	C.Font = FuroreFont;
	C.DrawText( "Divine Favor:",, C.ClipY/1000, C.ClipY/1000);
	C.Font = BahnschriftFont;
	C.DrawText( "Every"@MaxClock @"Seconds release Healing Wave",, ADTextScale, ADTextScale );
	C.DrawText( "that Heals you and Allies for:"@HealingAmount @"Health",, ADTextScale, ADTextScale );
	C.DrawText( "Healing Wave deals:"@ExplosionDamage @"Damage to ZEDs",, ADTextScale, ADTextScale );
	C.DrawText( "in"@ExplosionRadius/100 @"meter Radius",, ADTextScale, ADTextScale );

	if( DrawHudPassive1 )
	{
		// Passive (Swiftess Speed)
		Passive1Icon = Texture2D'Fass_MAT.Passive_Icons.Swiftess_Speed_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive1Icon, C.ClipY/1350);
	}

	if( bIsClockActive )
	{
		// MinClock = FClamp(MinClock + 0.05, 0.f, MaxClock);
		ClockPercentage = FMin(float(MinClock) / float(MaxClock), 100);

	    // Black box behind timer bar
	    C.SetDrawColor(0,0,0,255);
	    C.SetPos(C.SizeX * 0.165, C.SizeY * 0.965);
	    C.DrawRect(C.ClipY * 0.3, C.ClipY * 0.025);

	    // Timer bar
	    if( MinClock > 0 )
	        C.SetDrawColor(255,0,0,255);
	    if( MinClock > MaxClock - 6 )
	        C.SetDrawColor(255,255,0,255);
	    if( MinClock > MaxClock - 2 )
	        C.SetDrawColor(0,255,0,255);
	    C.SetPos(C.SizeX * 0.19, C.SizeY * 0.969);
	    C.DrawRect(C.ClipY * 0.25 * ClockPercentage, C.ClipY * 0.0175);

	    // Clock icon
		C.SetDrawColor(255,255,255,255);
		C.SetPos(C.SizeX * 0.168, C.SizeY * 0.965);
		C.DrawTexture(TimerIcon1, C.ClipY/5400);

		// Timer bar counter
		C.Font = BahnschriftFont;
	    C.SetDrawColor(255,255,255,255);
	    C.SetPos(C.SizeX * 0.338, C.SizeY * 0.96);
    	C.DrawText(MinClock,, C.ClipY/1300, C.ClipY/1300);
	}
}

// Partial Zedternal support
exec function TZS()
{
	local KFPlayerController KFPC;
    
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Sol keep you", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
}

// ****************************** Misc ******************************

simulated function float GetFireInterval(byte FireModeNum)
{
	if( FireModeNum == DEFAULT_FIREMODE && AmmoCount[FireModeNum] == 0 )
		return LastFireInterval;

	return super.GetFireInterval(FireModeNum);
}

simulated function PlayFiringSound( byte FireModeNum )
{
    local byte UsedFireModeNum;

	MakeNoise(1.0,'PlayerFiring'); // AI

	if( MedicComp != none && FireModeNum == ALTFIRE_FIREMODE )
		MedicComp.PlayFiringSound();
	else
	if( !bPlayingLoopingFireSnd )
	{
		UsedFireModeNum = FireModeNum;

		// Use the single fire sound if we're in zed time and want to play single fire sounds
		if( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && ShouldForceSingleFireSound() )
            UsedFireModeNum = SingleFireSoundIndex;
        // AKEvents
        if( UsedFireModeNum < WeaponFireSnd.Length )
			WeaponPlayFireSound(WeaponFireSnd[UsedFireModeNum].DefaultCue, WeaponFireSnd[UsedFireModeNum].FirstPersonCue);

		// SoundCues
        if( UsedFireModeNum < WeaponSoundCueFireSound.Length )
			WeaponPlayFireSound(WeaponSoundCueFireSound[UsedFireModeNum].ThirdpersonSoundCue, WeaponSoundCueFireSound[UsedFireModeNum].FirstPersonSoundCue);
	}
}

exec function ChangePrimaryFirstPersonVolume(float VolumeLevel)
{
	WeaponSoundCueFireSound[0].FirstPersonSoundCue.VolumeMultiplier = VolumeLevel;
}
exec function ChangePrimaryThirdPersonVolume(float VolumeLevel)
{
	WeaponSoundCueFireSound[0].ThirdpersonSoundCue.VolumeMultiplier = VolumeLevel;
}

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
	// Divine Favor
    bIsClockActive=true
    // HealingRingSpawnOffsetZ=-5
	// MinClock=0
	// MaxClock=12
	TimerIcon1=Texture2D'Fass_MAT.ClockIcon'

	// HealingAmount=25
	// ArmorRepairAmount=5

	// HealingExplosionEffect=ParticleSystem'Fass_EMIT.FX_DivineFavor'

	ExplosionActorClass = class'KFExplosion_DivinePunishment'
	Begin Object Class=KFGameExplosion Name=ExplosionRing
		// Damage=225
		// DamageRadius=1000
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_DivinePunishment'
		// HealingAmount=25

		MomentumTransferScale=0
		bIgnoreInstigator=false

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		// ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_DivineFavor'
		ExplosionEffects=KFImpactEffectInfo'WEP_DivinePunishment_ARCH.DivineFavor_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Mid'

		// Camera Shake
		CamShake=none
	End Object
	HealingExplosionTemplate=ExplosionRing

	// SwiftessSpeedRange=1000 // 10 meters
	// SwiftessSpeedChance=0.12f
	// SwiftessSpeedAmount=3

/*
	// Shield
	StartBlocking=true
	MinHitsTaken=0
	MaxHitsTaken=8
	DamageReductionValue=0.12f //0.06f;
	BlockAngle=360.f
	BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'

	// Shield shatter explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=110
		DamageRadius=800 //500
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_EMP'

		bIgnoreInstigator=true

		// Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=500.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Blocking_Shield_Explosion'
        // ExplosionSound=AkEvent'WW_ZED_Hans.Play_Hans_Shield_Break'
		ExplosionSound=AkEvent'WW_WEP_SA_RPG7.Play_WEP_SA_RPG7_Explosion'

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=0.5f
        bOrientCameraShakeTowardsEpicenter=true
        bUseOverlapCheck=false
	End Object
	ShatterExplosionTemplate=ExploTemplate0

	// Particle system
	Begin Object Class=KFParticleSystemComponent Name=BasePSC0
		TickGroup=TG_PostUpdateWork
	End Object
	ParticlePSC=BasePSC0
	ParticleFXTemplate=ParticleSystem'Fass_EMIT.FX_Blocking_Shield_1P'
	ParticleEffectSocket=Root
*/
	
	// Inventory / Grouping
	InventorySize=9 //10
	GroupPriority=21 // funny number
	WeaponSelectTexture=Texture2D'WEP_DivinePunishment_MAT.UI_WeaponSelect_DivinePunishment'
   	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'

    // FOV
	MeshIronSightFOV=70
    PlayerIronSightFOV=70

	// Content
	PackageKey="DivinePunishment"
	FirstPersonMeshName="WEP_DivinePunishment_MESH.WEP_1stP_DivinePunishment_Rig"
	FirstPersonAnimSetNames(0)="WEP_DivinePunishment_ARCH.WEP_1P_DivinePunishment_ANIM"
	PickupMeshName="WEP_DivinePunishment_MESH.Wep_DivinePunishment_Pickup"
	AttachmentArchetypeName="WEP_DivinePunishment_ARCH.Wep_DivinePunishment_3P"
	MuzzleFlashTemplateName="WEP_RailGun_ARCH.Wep_RailGun_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=20
	InitialSpareMags[0]=5
	bCanBeReloaded=true
	bReloadFromMagazine=true
	AmmoPickupScale[0]=3.0

	// Zooming/Position
	PlayerViewOffset=(X=3.0,Y=7,Z=-2)
	IronSightPosition=(X=-0.25,Y=0.005,Z=-0.005) // any further back along X and the scope clips through the camera during firing

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=600
	minRecoilPitch=450
	maxRecoilYaw=250
	minRecoilYaw=-250
	RecoilRate=0.09
	RecoilBlendOutRatio=1.1
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.6
	FallingRecoilModifier=1.5
	HippedRecoilModifier=2.33333

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_DivinePunishment'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_M99'
	InstantHitDamage(DEFAULT_FIREMODE)=81
	FireInterval(DEFAULT_FIREMODE)=0.2
	// PenetrationPower(DEFAULT_FIREMODE)=0.0
	Spread(DEFAULT_FIREMODE)=0.005
	FireOffset=(X=30,Y=3.0,Z=-2.5)
	ForceReloadTimeOnEmpty=0.5
	LastFireInterval=0.3

	// SelfDamageReductionValue=0.08f;

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None
	
	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_M99'
	InstantHitDamage(BASH_FIREMODE)=30

	// Fire Effects
	// WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_M99.Play_WEP_M99_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_M99.Play_WEP_M99_Fire_1P_Single')
	WeaponSoundCueFireSound(DEFAULT_FIREMODE)=(ThirdpersonSoundCue=SoundCue'WEP_DivinePunishment_SND.Shoot2b3_3P_Cue', FirstPersonSoundCue=SoundCue'WEP_DivinePunishment_SND.Shoot2b3_1P_Cue')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_M99.Play_WEP_M99_DryFire'

	//Ambient Sounds
    AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_Railgun.Stop_Railgun_Loop'
	AmbientSoundSocketName=AmbientSound
	
	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
    BonesToLockOnEmpty=(RW_TopLeft_RadShield1,RW_TopRight_RadShield1,RW_TopLeft_RadShield2,RW_TopRight_RadShield2,RW_TopLeft_RadShield3,RW_TopRight_RadShield3,RW_TopLeft_RadShield4,RW_TopRight_RadShield4,RW_TopLeft_RadShield5,RW_TopRight_RadShield5,RW_TopLeft_RadShield6,RW_TopRight_RadShield6,RW_BottomLeft_RadShield2,RW_BottomRight_RadShield2,RW_BottomLeft_RadShield3,RW_BottomRight_RadShield3,RW_BottomLeft_RadShield4,RW_BottomRight_RadShield4,RW_BottomLeft_RadShield5,RW_BottomRight_RadShield5,RW_BottomLeft_RadShield6,RW_BottomRight_RadShield6,RW_BottomLeft_RadShield1,RW_BottomRight_RadShield1,RW_Bullets1,RW_AcceleratorMagnetrons,RW_Bolt)

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Damage1, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))

	SuperSecretMessageChance=0.01
}