//When Valhalla is unlocked, Mercy should start the next turn with a bonus action (or two if Sleipnir is also unlocked)
class X2Effect_MercyClassMod_Valhalla extends X2Effect_PersistentStatChange;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	local int i;
	local int Points;

	Points = 1;
	if (UnitState.HasSoldierAbility('Sleipnir'))
		Points += 1;

	for (i = 0; i < Points; ++i)
	{
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
}

defaultproperties
{
	EffectName="ValhallaEffect"
}