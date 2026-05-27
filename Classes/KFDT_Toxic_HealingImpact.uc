class KFDT_Toxic_HealingImpact extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Type=DOT_Toxic
	DoT_Duration=4.0
	DoT_Interval=1.0
	DoT_DamageScale=0.2

	PoisonPower=30 //50
	
	// ModifierPerkList(0)=class'KFPerk_FieldMedic'
	// WeaponDef=class'KFWeapDef_HRG_MedicMissile'
}