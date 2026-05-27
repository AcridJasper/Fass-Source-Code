class KFDT_Ballistic_Aureolin_FireClip extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

// Damage type to use for the burning damage over time
var class<KFDamageType> DoTDamageType;

// Play damage type specific impact effects when taking damage
static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
	// Play burn effect when dead
	if( P.bPlayedDeath && P.WorldInfo.TimeSeconds > P.TimeOfDeath )
	{
		default.DoTDamageType.static.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
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
	if( default.DoTDamageType.default.DoT_Type != DOT_None )
		Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.DoTDamageType);
}

// Allows the damage type to customize exactly which hit zones it can dismember
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
		return true;

    switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
		case 'chest':
		case 'heart':
	 		return true;
	}

	return false;
}

defaultproperties
{
	KDamageImpulse=2500
	KDeathUpKick=-500
	KDeathVel=250

	KnockdownPower=20
	StumblePower=30
	GunHitPower=150

	DoTDamageType=class'KFDT_Fire_Mac10DoT'

	WeaponDef=class'KFWeapDef_Aureolin'
	ModifierPerkList(0)=class'KFPerk_Gunslinger'
}