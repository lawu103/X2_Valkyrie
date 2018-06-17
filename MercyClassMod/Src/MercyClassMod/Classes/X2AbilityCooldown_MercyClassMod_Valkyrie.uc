class X2AbilityCooldown_MercyClassMod_Valkyrie extends X2AbilityCooldown;

simulated function int GetNumTurns(XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	if (XComGameState_Unit(AffectState).HasSoldierAbility('RagnarokMercy'))
		return iNumTurns - 1;

	return iNumTurns;
}