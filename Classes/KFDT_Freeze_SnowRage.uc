class KFDT_Freeze_SnowRage extends KFDamageType
	abstract;

defaultproperties
{
	DoT_Type=DOT_Fire
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=1.0
	bIgnoreSelfInflictedScale=true

	KDamageImpulse=0
	FreezePower=50
}