class KFDT_Bludgeon_InstaGibCrowbar_Light extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3600 //1600
	KDeathUpKick=400 //200
	KDeathVel=750 //500

	StunPower=45 //50 75
	StumblePower=80
	MeleeHitPower=80

	// Obliteration
	GoreDamageGroup = DGT_Explosive
	RadialDamageImpulse = 17000.f // This controls how much impulse is applied to gibs when exploding
	bUseHitLocationForGibImpulses = true // This will make the impulse origin where the victim was hit for directional gibs
	bPointImpulseTowardsOrigin = true // This creates an impulse direction aligned along hitlocation and pawn location -- this will push all gibs in the same direction
	ImpulseOriginScale = 100.f // Higher means more directional gibbing, lower means more outward (and upward) gibbing
	ImpulseOriginLift = 150.f
	MaxObliterationGibs = 12 // Maximum number of gibs that can be spawned by obliteration, 0=MAX
	bCanGib = true
	bCanObliterate = true
	ObliterationHealthThreshold = 0
	ObliterationDamageThreshold = 100
	
	WeaponDef=class'KFWeapDef_InstaGibCrowbar'
	ModifierPerkList(0)=class'KFPerk_Berserker'	
}