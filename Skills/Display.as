void PluginInit() {
	g_Module.ScriptInfo.SetAuthor("https://github.com/sugar-crystal-ice-water");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/sugar-crystal-ice-water");
	
	g_Scheduler.SetInterval("onDisplayProcess", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES);
}

namespace MSCAP {
	namespace Skills {
		void onDisplayProcess() {
			for (int index = 0; index < g_PlayerFuncs.GetNumPlayers(); index += 1) {
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index + 1);
				
				if (@pPlayer == null)
					continue;
				
				CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
				
				float flNow              = g_EngineFuncs.Time();
				
				HUDTextParams hudParams();
				string szDisplay = "";
				
				
				
				hudParams.r1 = 255;
				hudParams.g1 = 255;
				hudParams.b1 = 255;
				hudParams.a1 = 255;
				
				hudParams.r2 = 0;
				hudParams.g2 = 0;
				hudParams.b2 = 0;
				hudParams.a2 = 255;
				
				hudParams.fadeinTime  = 0.0;
				hudParams.fadeoutTime = 0.1;
				hudParams.holdTime    = 0.15;
				
				if (pCustom.GetKeyvalue("$i_mscap_armour").GetInteger() > 0) {
					int iFunction = pCustom.GetKeyvalue("$i_mscap_armour_function").GetInteger();
					
					float flDamage = pCustom.GetKeyvalue("$f_mscap_armour_damage").GetFloat();
					float flOffset = pCustom.GetKeyvalue("$f_mscap_armour_offset").GetFloat();
					float flFactor = pCustom.GetKeyvalue("$f_mscap_armour_factor").GetFloat();
					float flLast   = pCustom.GetKeyvalue("$f_mscap_armour_last").GetFloat();
					
					float flDelta = flNow - flLast;
					float flDelay = flOffset + (flDamage * flFactor);
					
					if (iFunction == 1)
						flDelay = sqrt(flDelay);
					if (iFunction == 2)
						flDelay = log(flDelay);
					
					szDisplay += "Armour self-repair spool: ";
					szDisplay += formatFloat(flDelta < flDelay ? flDelta / flDelay * 100.0 : 100.0, "", 0, 0) + "%\n";
					
					szDisplay += "Armour self-repair spool ETA: ";
					szDisplay += formatFloat(flDelta < flDelay ? flDelay - flDelta : 0.0, "", 0, 0) + "s\n";
				}
				
				hudParams.channel = 1;
				hudParams.x = 0;
				hudParams.y = 0;
				
				g_PlayerFuncs.HudMessage(@pPlayer, hudParams, szDisplay);
			}
		}
	}
}
