class KFDroppedPickup_Trophy_RallySkull extends KFDroppedPickup;

// var float Health;

// Particle system
var ParticleSystem TrophyFX;
var transient ParticleSystemComponent TrophyPSC;

// Rally ZEDs
var bool BuffZEDs;
var float RallyRadius, BuffZEDsDelay;
var AkEvent RallySound;
var KFPawn_Monster RallyTarget;
var ParticleSystem RallyEffect, AltRallyEffect;
var name RallyEffectBoneName;
var name AltRallyEffectBoneNames[2];
var vector RallyEffectOffset, AltRallyEffectOffset;
var ParticleSystem SkullRallingFX;
var transient ParticleSystemComponent SkullRallingPSC;

// Point light
var bool bEnableGlowLight;
// var float LightFadeStartTime;
var transient float LightFadePerSecond;
var PointLightComponent GlowLight;
var LightPoolPriority GlowLightPriority;

simulated function PostBeginPlay()
{
    if( TrophyFX != none )
        StartTrophyFX();

    if( WorldInfo.NetMode != NM_DedicatedServer )
        LightFadePerSecond = GlowLight.Brightness;

    // Set its light if it has one
    if( bEnableGlowLight )
    {
        if( GlowLight != None )
        {
            AttachComponent(GlowLight);
            `LightPool.RegisterPointLight(GlowLight, GlowLightPriority);
        }
    }

    // Buffs ZEDs
    if( BuffZEDs )
        SetTimer(BuffZEDsDelay, false, nameof(BuffVisibleZEDs));

    super.PreBeginPlay();
}

simulated function StartTrophyFX()
{
    TrophyPSC = new(self) class'ParticleSystemComponent';
    TrophyPSC.SetTemplate( TrophyFX );
    AttachComponent(TrophyPSC);
    TrophyPSC.SetAbsolute(false, true, true);
}

simulated function StopTrophyFX()
{
    if( WorldInfo.NetMode != NM_DedicatedServer && TrophyPSC != none )
        TrophyPSC.DeactivateSystem();
}

function GiveTo( Pawn P )
{
    // Can't pickup
}

auto state Pickup
{
    // Can't pickup
}

simulated function BuffVisibleZEDs()
{
    if( RallySound != None )
        PlaySoundBase(RallySound, true,, true);
    
    if( SkullRallingFX != none )
        StartSkullRallingFX();

    foreach WorldInfo.GRI.VisibleCollidingActors(class'KFPawn_Monster', RallyTarget, RallyRadius, Location)
    {
        RallyTarget.Rally(RallyTarget, RallyEffect, RallyEffectBoneName, RallyEffectOffset, AltRallyEffect, AltRallyEffectBoneNames, AltRallyEffectOffset, false);
    }
}

simulated function StartSkullRallingFX()
{
    SkullRallingPSC = new(self) class'ParticleSystemComponent';
    SkullRallingPSC.SetTemplate( SkullRallingFX );
    AttachComponent(SkullRallingPSC);
    SkullRallingPSC.SetAbsolute(false, true, true);
}

simulated function StopSkullRallingFX()
{
    if( WorldInfo.NetMode != NM_DedicatedServer && SkullRallingPSC != none )
        SkullRallingPSC.DeactivateSystem();
}

State FadeOut
{
    function Tick(float DeltaTime)
    {
        local float NewBrightness;

        // Fade out gradually
        if ( GlowLight != None && GlowLight.bAttached )
        {
            if( GlowLight.Brightness > 0 )
            {
                NewBrightness = FMax( 0.01, GlowLight.Brightness - (LightFadePerSecond * DeltaTime) );
                GlowLight.SetLightProperties( NewBrightness );
            }
        }

        TrophyPSC.SetScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
        SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
        Global.Tick(DeltaTime);
    }

    simulated event BeginState(Name PreviousStateName)
    {
        bFadeOut = true;
        RotationRate.Yaw=60000;
        SetPhysics(PHYS_Rotating);
        LifeSpan = 1.0;

        SetTimer(2.0, false, nameof(StopSkullRallingFX));
        // SetTimer(2.0, false, nameof(KYS)); // Fully kill off all effects
    }

    // disable normal touching. we require input from the player to pick it up
    event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

event Destroyed()
{
    // super.Destroyed();
    
    // Do NOT destroy the inventory item
    // Inventory = none;
}

/*
simulated function KYS()
{
    ClearTimer(nameof(BuffZEDsDelay));
    ClearTimer(nameof(TryFadeOut));
    GotoState('Died');
}

event Destroyed()
{
    super.Destroyed();
    
    Inventory.Destroy();
    Inventory = none;
}

State Died
{
    simulated event BeginState(Name PreviousStateName)
    {
        ClearTimer(nameof(BuffZEDsDelay));
        ClearTimer(nameof(TryFadeOut));
        SetDrawScale(0);
        StopTrophyFX();
        TrophyPSC.SetScale(0);
        StopSkullRallingFX();
        SkullRallingPSC.SetScale(0);
    }
}

// Capture damage so that human players can destroy the krystal
singular event TakeDamage( int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
    if( Health > 0 && inDamage > 0 )
    {
        Health -= inDamage;
        if( Health <= 0 )
            KYS();
    }
}
*/

DefaultProperties
{
    LifeSpan=8

    // ZED Rally
    BuffZEDs=true
    BuffZEDsDelay=5
    RallyRadius=1000.0f
    RallySound=AkEvent'WW_ZED_Clot_Alpha.Play_Alpha_Clot_Special_Enrage'
    RallyEffect=ParticleSystem'ZED_ClotHans_EMIT.FX_ClotA_Rage_01'
    AltRallyEffect=ParticleSystem'ZED_ClotHans_EMIT.FX_Player_Zed_Buff_01'
    RallyEffectBoneName="Root"
    AltRallyEffectBoneNames(0)="FX_EYE_L"
    AltRallyEffectBoneNames(1)="FX_EYE_R"
    RallyEffectOffset=(X=0.0f,Y=0.0f,Z=0.0f)
    AltRallyEffectOffset=(X=0.0f,Y=0.0f,Z=0.0f)
    SkullRallingFX=ParticleSystem'Fass_EMIT.FX_RallySkull_RallyFX'

/*
    Health=40

    bCollideActors=true
    bProjTarget=true
    bCanBeDamaged=true
    bCollideComplex=true
    bNoEncroachCheck=true
    // bPushedByEncroachers=false
    bAlwaysRelevant=true
    bGameRelevant=true

    Begin Object Name=CollisionCylinder
        // CollisionRadius=0.f
        // CollisionHeight=0.f
        CollideActors=true
        // Beam weapons (microwave gun, flamey things, etc.) won't hit without this
        BlockNonZeroExtent=true
        PhysMaterialOverride=PhysicalMaterial'Fass_ARCH.MeatySkull_PM'
    End Object
*/

    TrophyFX=ParticleSystem'Fass_EMIT.FX_RallySkull_Indicator'

    bEnableGlowLight=false
    Begin Object Class=PointLightComponent Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        FalloffExponent=3.0f
        CastShadows=FALSE
        CastStaticShadows=false
        CastDynamicShadows=false
        bCastPerObjectShadows=false
        bEnabled=true
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object
    GlowLight=PointLight0
    GlowLightPriority=LPP_High
}