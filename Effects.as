namespace MSCAP {
	namespace Effects {
		Vector Teleport(
			Vector vecOrigin)
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_TELEPORT);
			
			nmsgEffect.WriteCoord(vecOrigin.x);
			nmsgEffect.WriteCoord(vecOrigin.y);
			nmsgEffect.WriteCoord(vecOrigin.z);
			
			nmsgEffect.End();
			
			return vecOrigin;
		}
		
		Vector SphericalDynamicLight(
			Vector vecOrigin,
			float flRadius = 100.0,
			RGBA colColour = RGBA(255, 255, 255),
			float flDuration = 1.0,
			float flDecayRate = 100.0)
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_DLIGHT);
			
			nmsgEffect.WriteCoord(vecOrigin.x);
			nmsgEffect.WriteCoord(vecOrigin.y);
			nmsgEffect.WriteCoord(vecOrigin.z);
			
			nmsgEffect.WriteByte(uint8(flRadius));
			
			nmsgEffect.WriteByte(colColour.r);
			nmsgEffect.WriteByte(colColour.g);
			nmsgEffect.WriteByte(colColour.b);
			
			nmsgEffect.WriteByte(uint8(flDuration * 10));
			
			nmsgEffect.WriteByte(uint8(flDecayRate));
			
			nmsgEffect.End();
			
			return vecOrigin;
		}
		
		Vector Beam(
			Vector vecBegin,
			Vector vecEnd,
			float flDuration = 1.0,
			float flWidth = 1.0,
			RGBA colColour = RGBA(255, 255, 255))
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_BEAMPOINTS);
			
			nmsgEffect.WriteCoord(vecBegin.x);
			nmsgEffect.WriteCoord(vecBegin.y);
			nmsgEffect.WriteCoord(vecBegin.z);
			
			nmsgEffect.WriteCoord(vecEnd.x);
			nmsgEffect.WriteCoord(vecEnd.y);
			nmsgEffect.WriteCoord(vecEnd.z);
			
			nmsgEffect.WriteShort(g_EngineFuncs.ModelIndex("sprites/laserbeam.spr"));
			
			nmsgEffect.WriteByte(0);
			nmsgEffect.WriteByte(1); 
			
			nmsgEffect.WriteByte(uint8(flDuration * 10));
			
			nmsgEffect.WriteByte(uint8(flWidth * 10));
			
			nmsgEffect.WriteByte(0);
			
			nmsgEffect.WriteByte(colColour.r);
			nmsgEffect.WriteByte(colColour.g);
			nmsgEffect.WriteByte(colColour.b);
			nmsgEffect.WriteByte(colColour.a);
			
			nmsgEffect.WriteByte(0);
			
			nmsgEffect.End();
			
			return vecEnd;
		}
		Vector Beam(
			Vector vecBegin,
			Vector vecEnd, 
			RGBA colColour = RGBA(255, 255, 255),
			float flDuration = 1.0,
			float flWidth = 1.0)
		{
			return Beam(vecBegin, vecEnd, flDuration, flWidth, colColour);
		}
		
		Vector BeamBetweenEntities(
			CBaseEntity@ pBegin,
			CBaseEntity@ pEnd,
			float flDuration = 1.0,
			float flWidth = 1.0,
			RGBA colColour = RGBA(255, 255, 255))
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_BEAMENTS);
			
			nmsgEffect.WriteShort(pBegin.entindex());
			nmsgEffect.WriteShort(pEnd.entindex());
			
			nmsgEffect.WriteShort(g_EngineFuncs.ModelIndex("sprites/laserbeam.spr"));
			
			nmsgEffect.WriteByte(0);
			nmsgEffect.WriteByte(1); 
			
			nmsgEffect.WriteByte(uint8(flDuration * 10));
			
			nmsgEffect.WriteByte(uint8(flWidth * 10));
			
			nmsgEffect.WriteByte(0);
			
			nmsgEffect.WriteByte(colColour.r);
			nmsgEffect.WriteByte(colColour.g);
			nmsgEffect.WriteByte(colColour.b);
			nmsgEffect.WriteByte(colColour.a);
			
			nmsgEffect.WriteByte(0);
			
			nmsgEffect.End();
			
			return pEnd.GetOrigin();
		}
		Vector BeamBetweenEntities(
			CBaseEntity@ pBegin,
			CBaseEntity@ pEnd,
			RGBA colColour = RGBA(255, 255, 255),
			float flDuration = 1.0,
			float flWidth = 1.0)
		{
			return BeamBetweenEntities(pBegin, pEnd, flDuration, flWidth, colColour);
		}
		
		Vector Implosion(
			Vector vecOrigin,
			float flRadius = 64.0,
			float flDuration = 1.0,
			int iTracerCount = 64.0)
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_IMPLOSION);
			
			nmsgEffect.WriteCoord(vecOrigin.x);
			nmsgEffect.WriteCoord(vecOrigin.y);
			nmsgEffect.WriteCoord(vecOrigin.z);
			
			nmsgEffect.WriteByte(uint8(flRadius * 10));
			
			nmsgEffect.WriteByte(uint8(iTracerCount));
			
			nmsgEffect.WriteByte(uint8(flDuration * 10));
			
			nmsgEffect.End();
			
			return vecOrigin;
		}
		
		Vector Bang(
			Vector vecOrigin)
		{
			NetworkMessage nmsgEffect(
				MSG_BROADCAST,
				NetworkMessages::SVC_TEMPENTITY,
				null);
			
			nmsgEffect.WriteByte(TE_TAREXPLOSION);
			
			nmsgEffect.WriteCoord(vecOrigin.x);
			nmsgEffect.WriteCoord(vecOrigin.y);
			nmsgEffect.WriteCoord(vecOrigin.z);
			
			nmsgEffect.End();
			
			return vecOrigin;
		}
	}
}
