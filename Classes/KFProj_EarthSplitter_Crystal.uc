class KFProj_EarthSplitter_Crystal extends KFProj_BallisticExplosive
    config(Fass);

// Explosion template
var() config float PulseExplosionTime, CrystalExplosionDamage, CrystalExplosionRadius;
// Lifespan and clear projectile
var() config float FuseTime, CrystalLifeSpan;
// Secondary explosion
var KFGameExplosion PulseExplosionTemplate;
var() config float PulseDamage, PulseRadius;

// Zapping
var() config int ZapDamage, MaxNumberOfZedsZapped, MaxDistanceToBeZapped;
var() config float ZapInterval;
var float TimeToZap;

var KFPawn_Monster oZedCurrentlyBeingSprayed;

var ParticleSystem BeamPSCTemplate;

var string EmitterPoolClassPath;
var EmitterPool vBeamEffects;

struct BeamZapInfo
{
    var ParticleSystemComponent oBeam;
    var KFPawn_Monster oAttachedZed;
    var Actor oSourceActor;
    var float oControlTime;
};

var array<BeamZapInfo> CurrentZapBeams;

var AkComponent ZapSFXComponent;
var AkEvent ZapSFX;

var Controller oOriginalOwnerController;

simulated event PreBeginPlay()
{
    local class<EmitterPool> PoolClass;
    
    super.PreBeginPlay();

    oOriginalOwnerController = Instigator.Controller;

    PoolClass = class<EmitterPool>(DynamicLoadObject(EmitterPoolClassPath, class'Class'));
    if( PoolClass != None )
        vBeamEffects = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));

    // Allow to change these in configs
    LifeSpan = CrystalLifeSpan;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if( Role == ROLE_Authority )
    {
        SetTimer(FuseTime, false, 'ExplodeTimer');
        SetTimer(PulseExplosionTime, false, 'TriggerPulseExplosion');
    }

    // SetPhysics(PHYS_Rotating);
    // RotationRate.Yaw = 150000;
}

function TriggerPulseExplosion()
{
    local KFExplosionActorReplicated ExploActor;

    if( PulseExplosionTemplate != none )
    {
        // explode using the given template
        ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
        if( ExploActor != None )
        {
            ExploActor.Instigator = Instigator;
            ExploActor.InstigatorController = Instigator.Controller;

            PulseExplosionTemplate.Damage = PulseDamage;
            PulseExplosionTemplate.DamageRadius = PulseRadius;

            ExploActor.Explode(PulseExplosionTemplate);
        }
    }
}

simulated event Tick( float DeltaTime )
{
    Local int i;
    local vector BeamEndPoint;

    // super.Tick( DeltaTime );

    if( CurrentZapBeams.length > 0 )
    {
        for( i=0 ; i<CurrentZapBeams.length ; i++ )
        {
            CurrentZapBeams[i].oControlTime -= DeltaTime;
            if( CurrentZapBeams[i].oControlTime > 0 && CurrentZapBeams[i].oAttachedZed.IsAliveAndWell() )
            {
                BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');
                if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Location;

                CurrentZapBeams[i].oBeam.SetBeamSourcePoint(0, CurrentZapBeams[i].oSourceActor.Location, 0);
                CurrentZapBeams[i].oBeam.SetBeamTargetPoint(0, BeamEndPoint, 0);
            }
            else
            {
                CurrentZapBeams[i].oBeam.DeactivateSystem();
                CurrentZapBeams.RemoveItem(CurrentZapBeams[i]);
                i--;
            }
        }
    }

    TimeToZap += DeltaTime;
    if(TimeToZap > ZapInterval)
    {
        if(ZapFunction(self))
            TimeToZap = 0;
    }
}

// Notification that a direct impact has occurred
event ProcessDirectImpact()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(oOriginalOwnerController);
    if( KFPC != none )
        KFPC.AddShotsHit(1);
}

simulated function FinalEffectHandling()
{
    Local int i;

    if( CurrentZapBeams.length > 0 )
    {
        for( i=0 ; i<CurrentZapBeams.length ; i++ )
            CurrentZapBeams[i].oBeam.DeactivateSystem();
    }
}

simulated function bool ZapFunction(Actor _TouchActor)
{
    local vector BeamEndPoint;
    local KFPawn_Monster oMonsterPawn;
    local int iZapped;
    local ParticleSystemComponent BeamPSC;

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
    {
        if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != _TouchActor)
        {
            if( VSizeSQ(oMonsterPawn.Location - _TouchActor.Location) < Square(MaxDistanceToBeZapped) )
            {
                if( FastTrace(_TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false )
                    continue;

                if( WorldInfo.NetMode != NM_DedicatedServer )
                {
                    BeamPSC = vBeamEffects.SpawnEmitter(BeamPSCTemplate, _TouchActor.Location, _TouchActor.Rotation);

                    BeamEndPoint = oMonsterPawn.Mesh.GetBoneLocation('Spine1');
                    if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = oMonsterPawn.Location;

                    BeamPSC.SetBeamSourcePoint(0, _TouchActor.Location, 0);
                    BeamPSC.SetBeamTargetPoint(0, BeamEndPoint, 0);
                    
                    BeamPSC.SetAbsolute(false, false, false);
                    BeamPSC.bUpdateComponentInTick = true;
                    BeamPSC.SetActive(true);

                    StoreBeam(BeamPSC, oMonsterPawn);
                    ZapSFXComponent.PlayEvent(ZapSFX, true);
                }

                if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_StandAlone ||  WorldInfo.NetMode == NM_ListenServer )
                    ChainedZapDamageFunction(oMonsterPawn, _TouchActor);

                ++iZapped;
            }
        }

        if( iZapped >= MaxNumberOfZedsZapped )
            break;
    }

    if(iZapped > 0) 
        return true;
    else
        return false;
}

simulated function StoreBeam(ParticleSystemComponent Beam, KFPawn_Monster Monster)
{
    local BeamZapInfo BeamInfo;
    BeamInfo.oBeam = Beam;
    BeamInfo.oAttachedZed = Monster;
    BeamInfo.oSourceActor = self;
    BeamInfo.oControlTime = ZapInterval;
    CurrentZapBeams.AddItem(BeamInfo);
}

function ChainedZapDamageFunction(Actor _TouchActor, Actor _OriginActor)
{
    //local float DistToHitActor;
    local vector Momentum;
    local TraceHitInfo HitInfo;
    local Pawn TouchPawn;
 
    if( _OriginActor != none )
        Momentum = _TouchActor.Location - _OriginActor.Location;

    //DistToHitActor = VSize(Momentum);
    //Momentum *= (MomentumScale / DistToHitActor);
    if( ZapDamage > 0 )
    {
        TouchPawn = Pawn(_TouchActor);
        // Let script know that we hit something
        if (TouchPawn != none)
            ProcessDirectImpact();
        
        _TouchActor.TakeDamage(ZapDamage, oOriginalOwnerController, _TouchActor.Location, Momentum, class'KFDT_EMP_HVStormCannon', HitInfo, self);
    }
}

function ExplodeTimer()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    // Set these so that it doesn't zap when projectile explodes on uneven time
    MaxDistanceToBeZapped = 0;
    MaxNumberOfZedsZapped = 0;

    GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);
    TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function Destroyed()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    // Set these so that it doesn't zap when projectile explodes on uneven time
    MaxDistanceToBeZapped = 0;
    MaxNumberOfZedsZapped = 0;

    // Final Failsafe check for explosion effect
    if( !bHasExploded && !bHasDisintegrated )
    {
        GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);
        TriggerExplosion(HitLocation, HitNormal, HitActor);
    }

    super.Destroyed();
}

simulated function GetExplodeEffectLocation(out vector HitLocation, out vector HitRotation, out Actor HitActor)
{
    local vector EffectStartTrace, EffectEndTrace;
    local TraceHitInfo HitInfo;

    EffectStartTrace = Location + vect(0,0,1) * 4.f;
    EffectEndTrace = EffectStartTrace - vect(0,0,1) * 32.f;

    // Find where to put the decal
    HitActor = Trace(HitLocation, HitRotation, EffectEndTrace, EffectStartTrace, false,, HitInfo, TRACEFLAG_Bullet);

    // If the locations are zero (probably because this exploded in the air) set defaults
    if( IsZero(HitLocation) )
        HitLocation = Location;

    if( IsZero(HitRotation) )
        HitRotation = vect(0,0,1);
}

simulated protected function PrepareExplosionTemplate()
{
    super.PrepareExplosionTemplate();

    if( ExplosionTemplate != none )
    {
        // Since bIgnoreInstigator is transient, its value must be defined here 
        ExplosionTemplate.bIgnoreInstigator = true;
        // Config stats here
        ExplosionTemplate.Damage = CrystalExplosionDamage;
        ExplosionTemplate.DamageRadius = CrystalExplosionRadius;
    }

    if( PulseExplosionTemplate != none )
        PulseExplosionTemplate.bIgnoreInstigator = true;
}

DefaultProperties
{
    MaxSpeed=1200
    Speed=1200
    // LifeSpan=10
    
    // FuseTime=4.0
    // PulseExplosionTime=1

    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Crystal'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_EarthSplitter_Crystal'

    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    // Zapping
    Begin Object Class=AkComponent name=ZapOneShotSFX
        BoneName=dummy // need bone name so it doesn't interfere with default PlaySoundBase functionality
        bStopWhenOwnerDestroyed=true
    End Object
    ZapSFXComponent=ZapOneShotSFX
    Components.Add(ZapOneShotSFX)

    ZapSFX=AkEvent'WW_DEV_TestTones.Play_Beep_WeaponAtten' //ww_wep_hrg_energy.Play_WEP_HRG_Energy_1P_Shoot
    BeamPSCTemplate = ParticleSystem'Fass_EMIT.FX_IonCrystal_Beam'
    EmitterPoolClassPath="Engine.EmitterPool"

    // MaxNumberOfZedsZapped=4
    // MaxDistanceToBeZapped=600 //800
    // ZapInterval=0.8 //0.2
    TimeToZap=100
    // ZapDamage=20 //30

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
        // Damage=25 //100
        // DamageRadius=700 //600
        DamageFalloffExponent=1  //2
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_HRG_Stunner'

        ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'WEP_EarthSplitter_ARCH.EarthSplitter_Crystal_Explosion'
        ExplosionSound=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Impact_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
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
    ExplosionTemplate=ExploTemplate0

    // Pulse explosion
    Begin Object Class=KFGameExplosion Name=PulseRing
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
    PulseExplosionTemplate=PulseRing
}