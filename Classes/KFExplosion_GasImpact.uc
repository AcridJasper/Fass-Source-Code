class KFExplosion_GasImpact extends KFExplosionActorLingering;

defaultproperties
{
	Interval=0.5f
	MaxTime=10.0
	
	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}