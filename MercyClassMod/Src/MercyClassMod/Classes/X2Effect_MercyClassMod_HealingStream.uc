class X2Effect_MercyClassMod_HealingStream extends X2Effect;

var int PerUseHP;       //  amount of HP to heal for any application of the effect

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability	Ability;
	local XComGameState_Unit	TargetUnit, SourceUnit;
	local XComGameState_Item	ItemState;
	local X2GremlinTemplate		GremlinTemplate;
	local int					SourceObjectID, HealAmount;
	local XComGameStateHistory	History;

	History = `XCOMHISTORY;
	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (Ability == none)
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (Ability != none && TargetUnit != none)
	{
		HealAmount = PerUseHP;

		ItemState = Ability.GetSourceWeapon();
		if (ItemState != none)
		{
			GremlinTemplate = X2GremlinTemplate(ItemState.GetMyTemplate());
			if (GremlinTemplate != none)
				HealAmount += GremlinTemplate.HealingBonus;
		}

		SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
		SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
		if(SourceUnit.AffectedByEffectNames.Find('RideValkyriesDummy') != INDEX_NONE)
			HealAmount += 1;

		if(TargetUnit.AffectedByEffectNames.Find('Anesthetic') != INDEX_NONE)
			HealAmount += 1;

		TargetUnit.ModifyCurrentStat(eStat_HP, HealAmount);
		`TRIGGERXP('XpHealDamage', ApplyEffectParameters.SourceStateObjectRef, kNewTargetState.GetReference(), NewGameState);

		if ((SourceObjectID != TargetUnit.ObjectID) && SourceUnit.CanEarnSoldierRelationshipPoints(TargetUnit)) // pmiller - so that you can't have a relationship with yourself
		{
			SourceUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SourceObjectID));
			SourceUnit.AddToSquadmateScore(TargetUnit.ObjectID, class'X2ExperienceConfig'.default.SquadmateScore_MedikitHeal);
			TargetUnit.AddToSquadmateScore(SourceUnit.ObjectID, class'X2ExperienceConfig'.default.SquadmateScore_MedikitHeal);
		}
	}
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int Healed;
	local string Msg;

	OldUnit = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (OldUnit != none && NewUnit != None)
	{
		Healed = NewUnit.GetCurrentStat(eStat_HP) - OldUnit.GetCurrentStat(eStat_HP);

		if (Healed != 0)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			Msg = Repl(class'X2Effect_ApplyMedikitHeal'.default.HealedMessage, "<Heal/>", Healed);
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Msg, '', eColor_Good);
		}
	}
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}