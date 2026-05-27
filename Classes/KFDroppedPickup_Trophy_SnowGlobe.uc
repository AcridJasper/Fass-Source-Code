class KFDroppedPickup_Trophy_SnowGlobe extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    PickupSound=AkEvent'WW_WEP_FrostFang.Play_FrostFang_Frozen_Impact'

    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_SnowRage_NoCostNoHeal'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_SnowGlobe_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=255,B=255,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}