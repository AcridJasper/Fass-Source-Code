class KFWeapAttach_Calderon extends KFWeaponAttachment
	config(Fass);

// var() config LinearColor GlowColorDefault, GlowColorHeat, GlowColorFreeze, GlowColorToxin, GlowColorElectric;

// `define WEAPON_GLOW_INDEX 0

/*
simulated event Tick( float DeltaTime )
{
	// super.Tick( DeltaTime );

	// Update colors (but in thridperson WOAW)
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 0 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorHeat);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 1 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorFreeze);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 2 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorToxin);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 3 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorElectric);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 4 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorDefault);
	}
}

simulated function UpdateMaterials()
{
	// Update colors (but in thridperson WOAW)
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 0 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorHeat);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 1 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorFreeze);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 2 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorToxin);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 3 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorElectric);
	}
	if( class'KFWeap_Calderon'.default.CurrentProjectileIndex == 4 )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`WEAPON_GLOW_INDEX);
		WeaponMIC.SetVectorParameterValue('Vector_GlowColor', class'KFWeap_Calderon'.default.GlowColorDefault);
	}
}
*/

defaultproperties
{
	// GlowColorDefault=(R=0.186060,G=0.931820,B=1)
	// GlowColorHeat=(R=1,G=0.2,B=0)
	// GlowColorFreeze=(R=0,G=0.2,B=1)
	// GlowColorToxin=(R=0,G=0.5,B=0)
	// GlowColorElectric=(R=0,G=0.5,B=1)
}