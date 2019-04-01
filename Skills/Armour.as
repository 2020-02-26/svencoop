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
	
	pCustom.SetKeyvalue("$i_mscap_armour_function",  2);
	pCustom.SetKeyvalue("$f_mscap_armour_offset",    1.0);
	pCustom.SetKeyvalue("$f_mscap_armour_factor",    1.0);
	pCustom.SetKeyvalue("$f_mscap_armour_increment", 1.0);
	pCustom.SetKeyvalue("$f_mscap_armour_interval",  0.2);
	pCustom.SetKeyvalue("$f_mscap_armour_threshold", 1.0);
	pCustom.SetKeyvalue("$f_mscap_armour_limit",     75.0);
	
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
	
	g_PlayerFuncs.ClientPrint(cast<CBasePlayer@>(pDamageInfo.pVictim), HUD_PRINTCENTER, "Taken " + string(flDamage + pDamageInfo.flDamage) + " damage\n");
	
	return HOOK_CONTINUE;
}

HookReturnCode onChat(
	SayParameters@ pParams)
{
	const CCommand@ cArgs = pParams.GetArguments();
	
	if (cArgs.ArgC() <= 0)
		return HOOK_CONTINUE;
	
	if (cArgs.Arg(0) != "armour")
		return HOOK_CONTINUE;
	
	pParams.ShouldHide = true;
	
	if (cArgs.Arg(1) == "info")
		MSCAP::Skills::onArmourInfo(pParams.GetPlayer());
	else
		g_PlayerFuncs.SayText(pParams.GetPlayer(), "Unknown armour action \"" + cArgs.Arg(1) + "\".\n");
	
	return HOOK_CONTINUE;
}

namespace MSCAP {
	namespace Skills {
		void onArmourInfo(CBasePlayer@ pPlayer) {
			//g_PlayerFuncs.SayText(pParams.GetPlayer(), "Unknown armour action \"" + cArgs.Arg(1) + "\".\n");
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
				
				float flDelay = flOffset + (flDamage * flFactor);
				
				if (iFunction == 1)
					flDelay = sqrt(flDelay);
				if (iFunction == 2)
					flDelay = log(flDelay);
				
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
				
				
				pPlayer.TakeArmor(flIncrement, DMG_MEDKITHEAL, int(flLimit));
			}
		}
	}
}
