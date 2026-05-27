class KFWeapAttach_EarthSplitter extends KFWeaponAttachment;

const ThrowBodyAnim     = 'ADD_Nade_Throw';
const ThrowBodyAnimCH   = 'ADD_Nade_Throw_CH';
const ThrowBodyAnimIron = 'ADD_Nade_Throw';

/*
var transient ParticleSystemComponent ParticlePSC;
var ParticleSystem ParticleTemplate;
var name ParticleSocket;

simulated function AttachTo(KFPawn P)
{
    Super.AttachTo(P);

	// setup and play the beam charge particle system
	if( ParticlePSC == none )
	{
		ParticlePSC = new(self) class'ParticleSystemComponent';

		if( WeapMesh != none )
			WeapMesh.AttachComponentToSocket(ParticlePSC, ParticleSocket);
		else
			AttachComponent(ParticlePSC);
	}
	else
		ParticlePSC.ActivateSystem();

	if( ParticlePSC != none )
	{
		ParticlePSC.SetTemplate(ParticleTemplate);
		// ParticlePSC.SetAbsolute(false, false, false);
	}
}
*/

// Plays anim early
/*simulated function StartFire()
{
	local KFPawn_Human P;
	local EAnimSlotStance AnimType;

	if( P.IsDoingSpecialMove() && P.SpecialMoves[P.SpecialMove].bAllowFireAnims )
		AnimType = EAS_Additive;
	else
		AnimType = EAS_FullBody;
	
	P = KFPawn_Human(Owner);
	if( P.FiringMode == 1 ) // ALTFIRE_FIREMODE
	{
		if( P.bIsCrouched )
			P.PlayBodyAnim(ThrowBodyAnimCH, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		else if( P.bIsWalking )
			P.PlayBodyAnim(ThrowBodyAnimIron, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		else
			P.PlayBodyAnim(ThrowBodyAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
}*/

// Plays fire animation on pawn
simulated function PlayPawnFireAnim( KFPawn P, EAnimSlotStance AnimType )
{
	if( P.FiringMode == 0 )
		super.PlayPawnFireAnim(P, AnimType);
	else if( P.FiringMode == 1 ) // ALTFIRE_FIREMODE
	{
		if( P.bIsCrouched )
			P.PlayBodyAnim(ThrowBodyAnimCH, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		else if( P.bIsWalking )
			P.PlayBodyAnim(ThrowBodyAnimIron, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		else
			P.PlayBodyAnim(ThrowBodyAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else
		super.PlayPawnFireAnim(P, AnimType);
}

defaultproperties
{
	// ParticleTemplate=ParticleSystem'Fass_EMIT.FX_EarthSplitter_ParticleFX'
	// ParticleSocket=Particle
}