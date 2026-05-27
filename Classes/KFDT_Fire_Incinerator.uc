class KFDT_Fire_Incinerator extends KFDT_Explosive
	abstract;

// Damage type to use for the damage over time effect
var class<KFDamageType> DoTDamageType;

// Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) 
static function ApplySecondaryDamage(KFPawn Victim, int DamageTaken, optional Controller InstigatedBy)
{
    if( Victim.Controller == InstigatedBy )
        return;

	if( default.DoTDamageType.default.DoT_Type != DOT_None )
		Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.DoTDamageType);
}

defaultproperties
{
	bShouldSpawnPersistentBlood=false

	// physics impact
	RadialDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0

	KnockdownPower=0
	StumblePower=100
	BurnPower=8

    DoTDamageType=class'KFDT_Fire_Incinerator_DoT'

	WeaponDef=class'KFWeapDef_Incinerator'
}