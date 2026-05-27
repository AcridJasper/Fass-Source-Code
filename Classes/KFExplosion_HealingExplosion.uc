class KFExplosion_HealingExplosion extends KFExplosionActorLingering;

var() class<KFDamageType> HealingDamageType;
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
			MonsterVictim.ApplyDamageOverTime(class'KFDT_Toxic_HealingImpact'.default.PoisonPower, Instigator.Controller, class'KFDT_Toxic_HealingImpact');
			// Actuall damage based of template
			MonsterVictim.TakeRadiusDamage(InstigatorController, ExplosionTemplate.Damage * DamageScale, ExplosionTemplate.DamageRadius,
				ExplosionTemplate.MyDamageType, ExplosionTemplate.MomentumTransferScale, Location, bDoFullDamage,
				(Owner != None) ? Owner : self, ExplosionTemplate.DamageFalloffExponent);
		}
	
		HumanVictim = KFPawn_Human(Victim);
		if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
		{
			// Heal health
			HumanVictim.HealDamage(HealingValue, Instigator.Controller, HealingDamageType);
			// Repair armor
			HumanVictim.AddArmor(ArmorRepairValue);
		}
	}
}

DefaultProperties
{
	Interval=1.0f
	MaxTime=8.0f
	// bOnlyDamagePawns=true
	// bDoFullDamage=false

	HealingDamageType=class'KFDT_Healing_MedicGrenade'
	HealingValue=10
	ArmorRepairValue=0
}