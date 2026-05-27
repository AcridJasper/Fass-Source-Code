class KFDroppedPickup_Trophy_RandomWeaponBox extends KFDroppedPickup;

event Destroyed()
{
    // super.Destroyed();
    
    // Do NOT destroy the inventory item
    // Inventory = none;
}

State FadeOut
{
    function Tick(float DeltaTime)
    {
        SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
        Global.Tick(DeltaTime);
    }

    simulated event BeginState(Name PreviousStateName)
    {
        bFadeOut = true;
        RotationRate.Yaw=60000;
        SetPhysics(PHYS_Rotating);
        LifeSpan = 1.0;
    }

    // disable normal touching. we require input from the player to pick it up
    event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

DefaultProperties
{
    LifeSpan=60
}