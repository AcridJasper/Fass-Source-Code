class KFDroppedPickup_Trophy_AmmunitionBox extends KFDroppedPickup_TrophyBase;

/*
// var PrimitiveComponent PickupMesh;
var PrimitiveComponent RandomWeaponBoxMesh;

simulated function PostBeginPlay()
{
    super.PreBeginPlay();
    
    // AttachComponent(PickupMesh);
    AttachComponent(RandomWeaponBoxMesh);
}
*/

DefaultProperties
{
    AmmoAmount=25 //50
    NoMagAmmoAmount=5
    GrenadeAmount=1

    // bEnableGlowLight=true
    // Begin Object Name=PointLight0
    //     LightColor=(R=0,G=255,B=0,A=255)
    //     Brightness=3.5f
    //     Radius=85.f
    //     bEnabled=true
    // End Object

/*
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        // StaticMesh=StaticMesh'ENV_Horzine_MESH.crates.ENV_Horzine_Equiptment_Crate_02'
        StaticMesh=StaticMesh'ENV_VolterCastle_MESH_BOSS.Mat.deco.ENV_TommyGun_Pickup'
        // Materials(0)=MaterialInstanceConstant'GP_Mat_Lib.GP_Ammo_MIC'
        Scale=5.5f
        bCastDynamicShadow=FALSE
        CollideActors=FALSE
        // Translation=(Z=-50)
    End Object
    PickupMesh=StaticMeshComponent0
    Components.Add(StaticMeshComponent0)
*/

/*
    Begin Object Class=SkeletalMeshComponent Name=SkelMesh0
        SkeletalMesh=SkeletalMesh'Fass_MESH.AmmunitionBox'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.AmmunitionBox_SM_Physics'
        // Scale=0.5f
        bCastDynamicShadow=FALSE
    End Object
    RandomWeaponBoxMesh=SkelMesh0

    Begin Object name=CollisionCylinder
        CollisionRadius=100.f
        CollisionHeight=50.f
    End Object
*/
}