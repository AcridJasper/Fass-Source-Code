class KFDroppedPickup_Trophy_EnergyDrink extends KFDroppedPickup_TrophyBase;

function GiveTo( Pawn P )
{
    local KFPawn_Human KFPH;

    KFPH = KFPawn_Human(P);
    if( KFPH != none && KFPH.IsAliveAndWell() )
    {
        KFPH.UpdateHealingSpeedBoost();
        KFPH.UpdateHealingSpeedBoost();
        KFPH.UpdateHealingSpeedBoost();
    }

    bForceNetUpdate = true;
    P.PlaySoundBase(PickUpSound);

    PickedUpBy(P);
}

DefaultProperties
{
    TrophyFX=ParticleSystem'Fass_EMIT.FX_EnergyDrink_Indicator'

	bEnableGlowLight=true
	Begin Object Name=PointLight0
        LightColor=(R=0,G=90,B=255,A=255)
        Brightness=3.5f
        Radius=85.f
        bEnabled=true
    End Object
}