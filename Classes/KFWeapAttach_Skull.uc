class KFWeapAttach_Skull extends KFWeapAttach_DualBase;

const ThrowAnim = 'C4_Throw';
const CrouchThrowAnim = 'C4_Throw_CH';

// Effect that happens while charging up the beam
var transient ParticleSystemComponent ParticlePSC;
var const ParticleSystem ParticleTemplate;

var name ParticleSocket;

// Attach weapon to owner's skeletal mesh
simulated function AttachTo(KFPawn P)
{
	local byte WeaponAnimSetIdx;

    if( bWeapMeshIsPawnMesh )
	{
		WeapMesh = P.Mesh;
	}
	else if ( WeapMesh != None )
	{
		// Attach Weapon mesh to player skel mesh
		WeapMesh.SetShadowParent(P.Mesh);
		P.Mesh.AttachComponent(WeapMesh, 'RW_Weapon');
	}

	// Additional attachments
	if( bHasLaserSight && !P.IsFirstPerson() )
	{
		AttachLaserSight();
	}
	
	// Animation
	if ( CharacterAnimSet != None )
	{
		WeaponAnimSetIdx = P.CharacterArch.GetWeaponAnimSetIdx();
		P.Mesh.AnimSets[WeaponAnimSetIdx] = CharacterAnimSet;
		// update animations will reload all AnimSeqs with the new AnimSet
		P.Mesh.UpdateAnimations();
	}

	// update aim offset nodes with new profile for this weapon
	P.SetAimOffsetNodesProfile(AimOffsetProfileName);

	// setup and play the beam charge particle system
	if (ParticlePSC == none)
	{
		ParticlePSC = new(self) class'ParticleSystemComponent';

		if( WeapMesh != none )
		{
			WeapMesh.AttachComponentToSocket(ParticlePSC, ParticleSocket);
		}
		else
		{
			AttachComponent(ParticlePSC);
		}
	}
	else
	{
		ParticlePSC.ActivateSystem();
	}

	if (ParticlePSC != none)
	{
		ParticlePSC.SetTemplate(ParticleTemplate);
		// ParticlePSC.SetAbsolute(false, false, false);
	}
}

simulated function DetachFrom(KFPawn P)
{
	if( ParticlePSC != none )
	{
		ParticlePSC.DeactivateSystem();
	}

    Super.DetachFrom(P);
}

simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local float Duration;

	// Effects below this point are culled based on visibility and distance
	if( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Weapon shoot anims
	if (P.FiringMode == 0)
	{
		// anim simply hides and unhides bone
		Duration = WeapMesh.GetAnimLength( ThrowAnim );
		WeapMesh.PlayAnim( ThrowAnim, Duration / ThirdPersonAnimRate,, true );

		// use timer to make sure bone gets un-hidden (in case anim gets interrupted)
		SetTimer( 0.75f, false, nameof(UnHide) );
	}

	// Additive character shoot anims
	if( !P.IsDoingSpecialMove() )
	{
		if( P.FiringMode == 0 )
		{
			if ( P.bIsCrouched )
			{
				P.PlayBodyAnim(CrouchThrowAnim, EAS_CH_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
			else
			{
				P.PlayBodyAnim(ThrowAnim, EAS_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
		}
		else if (P.FiringMode == 1)
		{
			if ( P.bIsCrouched )
			{
				P.PlayBodyAnim(CrouchThrowAnim, EAS_CH_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
			else
			{
				P.PlayBodyAnim(ThrowAnim, EAS_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
		}
	}

	// prevent using "aiming" KFAnim_BlendByTargetingMode since we don't have/need the aim anims for C4
	P.LastWeaponFireTime = -1.f;

	return true;
}

simulated function UnHide()
{
	if( WeapMesh != none )
	{
		WeapMesh.UnHideBoneByName('RW_Weapon');
	}
}

defaultproperties
{
	ParticleSocket=Particle
	ParticleTemplate=ParticleSystem'Fass_EMIT.FX_Trophy'
}