class KFDT_Fire_Aureolin extends KFDT_Fire
	abstract;

defaultproperties
{
	bShouldSpawnPersistentBlood=false

	// physics impact
	RadialDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0

	KnockdownPower=0
	StumblePower=100
	BurnPower=10

	// DOT
	DoT_Duration=3.0 //5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.5 //0.2
	bIgnoreSelfInflictedScale=false
	bNoInstigatorDamage=true
	bNoFriendlyFire=true
	bNonLethalDamage=true

	WeaponDef=class'KFWeapDef_Aureolin'
}