class KFWeap_InstaGibCrowbar extends KFWeap_MeleeBase;

var KFProjectile Rocket;
var int HalfConeAngle;
var float TraceDist;
var float SeekStrength, RocketSpeed;
var vector TraceHitLocation;

simulated event Tick( float DeltaTime )
{
    local vector HitNormal, StartTrace, EndTrace;
    local rotator AimRot;
	local vector DirToTarget;

	super.Tick( DeltaTime );

    StartTrace = GetSafeStartTraceLocation();
    AimRot = GetAdjustedAim(StartTrace);
    EndTrace = StartTrace + vector(AimRot) * TraceDist;
    Trace( TraceHitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0),, 1 );

	if( Rocket != none )
	{
		Rocket.Speed = VSize( Rocket.Velocity );
		DirToTarget = Normal( TraceHitLocation - Rocket.Location );
		Rocket.Velocity = Normal( Rocket.Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Rocket.Speed;
	}
}

exec function FireRocket()
{
	local vector SpawnLocation;
	local rotator SpawnRotation;

	if( Role == ROLE_Authority )
	{
		MySkelMesh.GetSocketWorldLocationAndRotation( 'BlockEffect', SpawnLocation, SpawnRotation );
		SpawnRocketProjectile( SpawnLocation, SpawnRotation );
	}
}

simulated function SpawnRocketProjectile( vector SpawnLocation, rotator SpawnRotation )
{
	local vector Direction, DirectionUp;
    
    SpawnRotation = Rotator(Direction);
	DirectionUp = vect(0,0,1);
	Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone

	Rocket = Spawn( class'KFProj_Rocket_InstaGibCrowbar', Instigator,, SpawnLocation, SpawnRotation,, true );
	if( Rocket != none )
	{
		Rocket.Instigator = Instigator;
		Rocket.Init( vector(SpawnRotation) );
	    Rocket.Velocity = Direction * RocketSpeed;
	}
}

defaultproperties
{
	HalfConeAngle=20
	TraceDist=150000
	SeekStrength=15000.0f
	RocketSpeed=3000

	// Content
	PackageKey="InstaGibCrowbar"
	
	// Crovel
	FirstPersonMeshName="WEP_InstaGibCrowbar_MESH.Wep_1stP_InstaGibCrowbar_Rig"
	FirstPersonAnimSetNames(0)="WEP_InstaGibCrowbar_ARCH.WEP_1P_InstaGibCrowbar_ANIM"
	PickupMeshName="WEP_InstaGibCrowbar_MESH.Wep_InstaGibCrowbar_Pickup"
	AttachmentArchetypeName="WEP_InstaGibCrowbar_ARCH.Wep_InstaGibCrowbar_3P"

	Begin Object Name=MeleeHelper_0
		MaxHitRange=190
		// Override automatic hitbox creation (advanced)
		HitboxChain.Add((BoneOffset=(X=+3,Z=190)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=170)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=150)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=130)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=110)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=90)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=70)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
		// modified combo sequences
		MeleeImpactCamShakeScale=0.035f //0.4
		ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardLeft, DIR_Left, DIR_Right, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_BackwardRight, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_BackwardLeft, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

    // Inventory
	GroupPriority=21 // funny number
	InventorySize=4
	WeaponSelectTexture=Texture2D'WEP_InstaGibCrowbar_MAT.UI_WeaponSelect_InstaGibCrowbar'

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_InstaGibCrowbar_Light'
	InstantHitDamage(DEFAULT_FIREMODE)=999999

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Bludgeon_InstaGibCrowbar_Heavy'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=999999

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_InstaGibCrowbar_Bash'
	InstantHitDamage(BASH_FIREMODE)=25

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'
	
	ParryStrength=99
	ParryDamageMitigationPercent=5
	BlockDamageMitigation=5
}