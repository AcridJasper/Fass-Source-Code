class KFDT_Explosive_EarthSplitter extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood = true

	// physics impact
	RadialDamageImpulse=2000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	// KnockdownPower = 150
	StumblePower=60

	ModifierPerkList(0)=class'KFPerk_Firebug'
	ModifierPerkList(1)=class'KFPerk_Demolitionist'
	WeaponDef=class'KFWeapDef_EarthSplitter'
}