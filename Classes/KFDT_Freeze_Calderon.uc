class KFDT_Freeze_Calderon extends KFDT_Freeze
	abstract;

// Play damage type specific impact effects when taking damage 
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	local float ParamValue;

	// If we're dead and not already frozen (prevents re-shattering)
	if( P.bPlayedDeath 
		&& P.CharacterMICs.Length > 0 
		&& P.CharacterMICs[0].GetScalarParameterValue('Scalar_Ice', ParamValue) )
	{
		if( ParamValue == 0 )
		{
			PlayShatter(P, false, `TimeSinceEx(P, P.TimeOfDeath) > 0.5f, HitDirection * default.KDeathVel);
			return;
		}
	}

	Super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

defaultproperties
{
	KDeathVel=300

	DoT_Type=DOT_Fire
	DoT_Duration=5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2
	bIgnoreSelfInflictedScale=false
	
	FreezePower=50
	
	// WeaponDef=class'KFWeapDef_FreezeThrower'
	// ModifierPerkList(0)=class'KFPerk_Survivalist'
}