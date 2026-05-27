class KFDT_Heat_Calderon extends KFDT_Fire
	abstract;

defaultproperties
{
	KDeathVel=300

	DoT_Type=DOT_Fire
	DoT_Duration=5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2
	bIgnoreSelfInflictedScale=true
	
	BurnPower=50
	
	// WeaponDef=class'KFWeapDef_FreezeThrower'
	// ModifierPerkList(0)=class'KFPerk_Survivalist'
}