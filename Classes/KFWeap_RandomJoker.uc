class KFWeap_RandomJoker extends KFWeap_RifleBase
	config(Fass);

// ****************************** Perk Passive ******************************
var KFPawn_Monster Monster;
var() config float ReloadAnimRateModifierRange, ReloadAnimRateModifier, ReloadAnimRateModifierElite;

// ****************************** Sodaorb ******************************
var bool DrawHudPassive1;
var bool SpawnTrophy;
var() config float SodaOrbDropChance, SodaOrbHalfConeAngle, SodaOrbSpawnSpeed, SodaOrbSpawnOffsetZ;
var PrimitiveComponent EnergyDrinkMesh, HealingOrbMesh;

// ****************************** Super Nova ******************************
var bool DrawHudPassive2;
var() config float SuperNovaExplosionChance, SuperNovaSpawnOffsetZ, SuperNovaDamage, SuperNovaDamageRadius;
var() KFGameExplosion SuperNovaExplosionTemplate;

// ****************************** Misc ******************************
var float SuperSecretMessageChance;

// ****************************** Sodaorb ******************************

// Handles pawn penetration
simulated function bool PassThroughDamage(Actor HitActor)
{
	super.PassThroughDamage(HitActor);

	// if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
	{
		if( DrawHudPassive2 )
		{
	    	if( KFPawn_Monster(HitActor) != none && KFPawn_Monster(HitActor).IsAliveAndWell() )
	    	{
	         	if( FRand() <= SodaOrbDropChance )
				{
					SpawnEnergyDrink();
		            SpawnHealingOrb();
				}
			}
	    }
	}

	return(!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')
		|| HitActor.IsA('InteractiveFoliageActor') || HitActor.IsA('KFWaterMeshActor')) );
}

// ****************************** Perk Passive ******************************

simulated function float GetReloadRateScale()
{
	local float ModdedReloadSpeed;

	ModdedReloadSpeed = UseTacticalReload() ? ReloadAnimRateModifierElite : ReloadAnimRateModifier;

	// Modded reload speed that is only active if ZED is within specific range
	foreach VisibleCollidingActors(class'KFPawn_Monster', Monster, ReloadAnimRateModifierRange)
	{
		if( Monster.IsAliveAndWell() )
			return super.GetReloadRateScale() * ModdedReloadSpeed;
	}

	return super.GetReloadRateScale();
}

// ****************************** Sodaorb ******************************

function SpawnEnergyDrink()
{
    local KFDroppedPickup_Trophy_EnergyDrink Drink;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Instigator.Location + vect(0,0,1) * SodaOrbSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, SodaOrbHalfConeAngle * DegToRad ); //aim upwards in cone

        Drink = Spawn(class'KFDroppedPickup_Trophy_EnergyDrink',,, SpawnLocation, SpawnRotation,, false);
        if( Drink != None )
        {
            Drink.SetPhysics(PHYS_Falling);
            Drink.Velocity = Direction * SodaOrbSpawnSpeed;
            Drink.Instigator = Instigator;
            Drink.SetPickupMesh(EnergyDrinkMesh);
        }
    }
}

function SpawnHealingOrb()
{
    local KFDroppedPickup_Trophy_HealingOrb Orb;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Location + vect(0,0,1) * SodaOrbSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, SodaOrbHalfConeAngle * DegToRad ); //aim upwards in cone
        
        Orb = Spawn(class'KFDroppedPickup_Trophy_HealingOrb',,, SpawnLocation, SpawnRotation,, false);
        if( Orb != None )
        {
            Orb.SetPhysics(PHYS_Falling);
            Orb.Velocity = Direction * SodaOrbSpawnSpeed;
            Orb.Instigator = Instigator;
            Orb.SetPickupMesh(HealingOrbMesh);
        }
    }
}

// ****************************** Super Nova ******************************

function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{	
    super.AdjustDamage(InDamage, DamageType, DamageCauser);

    if( Role == ROLE_Authority )
    {
		if( DrawHudPassive2 )
    	{
			if( KFPawn_Monster(DamageCauser) != none && FRand() <= SuperNovaExplosionChance ) //Instigator != none
				SpawnNovaExplosion();
    	}
	}
}

function SpawnNovaExplosion()
{
	local KFExplosionActorReplicated ExploActor;
	local vector SpawnLocation;

	if( SuperNovaExplosionTemplate != none )
	{
		SpawnLocation = Instigator.Location + vect(0,0,1) * SuperNovaSpawnOffsetZ;

		ExploActor = Spawn(class'KFExplosionActorReplicated',,, SpawnLocation, rotator(vect(0,0,1)),, true);
		if( ExploActor != None )
		{
			ExploActor.Instigator = Instigator;
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.bReplicateInstigator = true;

			SuperNovaExplosionTemplate.Damage = SuperNovaDamage;
			SuperNovaExplosionTemplate.DamageRadius = SuperNovaDamageRadius;

			SuperNovaExplosionTemplate.bIgnoreInstigator = false;

			ExploActor.Explode(SuperNovaExplosionTemplate);
		}
	}
}

// ****************************** HUD ******************************

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( CurrentWeaponUpgradeIndex >= 1 )
		DrawHudPassive1=true;
	if( CurrentWeaponUpgradeIndex >= 2 )
		DrawHudPassive2=true;
}

simulated function DrawHUD( HUD H, Canvas C )
{
    local Texture2D AbilityIcon, AbilityDescriptionImage, PassiveIcon, Passive2Icon;
	local KFPlayerController KFPC;

    // Don't draw canvas HUD in cinematic mode
	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && KFPC.bCinematicMode )
        return;

	// The Ability icon (Roll the dice)
	AbilityIcon = Texture2D'Fass_MAT.Perk_Icons.Roll_The_Dice_Icon';
	C.SetPos(C.SizeX * 0.16f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityIcon, C.ClipY/1250);

	// Ability description (Roll the dice)
	AbilityDescriptionImage = Texture2D'Fass_MAT.Perk_Descriptions.Roll_The_Dice_Text';
	C.SetPos(C.SizeX * 0.22f, C.SizeY * 0.85f);
	C.SetDrawColor(255,255,255,255);
	C.DrawTexture(AbilityDescriptionImage, C.ClipY/1250);

	if( DrawHudPassive1 )
	{	
		// Passive (Sodaorb)
		PassiveIcon = Texture2D'Fass_MAT.Passive_Icons.Sodaorb_Icon';
		C.SetPos(C.SizeX * 0.785f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(PassiveIcon, C.ClipY/1350);
	}

	if( DrawHudPassive2 )
	{	
		// Passive (Super Nova)
		Passive2Icon = Texture2D'Fass_MAT.Passive_Icons.Super_Nova_Icon';
		C.SetPos(C.SizeX * 0.73f, C.SizeY * 0.85f);
		C.SetDrawColor(255,255,255,255);
		C.DrawTexture(Passive2Icon, C.ClipY/1350);
	}
}

// Partial Zedternal support
exec function TZS()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Instigator.Controller);
    if( KFPC != none && FRand() <= SuperSecretMessageChance ) // VerySecret™
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("27x mult with this one", "FF0000");

    if( KFPC != none && DrawHudPassive1 )
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: OFF", "FF0000");
    else
    	KFPC.MyGFxHUD.HudChatBox.AddChatMessage("Partial Zedtenral support: ON", "AAFF00");

    DrawHudPassive1 = !DrawHudPassive1;
    DrawHudPassive2 = !DrawHudPassive2;
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
	// Sodaorb
	Begin Object Class=SkeletalMeshComponent Name=PickupMesh0
        SkeletalMesh=SkeletalMesh'Fass_MESH.EnergyDrink'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.EnergyDrink_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
        Scale=1.5f
    End Object
    EnergyDrinkMesh=PickupMesh0

    Begin Object Class=SkeletalMeshComponent Name=PickupMesh1
        SkeletalMesh=SkeletalMesh'Fass_MESH.EmptyArmatrure'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.HealingOrb_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    HealingOrbMesh=PickupMesh1

    // Super Nova
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

	Begin Object Class=KFGameExplosion Name=HeatSuperNova
		// Damage=175
		// DamageRadius=800 //600
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Fire_MolotovGrenade'

        ActorClassToIgnoreForDamage = class'KFPawn_Human'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.SuperNova_Fass_Explosion'
		ExplosionSound=SoundCue'Fass_SND.Fass_supernova_explosion_Cue'
		// ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

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
	SuperNovaExplosionTemplate=HeatSuperNova

	// Inventory / Grouping
	InventorySize=4 //5
	GroupPriority=21 // funny number
	WeaponSelectTexture=Texture2D'WEP_RandomJoker_MAT.UI_WeaponSelect_RandomJoker'
   	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'
   	AssociatedPerkClasses(1)=class'KFPerk_Sharpshooter'

    // FOV
    MeshFOV=65
	MeshIronSightFOV=45
    PlayerIronSightFOV=65

	// Content
	PackageKey="RandomJoker"
	FirstPersonMeshName="WEP_RandomJoker_MESH.Wep_1stP_RandomJoker_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Winchester_ANIM.Wep_1stP_Winchester_Anim"
	PickupMeshName="WEP_RandomJoker_MESH.Wep_RandomJoker_Pickup"
	AttachmentArchetypeName="WEP_RandomJoker_ARCH.WEP_RandomJoker_Marker_3P" //WEP_RandomJoker_ARCH.Wep_RandomJoker_3P
	MuzzleFlashTemplateName="wep_winchester_arch.Wep_Winchester_MuzzleFlash"

	// DroppedPickupClass=class'KFDroppedPickup_LootBeam_Legendary_Fass' // Loot beam fx (no offset)

	// Ammo
	MagazineCapacity[0]=12
	SpareAmmoCapacity[0]=84 //84
	InitialSpareMags[0]=4 //3
	bCanBeReloaded=true
	bReloadFromMagazine=false

	// Zooming/Position
	PlayerViewOffset=(X=8.0,Y=7,Z=-3.5)
	IronSightPosition=(X=0,Y=0,Z=0)

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
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_RandomJoker'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Winchester'
	InstantHitDamage(DEFAULT_FIREMODE)=80
	FireInterval(DEFAULT_FIREMODE)=0.4 // 70 RPM
	Spread(DEFAULT_FIREMODE)=0.007
	PenetrationPower(DEFAULT_FIREMODE)=1.5
	FireOffset=(X=25,Y=3.0,Z=-2.5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	// FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	// WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	// WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Grenade_Car' //KFProj_Bullet_RandomJoker1
	// InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_Winchester'
	// InstantHitDamage(ALTFIRE_FIREMODE)=80
	// FireInterval(ALTFIRE_FIREMODE)=0.4 // 70 RPM
	// Spread(ALTFIRE_FIREMODE)=0.007
	// PenetrationPower(ALTFIRE_FIREMODE)=1.5

	// Reloading
	// RTDReloadAnimRateModifier=1.0f
	// RTDReloadAnimRateModifierElite=1.0f

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty=(RW_Hammer)
	bHasFireLastAnims=true

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Winchester'
	InstantHitDamage(BASH_FIREMODE)=25

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Handling_DryFire'
	EjectedShellForegroundDuration=1.5f

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.5f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f), (Stat=EWUS_Weight, Add=2)))

	SuperSecretMessageChance=0.01
}