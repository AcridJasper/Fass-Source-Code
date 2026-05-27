class KFDT_DivinePunishment_Radial extends KFDamageType
	abstract
	hidedropdown;

var ParticleSystem DOTEffect;
// var ParticleSystem NullEffect;
var AKEvent DOTEffectSound;

// Play damage type specific impact effects when taking damage
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	if( default.DOTEffect != none )
		P.WorldInfo.MyEmitterPool.SpawnEmitter( default.DOTEffect, HitLocation, rotator(-HitDirection), P );

	// if( P.bPlayedDeath && P.WorldInfo.TimeSeconds > P.TimeOfDeath )
	// 	P.WorldInfo.MyEmitterPool.SpawnEmitter( default.NullEffect, HitLocation, rotator(-HitDirection), P );

	if( default.DOTEffectSound != None )
		P.PlaySoundBase( default.DOTEffectSound, true,,, HitLocation );

	super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

// Test obliterate conditions when taking damage
static function bool CheckObliterate(Pawn P, int Damage)
{
	return default.bCanObliterate;
}

defaultproperties
{
	KDamageImpulse=0
    KDeathUpKick=0
    KDeathVel=0

	// bStackDoT=true
	DoT_Type=DOT_Fire
	DoT_Duration=0.3
	DoT_Interval=0.1
	DoT_DamageScale=4

	SnarePower=60

/*
	// Obliteration
	GoreDamageGroup = DGT_Explosive
	RadialDamageImpulse = 8000.f // This controls how much impulse is applied to gibs when exploding
	bUseHitLocationForGibImpulses = true // This will make the impulse origin where the victim was hit for directional gibs
	bPointImpulseTowardsOrigin = true // This creates an impulse direction aligned along hitlocation and pawn location -- this will push all gibs in the same direction
	ImpulseOriginScale = 100.f // Higher means more directional gibbing, lower means more outward (and upward) gibbing
	ImpulseOriginLift = 150.f
	MaxObliterationGibs = 12 // Maximum number of gibs that can be spawned by obliteration, 0=MAX
	bCanGib = true
	bCanObliterate = true
	ObliterationHealthThreshold = 0
	ObliterationDamageThreshold = 100
*/
	
	// NullEffect=ParticleSystem'WEP_Ion_Sword_EMIT.FX_Ion_Sword_Impact'

	DOTEffect=ParticleSystem'Fass_EMIT.FX_Punishment_Puff'
    DOTEffectSound=AkEvent'WW_Emotes.Play_Emote_Deluxe_MasterOfUniverse_Sheathe'
}