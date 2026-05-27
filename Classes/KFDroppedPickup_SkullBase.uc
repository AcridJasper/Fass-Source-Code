class KFDroppedPickup_SkullBase extends KFDroppedPickup;

var ParticleSystem TrophyFX;
var	transient ParticleSystemComponent TrophyPSC;

simulated function PostBeginPlay()
{
	if( TrophyFX != none )
		StartTrophyFX();

    super.PreBeginPlay();
}

simulated function StartTrophyFX()
{
	TrophyPSC = new(self) class'ParticleSystemComponent';
	TrophyPSC.SetTemplate( TrophyFX );
	AttachComponent(TrophyPSC);
	TrophyPSC.SetAbsolute(false, true, true);
}

event Destroyed()
{
	// don't destroy the inventory item
	Inventory = none;
}

State FadeOut
{
	function Tick(float DeltaTime)
	{
		// Scales down loot beam fx same way the mesh does
		TrophyPSC.SetScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));

		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
		Global.Tick(DeltaTime);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;

		SetTimer(2.0, false, nameof(StopTrophyFX));
		// StopTrophyFX();
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function StopTrophyFX()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && TrophyPSC != none )
        TrophyPSC.DeactivateSystem();
}

DefaultProperties
{
	LifeSpan=60 // Life span for skull that just dropped

	TrophyFX=ParticleSystem'Fass_EMIT.FX_Trophy'
}