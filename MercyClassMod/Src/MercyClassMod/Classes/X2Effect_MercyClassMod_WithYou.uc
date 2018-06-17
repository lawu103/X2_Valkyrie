class X2Effect_MercyClassMod_WithYou extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	SourceUnit;
	local int					SourceObjectID;
	local XComGameStateHistory	History;
	local string DisplayText;

	History = `XCOMHISTORY;

	SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
	
	DisplayText = "This unit is guaranteed to bleed out while ";
	DisplayText $= SourceUnit.GetFullName();
	DisplayText $= " has not been downed.";
	SetDisplayInfo(ePerkBuff_Passive, "I'm With You", DisplayText, "img:///UILibrary_MercyClassMod.WithYou");
}

defaultproperties
{
	EffectName = "WithYouDummy";
	DuplicateResponse = eDupe_Ignore;
	bRemoveWhenTargetDies = false;
}