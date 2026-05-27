class KFExplosion_Heat_Calderon extends KFExplosionActorLingering;

DefaultProperties
{
	// Interval=0.5
	// MaxTime=10

	bDoFullDamage=true

	LoopingParticleEffect=ParticleSystem'Fass_EMIT.FX_Calderon_Heat_Groundfire'

	LoopStartEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    LoopStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'
}