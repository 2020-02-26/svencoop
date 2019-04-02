void PluginInit() {
	g_Module.ScriptInfo.SetAuthor("https://github.com/sugar-crystal-ice-water");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/sugar-crystal-ice-water");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onClientPutInServer);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @onPlayerTakeDamage);
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
	
	g_Scheduler.SetInterval("onArmourProcess", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES);
}

HookReturnCode onClientPutInServer(
	CBasePlayer@ pPlayer)
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue("$i_mscap_armour", 1);
	
	pCustom.SetKeyvalue("$i_mscap_armour_active", 1);
	
	pCustom.SetKeyvalue("$i_mscap_armour_function",  1);
	pCustom.SetKeyvalue("$f_mscap_armour_offset",    5.0);
	pCustom.SetKeyvalue("$f_mscap_armour_factor",    1.0);
	pCustom.SetKeyvalue("$f_mscap_armour_increment", 0.5);
	pCustom.SetKeyvalue("$f_mscap_armour_interval",  0.5);
	pCustom.SetKeyvalue("$f_mscap_armour_threshold", 5.0);
	pCustom.SetKeyvalue("$f_mscap_armour_limit",     100.0);
	
	return HOOK_CONTINUE;
}

HookReturnCode onClientDisconnect(
	CBasePlayer@ pPlayer)
{
	return HOOK_CONTINUE;
}

HookReturnCode onPlayerTakeDamage(
	DamageInfo@ pDamageInfo)
{
	CustomKeyvalues@ pCustom = pDamageInfo.pVictim.GetCustomKeyvalues();
	
	float flDamage = pCustom.GetKeyvalue("$f_mscap_armour_damage").GetFloat();
	
	pCustom.SetKeyvalue("$f_mscap_armour_damage", flDamage + pDamageInfo.flDamage);
	pCustom.SetKeyvalue("$f_mscap_armour_last", g_EngineFuncs.Time());
	
	return HOOK_CONTINUE;
}

HookReturnCode onChat(
	SayParameters@ pParams)
{
	const CCommand@ cArgs = pParams.GetArguments();
	CustomKeyvalues@ pCustom = pParams.GetPlayer().GetCustomKeyvalues();
	
	if (cArgs.ArgC() <= 0)
		return HOOK_CONTINUE;
	
	if (cArgs.Arg(0) != "armour")
		return HOOK_CONTINUE;
	
	pParams.ShouldHide = true;
	
	if (cArgs.Arg(1) == "info")
		MSCAP::Skills::onArmourInfo(pParams.GetPlayer());
	else if (cArgs.Arg(1) == "activate")
		pCustom.SetKeyvalue("$i_mscap_armour_active", 1);
	else if (cArgs.Arg(1) == "deactivate")
		pCustom.SetKeyvalue("$i_mscap_armour_active", 0);
	else
		g_PlayerFuncs.SayText(pParams.GetPlayer(), "Unknown armour action \"" + cArgs.Arg(1) + "\".\n");
	
	return HOOK_CONTINUE;
}

namespace MSCAP {
	namespace Skills {
		void onArmourInfo(CBasePlayer@ pPlayer) {
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			
			float flOffset    = pCustom.GetKeyvalue("$f_mscap_armour_offset").GetFloat();
			float flFactor    = pCustom.GetKeyvalue("$f_mscap_armour_factor").GetFloat();
			float flIncrement = pCustom.GetKeyvalue("$f_mscap_armour_increment").GetFloat();
			float flInterval  = pCustom.GetKeyvalue("$f_mscap_armour_interval").GetFloat();
			float flThreshold = pCustom.GetKeyvalue("$f_mscap_armour_threshold").GetFloat();
			float flLimit     = pCustom.GetKeyvalue("$f_mscap_armour_limit").GetFloat();
			
			float flDamage    = pCustom.GetKeyvalue("$f_mscap_armour_damage").GetFloat();
			
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair current damage incurred: "          + formatFloat(flDamage < 0.0 ? 0.0 : flDamage, "", 0, 1) + ".\n");
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair interruption delay: "               + formatFloat(flOffset,                        "", 0, 1) + "s.\n");
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair interruption damage delay factor: " + formatFloat(flFactor,                        "", 0, 1) + "x.\n");
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair optimal rate: "                     + formatFloat(flIncrement / flInterval,        "", 0, 1) + "/s.\n");
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair minimum functional state: "         + formatFloat(flThreshold,                     "", 0, 1) + ".\n");
			g_PlayerFuncs.SayText(pPlayer, "Armour self-repair maximum state: "                    + formatFloat(flLimit,                         "", 0, 1) + ".\n");
		}
		
		void onArmourProcess() {
			for (int index = 0; index < g_PlayerFuncs.GetNumPlayers(); index += 1) {
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index + 1);
				
				if (@pPlayer == null)
					continue;
				
				CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
				
				float flDamage = pCustom.GetKeyvalue("$f_mscap_armour_damage").GetFloat();
				float flLast   = pCustom.GetKeyvalue("$f_mscap_armour_last").GetFloat();
				float flThen   = pCustom.GetKeyvalue("$f_mscap_armour_then").GetFloat();
				
				float flNow    = g_EngineFuncs.Time();
				float flDelta  = flNow - flLast;
				
				int iFunction = pCustom.GetKeyvalue("$i_mscap_armour_function").GetInteger();
				
				float flOffset    = pCustom.GetKeyvalue("$f_mscap_armour_offset").GetFloat();
				float flFactor    = pCustom.GetKeyvalue("$f_mscap_armour_factor").GetFloat();
				float flIncrement = pCustom.GetKeyvalue("$f_mscap_armour_increment").GetFloat();
				float flInterval  = pCustom.GetKeyvalue("$f_mscap_armour_interval").GetFloat();
				float flThreshold = pCustom.GetKeyvalue("$f_mscap_armour_threshold").GetFloat();
				float flLimit     = pCustom.GetKeyvalue("$f_mscap_armour_limit").GetFloat();
				
				float flDelay =  flDamage * flFactor;
				
				if (iFunction == 1)
					flDelay = flOffset + sqrt(flDelay);
				if (iFunction == 2)
					flDelay = flOffset + log(flDelay);
				
				if (pPlayer.pev.armorvalue < flThreshold)
					pCustom.SetKeyvalue("$f_mscap_armour_last", flNow);
				
				if (pPlayer.pev.armorvalue < flThreshold)
					continue;
				
				if (flDelta < flDelay && flDamage > 0)
					continue;
				else
					pCustom.SetKeyvalue("$f_mscap_armour_damage", -1.0);
				
				if (flNow - flThen < flInterval)
					continue;
				else
					pCustom.SetKeyvalue("$f_mscap_armour_then", flNow);
				
				flIncrement *= (pPlayer.pev.armorvalue - flThreshold) / (flLimit - flThreshold);
				
				if (pCustom.GetKeyvalue("$i_mscap_armour_active").GetInteger() > 0)
					pPlayer.TakeArmor(flIncrement, DMG_MEDKITHEAL, int(flLimit));
			}
		}
	}
}
