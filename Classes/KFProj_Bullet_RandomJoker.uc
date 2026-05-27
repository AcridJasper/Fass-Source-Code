class KFProj_Bullet_RandomJoker extends KFProj_Bullet
    config(Fass);

// Trophie settings
var() config float TrophyDropChance;
var() config int TrophyHalfConeAngle, TrophySpawnSpeed, TrophySpawnOffsetZ;
var vector TrophyLocation;
// Chunk
var() config float ChunksToSpawn;
var AkEvent TrophySpawnSound;
var PrimitiveComponent ChunkMesh;
// Skull
var() config float ThrowableSkullsToSpawn;
var AkEvent SkullSpawnSound;
var PrimitiveComponent THSkullMesh;
// Healing orb
var() config float HealingOrbsToSpawn;
var PrimitiveComponent HealingOrbMesh;
// Ion krystal
var() config float IonCrystalsToSpawn;
var PrimitiveComponent IonCrystalMesh;
// Explosive barrel
var() config float ExposiveBarrelsToSpawn;
var PrimitiveComponent ExplosiveBarrelMesh;
// Car
var() config float CarsToSpawn, CarSpawnSpeed;
var PrimitiveComponent CarMesh;
// Hellish skull, Hurt skull, Rally skull
var() config float HellishSkullsToSpawn, HurtSkullsToSpawn, RallySkullsToSpawn;
var PrimitiveComponent HellishSkullMesh;
// Ammunition box
var() config float AmmunitionBoxesToSpawn;
var PrimitiveComponent AmmunitionBoxMesh;
// Random weapon box
var int RandWeapBoxNumber;
var() config float RandomWeaponBoxesToSpawn;
var PrimitiveComponent RandomWeaponBoxMesh;
// Napalm canister
var() config float NapalmCanistersToSpawn;
var PrimitiveComponent NapalmCanisterMesh;
// Mini nuke
var() config float MiniNukesToSpawn;
var PrimitiveComponent MiniNukeMesh;
// Snow rage
var() config float SnowGlobesToSpawn;
var PrimitiveComponent SnowGlobeMesh;
// Gas drum
var() config float GasDrumsToSpawn;
var PrimitiveComponent GasDrumMesh;
// Syringe
var() config float SyringesToSpawn;
var PrimitiveComponent SyringeMesh;
// Energy drink
var() config float EnergyDrinksToSpawn;
var PrimitiveComponent EnergyDrinkMesh;
// Shield booster
var() config float ShieldBoostersToSpawn;
var PrimitiveComponent ShieldBoosterMesh;
// Armor piece
var() config float ArmorPiecesToSpawn;
var PrimitiveComponent ArmorPieceMesh;
// Armor vest
var() config float ArmorsToSpawn;
var PrimitiveComponent ArmorMesh;
// Coil
var() config float CoilsToSpawn;
var PrimitiveComponent CoilMesh;
// Fumo (unused)
var PrimitiveComponent CirnoMesh;
// Glowstick
var() config float GlowsticksToSpawn;
var PrimitiveComponent GlowstickMesh;
// Dynamie, HE Grenade
var() config float DynamitesToSpawn, HEGrenadesToSpawn, TrophyGrenadeSpawnSpeed;
// Mines
var vector MineLocation;
var() config float MinesToSpawn, FriendlyMinesToSpawn, FriendlyNapalmMinesToSpawn, MineSpawnSpeed, MineSpawnOffsetZ;

var int TrophyRandomNum;

function Init(vector Direction)
{
    Super.Init(Direction);

    if( RandWeapBoxNumber == 0 )
        RandWeapBoxNumber = rand(10);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    local int i;

    Super.ProcessTouch(Other, HitLocation, HitNormal);

    if( WorldInfo.NetMode != NM_DedicatedServer )
        `ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator, HitNormal, ImpactEffects);

    TrophyLocation = HitLocation;
    MineLocation = HitLocation;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    // {
        if( Role == ROLE_Authority )
        {
            TrophyRandomNum = rand(27);
            if( KFPawn_Monster(ImpactedActor) != none && KFPawn_Monster(ImpactedActor).IsAliveAndWell() )
            {
                if( FRand() <= TrophyDropChance )
                {
                    switch( TrophyRandomNum )
                    {
                    case 0:
                        for( i = 0; i < ChunksToSpawn; i++ )
                            SpawnChunk();
                        break;
                    case 1:
                        for( i = 0; i < ThrowableSkullsToSpawn; i++ )
                            SpawnThrowableSkull();
                        break;
                    case 2:
                        for( i = 0; i < HealingOrbsToSpawn; i++ )
                            SpawnHealingOrb();
                        break;
                    case 3:
                        for( i = 0; i < IonCrystalsToSpawn; i++ )
                            SpawnIonCrystal();
                        break;
                    case 4:
                        for( i = 0; i < ExposiveBarrelsToSpawn; i++ )
                            SpawnExposiveBarrel();
                        break;
                    case 5:
                        for( i = 0; i < MinesToSpawn; i++ )
                            SpawnMine();
                        break;
                    case 6:
                        for( i = 0; i < HellishSkullsToSpawn; i++ )
                            SpawnHellishSkull();
                        break;
                    case 7:
                        for( i = 0; i < AmmunitionBoxesToSpawn; i++ )
                            SpawnAmmunitionBox();
                        break;
                    case 8:
                        for( i = 0; i < RandomWeaponBoxesToSpawn; i++ )
                            SpawnRandomWeaponBox();
                        break;
                    case 9:
                        for( i = 0; i < NapalmCanistersToSpawn; i++ )
                            SpawnNapalmCanister();
                        break;
                    case 10:
                        for( i = 0; i < MiniNukesToSpawn; i++ )
                            SpawnMiniNuke();
                        break;
                    case 11:
                        for( i = 0; i < SnowGlobesToSpawn; i++ )
                            SpawnSnowGlobe();
                        break;
                    case 12:
                        for( i = 0; i < GasDrumsToSpawn; i++ )
                            SpawnGasDrum();
                        break;
                    case 13:
                        for( i = 0; i < SyringesToSpawn; i++ )
                            SpawnSyringe();
                        break;
                    case 14:
                        for( i = 0; i < EnergyDrinksToSpawn; i++ )
                            SpawnEnergyDrink();
                        break;
                    case 15:
                        for( i = 0; i < FriendlyMinesToSpawn; i++ )
                            SpawnFriendlyMine();
                        break;
                    case 16:
                        for( i = 0; i < FriendlyNapalmMinesToSpawn; i++ )
                            SpawnFriendlyNapalmMine();
                        break;
                    case 17:
                        for( i = 0; i < ShieldBoostersToSpawn; i++ )
                            SpawnShieldBooster();
                        break;
                    case 18:
                        for( i = 0; i < HurtSkullsToSpawn; i++ )
                            SpawnHurtSkull();
                        break;
                    case 19:
                        for( i = 0; i < RallySkullsToSpawn; i++ )
                            SpawnRallySkull();
                        break;
                    case 20:
                        for( i = 0; i < ArmorPiecesToSpawn; i++ )
                            SpawnArmorPiece();
                        break;
                    case 21:
                        for( i = 0; i < ArmorsToSpawn; i++ )
                            SpawnArmor();
                        break;
                    case 22:
                        for( i = 0; i < CoilsToSpawn; i++ )
                            SpawnCoil();
                        break;
                    case 23:
                        for( i = 0; i < GlowsticksToSpawn; i++ )
                            SpawnGlowstick();
                        break;
                    case 24:
                        for( i = 0; i < DynamitesToSpawn; i++ )
                            SpawnDynamite();
                        break;
                    case 25:
                        for( i = 0; i < HEGrenadesToSpawn; i++ )
                            SpawnHEGrenade();
                        break;
                    case 26:
                        for( i = 0; i < CarsToSpawn; i++ )
                            SpawnCar();
                        break;
                    }
                }
            }
        }
    // }
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    TrophyLocation = HitLocation;
    MineLocation = HitLocation;
    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

// **************************** Trophies ****************************

simulated function SpawnChunk()
{
    local KFDroppedPickup_Trophy_Chunk Chunk;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );
        
        Chunk = Spawn(class'KFDroppedPickup_Trophy_Chunk',,, SpawnLocation, SpawnRotation,, false);
        if( Chunk == None )
            Destroy();
        else
        {
            Chunk.SetPhysics(PHYS_Falling);
            Chunk.Velocity = Direction * TrophySpawnSpeed;
            Chunk.Instigator = Instigator;
            Chunk.SetPickupMesh(ChunkMesh);
        }
    }
}

simulated function SpawnThrowableSkull()
{
    local KFDroppedPickup_SkullBase THSkull;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * 5;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( SkullSpawnSound, true, true, false );

        THSkull = Spawn( class'KFDroppedPickup_SkullBase',,, SpawnLocation, SpawnRotation,, false );
        if( THSkull == None )
            Destroy();
        else
        {
            THSkull.SetPhysics(PHYS_Falling);
            THSkull.Velocity = Direction * TrophySpawnSpeed;
            THSkull.Instigator = Instigator;
            THSkull.Inventory = Instigator.CreateInventory( THSkull.InventoryClass );
            THSkull.InventoryClass = class'KFWeap_Skull';
            THSkull.SetPickupMesh(THSkullMesh);
        }
    }
}

simulated function SpawnHealingOrb()
{
    local KFDroppedPickup_Trophy_HealingOrb Orb;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
        
        PostAkEvent( TrophySpawnSound, true, true, false );

        Orb = Spawn(class'KFDroppedPickup_Trophy_HealingOrb',,, SpawnLocation, SpawnRotation,, false);
        if( Orb == None )
            Destroy();
        else
        {
            Orb.SetPhysics(PHYS_Falling);
            Orb.Velocity = Direction * TrophySpawnSpeed;
            Orb.Instigator = Instigator;
            Orb.SetPickupMesh(HealingOrbMesh);
        }
    }
}

simulated function SpawnIonCrystal()
{
    local KFDroppedPickup_Trophy_IonCrystal Krystal;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Krystal = Spawn(class'KFDroppedPickup_Trophy_IonCrystal',,, SpawnLocation, SpawnRotation,, false);
        if( Krystal == None )
            Destroy();
        else
        {
            Krystal.SetPhysics(PHYS_Falling);
            Krystal.Velocity = Direction * TrophySpawnSpeed;
            Krystal.Instigator = Instigator;
            Krystal.SetPickupMesh(IonCrystalMesh);
        }
    }
}

simulated function SpawnExposiveBarrel()
{
    local KFDroppedPickup_Trophy_ExplosiveBarrel Barrel;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Barrel = Spawn(class'KFDroppedPickup_Trophy_ExplosiveBarrel',,, SpawnLocation, SpawnRotation,, false);
        if( Barrel == None )
            Destroy();
        else
        {
            Barrel.SetPhysics(PHYS_Falling);
            Barrel.Velocity = Direction * TrophySpawnSpeed;
            Barrel.Instigator = Instigator;
            Barrel.SetPickupMesh(ExplosiveBarrelMesh);
        }
    }
}

simulated function SpawnMine()
{
    local KFProj_Mine_Explosive Mine;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;

    PostAkEvent( TrophySpawnSound, true, true, false );

    SpawnLocation = MineLocation;
    SpawnLocation.Z += MineSpawnOffsetZ;
    SpawnRotation = Rotator(Direction);
    DirectionUp = vect(0,0,1);
    Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
    // Direction += VRand(); // aims anywere
    Mine = Spawn(class'KFProj_Mine_Explosive', self,, SpawnLocation, SpawnRotation);

    if( Mine != none )
        Mine.Velocity = Direction * MineSpawnSpeed;
}

simulated function SpawnCar()
{
    local KFDroppedPickup_Trophy_Car Car;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Car = Spawn(class'KFDroppedPickup_Trophy_Car',,, SpawnLocation, SpawnRotation,, false);
        if( Car == None )
            Destroy();
        else
        {
            Car.SetPhysics(PHYS_Falling);
            Car.Velocity = Direction * CarSpawnSpeed;
            Car.Instigator = Instigator;
            Car.SetPickupMesh(CarMesh);
        }
    }
}

simulated function SpawnHellishSkull()
{
    local KFDroppedPickup_Trophy_HellishRage HellishSkull;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        HellishSkull = Spawn(class'KFDroppedPickup_Trophy_HellishRage',,, SpawnLocation, SpawnRotation,, false);
        if( HellishSkull == None )
            Destroy();
        else
        {
            HellishSkull.SetPhysics(PHYS_Falling);
            HellishSkull.Velocity = Direction * TrophySpawnSpeed;
            HellishSkull.Instigator = Instigator;
            HellishSkull.SetPickupMesh(HellishSkullMesh);
        }
    }
}

simulated function SpawnAmmunitionBox()
{
    local KFDroppedPickup_Trophy_AmmunitionBox AmmunitionBox;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        AmmunitionBox = Spawn(class'KFDroppedPickup_Trophy_AmmunitionBox',,, SpawnLocation, SpawnRotation,, false);
        if( AmmunitionBox == None )
            Destroy();
        else
        {
            AmmunitionBox.SetPhysics(PHYS_Falling);
            AmmunitionBox.Velocity = Direction * TrophySpawnSpeed;
            AmmunitionBox.Instigator = Instigator;
            AmmunitionBox.SetPickupMesh(AmmunitionBoxMesh);
        }
    }
}

simulated function SpawnRandomWeaponBox()
{
    local KFDroppedPickup_Trophy_RandomWeaponBox WeaponBox;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * 5;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        WeaponBox = Spawn( class'KFDroppedPickup_Trophy_RandomWeaponBox',,, SpawnLocation, SpawnRotation,, false );
        if( WeaponBox == None )
            Destroy();
        else
        {
            WeaponBox.SetPhysics(PHYS_Falling);
            WeaponBox.Velocity = Direction * TrophySpawnSpeed;
            WeaponBox.Instigator = Instigator;
            WeaponBox.Inventory = Instigator.CreateInventory( WeaponBox.InventoryClass );
            switch( RandWeapBoxNumber )
            {
            case 0:
                WeaponBox.InventoryClass = class'KFWeap_Pistol_9mm';
                break;
            case 1:
                WeaponBox.InventoryClass = class'KFWeap_SMG_MP7';
                break;
            case 2:
                WeaponBox.InventoryClass = class'KFWeap_Blunt_Crovel';
                break;
            case 3:
                WeaponBox.InventoryClass = class'KFWeap_AssaultRifle_AR15';
                break;
            case 4:
                WeaponBox.InventoryClass = class'KFWeap_Shotgun_MB500';
                break;
            case 5:
                WeaponBox.InventoryClass = class'KFWeap_Pistol_Medic';
                break;
            case 6:
                WeaponBox.InventoryClass = class'KFWeap_GrenadeLauncher_HX25';
                break;
            case 7:
                WeaponBox.InventoryClass = class'KFWeap_Flame_CaulkBurn';
                break;
            case 8:
                WeaponBox.InventoryClass = class'KFWeap_Revolver_Rem1858';
                break;
            case 9:
                WeaponBox.InventoryClass = class'KFWeap_Rifle_Winchester1894';
                break;
            }
            WeaponBox.SetPickupMesh(RandomWeaponBoxMesh);
        }
    }
}

simulated function SpawnNapalmCanister()
{
    local KFDroppedPickup_Trophy_NapalmCanister Canister;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Canister = Spawn(class'KFDroppedPickup_Trophy_NapalmCanister',,, SpawnLocation, SpawnRotation,, false);
        if( Canister == None )
            Destroy();
        else
        {
            Canister.SetPhysics(PHYS_Falling);
            Canister.Velocity = Direction * TrophySpawnSpeed;
            Canister.Instigator = Instigator;
            Canister.SetPickupMesh(NapalmCanisterMesh);
        }
    }
}

simulated function SpawnMiniNuke()
{
    local KFDroppedPickup_Trophy_MiniNuke MiniNuke;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        MiniNuke = Spawn(class'KFDroppedPickup_Trophy_MiniNuke',,, SpawnLocation, SpawnRotation,, false);
        if( MiniNuke == None )
            Destroy();
        else
        {
            MiniNuke.SetPhysics(PHYS_Falling);
            MiniNuke.Velocity = Direction * TrophySpawnSpeed;
            MiniNuke.Instigator = Instigator;
            MiniNuke.SetPickupMesh(MiniNukeMesh);
        }
    }
}

simulated function SpawnSnowGlobe()
{
    local KFDroppedPickup_Trophy_SnowGlobe Globe;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Globe = Spawn(class'KFDroppedPickup_Trophy_SnowGlobe',,, SpawnLocation, SpawnRotation,, false);
        if( Globe == None )
            Destroy();
        else
        {
            Globe.SetPhysics(PHYS_Falling);
            Globe.Velocity = Direction * TrophySpawnSpeed;
            Globe.Instigator = Instigator;
            Globe.SetPickupMesh(SnowGlobeMesh);
        }
    }
}

simulated function SpawnGasDrum()
{
    local KFDroppedPickup_Trophy_GasDrum Drum;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Drum = Spawn(class'KFDroppedPickup_Trophy_GasDrum',,, SpawnLocation, SpawnRotation,, false);
        if( Drum == None )
            Destroy();
        else
        {
            Drum.SetPhysics(PHYS_Falling);
            Drum.Velocity = Direction * TrophySpawnSpeed;
            Drum.Instigator = Instigator;
            Drum.SetPickupMesh(GasDrumMesh);
        }
    }
}

simulated function SpawnSyringe()
{
    local KFDroppedPickup_Trophy_Syringe Syringe;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Syringe = Spawn(class'KFDroppedPickup_Trophy_Syringe',,, SpawnLocation, SpawnRotation,, false);
        if( Syringe == None )
            Destroy();
        else
        {
            Syringe.SetPhysics(PHYS_Falling);
            Syringe.Velocity = Direction * TrophySpawnSpeed;
            Syringe.Instigator = Instigator;
            Syringe.SetPickupMesh(SyringeMesh);
        }
    }
}

simulated function SpawnEnergyDrink()
{
    local KFDroppedPickup_Trophy_EnergyDrink Drink;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Drink = Spawn(class'KFDroppedPickup_Trophy_EnergyDrink',,, SpawnLocation, SpawnRotation,, false);
        if( Drink == None )
            Destroy();
        else
        {
            Drink.SetPhysics(PHYS_Falling);
            Drink.Velocity = Direction * TrophySpawnSpeed;
            Drink.Instigator = Instigator;
            Drink.SetPickupMesh(EnergyDrinkMesh);
        }
    }
}

simulated function SpawnFriendlyMine()
{
    local KFProj_Trophy_FriendlyMine FMine;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    PostAkEvent( TrophySpawnSound, true, true, false );

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = MineLocation;
        SpawnLocation.Z += MineSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere
        
        FMine = Spawn(class'KFProj_Trophy_FriendlyMine', self,, SpawnLocation, SpawnRotation);
        if( FMine != none )
            FMine.Velocity = Direction * MineSpawnSpeed;
    }
}

simulated function SpawnFriendlyNapalmMine()
{
    local KFProj_Trophy_FriendlyNapalmMine FMine;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    PostAkEvent( TrophySpawnSound, true, true, false );

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = MineLocation;
        SpawnLocation.Z += MineSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere
        
        FMine = Spawn(class'KFProj_Trophy_FriendlyNapalmMine', self,, SpawnLocation, SpawnRotation);
        if( FMine != none )
            FMine.Velocity = Direction * MineSpawnSpeed;
    }
}

simulated function SpawnShieldBooster()
{
    local KFDroppedPickup_Trophy_ShieldBooster SBooster;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        SBooster = Spawn(class'KFDroppedPickup_Trophy_ShieldBooster',,, SpawnLocation, SpawnRotation,, false);
        if( SBooster == None )
            Destroy();
        else
        {
            SBooster.SetPhysics(PHYS_Falling);
            SBooster.Velocity = Direction * TrophySpawnSpeed;
            SBooster.Instigator = Instigator;
            SBooster.SetPickupMesh(ShieldBoosterMesh);
        }
    }
}

simulated function SpawnHurtSkull()
{
    local KFDroppedPickup_Trophy_HurtSkull Hurter;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Hurter = Spawn(class'KFDroppedPickup_Trophy_HurtSkull',,, SpawnLocation, SpawnRotation,, false);
        if( Hurter == None )
            Destroy();
        else
        {
            Hurter.SetPhysics(PHYS_Falling);
            Hurter.Velocity = Direction * TrophySpawnSpeed;
            Hurter.Instigator = Instigator;
            Hurter.SetPickupMesh(HellishSkullMesh);
        }
    }
}

simulated function SpawnRallySkull()
{
    local KFDroppedPickup_Trophy_RallySkull RallySkull;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        RallySkull = Spawn(class'KFDroppedPickup_Trophy_RallySkull',,, SpawnLocation, SpawnRotation,, false);
        if( RallySkull == None )
            Destroy();
        else
        {
            RallySkull.SetPhysics(PHYS_Falling);
            RallySkull.Velocity = Direction * TrophySpawnSpeed;
            RallySkull.Instigator = Instigator;
            RallySkull.SetPickupMesh(HellishSkullMesh);
        }
    }
}

simulated function SpawnArmorPiece()
{
    local KFDroppedPickup_Trophy_ArmorPiece ArmorPiece;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        ArmorPiece = Spawn(class'KFDroppedPickup_Trophy_ArmorPiece',,, SpawnLocation, SpawnRotation,, false);
        if( ArmorPiece == None )
            Destroy();
        else
        {
            ArmorPiece.SetPhysics(PHYS_Falling);
            ArmorPiece.Velocity = Direction * TrophySpawnSpeed;
            ArmorPiece.Instigator = Instigator;
            ArmorPiece.SetPickupMesh(ArmorPieceMesh);
        }
    }
}

simulated function SpawnArmor()
{
    local KFDroppedPickup_Trophy_Armor Armor;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Armor = Spawn(class'KFDroppedPickup_Trophy_Armor',,, SpawnLocation, SpawnRotation,, false);
        if( Armor == None )
            Destroy();
        else
        {
            Armor.SetPhysics(PHYS_Falling);
            Armor.Velocity = Direction * TrophySpawnSpeed;
            Armor.Instigator = Instigator;
            Armor.SetPickupMesh(ArmorMesh);
        }
    }
}

simulated function SpawnCoil()
{
    local KFDroppedPickup_Trophy_Coil Koil;
    local vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Koil = Spawn(class'KFDroppedPickup_Trophy_Coil',,, SpawnLocation, SpawnRotation,, false);
        if( Koil == None )
            Destroy();
        else
        {
            Koil.SetPhysics(PHYS_Falling);
            Koil.Velocity = Direction * TrophySpawnSpeed;
            Koil.Instigator = Instigator;
            Koil.SetPickupMesh(CoilMesh);
        }
    }
}

simulated function SpawnGlowstick()
{
    local KFDroppedPickup_Trophy_Glowstick Glowstick;
    local vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Glowstick = Spawn(class'KFDroppedPickup_Trophy_Glowstick',,, SpawnLocation, SpawnRotation,, false);
        if( Glowstick == None )
            Destroy();
        else
        {
            Glowstick.SetPhysics(PHYS_Falling);
            Glowstick.Velocity = Direction * TrophySpawnSpeed;
            Glowstick.Instigator = Instigator;
            Glowstick.SetPickupMesh(GlowstickMesh);
        }
    }
}

simulated function SpawnDynamite()
{
    local KFProj_Trophy_Dynamite Dynamite;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    PostAkEvent( TrophySpawnSound, true, true, false );

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = MineLocation;
        SpawnLocation.Z += MineSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere

        Dynamite = Spawn(class'KFProj_Trophy_Dynamite', self,, SpawnLocation, SpawnRotation);
        if( Dynamite != none )
            Dynamite.Velocity = Direction * TrophyGrenadeSpawnSpeed;
    }
}

simulated function SpawnHEGrenade()
{
    local KFProj_Trophy_HEGrenade HEGrenade;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    PostAkEvent( TrophySpawnSound, true, true, false );

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = MineLocation;
        SpawnLocation.Z += MineSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere

        HEGrenade = Spawn(class'KFProj_Trophy_HEGrenade', self,, SpawnLocation, SpawnRotation);
        if( HEGrenade != none )
            HEGrenade.Velocity = Direction * TrophyGrenadeSpawnSpeed;
    }
}

// **************************** Misc ****************************

simulated function SpawnFumo()
{
    local KFDroppedPickup_Trophy_Fumo Cirno;
    local Vector SpawnLocation, Direction, DirectionUp;
    local rotator SpawnRotation;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        SpawnLocation = Location + vect(0,0,1) * TrophySpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, TrophyHalfConeAngle * DegToRad ); //aim upwards in cone

        PostAkEvent( TrophySpawnSound, true, true, false );

        Cirno = Spawn(class'KFDroppedPickup_Trophy_Fumo',,, SpawnLocation, SpawnRotation,, false);
        if( Cirno == None )
            Destroy();
        else
        {
            Cirno.SetPhysics(PHYS_Falling);
            Cirno.Velocity = Direction * TrophySpawnSpeed;
            Cirno.Instigator = Instigator;
            Cirno.SetPickupMesh(CirnoMesh);
        }
    }
}

defaultproperties
{
	MaxSpeed=22500
	Speed=22500

	DamageRadius=0
	
    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_NullF'
    ProjFlightTemplateZedTime=ParticleSystem'WEP_1P_L85A2_EMIT.FX_L85A2_Tracer_ZEDTime'

	ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Heavy_bullet_impact'
    
    // **************************** Trophy settings ****************************

    // Sounds
    TrophySpawnSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Collectible_Hit'
    SkullSpawnSound=AkEvent'WW_Skin_Impacts.Play_Bludgeon_Skull_3P'

    // Random numbers
    // TrophyRandomNum=0
    // RandWeapBoxNumber=0

    // **************************** Trophie physics ****************************

    // Chunk
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh0
        SkeletalMesh=SkeletalMesh'Fass_MESH.chunk'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.chunk_SM_Physics'
        CastShadow=false
    End Object
    ChunkMesh=PickupMesh0

    // Skull
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh1
        SkeletalMesh=SkeletalMesh'Fass_MESH.TrophySkull'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.skull_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    THSkullMesh=PickupMesh1

    // Healing orb
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh2
        SkeletalMesh=SkeletalMesh'Fass_MESH.EmptyArmatrure'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.HealingOrb_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    HealingOrbMesh=PickupMesh2

    // Ion crystal
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh3
        SkeletalMesh=SkeletalMesh'Fass_MESH.IonCrystal'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.IonCrystal_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    IonCrystalMesh=PickupMesh3

    // Explosive barrel
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh4
        SkeletalMesh=SkeletalMesh'Fass_MESH.ExplosiveBarrel'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.ExplosiveBarrel_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    ExplosiveBarrelMesh=PickupMesh4

    // Car
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh5
        SkeletalMesh=SkeletalMesh'Fass_MESH.whip'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Whip_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    CarMesh=PickupMesh5

    // Hellish skull, Hurt skull, ZED rally skull
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh6
        SkeletalMesh=SkeletalMesh'Fass_MESH.MeatySkull'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.MeatySkull_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    HellishSkullMesh=PickupMesh6

    // Ammunition box
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh7
        SkeletalMesh=SkeletalMesh'Fass_MESH.AmmunitionBox'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.AmmunitionBox_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    AmmunitionBoxMesh=PickupMesh7

    // Random weapon box
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh8
        SkeletalMesh=SkeletalMesh'Fass_MESH.RandomWeaponBox'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.RandomWeaponBox_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    RandomWeaponBoxMesh=PickupMesh8

    // Napalm canister
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh9
        SkeletalMesh=SkeletalMesh'Fass_MESH.NapalmCanister'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.NapalmCanister_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    NapalmCanisterMesh=PickupMesh9

    // Mini nuke
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh10
        SkeletalMesh=SkeletalMesh'Fass_MESH.MiniNuke'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.MiniNuke_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    MiniNukeMesh=PickupMesh10

    // Snow rage
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh11
        SkeletalMesh=SkeletalMesh'Fass_MESH.SnowGlobe'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.SnowGlobe_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    SnowGlobeMesh=PickupMesh11

    // Gas drum
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh12
        SkeletalMesh=SkeletalMesh'Fass_MESH.GasDrum'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.GasDrum_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
        Scale=0.9f
    End Object
    GasDrumMesh=PickupMesh12

    // Syringe
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh13
        SkeletalMesh=SkeletalMesh'Fass_MESH.Syringe'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Syringe_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    SyringeMesh=PickupMesh13

    // Energy drink
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh14
        SkeletalMesh=SkeletalMesh'Fass_MESH.EnergyDrink'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.EnergyDrink_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
        Scale=1.5f
    End Object
    EnergyDrinkMesh=PickupMesh14

    // Shield booster
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh15
        SkeletalMesh=SkeletalMesh'Fass_MESH.ShieldBooster'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.ShieldBooster_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
        Scale=0.37f
    End Object
    ShieldBoosterMesh=PickupMesh15

    // Armor piece
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh16
        SkeletalMesh=SkeletalMesh'Fass_MESH.ArmorPiece'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.ArmorPiece_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    ArmorPieceMesh=PickupMesh16

    // Armor vest
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh17
        SkeletalMesh=SkeletalMesh'Fass_MESH.Armor'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Armor_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    ArmorMesh=PickupMesh17

    // Coil
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh18
        SkeletalMesh=SkeletalMesh'Fass_MESH.Koil'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Koil_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    CoilMesh=PickupMesh18

    // Cirno
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh19
        SkeletalMesh=SkeletalMesh'ZED_Fumo_ARCH.Fumo'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Fumo_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    CirnoMesh=PickupMesh19

    // Glowstick
    Begin Object Class=SkeletalMeshComponent Name=PickupMesh20
        SkeletalMesh=SkeletalMesh'Fass_MESH.Glowstick'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Glowstick_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    GlowstickMesh=PickupMesh20
}