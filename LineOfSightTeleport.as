#include "Effects"

namespace MSCAP {
	bool LineOfSightTeleport(
		CBasePlayer@ pPlayer,
		float flMaxDistance = 16384)
	{
		TraceResult trLineOfSight;
		
		Vector vecBeginPoint = pPlayer.Center();
		Vector vecEndPoint   = pPlayer.Center() + g_Engine.v_forward * flMaxDistance;
		
		g_Utility.TraceLine(
			vecBeginPoint,
			vecEndPoint,
			dont_ignore_monsters,
			ignore_glass,
			pPlayer.pev.pContainingEntity,
			trLineOfSight);
		
		if (trLineOfSight.fAllSolid != 0)
			return false;
		if (trLineOfSight.fStartSolid != 0)
			return false;
		if (trLineOfSight.fInOpen == 0)
			return false;
		
		MSCAP::Effects::SphericalDynamicLight(pPlayer.Center());
		MSCAP::Effects::Teleport(pPlayer.Center());
		
		MSCAP::Effects::Implosion(pPlayer.Center(), 64, 0.2, 64);
		
		pPlayer.SetOrigin(trLineOfSight.vecEndPos);
		
		NetworkMessage nmsgUnstuck(
			MSG_ONE,
			NetworkMessages::NetworkMessageType(9),
			pPlayer.edict());
		nmsgUnstuck.WriteString("unstuck");
		nmsgUnstuck.End();
		
		MSCAP::Effects::SphericalDynamicLight(trLineOfSight.vecEndPos);
		MSCAP::Effects::Teleport(pPlayer.Center());
		
		MSCAP::Effects::Bang(trLineOfSight.vecEndPos);
		
		MSCAP::Effects::Beam(
			vecBeginPoint,
			trLineOfSight.vecEndPos,
			1.0,
			sqrt(trLineOfSight.flFraction * flMaxDistance),
			RGBA(255, 255, 255, 64));
		
		return true;
	}
}
