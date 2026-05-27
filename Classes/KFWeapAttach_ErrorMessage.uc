class KFWeapAttach_ErrorMessage extends KFWeaponAttachment;

// Nova explosion template
var KFGameExplosion TremorsExplosionTemplate; //GameExplosion

// simulated function AttachTo( KFPawn P )
// {
//     Super.AttachTo(P);

// 	if( P.MyKFWeapon != none && P.MyKFWeapon.bUseAltFireMode )
// 		PlayTremorsExplosion(P);
// }

simulated function PlayTremorsExplosion(KFPawn P)
{
	local KFExplosionActorReplicated NovaExplosionActor;

	if( TremorsExplosionTemplate != none )
	{
		NovaExplosionActor = Spawn(class'KFExplosionActorReplicated', self,, P.Location, Rotation,, true);
		if( NovaExplosionActor != None )
		{
			NovaExplosionActor.Instigator = Instigator;
			NovaExplosionActor.InstigatorController = Instigator.Controller;
			NovaExplosionActor.bIgnoreInstigator = true;

			NovaExplosionActor.Explode(TremorsExplosionTemplate);
		}
	}
}

// Spawn tracer effects for this weapon
simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	local ParticleSystemComponent PSC;
	local vector Dir;
	local float DistSQ;
	local float TracerDuration;
	local KFTracerInfo TracerInfo;

	if( Instigator == None || Instigator.FiringMode >= TracerInfos.Length )
		return;

	TracerInfo = TracerInfos[Instigator.FiringMode];
	if (((`NotInZedTime(self) && TracerInfo.bDoTracerDuringNormalTime)
		|| (`IsInZedTime(self) && TracerInfo.bDoTracerDuringZedTime))
		&& TracerInfo.TracerTemplate != none )
	{
		Dir = HitLocation - EffectLocation;
		DistSQ = VSizeSq(Dir);
		if (DistSQ > TracerInfo.MinTracerEffectDistanceSquared)
		{
			// Lifetime scales based on the distance from the impact point. Subtract a frame so it doesn't clip.
			TracerDuration = fMin((Sqrt(DistSQ) - 100.f) / TracerInfo.TracerVelocity, 1.f);
			if (TracerDuration > 0.f)
			{
				PSC = WorldInfo.MyEmitterPool.SpawnEmitter(TracerInfo.TracerTemplate, EffectLocation, rotator(Dir));
				PSC.SetFloatParameter('Tracer_Lifetime', TracerDuration);
				PSC.SetVectorParameter('Shotend', HitLocation);
			}
		}
	}
}

defaultproperties
{
	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=170 //160
		DamageRadius=800 //600
		DamageFalloffExponent=2
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_NailBombGrenade'

		// Damage Effects
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_ErrorMessage_ARCH.ErrorMessage_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Alt_Fire_3P'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=500
		CamShakeFalloff=3.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	TremorsExplosionTemplate=ExploTemplate0
}