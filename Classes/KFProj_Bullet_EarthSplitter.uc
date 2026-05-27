class KFProj_Bullet_EarthSplitter extends KFProj_BallisticExplosive
	hidedropdown; //KFProjectile

var bool ImpactExplosionUpgrade;

var float ImpactExplosionChance;
var float FireExplosionChance;
var float FreezeExplosionChance;
var float EMPExplosionChance;
var float StunExplosionChance;
var float GasExplosionChance;
var float HealingExplosionChance;
var float NukeExplosionChance;

var KFGameExplosion ImpactExplosionTemplate;
var KFGameExplosion FireExplosionTemplate;
var KFGameExplosion FreezeExplosionTemplate;
var KFGameExplosion EMPExplosionTemplate;
var KFGameExplosion StunExplosionTemplate;
var KFGameExplosion GasExplosionTemplate;
var KFGameExplosion HealingExplosionTemplate;
var KFGameExplosion NukeExplosionTemplate;

// Clurster Grenades
var float ClusterNadesChance, ClusterNadesSpawnOffsetZ, ClusterNadesSpawnSpeed;
var int ClusterNadesAmount, ClusterNadeHalfConeAngle;

// Arc Traps
var float ArcMineChance, ArcMineSpawnOffsetZ, ArcMineSpawnSpeed;
var int ArcMineAmount, ArcMineHalfConeAngle;

// NorFleet Explosion and it's rings
var float NorFleetExplosionChance, NorFleetRingRange, NorFleetRingDamage;
var KFGameExplosion NorFleetExplosionTemplate;
var transient ParticleSystemComponent NorFleetPSC;
var ParticleSystem NorFleetFX;

// Player medic buffs
var KFGameExplosion BuffExplosionTemplate;
var float BuffExplosionChance, PlayerBuffRange;
var int PlayerBuffAmount;

var int SpawnRandomExplosionNum;

var float HitDamage;

// var() float SecondsBeforeDetonation;
// var() bool bIsProjActive;

// Our intended target actor
var KFPawn LockedTarget;
// How much 'stickyness' when seeking toward our target. Determines how accurate rocket is
var float SeekStrength;

// Aims anywere in cone
var bool RandomizeVelocityInCone;
var int HalfConeAngle;

// Shoots up lol
// var bool VelocityUpwards;

// Applies wobble to the missile, making it seem erratic. Simulates real liquid state thrusters
// var bool bEnableWobble;
// var bool bWobble;
// var float WobbleForce;

replication
{
    if( bNetDirty && Role == Role_Authority)
        LockedTarget;
}

function Init(vector Direction)
{
    Super.Init(Direction);
    // if( Instigator.Role < ROLE_Authority )
        // return;

    if( SpawnRandomExplosionNum == 0 )
        SpawnRandomExplosionNum = rand(11);
}

function SetLockedTarget( KFPawn NewTarget )
{
    LockedTarget = NewTarget;
}

simulated event Tick( float DeltaTime )
{
    local vector TargetImpactPos, DirToTarget;
    local vector Direction; //DirectionUp
    // local vector X,Y,Z;

    super.Tick( DeltaTime );

    // Skip the first frame, then start seeking
    if( !bHasExploded
        && LockedTarget != none
        && Physics == PHYS_Projectile
        && Velocity != vect(0,0,0)
        && LockedTarget.IsAliveAndWell()
        && `TimeSince(CreationTime) > 0.03f ) //0.6
    {
        // Grab our desired relative impact location from the weapon class
        TargetImpactPos = class'KFWeap_EarthSplitter'.static.GetLockedTargetLoc( LockedTarget );

        // Seek towards target
        Speed = VSize( Velocity );
        DirToTarget = Normal( TargetImpactPos - Location );
        Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;
    }

    // Stick helper
    // if( bIsProjActive )
    //     StickHelper.Tick(DeltaTime);
    // if( !IsZero(Velocity) )
    //     SetRelativeRotation(rotator(Velocity));

    // Aim rotation towards velocity every frame
    if( Physics == PHYS_Projectile && Velocity != vect(0,0,0) )
        SetRotation( rotator(Velocity) );

    // if( bEnableWobble )
    // {
    //     // Add some crazy wobble
    //     GetAxes( Rotation, X,Y,Z );
    //     Velocity += (bWobble ? Z * WobbleForce : -Z * WobbleForce) + (bWobble ? Y * WobbleForce : -Y * WobbleForce);

    //     bWobble = !bWobble;
    // }
  
    // if( VelocityUpwards )
    // {
    //     DirectionUp = vect(0,0,1);
    //     Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone
    //     Velocity = Direction * Speed;
    // }

    if( RandomizeVelocityInCone )
    {
        Direction = VRandCone( Velocity, HalfConeAngle * DegToRad ); //aim randomly anywere in cone radius
        Velocity = Direction * Speed;
    }
}

/*
function Timer_Detonate()
{
	Detonate();
}

// Called when the owning instigator controller has left a game 
simulated function OnInstigatorControllerLeft()
{
	if( WorldInfo.NetMode != NM_Client )
		SetTimer( 1.f + Rand(5) + fRand(), false, nameOf(Timer_Detonate) );
}

// Causes charge to explode 
function Detonate()
{
    local vector ExplosionNormal;

    ExplosionNormal = vect(0,0,1) >> Rotation;
    Explode(Location, ExplosionNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{   
    if (bIsProjActive)
    {
        StickHelper.UnPin();
        super.Explode(HitLocation, HitNormal);
    }
}
*/

/*
// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
    class'KFPerk_Demolitionist'.static.PrepareExplosive(Instigator, self);

    super.PrepareExplosionTemplate();

    // Since bIgnoreInstigator is transient, its value must be defined here
    ExplosionTemplate.bIgnoreInstigator = true;
}

simulated protected function SetExplosionActorClass()
{
   local KFPlayerReplicationInfo InstigatorPRI;

    if( WorldInfo.TimeDilation < 1.f && Instigator != none )
    {
        InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
        if( InstigatorPRI != none )
        {
            if( InstigatorPRI.bNukeActive && class'KFPerk_Demolitionist'.static.ProjectileShouldNuke( self ) )
                ExplosionActorClass = class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass();
        }
    }

    super.SetExplosionActorClass();
}
*/

/*
simulated function SyncOriginalLocation()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;
    local TraceHitInfo HitInfo;

    if (Role < ROLE_Authority && Instigator != none && Instigator.IsLocallyControlled())
    {
        HitActor = Trace(HitLocation, HitNormal, OriginalLocation, Location,,, HitInfo, TRACEFLAG_Bullet);
        if (HitActor != none)
            StickHelper.TryStick(HitNormal, HitLocation, HitActor);
    }
}

simulated function NotifyStick()
{
    if( Role == ROLE_Authority )
        SetTimer(SecondsBeforeDetonation, false, nameof(Timer_Detonate));
}

simulated function NotifyBounce()
{
    ClearTimer(nameof(Timer_Detonate), self);
    ClearTimer(nameOf(Destroy));
    bIsProjActive=false;
}
*/

// ******************************** Impact explosion ********************************

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    HitDamage = ExplosionTemplate.Damage;
    Super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    HitDamage = ExplosionTemplate.Damage;
    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);

    if( bHasDisintegrated )
        return;
}

simulated protected function StopSimulating()
{
    local int i;
    // local KFWeap_EarthSplitter Cannon;

    if( Role == ROLE_Authority )
    {
        if( ImpactExplosionUpgrade )
        {
            // Cannon = KFWeap_EarthSplitter(Owner);
            // if( Cannon != none && Cannon.CurrentWeaponUpgradeIndex >= 2 )
            if( KFPawn_Monster(ImpactedActor) != none && KFPawn_Monster(ImpactedActor).IsAliveAndWell() && (KFPawn_Monster(ImpactedActor).Health - HitDamage) <= 0 )
            {
                switch( SpawnRandomExplosionNum )
                {
                case 0:
                    if( FRand() <= ImpactExplosionChance )
                        TriggerImpactExplosion();
                    break;
                case 1:
                    if( FRand() <= FireExplosionChance )
                        TriggerFireExplosion();
                    break;
                case 2:
                    if( FRand() <= FreezeExplosionChance )
                       TriggerFreezeExplosion();
                    break;
                case 3:
                    if( FRand() <= EMPExplosionChance )
                        TriggerEMPExplosion();
                    break;
                case 4:
                    if( FRand() <= StunExplosionChance )
                        TriggerStunExplosion();
                    break;
                case 5:
                    if( FRand() <= GasExplosionChance )
                        TriggerGasExplosion();
                    break;
                case 6:
                    if( FRand() <= HealingExplosionChance )
                        TriggerHealingExplosion();
                    break;
                case 7:
                    if( FRand() <= NukeExplosionChance )
                        TriggerNukeExplosion();
                    break;
                case 8:
                    if( FRand() <= NorFleetExplosionChance )
                        TriggerNorFleetExplosion();
                    break;
                case 9:
                    if( FRand() <= ClusterNadesChance )
                    {
                        for(i = 0; i < ClusterNadesAmount; i++)
                            SpawnClusterNades();
                    }
                    break;
                case 10:
                    if( FRand() <= ArcMineChance )
                    {
                        for(i = 0; i < ArcMineAmount; i++)
                            SpawnArcMine();
                    }
                    break;
                case 11:
                    if( FRand() <= BuffExplosionChance )
                        TriggerBuffExplosion();
                    break;
                // default:
                //     break;
                }

                // if( FRand() <= ImpactExplosionChance )
                //     TriggerImpactExplosion();

                // if( FRand() <= FireExplosionChance )
                //     TriggerFireExplosion();

                // if( FRand() <= FreezeExplosionChance )
                //     TriggerFreezeExplosion();

                // if( FRand() <= EMPExplosionChance )
                //     TriggerEMPExplosion();

                // if( FRand() <= StunExplosionChance )
                //     TriggerStunExplosion();

                // if( FRand() <= GasExplosionChance )
                //     TriggerGasExplosion();

                // if( FRand() <= HealingExplosionChance )
                //     TriggerHealingExplosion();

                // if( FRand() <= NukeExplosionChance )
                //     TriggerNukeExplosion();

                // if( FRand() <= NorFleetExplosionChance )
                //     TriggerNorFleetExplosion();

                // if( FRand() <= ClusterNadesChance )
                // {
                //     for(i = 0; i < ClusterNadesAmount; i++)
                //         SpawnClusterNades();
                // }

                // if( FRand() <= ArcMineChance )
                //     SpawnArcMine();

                // if( FRand() <= BuffExplosionChance )
                //     TriggerBuffExplosion();
            }
        }
    }

    Super.StopSimulating();
}

function TriggerImpactExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( ImpactExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            ImpactExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(ImpactExplosionTemplate);
        }
    }
}

function TriggerFireExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( FireExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            FireExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(FireExplosionTemplate);
        }
    }
}

function TriggerFreezeExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( FreezeExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            FreezeExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(FreezeExplosionTemplate);
        }
    }
}

function TriggerEMPExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( EMPExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            EMPExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(EMPExplosionTemplate);
        }
    }
}

function TriggerStunExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( StunExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            StunExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(StunExplosionTemplate);
        }
    }
}

function TriggerGasExplosion()
{
    local KFExplosion_GasImpact ExploActor;

    if( GasExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosion_GasImpact', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            GasExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(GasExplosionTemplate);
        }
    }
}

function TriggerHealingExplosion()
{
    local KFExplosion_HealingExplosion ExploActor;

    if( HealingExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosion_HealingExplosion', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            // HealingExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(HealingExplosionTemplate);
        }
    }
}

function TriggerNukeExplosion()
{
    local KFExplosion_Nuke ExploActor;

    if( NukeExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosion_Nuke', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            NukeExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(NukeExplosionTemplate);
        }
    }
}

function TriggerNorFleetExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( NorFleetExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            NorFleetExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(NorFleetExplosionTemplate);
            SpawnNorFleetRing();
        }
    }
}

function SpawnNorFleetRing()
{
    local int TotalDamage;
    local TraceHitInfo HitInfo;
    local KFPawn_Monster Monster;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        foreach VisibleCollidingActors(class'KFPawn_Monster', Monster, NorFleetRingRange)
        {
            if( Monster != none && Monster.IsAliveAndWell() )
            {
                if( NorFleetRingDamage > 0 )
                {
                    NorFleetPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( NorFleetFX, Monster.Mesh, 'Spine', true );
                    NorFleetPSC.SetAbsolute(false, true, true);
                
                    TotalDamage = NorFleetRingDamage * UpgradeDamageMod;
                    Monster.TakeDamage(TotalDamage, InstigatorController, Monster.Mesh.GetBoneLocation('Spine'), vect(0,0,0), class'KFDT_EMP', HitInfo, self);
                }
            }
        }
    }
}

function SpawnClusterNades()
{
    local KFProj_Gremade_ClusterNades ClusterNades;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Location + vect(0,0,1) * ClusterNadesSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, ClusterNadeHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere

        ClusterNades = Spawn(class'KFProj_Gremade_ClusterNades', self,, SpawnLocation, SpawnRotation);
        if( ClusterNades != none )
        {
            ClusterNades.Instigator = Instigator;
            ClusterNades.InstigatorController = Instigator.Controller;
            ClusterNades.Velocity = Direction * ClusterNadesSpawnSpeed;
        }
    }
}

function SpawnArcMine()
{
    local KFProj_Mine_ArcMine ArcMine;
    local Vector SpawnLocation, Direction, DirectionUp;
    local Rotator SpawnRotation;
    
    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        SpawnLocation = Location + vect(0,0,1) * ArcMineSpawnOffsetZ;
        SpawnRotation = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, ArcMineHalfConeAngle * DegToRad ); //aim upwards in cone
        // Direction += VRand(); // aims anywere

        ArcMine = Spawn(class'KFProj_Mine_ArcMine', self,, SpawnLocation, SpawnRotation);
        if( ArcMine != none )
        {
            ArcMine.Instigator = Instigator;
            ArcMine.InstigatorController = Instigator.Controller;
            ArcMine.Velocity = Direction * ArcMineSpawnSpeed;
        }
    }
}

function TriggerBuffExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( BuffExplosionTemplate != none )
    {
        // Explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, rotator(vect(0,0,1)),, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            BuffExplosionTemplate.bIgnoreInstigator = true;

            ExploActor.Explode(BuffExplosionTemplate);
            BuffPlayers();
        }
    }
}

function BuffPlayers()
{
    local int i;
    local KFPawn_Human KFPH;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    if( Role == ROLE_Authority )
    {
        foreach VisibleCollidingActors(class'KFPawn_Human', KFPH, PlayerBuffRange)
        {
            if( KFPH != none && KFPH.IsAliveAndWell() )
            {
                for( i = 0; i < PlayerBuffAmount; i++ )
                {
                    KFPH.UpdateHealingSpeedBoost();
                    KFPH.UpdateHealingDamageBoost();
                    KFPH.UpdateHealingShield();
                }
            }
        }
    }
}

simulated protected function PrepareExplosionTemplate()
{
    super.PrepareExplosionTemplate();

    ImpactExplosionTemplate.bIgnoreInstigator = true;
    FireExplosionTemplate.bIgnoreInstigator = true;
    EMPExplosionTemplate.bIgnoreInstigator = true;
    StunExplosionTemplate.bIgnoreInstigator = true;
    GasExplosionTemplate.bIgnoreInstigator = true;
    // HealingExplosionTemplate.bIgnoreInstigator = true;
    NukeExplosionTemplate.bIgnoreInstigator = true;
    NorFleetExplosionTemplate.bIgnoreInstigator = true;
    BuffExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
    MaxSpeed=4000
    Speed=4000

	DamageRadius=0

    RandomizeVelocityInCone=true
    HalfConeAngle=12 //15

    // VelocityUpwards=false

    // bEnableWobble=false
    // WobbleForce=30.f

    SeekStrength=200000.0f //228000.0f

    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Projectile'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Projectile'
    // ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Crossbow_impact'
    
    bCanDisintegrate=false
    // ProjDisintegrateTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Projectile'

    LifeSpan=4 //10

/*
    bBlockedByInstigator=false
    bCollideActors=true
    bCollideComplex=true
    bNoEncroachCheck=true
    bNoReplicationToInstigator=false
    bUseClientSideHitDetection=true
    bUpdateSimulatedPosition=false
    bRotationFollowsVelocity=false
    bNetTemporary=false
    bSyncToOriginalLocation=true
    bSyncToThirdPersonMuzzleLocation=true
    bReplicateClientHitsAsFragments=true

    //PinBoneIdx=INDEX_None
    bCanStick=true
    bCanPin=false
    Begin Object Class=KFProjectileStickHelper_EarthSplitter Name=StickHelper0
        StickAkEvent=AkEvent'WW_WEP_EXP_C4.Play_WEP_EXP_C4_Handling_Detonate'
    End Object
    StickHelper=StickHelper0

    SecondsBeforeDetonation=0.4f
    bIsProjActive=true
    bCanDisintegrate=true
    bAlwaysReplicateExplosion=true

    ExplosionActorClass=class'KFExplosionActor'
*/

    // Explosion light
    Begin Object Class=PointLightComponent Name=ExplosionPointLight
        LightColor=(R=255,G=35,B=235,A=255)
        Brightness=2.f
        Radius=500.f
        FalloffExponent=10.f
        CastShadows=false
        CastStaticShadows=FALSE
        CastDynamicShadows=false
        bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Explosion
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=12 //16 24
        DamageRadius=200 //300
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_EarthSplitter'

        MomentumTransferScale=10000
        // bIgnoreInstigator=true

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'WEP_EarthSplitter_ARCH.EarthSplitter_Explosion'
        ExplosionSound=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Explosion_Heavy' //WW_Emotes.Play_Emote_Deluxe_SpiritFingers_Energy_Explosion

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
        CamShakeInnerRadius=30
        CamShakeOuterRadius=300
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ExplosionTemplate=ExploTemplate0

    // Explodes on kill once weapon has been upgraded
    ImpactExplosionUpgrade=false

// ************************* Impact *************************

    ImpactExplosionChance=0.3f

    // Impact explosion light
    Begin Object Class=PointLightComponent Name=ImpactExplosionPointLight
        LightColor=(R=252,G=218,B=171,A=255)
        Brightness=4.f
        Radius=2000.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=False
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Impact explosion
    Begin Object Class=KFGameExplosion Name=ImpactExplosion
        Damage=100 //200
        DamageRadius=650
        DamageFalloffExponent=2.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_HEGrenade'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0   
        ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HEGrenade_Explosion'
        ExplosionSound=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Impact_Explosion_Alt_Fire_Zed'

        // Dynamic Light
        ExploLight=ImpactExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ImpactExplosionTemplate=ImpactExplosion

// ************************* Fire *************************

    FireExplosionChance=0.3f

    // Fire explosion light
    Begin Object Class=PointLightComponent Name=FireExplosionPointLight
        LightColor=(R=245,G=190,B=140,A=255)
        Brightness=4.f
        Radius=1000.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=False
        bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Fire explosion
    Begin Object Class=KFGameExplosion Name=FireExplosion
        Damage=55
        DamageRadius=500
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Fire_MolotovGrenade'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'
        ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'

        // Dynamic Light
        ExploLight=FireExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    FireExplosionTemplate=FireExplosion

// ************************* Freeze *************************

    FreezeExplosionChance=0.3f

    // Freeze explosion light
    Begin Object Class=PointLightComponent Name=FreezeExplosionPointLight
        LightColor=(R=128,G=200,B=255,A=255)
        Brightness=4.f
        Radius=1500.f //1500
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=True
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Freeze explosion
    Begin Object Class=KFGameExplosion Name=FreezeExplosion
        Damage=25
        DamageRadius=900
        DamageFalloffExponent=1
        DamageDelay=0.f
        MyDamageType=class'KFDT_Freeze_FreezeGrenade'

        MomentumTransferScale=1
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Freeze_Impact_Explosion'
        ExplosionSound=AkEvent'WW_WEP_Freeze_Grenade.Play_Freeze_Grenade_Explo'

        // Dynamic Light
        ExploLight=FreezeExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    FreezeExplosionTemplate=FreezeExplosion

// ************************* EMP *************************

    EMPExplosionChance=0.3f

    // EMP explosion light
    Begin Object Class=PointLightComponent Name=EMPExplosionPointLight
        LightColor=(R=128,G=200,B=255,A=255)
        Brightness=4.f
        Radius=1500.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=True
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // EMP explosion
    Begin Object Class=KFGameExplosion Name=EMPExplosion
        Damage=25
        DamageRadius=700
        DamageFalloffExponent=1
        DamageDelay=0.f
        MyDamageType=class'KFDT_EMP_EMPGrenade'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.EMP_Impact_Explosion'
        ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

        // Dynamic Light
        ExploLight=EMPExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    EMPExplosionTemplate=EMPExplosion

// ************************* Stun *************************

    StunExplosionChance=0.3f

    // Stun explosion light
    Begin Object Class=PointLightComponent Name=StunExplosionPointLight
        LightColor=(R=252,G=218,B=171,A=255)
        Brightness=4.f
        Radius=2000.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=False
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Stun explosion
    Begin Object Class=KFGameExplosion Name=StunExplosion
        Damage=125
        DamageRadius=700
        DamageFalloffExponent=2.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_FlashBangGrenade'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0   
        ExplosionEffects=KFImpactEffectInfo'WEP_M84_ARCH.M84_Explosion'
        ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_Flashbang'

        // Dynamic Light
        ExploLight=StunExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    StunExplosionTemplate=StunExplosion

// ************************* Gas *************************

    GasExplosionChance=0.3f

    // Gas explosion
    Begin Object Class=KFGameExplosion Name=GasExplosion
        Damage=25
        DamageRadius=700
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_GasImpact'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0  
        // ExplosionEffects=KFImpactEffectInfo'ARCH'
        ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_GasDrum_Cloud'
        ExplosionSound=AkEvent'WW_WEP_MEL_MedicBat.Play_WEP_MedicBat_Smoke_Explode'

        // Camera Shake
        CamShake=none
    End Object
    GasExplosionTemplate=GasExplosion

// ************************* Healing *************************

    HealingExplosionChance=0.3f

    // Healing explosion
    Begin Object Class=KFGameExplosion Name=HealingExplosion
        Damage=50
        DamageRadius=350
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_MedicGrenade'

        MomentumTransferScale=0
        // bIgnoreInstigator=true
        // ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0  
        // ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.MedicGrenade_Explosion'
        ParticleEmitterTemplate=ParticleSystem'FX_Impacts_EMIT.FX_Medic_Airborne_Agent_01'
        ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Explosion'

        // Camera Shake
        CamShake=none
    End Object
    HealingExplosionTemplate=HealingExplosion

// ************************* Nuke *************************

    NukeExplosionChance=0.3f

    // Nuke explosion
    Begin Object Class=KFGameExplosion Name=NukeExplosion
        Damage=45
        DamageRadius=450
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_DemoNuke'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Nuke_Impact_Explosion'
        ExplosionSound=AkEvent'WW_GLO_Runtime.Play_WEP_Nuke_Explo'

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    NukeExplosionTemplate=NukeExplosion

// ************************* NorFleet *************************

    NorFleetExplosionChance=0.3f
    NorFleetRingRange=600
    NorFleetRingDamage=25
    NorFleetFX=ParticleSystem'Fass_EMIT.FX_NorFleet_Impact_Radial'

    // NorFleet explosion light
    Begin Object Class=PointLightComponent Name=NorFleetExplosionPointLight
        LightColor=(R=235,G=14,B=194,A=255)
        Brightness=1.f
        Radius=2000.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=False
        bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // NorFleet explosion
    Begin Object Class=KFGameExplosion Name=NorFleetExplosion
        Damage=100 // + NorFleetRingDamage
        DamageRadius=800
        DamageFalloffExponent=2.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_EMP'

        MomentumTransferScale=0
        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=0.0
        FracturePartVel=0.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.NorFleet_Impact_Explosion'
        ExplosionSound=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Tesla_Blast_Attack_01'

        // Dynamic Light
        ExploLight=NorFleetExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
        CamShakeInnerRadius=0
        CamShakeOuterRadius=300
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    NorFleetExplosionTemplate=NorFleetExplosion

// ************************* ClusterNades *************************

    ClusterNadesChance=0.3f
    ClusterNadeHalfConeAngle=30
    ClusterNadesAmount=3
    ClusterNadesSpawnOffsetZ=0
    ClusterNadesSpawnSpeed=1200

// ************************* ArcMine *************************

    ArcMineChance=0.3f
    ArcMineAmount=1
    ArcMineHalfConeAngle=30
    ArcMineSpawnOffsetZ=0
    ArcMineSpawnSpeed=1200

// ************************* Buff *************************

    BuffExplosionChance=0.3f
    PlayerBuffRange=1500
    PlayerBuffAmount=3

    // Buff explosion
    Begin Object Class=KFGameExplosion Name=BuffExplosion
        Damage=15 //25
        DamageRadius=1500
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Bludgeon'

        bIgnoreInstigator=true
        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ParticleEmitterTemplate=ParticleSystem'Fass_EMIT.FX_PlayerBuffRing'
        ExplosionSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Mid' // WW_WEP_Cryo_Gun.Play_WEP_HRG_Healthrower_MedicDart_Heal

        // Camera Shake
        CamShake=none
    End Object
    BuffExplosionTemplate=BuffExplosion
}