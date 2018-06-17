class X2Effect_MercyClassMod_DamageBuff extends X2Effect_Persistent;

var int BonusDamage, BonusDamageTotal;
var bool ApplyToGrenades;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	SourceUnit;
	local XComGameState_Item	SourceItem;
	local X2GremlinTemplate		GremlinTemplate;
	local int					SourceObjectID;
	local XComGameStateHistory	History;
	local string				DisplayText;

	History = `XCOMHISTORY;

	BonusDamageTotal = BonusDamage;
	ApplyToGrenades = false;

	SourceItem = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceItem == none)
		SourceItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	if (SourceItem != none)
	{
		GremlinTemplate = X2GremlinTemplate(SourceItem.GetMyTemplate());
		if (GremlinTemplate != none)
		{
			BonusDamageTotal += GremlinTemplate.HealingBonus;
		}
	}

	SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
	if(SourceUnit.AffectedByEffectNames.Find('RideValkyriesDummy') != INDEX_NONE)
		BonusDamageTotal += 1;

	if(SourceUnit.HasSoldierAbility('Uninhibited'))
		ApplyToGrenades = true;

	DisplayText = "This unit is dealing +";
	DisplayText $= BonusDamageTotal;
	DisplayText $= " damage.";
	SetDisplayInfo(ePerkBuff_Bonus, "Damage Buff", DisplayText, "img:///UILibrary_MercyClassMod.DamageBuff", true);
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{
	local XComGameState_Item			SourceWeapon;
	local X2GrenadeTemplate				GrenadeTemplate;
	local X2Effect_ApplyWeaponDamage	DamageEffect;

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult) || CurrentDamage == 0)
		return 0;

	SourceWeapon = AbilityState.GetSourceWeapon();

	if (SourceWeapon != none)
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());

		if (GrenadeTemplate == none)
		{
			GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
			// only limit this when actually applying damage (not previewing)
			if( NewGameState != none )
			{
				//	only add the bonus damage when the damage effect is applying the weapon's base damage
				DamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
				if( DamageEffect == none || DamageEffect.bIgnoreBaseDamage )
				{
					return 0;
				}
			}
		}

		if (GrenadeTemplate != none && GrenadeTemplate.bAllowVolatileMix)
		{
			//	no game state means it's for damage preview
			if (NewGameState == none && !ApplyToGrenades)
			{				
				return 0;
			}

			//	only add the bonus damage when the damage effect is applying the weapon's base damage
			DamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
			if (DamageEffect != none && !DamageEffect.bIgnoreBaseDamage && !ApplyToGrenades)
			{
				return 0;
			}			
		}
	}

	return BonusDamageTotal;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local string Msg;

	OldUnit = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (OldUnit != none && NewUnit != None)
	{
		if (BonusDamageTotal != 0)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			Msg = "+"$BonusDamageTotal$" Damage Buffed";
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Msg, '', eColor_Good);
		}
	}
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}

DefaultProperties
{
	EffectName = "DamageBuff"
	DuplicateResponse = eDupe_Ignore
	bRemoveWhenTargetDies = true
	bDisplayInSpecialDamageMessageUI = true
}
