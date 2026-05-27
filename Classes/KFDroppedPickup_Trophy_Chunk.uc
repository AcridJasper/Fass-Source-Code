class KFDroppedPickup_Trophy_Chunk extends KFDroppedPickup_TrophyBase;

DefaultProperties
{
	HealingValue=5
	ArmorAmount=5
	PlayHealingSpeedBoost=true
	DoshAmount=10

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}