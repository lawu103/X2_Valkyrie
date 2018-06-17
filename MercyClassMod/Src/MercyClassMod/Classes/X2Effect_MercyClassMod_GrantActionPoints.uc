// Gives one or two bonus actions when Valkyrie is activated, depending if Sleipnir is also unlocked
class X2Effect_MercyClassMod_GrantActionPoints extends X2Effect_GrantActionPoints;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local int i;
	local Name SkipEffect;
	local int Points;

	UnitState = XComGameState_Unit(kNewTargetState);
	if( UnitState != none )
	{
		foreach SkipWithEffect(SkipEffect)
		{
			if( UnitState.IsUnitAffectedByEffectName(SkipEffect) )
			{
				return;
			}
		}

		Points = 1;
		if (UnitState.HasSoldierAbility('Sleipnir'))
			Points += 1;

		if( !bApplyOnlyWhenOut || (UnitState.NumActionPoints(class'X2CharacterTemplateManager'.default.StandardActionPoint) == 0) )
		{
			for( i = 0; i < Points; ++i )
			{
				UnitState.ActionPoints.AddItem(PointType);
			}
		}
	}
}