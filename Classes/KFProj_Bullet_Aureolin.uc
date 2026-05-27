class KFProj_Bullet_Aureolin extends KFProj_Bullet
	hidedropdown;

var bool bSpawnGroundFire;
var float EffectDuration, DamageInterval;
var class<KFExplosionActorLingering> GroundExplosionActorClass;
var KFGameExplosion GroundExplosionTemplate;

var KFGameExplosion ImpactExplosionTemplate;

var ParticleSystem AddedImpactEffect;

// Last hit normal from Touch() or HitWall()
var vector LastHitNormal;

// var KFPawn_Monster HitMonster;

replication
{
    if( bNetInitial )
        bSpawnGroundFire;
}

simulated function PostBeginPlay()
{
    local KFWeap_Aureolin Cannon;

    if( Role == ROLE_Authority )
    {
        Cannon = KFWeap_Aureolin(Owner);
        if( Cannon != none )
            bSpawnGroundFire = true;
    }

    super.PostBeginPlay();
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    // local KFWeap_Aureolin Cannon;
    // local KFPawn_Monster HitMonster;

    LastHitNormal = HitNormal;
    Super.ProcessTouch(Other, HitLocation, HitNormal);

    // // Necromancer (Shoot corpse to explode it once) 
    // HitMonster = KFPawn_Monster(Other);
    // if( WorldInfo.NetMode != NM_DedicatedServer && (HitMonster.bTearOff && HitMonster.bPlayedDeath) )
    // {
    //     SpawnImpactExplosion();
    //     HitMonster.bTearOff = false;
    //     HitMonster.bPlayedDeath = false;
    // }

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    // {  
        // if( Role == ROLE_Authority )
        // {
        //     PenetrationPower = 0;

        //     // On Hit ( NO IsAliveAndWell because we turn off the boolean instead)
        //     Cannon = KFWeap_Aureolin(Owner);
        //     if( Cannon != none )
        //     {
        //         if( Cannon.StartPerkAction == true )
        //         {
        //             Cannon.StartPerkAction = false; // Also disable the boolean (failsafe)
        //             // if( KFPawn_Monster(Other).LastHitZoneIndex == HZI_HEAD )
        //                 SpawnImpactExplosion();
        //         }
        //     }
        // }
    // }
}

simulated protected function StopSimulating()
{
    local KFWeap_Aureolin Cannon;

    if( Role == ROLE_Authority )
    {
        PenetrationPower = 0;

        // On Hit ( NO IsAliveAndWell because we turn off the boolean instead)
        Cannon = KFWeap_Aureolin(Owner);
        if( Cannon != none )
        {
            if( Cannon.StartPerkAction ) // == true
            {
                SpawnImpactExplosion();
                Cannon.StartPerkAction = false; // Also disable the boolean (failsafe)
            }
        }
    }

    Super.StopSimulating();
}

simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
    local KFWeap_Aureolin Cannon;
    // local vector FlameSpawnVel;
    
    PenetrationPower = 0;
    LastHitNormal = HitNormal;

    Cannon = KFWeap_Aureolin(Owner);
    if( Cannon != none )
    {
        if( Cannon.LineEmUpActive == true )
        {
            if( Role == ROLE_Authority && Physics == PHYS_Projectile )
            {
                // FlameSpawnVel = 0.25f * CalculateResidualFlameVelocity( LastHitNormal, Normal( Velocity ), VSize( Velocity ) );
                SpawnResidualFlame( class'KFProj_FlareGunSplash', Location + (LastHitNormal * 10.f), vect(0,0,-1) ); //FlameSpawnVel
            }
        }
    }

    Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

function SpawnImpactExplosion()
{   
    local KFExplosionActorReplicated ExploActor;
    local KFExplosionActorLingering GFExplosionActor;

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    // {
        if( ImpactExplosionTemplate != none )
        {
            ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
            if(ExploActor != None)
            {
                ExploActor.InstigatorController = Instigator.Controller;
                ExploActor.Instigator = Instigator;
                // ImpactExplosionTemplate.Damage *= UpgradeDamageMod;  

                ExploActor.bReplicateInstigator = true;
                ExploActor.bIgnoreInstigator = true;

                ExploActor.Explode(ImpactExplosionTemplate); //, vect(0,1,0)
            }
        }

        if( bSpawnGroundFire )
        {
            // Spawn our explosion and set up its parameters
            GFExplosionActor = Spawn(GroundExplosionActorClass, self,, Location, Rotation,, true);
            if (GFExplosionActor != None)
            {
                GFExplosionActor.Instigator = Instigator;
                GFExplosionActor.InstigatorController = InstigatorController;
                GroundExplosionTemplate.bIgnoreInstigator = true;
                // GroundExplosionTemplate.Damage *= UpgradeDamageMod; 

                // Set our duration
                GFExplosionActor.MaxTime = EffectDuration;
                // Set our burn interval
                GFExplosionActor.Interval = DamageInterval;
                // Boom
                GFExplosionActor.Explode(GroundExplosionTemplate);
            }
        }
    // }
}

/*
simulated protected function StopFlightEffects()
{
    local KFWeap_Aureolin Cannon;
    // local vector FlameSpawnVel;

    Super.StopFlightEffects();

    // if( WorldInfo.NetMode != NM_DedicatedServer )
    // {
        PenetrationPower = 0;

        Cannon = KFWeap_Aureolin(Owner);
        if( Cannon != none )
        {
            if( Cannon.LineEmUpActive == true )
            {
                if( Role == ROLE_Authority && Physics == PHYS_Projectile )
                {
                    // FlameSpawnVel = 0.25f * CalculateResidualFlameVelocity( LastHitNormal, Normal( Velocity ), VSize( Velocity ) );
                    SpawnResidualFlame( class'KFProj_FlareGunSplash', Location + (LastHitNormal * 10.f), vect(0,0,-1) ); //FlameSpawnVel
                }
            }
        }
    // }
}
*/

simulated static function PlayAddedImpactEffect(Vector HitLocation, Vector HitNormal)
{
    local WorldInfo WI;
    
    if( default.AddedImpactEffect != none )
    {
        WI = Class'WorldInfo'.static.GetWorldInfo();
        WI.MyEmitterPool.SpawnEmitter(default.AddedImpactEffect, HitLocation, rotator(HitNormal));
    }
}

defaultproperties
{
	MaxSpeed=22500
	Speed=22500

	DamageRadius=0
	
    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_NullF'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_NullF'
    
    ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Heavy_bullet_impact'
    AddedImpactEffect=ParticleSystem'Fass_EMIT.FX_Aureolin_Impact_Extra'

    Begin Object Class=PointLightComponent Name=FlamePointLight
        LightColor=(R=245,G=190,B=140,A=255)
        Brightness=3.f
        Radius=1200.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=FALSE
        bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object
    
    Begin Object Class=KFGameExplosion Name=ImpactExploTemplate0
        Damage=60
        DamageRadius=700 //500
        DamageFalloffExponent=1 //2
        DamageDelay=0.f
        MyDamageType=class'KFDT_Fire_Aureolin'

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'
        ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'
        // ParticleEmitterTemplate=ParticleSystem''

        // Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=0.4
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=KFCameraShake'FX_CameraShake_Arch.Grenades.Molotov'
        CamShakeInnerRadius=250
        CamShakeOuterRadius=400
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ImpactExplosionTemplate=ImpactExploTemplate0

    // Ground effect
    EffectDuration=4.0f
    DamageInterval=0.2f
    GroundExplosionActorClass=class'KFExplosion_Aureolin'

    // Ground effect
    Begin Object Class=KFGameExplosion Name=ExploTemplate1
        Damage=15 //25
        DamageRadius=800
        DamageFalloffExponent=1.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Fire_Aureolin'

        MomentumTransferScale=0
        // bIgnoreInstigator=true

        // Damage Effects
        KnockDownStrength=0
        FractureMeshRadius=0
        ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_GroundFire' // ground effect is inside Class

        // Camera Shake
        CamShake=none
    End Object
    GroundExplosionTemplate=ExploTemplate1
}