class KFWeapAttach_RandomJoker extends KFWeaponAttachment;

var ParticleSystemComponent AbilityPSC;
/** Particle system template */
var() ParticleSystem AbilityFXTemplate;
/** Particle socket name that particle template gets attached to */
var() name AbilityEffectSocket;

simulated function AttachTo(KFPawn P)
{
    Super.AttachTo(P);
    
	if( AbilityPSC == none )
	{
    	AbilityPSC = new(self) class'ParticleSystemComponent';
		AttachComponent(AbilityPSC);
		AbilityPSC.ActivateSystem();
		AbilityPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( AbilityFXTemplate, P.Mesh, AbilityEffectSocket, true );
		AbilityPSC.SetAbsolute(false, true, true);
	}
}

simulated function DetachFrom(KFPawn P)
{
	if( AbilityPSC != none )
		AbilityPSC.DeactivateSystem();

    Super.DetachFrom(P);
}

// ********************************* Misc *********************************

// Spawn tracer effects for this weapon
simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	local ParticleSystemComponent PSC;
	local vector Dir;
	local float DistSQ;
	local float TracerDuration;
	local KFTracerInfo TracerInfo;

	if (Instigator == None || Instigator.FiringMode >= TracerInfos.Length)
		return;

	TracerInfo = TracerInfos[Instigator.FiringMode];
	if (((`NotInZedTime(self) && TracerInfo.bDoTracerDuringNormalTime)
		|| (`IsInZedTime(self) && TracerInfo.bDoTracerDuringZedTime))
		&& TracerInfo.TracerTemplate != none )
	{
		Dir = HitLocation - EffectLocation;
		DistSQ = VSizeSq(Dir);
		if (DistSQ > TracerInfo.MinTracerEffectDistanceSquared)
		{
			// Lifetime scales based on the distance from the impact point. Subtract a frame so it doesn't clip.
			TracerDuration = fMin((Sqrt(DistSQ) - 100.f) / TracerInfo.TracerVelocity, 1.f);
			if (TracerDuration > 0.f)
			{
				PSC = WorldInfo.MyEmitterPool.SpawnEmitter(TracerInfo.TracerTemplate, EffectLocation, rotator(Dir));
				PSC.SetFloatParameter('Tracer_Lifetime', TracerDuration);
				PSC.SetVectorParameter('Shotend', HitLocation);
			}
		}
	}
}

defaultproperties
{
	// AbilityFXTemplate=ParticleSystem''
	// AbilityEffectSocket=
	// AbilitySound=AkEvent''
}