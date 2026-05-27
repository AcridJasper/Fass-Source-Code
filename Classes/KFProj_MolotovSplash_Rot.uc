class KFProj_MolotovSplash_Rot extends KFProj_MolotovSplash;

simulated event Tick( float DeltaTime )
{
	super.Tick(DeltaTime);

	// Aim rotation towards velocity every frame
	if( Physics == PHYS_Falling && Velocity != vect(0,0,0) )
		SetRotation( rotator(Velocity) );
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'Fass_EMIT.FX_Flaret' //WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_01
}