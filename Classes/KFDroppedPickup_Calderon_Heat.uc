class KFDroppedPickup_Calderon_Heat extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    LifeSpan=30
    PickupSound=AkEvent'WW_WEP_EXP_MOLOTOV.Play_WEP_EXP_Molotov_Throw'

    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_Calderon_Heat'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_Calderon_Heat_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}