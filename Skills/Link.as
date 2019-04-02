#include "../LinkDamageSphere"

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor("https://github.com/sugar-crystal-ice-water");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/sugar-crystal-ice-water");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onClientPutInServer);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @onPlayerTakeDamage);
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
}

HookReturnCode onClientPutInServer(
	CBasePlayer@ pPlayer)
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue("$i_mscap_link", 1);
	
	pCustom.SetKeyvalue("$i_mscap_link_active", 1);
	
	pCustom.SetKeyvalue("$f_mscap_link_cooldown", 3.0);
	pCustom.SetKeyvalue("$f_mscap_link_distance", 512.0);
	pCustom.SetKeyvalue("$f_mscap_link_ratio",    0.5);
	pCustom.SetKeyvalue("$i_mscap_link_limit",    4);
	
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
	
	if (!(pCustom.GetKeyvalue("$i_mscap_link_active").GetInteger() > 0))
		return HOOK_CONTINUE;
	
	float flCooldown = pCustom.GetKeyvalue("$f_mscap_link_cooldown").GetFloat();
	float flDistance = pCustom.GetKeyvalue("$f_mscap_link_distance").GetFloat();
	float flRatio    = pCustom.GetKeyvalue("$f_mscap_link_ratio").GetFloat();
	uint  uiLimit    = pCustom.GetKeyvalue("$i_mscap_link_limit").GetInteger();
	
	float flNow      = g_EngineFuncs.Time();
	float flDelta    = flNow - pCustom.GetKeyvalue("$f_mscap_link_then").GetFloat();
	
	if (flDelta < flCooldown)
		return HOOK_CONTINUE;
	
	bool bLinked = MSCAP::LinkDamageSphere(
		pDamageInfo,
		flDistance,
		flRatio,
		uiLimit);
	
	if (bLinked)
		pCustom.SetKeyvalue("$f_mscap_link_then", flNow);
	
	return HOOK_CONTINUE;
}

HookReturnCode onChat(
	SayParameters@ pParams)
{
	const CCommand@ cArgs = pParams.GetArguments();
	CustomKeyvalues@ pCustom = pParams.GetPlayer().GetCustomKeyvalues();
	
	if (cArgs.ArgC() <= 0)
		return HOOK_CONTINUE;
	
	if (cArgs.Arg(0) != "link")
		return HOOK_CONTINUE;
	
	pParams.ShouldHide = true;
	
	if (cArgs.Arg(1) == "info")
		MSCAP::Skills::onLinkInfo(pParams.GetPlayer());
	else if (cArgs.Arg(1) == "activate")
		pCustom.SetKeyvalue("$i_mscap_link_active", 1);
	else if (cArgs.Arg(1) == "deactivate")
		pCustom.SetKeyvalue("$i_mscap_link_active", 0);
	else
		g_PlayerFuncs.SayText(pParams.GetPlayer(), "Unknown link action \"" + cArgs.Arg(1) + "\".\n");
	
	return HOOK_CONTINUE;
}

namespace MSCAP {
	namespace Skills {
		void onLinkInfo(CBasePlayer@ pPlayer) {
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			
			float flCooldown = pCustom.GetKeyvalue("$f_mscap_link_cooldown").GetFloat();
			float flDistance = pCustom.GetKeyvalue("$f_mscap_link_distance").GetFloat();
			float flRatio    = pCustom.GetKeyvalue("$f_mscap_link_ratio").GetFloat();
			uint  uiLimit    = pCustom.GetKeyvalue("$i_mscap_link_limit").GetInteger();
			
			g_PlayerFuncs.SayText(pPlayer, "Damage link cooldown: "         + formatFloat(flCooldown,      "", 0, 1) + "s.\n");
			g_PlayerFuncs.SayText(pPlayer, "Damage link maximum distance: " + formatFloat(flDistance,      "", 0, 1) + " units.\n");
			g_PlayerFuncs.SayText(pPlayer, "Damage link ratio: "            + formatFloat(flRatio * 100.0, "", 0, 0) + "%.\n");
			g_PlayerFuncs.SayText(pPlayer, "Damage link maximum links: "    + uiLimit                                + "x.\n");
		}
	}
}
