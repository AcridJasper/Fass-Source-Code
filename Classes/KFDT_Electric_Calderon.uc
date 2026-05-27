class KFDT_Electric_Calderon extends KFDT_EMP
	abstract;

defaultproperties
{
	KDeathVel=300

	DoT_Type=DOT_None
	DoT_Duration=5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2
	bIgnoreSelfInflictedScale=false
	
	EMPPower=50
	
	// WeaponDef=class'KFWeapDef_FreezeThrower'
	// ModifierPerkList(0)=class'KFPerk_Survivalist'
}