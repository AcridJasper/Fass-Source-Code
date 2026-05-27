class KFWeap_Skull extends KFWeap_ThrownBase;

var transient KFParticleSystemComponent ParticlePSC;
var const ParticleSystem ParticleTemplate;
var name ParticleSocket;

// var KFPlayerControllerVersus Something;

// Route ironsight player input to melee
simulated function SetIronSights(bool bNewIronSights)
{
	if( !Instigator.IsLocallyControlled()  )
		return;

	if( bNewIronSights )
		StartFire(BASH_FIREMODE);
	else
		StopFire(BASH_FIREMODE);
}

static simulated event bool UsesAmmo()
{
    return true;
}

// ain't got one
// simulated function AltFireMode();

// Allow weapons with abnormal state transitions to always use zed time resist
simulated function bool HasAlwaysOnZedTimeResist()
{
    return true;
}

simulated state Active
{
	// Overridden to prevent playing fidget if play has no more ammo
	simulated function bool CanPlayIdleFidget(optional bool bOnReload)
	{
		if( !HasAmmo(0) )
			return false;

		return super.CanPlayIdleFidget( bOnReload );
	}
}

simulated state WeaponThrowing
{
	// Never refires. Must re-enter this state instead
	simulated function bool ShouldRefire()
	{
		return false;
	}

    simulated function EndState(Name NextStateName)
    {
        local KFPerk InstigatorPerk;

        Super.EndState(NextStateName);

        //Targeted fix for Demolitionist w/ the C4.  It should remain in zed time  while waiting on
        //      the fake reload to be triggered.  This will return 0 for other perks.
        InstigatorPerk = GetPerk();
        if( InstigatorPerk != none )
        {
            SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
        }
    }
}

simulated state WeaponEquipping
{
	simulated event BeginState( name PreviousStateName )
	{
		super.BeginState( PreviousStateName );

		// SpawnMonster();

		ActivatePSC(ParticlePSC, ParticleTemplate, ParticleSocket);

		// perform a "reload" if we refilled our ammo from empty while it was unequipped
		if( !HasAmmo(THROW_FIREMODE) && HasSpareAmmo() )
			PerformArtificialReload();
	}
}

/*
simulated function SpawnMonster(optional float Distance = 0.f)
{
    local class<KFPawn_Monster> MonsterClass;
    local KFPawn ZED;
	local KFPawn_Human YOU;
	local KFPlayerController KFPC;
    local vector SpawnLoc;
    local rotator SpawnRot;

    MonsterClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshPound_Versus", class'Class'));

    SpawnLoc = Location; // location of the bullet

    SpawnLoc += Distance * vector(Rotation) + vect(0,0,1) * 150; // offset the spawn
    SpawnRot.Yaw = Rotation.Yaw + 32768;

	YOU = KFPawn_Human(Instigator);
    KFPC = KFPlayerController(Instigator.Controller);
    ZED = Spawn( MonsterClass,,, SpawnLoc, SpawnRot,, false );
    if( ZED != None )
    {
        if( YOU != none )
            YOU.Destroy();
        if( YOU.Controller != none )
            YOU.Controller.Destroy();
    	
        ZED.SetPhysics(PHYS_Falling);
        ZED.SpawnDefaultController();
        KFPC.Possess( ZED, false );
        KFPC.ServerCamera( 'ThirdPerson' );
    }
}

simulated function SpawnZedV()
{
	local KFPawn_Human YOU;
	local KFPlayerController KFPC;
    local class<KFPawn_Monster> MonsterClass;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local KFPawn KFP;

    MonsterClass = class<KFPawn_Monster>(DynamicLoadObject("KFPawn_ZedFleshPound_Versus", class'Class'));

    if( MonsterClass != none )
    {
		YOU = KFPawn_Human(Instigator);
        if( YOU != None )
            SpawnLoc = Location;

        SpawnLoc += 200.f * vector(Rotation) + vect(0,0,1) * 15.f;
        SpawnRot.Yaw = Rotation.Yaw + 32768;

        KFPC = KFPlayerController(Instigator.Controller);
        KFP = Spawn( MonsterClass,,, SpawnLoc, SpawnRot,, false );
        if( KFP != none )
        {
            if( YOU != none )
                YOU.Destroy();
            if( YOU.Controller != none )
                YOU.Controller.Destroy();

            KFPC.Possess( KFP, false );
            KFPC.ServerCamera( 'ThirdPerson' );

            KFP.SetPhysics( PHYS_Falling );
        }
    }
}
*/

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
		// local KFPlayerController KFPC;
	
	super.SetFOV(NewFOV);

   		// KFPC = KFPlayerController(Instigator.Controller);
		// WorldInfo.Game.SwapPlayerControllers(KFPC, Something);
		// Something = KFPlayerControllerVersus(Instigator.Controller);

   		// KFPC = KFPlayerController(Instigator.Controller);
			// foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    	    	// WorldInfo.Game.PlayerControllerClass = class'KFPlayerControllerVersus';
				// WorldInfo.Game.SwapPlayerControllers(KFPC, Something);
		

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

function DropFrom(vector StartLocation, vector StartVelocity)
{
	local DroppedPickup P;

	// Offset spawn closer to eye location
	StartLocation.Z += Instigator.BaseEyeHeight / 2;

	// for some reason, Inventory::DropFrom removes weapon from inventory whether it was able to spawn the pickup or not.
	// we only want the weapon removed from inventory if pickup was successfully spawned, so instead of calling the supers,
	// do all the super functionality here.

	if( !CanThrow() )
	{
		return;
	}

	if( DroppedPickupClass == None || DroppedPickupMesh == None )
	{
		Destroy();
		return;
	}

	// Destroy skull when it's being dropped
	if( Class.Name == 'KFWeap_Skull' )
	{
		Destroy();
		return;
	}

	// the last bool param is to prevent collision from preventing spawns
	P = Spawn(DroppedPickupClass,,, StartLocation,,,true);
	if( P == None )
	{
		// if we can't spawn the pickup (likely for collision reasons),
		// just return without removing from inventory or destroying, which removes from inventory
		PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_FailedDropInventory );
		return;
	}

	if( Instigator != None && Instigator.InvManager != None )
	{
		Instigator.InvManager.RemoveFromInventory(Self);

		if( Instigator.IsAliveAndWell() && !Instigator.InvManager.bPendingDelete )
		{
			`DialogManager.PlayDropWeaponDialog( KFPawn(Instigator) );
		}
	}

	SetupDroppedPickup( P, StartVelocity );

	Instigator = None;
	GotoState('');

	AIController = None;
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Explosive;
}

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=6.0,Y=2,Z=-4)

	// Create all these particle system components off the bat so that the tick group can be set
	// fixes issue where the particle systems get offset during animations
	Begin Object Class=KFParticleSystemComponent Name=BasePSC0
		TickGroup=TG_PostUpdateWork
	End Object
	ParticlePSC=BasePSC0
	ParticleTemplate=ParticleSystem'Fass_EMIT.FX_Trophy_1P'
	ParticleSocket=Particle

	// Content
	PackageKey="Skull"
	FirstPersonMeshName="Fass_EMIT.Wep_1stP_Skull_Rig"
	FirstPersonAnimSetNames(0)="Fass_ARCH.Wep_1P_Skull_ANIM"
	// PickupMeshName=""
	AttachmentArchetypeName="Fass_ARCH.WEP_Skull_3P"

	// Anim
	FireAnim=C4_Throw
	FireLastAnim=C4_Throw_Last

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=5
	InitialSpareMags[0]=5
	AmmoPickupScale[0]=3.0

	// THROW_FIREMODE
	FireModeIconPaths(THROW_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade'
	WeaponProjectiles(THROW_FIREMODE)=class'KFProj_Projectile_Skull'
	InstantHitDamageTypes(THROW_FIREMODE)=class'KFDT_Bludgeon_ChainBat'
	InstantHitDamage(THROW_FIREMODE)=90
	FireInterval(THROW_FIREMODE)=0.25
	NumPellets(DEFAULT_FIREMODE)=1
	Spread(DEFAULT_FIREMODE)=0.025
	// PenetrationPower(DEFAULT_FIREMODE)=0.0
	FireOffset=(X=25,Y=4) //y=15

	// ALTFIRE_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_C4'
	InstantHitDamage(BASH_FIREMODE)=24

	// Inventory / Grouping
	InventoryGroup=IG_Equipment
	GroupPriority=2
	WeaponSelectTexture=Texture2D'Fass_MAT.UI_WeaponSelect_Skull'
	InventorySize=1

	AssociatedPerkClasses(0)=none
   	// AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}