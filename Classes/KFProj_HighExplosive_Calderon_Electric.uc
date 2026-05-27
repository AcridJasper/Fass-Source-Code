class KFProj_HighExplosive_Calderon_Electric extends KFProjectile
    config(Fass);
	// hidedropdown;

var float FuseTime;

// Zapping
var() config int ZapDamage, MaxNumberOfZedsZapped, MaxDistanceToBeZapped;
var() config float ZapInterval;
var float TimeToZap;
var vector BeamOffset;

var() config float EMPExplosionDamage, EMPExplosionRadius;

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

    if( ExplosionTemplate != none )
    {
        ExplosionTemplate.Damage = EMPExplosionDamage * UpgradeDamageMod;
        ExplosionTemplate.DamageRadius = EMPExplosionRadius;
    }
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if( Role == ROLE_Authority )
        SetTimer(FuseTime, false, 'ExplodeTimer');

    AdjustCanDisintigrate();
}

simulated event Tick( float DeltaTime )
{
    Local int i;
    local vector BeamEndPoint;

    super.Tick( DeltaTime );

    StickHelper.Tick(DeltaTime);

    if( !IsZero(Velocity) )
        SetRelativeRotation(rotator(Velocity));

    if( CurrentZapBeams.length > 0 )
    {
        for( i=0 ; i<CurrentZapBeams.length ; i++ )
        {
            CurrentZapBeams[i].oControlTime -= DeltaTime;
            if( CurrentZapBeams[i].oControlTime > 0 && CurrentZapBeams[i].oAttachedZed.IsAliveAndWell() )
            {
                BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');
                if( BeamEndPoint == vect(0,0,0) )
                    BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Location;

                CurrentZapBeams[i].oBeam.SetBeamSourcePoint(0, CurrentZapBeams[i].oSourceActor.Location + BeamOffset, 0);
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
	if( TimeToZap > ZapInterval )
	{
	    if( ZapFunction(self) )
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

simulated function bool ZapFunction(Actor TouchActor)
{
    local vector BeamEndPoint;
    local KFPawn_Monster oMonsterPawn;
    local int iZapped;
    local ParticleSystemComponent BeamPSC;

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
    {
        if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != TouchActor)
        {
            if( VSizeSQ(oMonsterPawn.Location - TouchActor.Location) < Square(MaxDistanceToBeZapped) )
            {
                if( FastTrace(TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false )
                    continue;

                if( WorldInfo.NetMode != NM_DedicatedServer )
                {
                    BeamPSC = vBeamEffects.SpawnEmitter(BeamPSCTemplate, TouchActor.Location, TouchActor.Rotation);

                    BeamEndPoint = oMonsterPawn.Mesh.GetBoneLocation('Spine1');
                    if( BeamEndPoint == vect(0,0,0) )
                        BeamEndPoint = oMonsterPawn.Location;

                    BeamPSC.SetBeamSourcePoint(0, TouchActor.Location + BeamOffset, 0);
                    BeamPSC.SetBeamTargetPoint(0, BeamEndPoint, 0);
                    
                    BeamPSC.SetAbsolute(false, false, false);
                    BeamPSC.bUpdateComponentInTick = true;
                    BeamPSC.SetActive(true);

                    StoreBeam(BeamPSC, oMonsterPawn);
                    ZapSFXComponent.PlayEvent(ZapSFX, true);
                }

                if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_StandAlone ||  WorldInfo.NetMode == NM_ListenServer )
                    ChainedZapDamageFunction(oMonsterPawn, TouchActor);

                ++iZapped;
            }
        }

        if( iZapped >= MaxNumberOfZedsZapped )
            break;
    }

    if( iZapped > 0 ) 
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

function ChainedZapDamageFunction(Actor TouchActor, Actor OriginActor)
{
    //local float DistToHitActor;
    local vector Momentum;
    local TraceHitInfo HitInfo;
    local Pawn TouchPawn;
 
    if( OriginActor != none )
        Momentum = TouchActor.Location - OriginActor.Location;

    //DistToHitActor = VSize(Momentum);
    //Momentum *= (MomentumScale / DistToHitActor);
    if( ZapDamage > 0 )
    {
        TouchPawn = Pawn(TouchActor);
        // Let script know that we hit something
        if( TouchPawn != none )
            ProcessDirectImpact();
        
        TouchActor.TakeDamage(ZapDamage, oOriginalOwnerController, TouchActor.Location, Momentum, class'KFDT_EMP', HitInfo, self);
    }
}

// Trace down and get the location to spawn the explosion effects and decal
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

function ExplodeTimer()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    StickHelper.UnPin();

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

    StickHelper.UnPin();

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

simulated function SyncOriginalLocation()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;
    local TraceHitInfo HitInfo;

    if( Role < ROLE_Authority && Instigator != none && Instigator.IsLocallyControlled() )
    {
        HitActor = Trace(HitLocation, HitNormal, OriginalLocation, Location,,, HitInfo, TRACEFLAG_Bullet);
        if( HitActor != none )
            StickHelper.TryStick(HitNormal, HitLocation, HitActor);
    }
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
    class'KFPerk_Demolitionist'.static.PrepareExplosive(Instigator, self);
    super.PrepareExplosionTemplate();
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

/*simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	// Since bIgnoreInstigator is transient, its value must be defined here
	ExplosionTemplate.bIgnoreInstigator = true;
}*/

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
    TerminalVelocity=4000
    TossZ=150
    GravityScale=1.0
	LifeSpan=0

    FuseTime=5.0
	PostExplosionLifetime=1

	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Electric'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_Calderon_Projectile_Electric'

	// bCanDisintegrate=false
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	// Mine functionality
	bBounce=true
	bNetTemporary=false

    bIgnoreFoliageTouch=true
	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=true
	bCollideComplex=true
	bNoEncroachCheck=true
    // bPushedByEncroachers=false
	bAlwaysRelevant=true
	bGameRelevant=true

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

	// MaxNumberOfZedsZapped=2
	// MaxDistanceToBeZapped=600 //800
	// ZapInterval=0.2 //0.8
	TimeToZap=100
	// ZapDamage=12
    BeamOffset=(X=0,Y=0,Z=20)

    bCanStick=true
    bCanPin=false
    Begin Object Class=KFProjectileStickHelper Name=StickHelper0
        StickAkEvent=AkEvent'WW_WEP_EXP_C4.Play_WEP_EXP_C4_Handling_Place'
    End Object
    StickHelper=StickHelper0

    ExplosionActorClass=class'KFExplosionActor'

	// Explosion light
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

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
        // Damage=25
        // DamageRadius=700
        DamageFalloffExponent=1
        DamageDelay=0.f
        MyDamageType=class'KFDT_EMP_EMPGrenade'

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
	ExplosionTemplate=ExploTemplate0
}