class KFProj_Grenade_Car extends KFProj_Grenade
	hidedropdown;

// var ParticleSystemComponent	ProjectorPSC;
// var(Projectile) ParticleSystem ProjectorFX;

// var transient bool bZEDReadyToUse;

var int CarSpawnSpeed;
var int CarSpawnOffsetZ;
var int HalfConeAngle;
var PrimitiveComponent CarMesh;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// fuze starts at rest
	ClearTimer(nameof(ExplodeTimer));
}

simulated event GrenadeIsAtRest()
{
	local rotator NewRotation;

	super.GrenadeIsAtRest();

	NewRotation.Pitch=0;
	SetRotation(NewRotation);

	if( Role == ROLE_Authority )
	{
		SetTimer(FuseTime, false, 'ExplodeTimer');
		SetTimer(1.0, false, 'SpawnCar');
		// SpawnFriendly();
	}

	// if( ProjectorFX != None )
	//     ProjectorPSC = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjectorFX);

	// if(ProjectorPSC != None)
	// {
	// 	ProjectorPSC.SetAbsolute(false, true, true);
	// 	AttachComponent(ProjectorPSC);
	// }
}

// simulated protected function StopSimulating()
// {
// 	super.StopSimulating();

// 	if( ProjectorPSC!=None )
//         ProjectorPSC.DeactivateSystem();
// }

function SpawnCar()
{
    local KFDroppedPickup_Trophy_Car Car;
    local Vector Pos, Direction, DirectionUp;
    local rotator Rot;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        Pos = Location + vect(0,0,1) * CarSpawnOffsetZ;
        Rot = Rotator(Direction);
        DirectionUp = vect(0,0,1);
        Direction = VRandCone( DirectionUp, HalfConeAngle * DegToRad ); //aim upwards in cone

        Car = Spawn(class'KFDroppedPickup_Trophy_Car',,, Pos, Rot,, false);
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

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed=1500 //2000
	MaxSpeed=1500
	TossZ=150
    GravityScale=1.5

    CarSpawnOffsetZ=100
    CarSpawnSpeed=300
    HalfConeAngle=20

    Begin Object Class=SkeletalMeshComponent Name=PickupMesh0
        SkeletalMesh=SkeletalMesh'Fass_MESH.whip'
        PhysicsAsset=PhysicsAsset'Fass_PHYS.Whip_SM_Physics'
        BlockNonZeroExtent=false
        CastShadow=false
    End Object
    CarMesh=PickupMesh0

	// bZEDReadyToUse=true
	// ProjectorFX=ParticleSystem'ZED_H37LO_EMIT.FX_H37LO_Hologram'

	ProjFlightTemplate=ParticleSystem'DROW3_EMIT.FX_ZEDNade_Grenade_Projectile'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'

	bCanDisintegrate=false
	// ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	WeaponSelectTexture=Texture2D'DROW3_MAT.UI_WeaponSelect_ZEDNade'
	AssociatedPerkClass=class'KFPerk_Survivalist'

    LandedTranslationOffset=(X=0)

    FuseTime=30

	ExplosionActorClass=class'KFExplosionActor'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=400.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=10
		DamageRadius=100
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_HRG_Boomy'
		
		MomentumTransferScale=10000
		bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionSound=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_ProjExplosion'
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Boomy_ARCH.WEB_HRG_Boomy_Impacts'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}