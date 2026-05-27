class KFDT_Toxic_DivinePunishment extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	//DoT
	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=0.4

	//Afflictions
	PoisonPower=70 //300
	StumblePower=300

	bNoInstigatorDamage=true

	WeaponDef=class'KFWeapDef_MedicBat'

	ModifierPerkList(0)=class'KFPerk_Survivalist'
	ModifierPerkList(1)=class'KFPerk_FieldMedic'
}