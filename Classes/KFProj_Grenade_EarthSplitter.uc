class KFProj_Grenade_EarthSplitter extends KFProj_BallisticExplosive
	hidedropdown; //KFProjectile

// var KFGameExplosion PulseExplosionTemplate;
// var float PulseExplosionOffsetZ;

/*simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    local KFPawn_Monster HitMonster;

    Super.ProcessTouch(Other, HitLocation, HitNormal);

    HitMonster = KFPawn_Monster(Other);
    if( Role == ROLE_Authority )
    {
        if( HitMonster.IsAliveAndWell() )
        {
            // TriggerPulseExplosion()
            SetTimer(1.0, false, 'TriggerPulseExplosion');
        }
    }
}*/

/*simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    local KFPawn_Monster HitMonster;

    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);

    HitMonster = KFPawn_Monster(HitActor);
    if( Role == ROLE_Authority )
    {
        foreach VisibleCollidingActors(class'KFPawn_Monster', HitMonster, 1000, Location)
        {
            if( HitMonster.IsAliveAndWell() )
            {
                // TriggerPulseExplosion()
                SetTimer(1.0, false, 'TriggerPulseExplosion');
            }
        }
    }
}*/

/*simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);

    if( Role == ROLE_Authority )
    {
        // TriggerPulseExplosion()
        SetTimer(1.0, false, 'TriggerPulseExplosion');
    }
}*/

/*simulated function TriggerPulseExplosion()
{
    local KFExplosionActorReplicated ExploActor;
    local vector PulseLocation;

    if( PulseExplosionTemplate != none )
    {
        PulseLocation = Location + vect(0,0,1) * PulseExplosionOffsetZ;
        // PulseLocation.Z = PulseExplosionOffsetZ;

        // explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated',,, PulseLocation, Rotation,, true); //self
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            ExploActor.Explode(PulseExplosionTemplate);
        }
    }
}*/

/*
var() float SecondsBeforeDetonation;
var() bool bIsProjActive;

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
    if( bIsProjActive )
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
            {
                ExplosionActorClass = class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass();
            }
        }
    }

    super.SetExplosionActorClass();
}
*/

/*
// Used to check current status of StuckTo actor (to figure out if we should fall) 
simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (bIsProjActive)
        StickHelper.Tick(DeltaTime);

    if (!IsZero(Velocity))
        SetRelativeRotation(rotator(Velocity));
}

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

// simulated protected function PrepareExplosionTemplate()
// {
//     super.PrepareExplosionTemplate();
//     // Since bIgnoreInstigator is transient, its value must be defined here 
//     ExplosionTemplate.bIgnoreInstigator = true;
// }

defaultproperties
{
	Physics=PHYS_Falling
	Speed=2500
	MaxSpeed=2500
	TossZ=250

	DamageRadius=0

	// CollideActors=true allows detection via OverlappingActors or CollidingActors (for Siren scream)
	// Begin Object Name=CollisionCylinder
	// 	CollisionRadius=10.f
	// 	CollisionHeight=10.f
	// 	BlockNonZeroExtent=false
	// 	CollideActors=true
	// End Object
	
    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Grenade'
    ProjDisintegrateTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Grenade'
    // ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Crossbow_impact'

    LifeSpan=8 //20

    // PulseExplosionOffsetZ=20

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
    bSyncToThirdPersonMuzzleLocation=false
    bReplicateClientHitsAsFragments=true

    //PinBoneIdx=INDEX_None
    bCanStick=true
    bCanPin=false
    Begin Object Class=KFProjectileStickHelper_EarthSplitter Name=StickHelper0
    End Object
    StickHelper=StickHelper0

    SecondsBeforeDetonation=0.8f
    bIsProjActive=true
    bCanDisintegrate=true
    bAlwaysReplicateExplosion=true

    ExplosionActorClass=class'KFExplosionActor'
*/
    // Explosion light
    Begin Object Class=PointLightComponent Name=ExplosionPointLight
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

    // Explosion
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=400
        DamageRadius=600
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_HRG_Crossboom'

        // bIgnoreInstigator=true

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'WEP_EarthSplitter_ARCH.EarthSplitter_Grenade_Explosion'
        ExplosionSound=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Impact_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ExplosionTemplate=ExploTemplate0

    // Pulse explosion
/*    Begin Object Class=KFGameExplosion Name=PulseRing
        // Damage=25
        // DamageRadius=700
        DamageFalloffExponent=1
        DamageDelay=0.f
        MyDamageType=class'KFDT_EMP_EMPGrenade'

        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'WEP_EarthSplitter_ARCH.EarthSplitter_Pulse_Explosion'
        ExplosionSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Bass'

        // Camera Shake
        CamShake=none
    End Object
    PulseExplosionTemplate=PulseRing*/
}