class KFDT_Toxic_GasImpact extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=0.4

	PoisonPower=50

	EffectGroup=FXG_Toxic

	bNoInstigatorDamage=true

	// WeaponDef=class'KFWeapDef_MedicBat'
	// ModifierPerkList(0)=class'KFPerk_FieldMedic'
}