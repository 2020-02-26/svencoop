#include "../LinkDamageSphere"

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor("https://github.com/sugar-crystal-ice-water");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/sugar-crystal-ice-water");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onClientPutInServer);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @onPlayerTakeDamage);
}

HookReturnCode onClientPutInServer(
	CBasePlayer@ pPlayer)
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue("$i_mscap_link", 1);
	
	pCustom.SetKeyvalue("$f_mscap_link_cooldown", 0.25);
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
