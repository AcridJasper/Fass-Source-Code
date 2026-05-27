class KFDroppedPickup_Calderon_Freeze extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    LifeSpan=30
    PickupSound=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Cryo_On'

    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_Calderon_Freeze'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_Calderon_Freeze_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=255,B=255,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}