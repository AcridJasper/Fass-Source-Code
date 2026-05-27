class KFDroppedPickup_Trophy_HellishRage extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    PickupSound=AkEvent'WW_ENV_HellmarkStation.Play_KFTrigger_Activation'
    
    PlayPowerUp=true
    PowerUpType=class'KFPowerUp_HellishRage_NoCostHeal'

    TrophyFX=ParticleSystem'Fass_EMIT.FX_HellishSkull_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}