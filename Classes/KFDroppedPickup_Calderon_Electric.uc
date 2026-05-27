class KFDroppedPickup_Calderon_Electric extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    LifeSpan=30
    PickupSound=AkEvent'WW_WEP_HRG_Teslauncher.Play_WEP_HRG_Teslauncher_ElectricFX_A'

    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_Calderon_Electric'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_Calderon_Electric_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=0,G=90,B=255,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}