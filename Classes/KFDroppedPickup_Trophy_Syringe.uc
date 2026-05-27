class KFDroppedPickup_Trophy_Syringe extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
    HealingValue=15

    TrophyFX=ParticleSystem'Fass_EMIT.FX_Syringe_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=0,G=255,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}