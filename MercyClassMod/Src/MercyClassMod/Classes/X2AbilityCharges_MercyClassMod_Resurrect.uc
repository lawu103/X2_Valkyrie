class X2AbilityCharges_MercyClassMod_Resurrect extends X2AbilityCharges;

var int BaseCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit)
{
	local int TotalCharges;

	TotalCharges = BaseCharges;
	
	if(Unit.HasSoldierAbility('HeroesNeverDie'))
		TotalCharges += 1;

	return TotalCharges;
}