#include "../LineOfSightTeleport"

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor("https://github.com/sugar-crystal-ice-water");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/sugar-crystal-ice-water");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onClientPutInServer);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
}

HookReturnCode onClientPutInServer(
	CBasePlayer@ pPlayer)
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue("$i_mscap_blink", 1);
	
	pCustom.SetKeyvalue("$f_mscap_blink_cooldown", 5.0);
	pCustom.SetKeyvalue("$f_mscap_blink_distance", 1024.0);
	
	return HOOK_CONTINUE;
}

HookReturnCode onClientDisconnect(
	CBasePlayer@ pPlayer)
{
	return HOOK_CONTINUE;
}

HookReturnCode onChat(
	SayParameters@ pParams)
{
	const CCommand@ cArgs = pParams.GetArguments();
	
	if (cArgs.ArgC() <= 0)
		return HOOK_CONTINUE;
	
	if (cArgs.Arg(0) != "blink")
		return HOOK_CONTINUE;
	
	pParams.ShouldHide = true;
	
	if (cArgs.Arg(1) == "activate")
		MSCAP::Skills::onBlinkActivate(pParams.GetPlayer());
	else
		g_PlayerFuncs.SayText(pParams.GetPlayer(), "Unknown blink action \"" + cArgs.Arg(1) + "\".\n");
	
	return HOOK_CONTINUE;
}

namespace MSCAP {
	namespace Skills {
		void onBlinkActivate(CBasePlayer@ pPlayer) {
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			
			float flCooldown = pCustom.GetKeyvalue("$f_mscap_blink_cooldown").GetFloat();
			float flDistance = pCustom.GetKeyvalue("$f_mscap_blink_distance").GetFloat();
			
			float flNow      = g_EngineFuncs.Time();
			float flDelta    = flNow - pCustom.GetKeyvalue("$f_mscap_blink_then").GetFloat();
			
			if (flDelta < flCooldown) {
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Blink cooldown " + string(ceil(flCooldown - flDelta)) + "s\n");
			} else if (MSCAP::LineOfSightTeleport(pPlayer, flDistance)) {
				pCustom.SetKeyvalue("$f_mscap_blink_then", flNow);
				
			}
		}
	}
}
