class KFDroppedPickup_Trophy_HealingOrb extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
	HealingValue=8
	PlayHealingSpeedBoost=true

	TrophyFX=ParticleSystem'Fass_EMIT.FX_HealingOrb'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=90,G=255,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}