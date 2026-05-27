class KFExplosion_Aureolin extends KFExplosionActorLingering;

// Overriden to SetAbsolute
simulated function StartLoopingParticleEffect()
{
	LoopingPSC = new(self) class'ParticleSystemComponent';
	LoopingPSC.SetTemplate( LoopingParticleEffect );
	AttachComponent(LoopingPSC);
	LoopingPSC.SetAbsolute(false, true, false);
}

DefaultProperties
{
	// MaxTime=6.0 //13.0
	// Interval=0.5

	LoopingParticleEffect=ParticleSystem'Fass_EMIT.FX_Aureolin_HeatZone'

	// LoopStartEvent=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_Fire_Loop_Impact'
	// LoopStopEvent=AkEvent'WW_WEP_HRG_ArcGenerator.Stop_HRG_ArcGenerator_Fire_Loop_Impact' 
}