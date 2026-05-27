class KFDroppedPickup_Trophy_HurtSkull extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    LifeSpan=40 //60

    PickupSound=AkEvent'WW_Skin_Impacts.Play_Bludgeon_Flesh_3P'
    HurtPlayer=true
    HurtDamage=3

    TrophyFX=ParticleSystem'Fass_EMIT.FX_HurtSkull_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=0,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}