// For when Odin's Blessing and Valhalla are both unlocked (Mercy should heal the next turn)
class X2Effect_MercyClassMod_Regeneration extends X2Effect_Regeneration;

function int GetStartingNumTurns(const out EffectAppliedData ApplyEffectParameters)
{
	local XComGameState_Ability AbilityState;
	local XComGameState_BaseObject TargetState;
	local XComGameState_Unit TargetUnit, SourceUnit;
	local int SourceObjectID;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local int StartingNumTurns;
	local XComGameState_BattleData BattleDataState;
	local X2SitRepEffect_ModifyEffectDuration SitRepEffect;

	// if the Ability that spawned this effect has a limited duration, we want to use that duration
	History = `XCOMHISTORY;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (AbilityState != none && AbilityState.TurnsUntilAbilityExpires > 0)
	{
		bInfiniteDuration = false;
		return AbilityState.TurnsUntilAbilityExpires;
	}

	// if this effect is specified for an infinite duration, return 1
	if( bInfiniteDuration )
	{
		return 1;
	}

	StartingNumTurns = iNumTurns;
	TargetState = History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID);

	//Check for Valhalla
	SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
	if(SourceUnit.HasSoldierAbility('Valhalla'))
		StartingNumTurns += 1;

	// Check if any other effects on the source or target unit want to change the duration of this effect
	TargetUnit = XComGameState_Unit(TargetState);
	if(TargetUnit != none)
	{
		foreach TargetUnit.AffectedByEffects(EffectRef)
		{
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			EffectState.GetX2Effect().AdjustEffectDuration(ApplyEffectParameters, StartingNumTurns);
		}
	}

	// find any sitreps that can modify effect durations and apply those limits
	BattleDataState = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if (BattleDataState != none)
	{
		foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_ModifyEffectDuration', SitRepEffect, BattleDataState.ActiveSitReps)
		{
			StartingNumTurns = SitRepEffect.MaybeModifyDuration( self, TargetUnit, StartingNumTurns );
		}
	}

	// if the effect will tick per action instead of per turn, then modify the turns remaining counter
	// to reflect that.
	if(bConvertTurnsToActions && IsTickEveryAction(TargetState))
	{
		StartingNumTurns *= class'X2CharacterTemplateManager'.default.StandardActionsPerTurn;
	}

	// return the configured duration for this effect
	return StartingNumTurns;
}