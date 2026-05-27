class KFDroppedPickup_Trophy_Glowstick extends KFDroppedPickup_TrophyBase;

function GiveTo(Pawn P)
{
    // Can't pickup
}

auto state Pickup
{
    // Can't pickup
}

DefaultProperties
{
	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=15,G=255,B=15,A=255)
        Brightness=2.0f
        Radius=300.f
    End Object
    GlowLight=PointLight0
}