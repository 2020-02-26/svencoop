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
				
				pCustom.GetKeyvalue("$v_mscap_origin");
				
				Vector velocity = pCustom.GetKeyvalue("$v_mscap_origin").GetVector() - pPlayer.GetOrigin();
				
				pCustom.SetKeyvalue("$v_mscap_origin", pPlayer.GetOrigin());
				
				szDisplay += "Velocity: " + formatFloat(velocity.Length(), "", 0, 0) + " units/s\n";
				
				if (pCustom.GetKeyvalue("$i_mscap_armour").GetInteger() > 0) {
					int iFunction = pCustom.GetKeyvalue("$i_mscap_armour_function").GetInteger();
					
					float flDamage    = pCustom.GetKeyvalue("$f_mscap_armour_damage").GetFloat();
					float flOffset    = pCustom.GetKeyvalue("$f_mscap_armour_offset").GetFloat();
					float flFactor    = pCustom.GetKeyvalue("$f_mscap_armour_factor").GetFloat();
					float flIncrement = pCustom.GetKeyvalue("$f_mscap_armour_increment").GetFloat();
					float flInterval  = pCustom.GetKeyvalue("$f_mscap_armour_interval").GetFloat();
					float flThreshold = pCustom.GetKeyvalue("$f_mscap_armour_threshold").GetFloat();
					float flLimit     = pCustom.GetKeyvalue("$f_mscap_armour_limit").GetFloat();
					float flLast      = pCustom.GetKeyvalue("$f_mscap_armour_last").GetFloat();
					
					float flDelta = flNow - flLast;
					float flDelay = flDamage * flFactor;
					
					if (iFunction == 1)
						flDelay = flOffset + sqrt(flDelay);
					if (iFunction == 2)
						flDelay = flOffset + log(flDelay);
					
					flIncrement *= (pPlayer.pev.armorvalue - flThreshold) / (flLimit - flThreshold);
					
					if (pCustom.GetKeyvalue("$i_mscap_armour_active").GetInteger() <= 0)
						szDisplay += "Armour self-repair: inactive\n";
					else if (pPlayer.pev.armorvalue < flThreshold)
						szDisplay += "Armour self-repair: inoperable\n";
					else if (pPlayer.pev.armorvalue >= flLimit)
						szDisplay += "Armour self-repair: ready\n";
					else if (flDelta >= flDelay)
						szDisplay += "Armour self-repair: active @" + formatFloat(flIncrement / flInterval, "", 0, 1) + "/s\n";
					else
						szDisplay += "Armour self-repair: ETA " + formatFloat(ceil(flDelta < flDelay ? flDelay - flDelta : 0.0), "", 0, 0) + "s\n";
				}
				
				if (pCustom.GetKeyvalue("$i_mscap_blink").GetInteger() > 0) {
					float flCooldown = pCustom.GetKeyvalue("$f_mscap_blink_cooldown").GetFloat();
					float flDelta    = flNow - pCustom.GetKeyvalue("$f_mscap_blink_then").GetFloat();
					
					if (flDelta >= flCooldown)
						szDisplay += "Blink teleport: ready\n";
					else
						szDisplay += "Blink teleport: cooldown " + formatFloat(ceil(flCooldown - flDelta), "", 0, 0) + "s\n";
				}
				
				if (pCustom.GetKeyvalue("$i_mscap_link").GetInteger() > 0) {
					float flCooldown = pCustom.GetKeyvalue("$f_mscap_link_cooldown").GetFloat();
					float flDistance = pCustom.GetKeyvalue("$f_mscap_link_distance").GetFloat();
					float flRatio    = pCustom.GetKeyvalue("$f_mscap_link_ratio").GetFloat();
					uint  uiLimit    = pCustom.GetKeyvalue("$i_mscap_link_limit").GetInteger();
					
					float flDelta = flNow - pCustom.GetKeyvalue("$f_mscap_link_then").GetFloat();
					
					if (flDelta < flCooldown)
						szDisplay += "Damage link: cooldown " + formatFloat(ceil(flCooldown - flDelta), "", 0, 0) + "s\n";
					else if (pCustom.GetKeyvalue("$i_mscap_link_active").GetInteger() > 0)
						szDisplay += "Damage link: ready\n";
					else
						szDisplay += "Damage link: inactive\n";
				}
				
				hudParams.channel = 1;
				hudParams.x = 0;
				hudParams.y = 0;
				
				g_PlayerFuncs.HudMessage(@pPlayer, hudParams, szDisplay);
			}
		}
	}
}
