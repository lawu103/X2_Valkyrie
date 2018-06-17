class X2Effect_MercyClassMod_ResurrectPersistent extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	TargetUnit;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	
	if (TargetUnit.IsBleedingOut() || TargetUnit.IsUnconscious())
	{
		VisualizationFn = class'X2StatusEffects'.static.UnconsciousVisualizationRemoved;
	}
}