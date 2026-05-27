class KFExplosion_DivinePunishment extends KFExplosionActorLingering;

var() int HealingValue;
var() int ArmorRepairValue;

// Disable Knockdown for friendlies
protected function bool KnockdownPawn(BaseAiPawn Victim, float DistFromExplosion)
{
	if( Victim.GetTeamNum() != Instigator.GetTeamNum() )
		return Super.KnockdownPawn(Victim, DistFromExplosion);

	return false;
}

// Disable Stumble for friendlies
protected function bool StumblePawn(BaseAiPawn Victim, float DistFromExplosion)
{
	if( Victim.GetTeamNum() != Instigator.GetTeamNum() )
		return Super.StumblePawn(Victim, DistFromExplosion);

	return false;
}

protected simulated function AffectsPawn(Pawn Victim, float DamageScale)
{
	local KFPawn_Human HumanVictim;
	local KFPawn_Monster MonsterVictim;

	if( bWasFadedOut|| bDeleteMe || bPendingDelete )
		return;

	if( Victim != none && Victim.IsAliveAndWell() )
	{
		MonsterVictim = KFPawn_Monster(Victim);
		if( MonsterVictim != none )
		{
			// Apply damage over time
			MonsterVictim.ApplyDamageOverTime(class'KFDT_Toxic_HRG_MedicMissile'.default.PoisonPower, Instigator.Controller, class'KFDT_Toxic_HRG_MedicMissile');
			// Actuall damage based of template
			MonsterVictim.TakeRadiusDamage(InstigatorController, ExplosionTemplate.Damage * DamageScale, ExplosionTemplate.DamageRadius,
				ExplosionTemplate.MyDamageType, ExplosionTemplate.MomentumTransferScale, Location, bDoFullDamage,
				(Owner != None) ? Owner : self, ExplosionTemplate.DamageFalloffExponent);
		}
	
		HumanVictim = KFPawn_Human(Victim);
		if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
		{
			// Heal health
			HumanVictim.HealDamage(HealingValue, Instigator.Controller, class'KFDT_Healing');
			// Repair armor
			HumanVictim.AddArmor(ArmorRepairValue);
		}
	}
}

DefaultProperties
{
	Interval=0f
	MaxTime=0f
	// bOnlyDamagePawns=true
	// bDoFullDamage=false

	// HealingValue=25
	// ArmorRepairValue=5
}