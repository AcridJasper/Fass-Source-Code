class KFDT_Fire_Incinerator_DoT extends KFDT_Fire
	abstract
	hidedropdown;

defaultproperties
{
	WeaponDef=class'KFWeapDef_Incinerator'

	SelfDamageReductionValue=0.f
	bNoInstigatorDamage=true

	DoT_Type=DOT_Fire
	DoT_Duration=2.0 //5.0 //1.0 //2.7
	DoT_Interval=0.5
	DoT_DamageScale=0.4

	BurnPower=24
}