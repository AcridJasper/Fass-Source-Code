class KFDT_Ballistic_EarthSplitter extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

// Damage type to use for the burning damage over time
var class<KFDamageType> BurnDamageType;

// Play damage type specific impact effects when taking damage 
static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
	// Play burn effect when dead
	if( P.bPlayedDeath && P.WorldInfo.TimeSeconds > P.TimeOfDeath )
	{
		default.BurnDamageType.static.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
		return;
	}

	super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

// Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) 
static function ApplySecondaryDamage(KFPawn Victim, int DamageTaken, optional Controller InstigatedBy)
{
	// Overriden to specific a different damage type to do the burn damage over
	// time. We do this so we don't get shotgun pellet impact sounds/fx during
	// the DOT burning.
	if( default.BurnDamageType.default.DoT_Type != DOT_None )
		Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.BurnDamageType);
}

defaultproperties
{
	GoreDamageGroup=DGT_Submachinegun

	GunHitPower=12
	KnockdownPower=0
	// StumblePower=20 //12

	BurnPower=20
	BurnDamageType=class'KFDT_Fire_Mac10DoT'

	WeaponDef=class'KFWeapDef_EarthSplitter'
	ModifierPerkList(0)=class'KFPerk_Firebug'
	// ModifierPerkList(1)=class'KFPerk_SWAT'
}