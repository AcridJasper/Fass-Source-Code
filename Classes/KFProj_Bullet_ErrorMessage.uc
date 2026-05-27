class KFProj_Bullet_ErrorMessage extends KFProj_Bullet
	hidedropdown;

// Added impact fx
var ParticleSystem AddedImpactEffect;

// Last hit normal from Touch() or HitWall()
var vector LastHitNormal;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    local KFWeap_ErrorMessage Cannon;

    LastHitNormal = HitNormal;
    Super.ProcessTouch(Other, HitLocation, HitNormal);

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if( Role == ROLE_Authority )
        {
            Cannon = KFWeap_ErrorMessage(Owner);
            if( Cannon != none )
            {
                if( Cannon.SpawnSatellite == true )
                {
                    Cannon.SpawnSatellite = false; // Also disable the boolean (failsafe)
				 	SpawnResidualFlame( class'KFProj_Grenade_Satellite', Location + (LastHitNormal * 10.f), vect(0,0,-1) );
                }
            }
        }
    }
}

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
	MaxSpeed=24000
	Speed=24000

	DamageRadius=0

    ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_NullF'
    ProjFlightTemplateZedTime=ParticleSystem'Fass_EMIT.FX_NullF' //WEP_1P_L85A2_EMIT.FX_L85A2_Tracer_ZEDTime

    ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Heavy_bullet_impact'
    AddedImpactEffect=ParticleSystem'Fass_EMIT.FX_ErrorMessage_Impact'
}