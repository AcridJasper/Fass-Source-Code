class KFExplosion_Toxin_Calderon extends KFExplosionActorLingering;

// Overriden to SetAbsolute
simulated function StartLoopingParticleEffect()
{
	LoopingPSC = new(self) class'ParticleSystemComponent';
	LoopingPSC.SetTemplate( LoopingParticleEffect );
	AttachComponent(LoopingPSC);
	LoopingPSC.SetAbsolute(false, true, false);
	LoopingPSC.SetFloatParameter( name("CloudDuration"), MaxTime);
}

DefaultProperties
{
	// Interval=0.5f
	// MaxTime=10.0

	LoopingParticleEffect=ParticleSystem'Fass_EMIT.FX_Calderon_Toxin_Cloud'

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}