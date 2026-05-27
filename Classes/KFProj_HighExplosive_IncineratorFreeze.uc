class KFProj_HighExplosive_IncineratorFreeze extends KFProj_BallisticExplosive
	hidedropdown;

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( Physics == PHYS_Falling && Velocity != vect(0,0,0) )
		SetRotation( rotator(Velocity) );
}

/*simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	if( ExplosionTemplate != none )
	{
		// Since bIgnoreInstigator is transient, its value must be defined here
		ExplosionTemplate.bIgnoreInstigator = true;
	}
}*/

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150
	GravityScale=0.5
    MomentumTransfer=50000.0
    ArmDistSquared=0
    LifeSpan=10.0f

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'WEP_HRG_Winterbite_EMIT.FX_WinterBite_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Winterbite_EMIT.FX_WinterBite_Projectile'

	bCanDisintegrate=false
    // ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    // Freeze explosion light
    Begin Object Class=PointLightComponent Name=ExplosionPointLight
        LightColor=(R=128,G=200,B=255,A=255)
        Brightness=4.f
        Radius=1500.f //1500
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=True
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    // Freeze explosion
    Begin Object Class=KFGameExplosion Name=FreezeExplosion
        Damage=25
        DamageRadius=900
        DamageFalloffExponent=1
        DamageDelay=0.f
        MyDamageType=class'KFDT_Freeze_FreezeGrenade'

        MomentumTransferScale=1
        // bIgnoreInstigator=true
        // ActorClassToIgnoreForDamage = class'KFPawn_Human'

        // Damage Effects
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'Fass_ARCH.Freeze_Impact_Explosion'
        ExplosionSound=AkEvent'WW_WEP_Freeze_Grenade.Play_Freeze_Grenade_Explo'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ExplosionTemplate=FreezeExplosion
}