class X2Condition_MercyClassMod_Valkyrie extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kTarget);

	if (UnitState == none)
		return 'AA_NotAUnit';

	if(UnitState.AffectedByEffectNames.Find('Valkyrie') != INDEX_NONE)
		return 'AA_UnitIsImmune';

	return 'AA_Success';
}