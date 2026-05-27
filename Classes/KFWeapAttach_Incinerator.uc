class KFWeapAttach_Incinerator extends KFWeapAttach_SprayBase
	config(Fass);

var() config bool AttachBackpack;

// var transient ParticleSystemComponent WirePSC;
/** Wire particle FX */
// var() ParticleSystem WireFX;

var StaticMeshComponent BackpackAttachment;
/** Static mesh that attaches to players Back */
var() StaticMesh BackpackStaticMesh;
/** Socket for Backpack Static mesh */
var() name BackpackMeshSocket;

/** Effect for the pilot light */
var() protected KFParticleSystemComponent PSC_SpineLights[4];
/** Socket to attach the pilot light to */
var() name SpineLightSocketNames[4];

simulated function AttachTo( KFPawn P )
{
    Super.AttachTo(P);

    if( AttachBackpack )
		ApplyStaticMesh(P);
	// AttachWire(P);
}

simulated function ApplyStaticMesh(KFPawn P)
{
	local LightingChannelContainer NewLightingChannels;
	BackpackAttachment = new(self) class'StaticMeshComponent';

	if( BackpackAttachment != none )
	{
		BackpackAttachment.SetStaticMesh( BackpackStaticMesh );
		BackpackAttachment.CastShadow=true;
		BackpackAttachment.bCastDynamicShadow=true;
		BackpackAttachment.bAllowPerObjectShadowBatching=true;
		BackpackAttachment.SetShadowParent(P.Mesh);
		BackpackAttachment.bAllowApproximateOcclusion=true;
		BackpackAttachment.SetTraceBlocking(false, false);
		BackpackAttachment.SetActorCollision(false, false);	
		BackpackAttachment.SetLightingChannels(NewLightingChannels);
        // Attach static mesh
		P.Mesh.AttachComponentToSocket( BackpackAttachment, BackpackMeshSocket );
		// if( BackpackMeshSocket.Name == 'Backpack_Attach' )
			// P.ThirdPersonAttachments[0].SetHidden( true );
	}
}

/*simulated function AttachWire( KFPawn P )
{
	// if( WirePSC != None && WirePSC.bIsActive )
	// {
		WirePSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( WireFX, P.Mesh, 'Backpack_Attach', true );
		WirePSC.SetAbsolute(false, true, true);
		// WirePSC.SetTranslation(vect(0,0,20));
		WirePSC.ActivateSystem();	
		WirePSC.SetVectorParameter( 'WireEndpoint', WeapMesh.GetBoneLocation('MuzzleFlash') );
	// }
}*/

// Set the lighting channels on all the appropriate weapon attachment mesh(es)
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	if( !bWeapMeshIsPawnMesh )
		WeapMesh.SetLightingChannels(NewLightingChannels);

	if( BackpackAttachment != none )
		BackpackAttachment.SetLightingChannels(NewLightingChannels);
}

simulated function DetachFrom( KFPawn P )
{
	P.Mesh.DetachComponent( BackpackAttachment );

	// if( WirePSC != None && WirePSC.bIsActive )
    // 	WirePSC.DeactivateSystem();

    Super.DetachFrom(P);
}

// ***************** Flamethrower stuff *****************

simulated protected function TurnOnPilot()
{
    local int i;

	if( bPilotLightOn )
		return;

    // Attach and start up the pilot lights
    for( i = 0; i < 4; i++ )
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		WeapMesh.AttachComponentToSocket( PSC_SpineLights[i], SpineLightSocketNames[i] );

    		PSC_SpineLights[i].ActivateSystem();

    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    	}
	}

    super.TurnOnPilot();
}

simulated protected function TurnOffPilot()
{
    local int i;

    Super.TurnOffPilot();

    for( i = 0; i < 4; i++ )
    {
    	if( PSC_SpineLights[i] != None )
    		PSC_SpineLights[i].DeActivateSystem();
	}
}

simulated protected function TurnOnFireSpray()
{
    local int i;

	if( !bFireSpraying )
	{
        // Start up the pilot lights on top
        for( i = 0; i < 4; i++ )
        {
        	if( PSC_SpineLights[i] != None )
        	{
        		// Turn off the low flame, turn on the high flame
        		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 0.0);
        		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 1.0);
        	}
    	}
	}

	Super.TurnOnFireSpray();
}

simulated protected function TurnOffFireSpray()
{
    local int i;

    for( i = 0; i < 4; i++ )
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    	}
	}

	Super.TurnOffFireSpray();
}

defaultproperties
{
	Begin Object Name=PilotLight0
		Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
	End Object

    PilotLightSocketName=FXPilot1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight0
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(0)=SpineLight0

	Begin Object Class=KFParticleSystemComponent Name=SpineLight1
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(1)=SpineLight1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight2
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(2)=SpineLight2

	Begin Object Class=KFParticleSystemComponent Name=SpineLight3
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(3)=SpineLight3

    SpineLightSocketNames(0)=FXPilot2
    SpineLightSocketNames(1)=FXPilot3
    SpineLightSocketNames(2)=FXPilot4
    SpineLightSocketNames(3)=FXPilot5

	PilotLightPlayEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_PilotLight_Loop'
	PilotLightStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_PilotLight_Loop'

	// Muzzle Flash point light
	// want this light to illuminate characters only, so Marcus gets the glow
    Begin Object Class=PointLightComponent Name=PilotPointLight0
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=1.5f
		FalloffExponent=4.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

    Begin Object Class=PointLightComponent Name=PilotPointLight1
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=1.5f
		FalloffExponent=8.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	PilotLights(0)=(Light=PilotPointLight0,FlickerIntensity=1.5f,FlickerInterpSpeed=0.5f,LightAttachBone=LightPilot1)
	PilotLights(1)=(Light=PilotPointLight1,FlickerIntensity=4.f,FlickerInterpSpeed=3.f,LightAttachBone=LightPilot2)

	// AttachBackpack=true
}