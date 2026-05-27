class KFDT_Toxin_Calderon extends KFDT_Toxic
	abstract;

defaultproperties
{
	KDeathVel=300

	DoT_Type=DOT_None
	DoT_Duration=5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2
    bNoInstigatorDamage=true
	bIgnoreSelfInflictedScale=true
	
	PoisonPower=50
	BurnPower=0
	
	// WeaponDef=class'KFWeapDef_FreezeThrower'
	// ModifierPerkList(0)=class'KFPerk_Survivalist'
}