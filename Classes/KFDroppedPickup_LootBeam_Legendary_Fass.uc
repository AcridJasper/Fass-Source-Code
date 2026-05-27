class KFDroppedPickup_LootBeam_Legendary_Fass extends KFDroppedPickup;

var() ParticleSystem LootBeamFX;
var	transient ParticleSystemComponent LootBeamPSC;

// var float LightFadeStartTime;
var transient float LightFadePerSecond;

var PointLightComponent RayLight;
var LightPoolPriority RayLightPriority;

simulated function PostBeginPlay()
{
	if( LootBeamFX != none )
		StartLootBeamFX();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	    LightFadePerSecond = RayLight.Brightness;

	// Set its light if it has one
    if( RayLight != None )
    {
        AttachComponent(RayLight);
        `LightPool.RegisterPointLight(RayLight, RayLightPriority);
    }

    super.PreBeginPlay();
}

simulated function StartLootBeamFX()
{
	LootBeamPSC = new(self) class'ParticleSystemComponent';
	LootBeamPSC.SetTemplate( LootBeamFX );
	AttachComponent(LootBeamPSC);
	LootBeamPSC.SetAbsolute(false, true, true);
}

State FadeOut
{
	function Tick(float DeltaTime)
	{
		local float NewBrightness;

		// Scales down loot beam fx same way the mesh does
		LootBeamPSC.SetScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));

		// if( LifeSpan < default.LifeSpan - LightFadeStartTime )
		// {
			// Fade out gradually
	    	if ( RayLight != None && RayLight.bAttached )
	    	{
				if( RayLight.Brightness > 0 )
				{
					NewBrightness = FMax( 0.01, RayLight.Brightness - (LightFadePerSecond * DeltaTime) );
					RayLight.SetLightProperties( NewBrightness );
				}
	    	}
		// }

		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
		Global.Tick(DeltaTime);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;

		SetTimer(2.0, false, nameof(StopLootBeamFX));
		// StopLootBeamFX();
	}

	// disable normal touching. we require input from the player to pick it up
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ) {}
}

simulated function StopLootBeamFX()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && LootBeamPSC != none )
	{
        LootBeamPSC.DeactivateSystem();
	   	DetachComponent(RayLight);
	}
}

defaultproperties
{
	LootBeamFX=ParticleSystem'Fass_EMIT.FX_LootBeam_Legendary_Fass'

	// LightFadeStartTime=298

	Begin Object Class=PointLightComponent Name=PointLight0
        LightColor=(R=255,G=90,B=0,A=255)
        Brightness=3.5f
        Radius=85.f
        FalloffExponent=3.0f
        CastShadows=FALSE
        CastStaticShadows=false
        CastDynamicShadows=false
        bCastPerObjectShadows=false
        bEnabled=true
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object
    RayLight=PointLight0
    RayLightPriority=LPP_High
}