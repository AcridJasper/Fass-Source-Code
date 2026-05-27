class KFDroppedPickup_Calderon_Toxin extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    LifeSpan=30
    PickupSound=AkEvent'WW_WEP_HRG_Locust.Play_WEP_HRG_Locust_AirSmall_Part_02'

    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_Calderon_Toxin'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_Calderon_Toxin_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=60,G=255,B=60,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}