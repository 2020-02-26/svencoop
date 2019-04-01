#include "Effects"

namespace MSCAP {
	bool LinkDamageSphere(
		DamageInfo@ pDamageInfo,
		float flRadius = 512.0,
		float flDamageRatio = 1.0,
		uint uiLinkLimit = 256)
	{
		if (@pDamageInfo.pInflictor == null)
			return false;
		if (@pDamageInfo.pAttacker == null)
			return false;
		if (!(pDamageInfo.flDamage > 0))
			return false;
		
		array<CBaseEntity@> arrMonsters(uiLinkLimit + 1);
		
		arrMonsters.resize(g_EntityFuncs.MonstersInSphere(arrMonsters, pDamageInfo.pVictim.Center(), flRadius));
		arrMonsters.removeAt(arrMonsters.find(pDamageInfo.pVictim));
		
		float flDamageIntensity = pDamageInfo.flDamage / 100.0;
		
		if (flDamageIntensity > 1.0)
			flDamageIntensity = 1.0;
		
		if (!(arrMonsters.length() > 0))
			return false;
		
		Effects::SphericalDynamicLight(
			pDamageInfo.pVictim.Center(),
			flDamageIntensity * 100.0,
			RGBA(255, 0, 0, uint8(flDamageIntensity * 255.0)),
			1.0,
			flDamageIntensity * 100.0);
		
		for (uint index = 0; index < arrMonsters.length(); index += 1) {
			arrMonsters[index].TakeDamage(
				null,
				pDamageInfo.pVictim.pev,
				flDamageRatio * pDamageInfo.flDamage,
				pDamageInfo.bitsDamageType & DMG_PARALYZE & DMG_RADIATION & DMG_SHOCK & DMG_SHOCK_GLOW);
			
			Effects::BeamBetweenEntities(
				pDamageInfo.pVictim,
				arrMonsters[index],
				1.0,
				flDamageIntensity * 10,
				RGBA(32, 160, 255, uint8(flDamageIntensity * 255.0)));
		}
		
		return true;
	}
}
