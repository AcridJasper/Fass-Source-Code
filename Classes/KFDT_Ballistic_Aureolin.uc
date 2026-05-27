class KFDT_Ballistic_Aureolin extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

// Allows the damage type to customize exactly which hit zones it can dismember
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
	{
		return true;
	}

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
	StumblePower=65
	GunHitPower=165

	WeaponDef=class'KFWeapDef_Aureolin'

	ModifierPerkList(0)=class'KFPerk_Gunslinger'
}