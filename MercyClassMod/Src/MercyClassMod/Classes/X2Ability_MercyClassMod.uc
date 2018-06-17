class X2Ability_MercyClassMod extends X2Ability dependson(XComGameStateContext_Ability) config(GameData_MercyClassMod);

var config int HEALING_STREAM_HP, HEALING_STREAM_DISTANCE;
var config int DAMAGE_BUFF_DMG, DAMAGE_BUFF_DISTANCE;
var config int VALKYRIE_COOLDOWN;
var config int GUARDIAN_ANGEL_COOLDOWN, GUARDIAN_ANGEL_MOVEMENT;
var config int SURPRISING_AMOUNTS_DMG, SURPRISING_AMOUNTS_AIM;
var config int RESURRECT_HP, RESURRECT_CHARGES;
var config int PROTECT_ME_AIM;
var config int ODIN_SHIELD_DEFENSE;
var config int ANESTHETIC_SHIELD, ANESTHETIC_COOLDOWN;
var config int SWIFT_RESPONSE_COOLDOWN;
var config int ODIN_BLESSING_HP, ODIN_BLESSING_DMG;
var config int SELF_TREATMENT_HP;
var config int WITH_YOU_WILL;
var config int INCISION_PIERCE, INCISION_CRIT;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(HealingStream());
	Templates.AddItem(DamageBuff());
	Templates.AddItem(Valkyrie());
	Templates.AddItem(GuardianAngel());
	Templates.AddItem(SurprisingAmounts());
	Templates.AddItem(PurePassive('RideOfTheValkyries', "img:///UILibrary_MercyClassMod.RideValkyries", false));
	Templates.AddItem(Resurrect());
	Templates.AddItem(ProtectMe());
	Templates.AddItem(ProtectMeTrigger());
	Templates.AddItem(PurePassive('OdinShield', "img:///UILibrary_MercyClassMod.OdinShield", false));
	Templates.AddItem(PurePassive('Sleipnir', "img:///UILibrary_MercyClassMod.Sleipnir", false));
	Templates.AddItem(Anesthetic());
	Templates.AddItem(SwiftResponse());
	Templates.AddItem(PurePassive('GoGetEm', "img:///UILibrary_MercyClassMod.GoGetEm", false));
	Templates.AddItem(PurePassive('OdinBlessing', "img:///UILibrary_MercyClassMod.OdinBlessing", false));
	Templates.AddItem(SelfTreatment());
	Templates.AddItem(WithYou());
	Templates.AddItem(Incision());
	Templates.AddItem(PurePassive('Valhalla', "img:///UILibrary_MercyClassMod.Valhalla", false));
	Templates.AddItem(HeroesNeverDie());
	Templates.AddItem(PurePassive('Uninhibited', "img:///UILibrary_MercyClassMod.Uninhibited", false));
	Templates.AddItem(PurePassive('RagnarokMercy', "img:///UILibrary_MercyClassMod.RagnarokCD", false));

	return Templates;
}

static function X2AbilityTemplate HealingStream()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local array<name>							SkipExclusions;
	local X2Condition_UnitProperty				TargetProperty;
	local X2Condition_UnitStatCheck				UnitStatCheckCondition;
	local X2Condition_UnitEffects				UnitEffectsCondition;
	local X2Effect_MercyClassMod_HealingStream	HealingStreamHeal;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HealingStream');

	Template.IconImage = "img:///UILibrary_MercyClassMod.HealingStream";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = default.HEALING_STREAM_DISTANCE * class'XComWorldData'.const.WORLD_StepSize;
	TargetProperty.ExcludeDead = false; //Hack: See following comment.
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.ExcludeFullHealth = true;
	TargetProperty.ExcludeRobotic = true;
	TargetProperty.ExcludeTurret = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	//Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units.
	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityTargetConditions.AddItem(UnitStatCheckCondition);

	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_UnitIsImpaired');
	Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	HealingStreamHeal = new class'X2Effect_MercyClassMod_HealingStream';
	HealingStreamHeal.PerUseHP = default.HEALING_STREAM_HP;
	Template.AddTargetEffect(HealingStreamHeal);
	Template.AddTargetEffect(class'X2Ability_SpecialistAbilitySet'.static.RemoveAllEffectsByDamageType());

	Template.bStationaryWeapon = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;

	Template.ActivationSpeech = 'MedicalProtocol';

	Template.bOverrideWeapon = true;
	Template.CustomSelfFireAnim = 'NO_MedicalProtocol';

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}

static function X2AbilityTemplate DamageBuff()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2Effect_MercyClassMod_DamageBuff		DamageBuffEffect;
	local X2Effect_RemoveEffects				GoGetEmEffect;
	local X2Condition_AbilityProperty			GoGetEmCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DamageBuff');

	Template.IconImage = "img:///UILibrary_MercyClassMod.DamageBuff";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('Valkyrie');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = default.DAMAGE_BUFF_DISTANCE * class'XComWorldData'.const.WORLD_StepSize;
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.ExcludeRobotic = false;
	TargetProperty.ExcludeTurret = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('DamageBuff', 'AA_UnitIsImmune');
	EffectsCondition.AddExcludeEffect('MimicBeaconEffect', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	DamageBuffEffect = new class'X2Effect_MercyClassMod_DamageBuff';
	DamageBuffEffect.BonusDamage = default.DAMAGE_BUFF_DMG;
	DamageBuffEffect.BuildPersistentEffect(1, , false, , eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(DamageBuffEffect);

	//if Go Get 'Em is unlocked, remove negative mental effects from the target
	GoGetEmEffect = GoGetEmRemoveEffects();
	GoGetEmCondition = new class 'X2Condition_AbilityProperty';
	GoGetEmCondition.OwnerHasSoldierAbilities.AddItem('GoGetEm');
	GoGetEmEffect.TargetConditions.AddItem(GoGetEmCondition);
	Template.AddTargetEffect(GoGetEmEffect);

	Template.bStationaryWeapon = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;

	Template.bOverrideWeapon = true;
	Template.CustomSelfFireAnim = 'NO_RevivalProtocol';

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'DamageBuff'
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
//END AUTOGENERATED CODE: Template Overrides 'DamageBuff'

	return Template;
}

static function X2Effect_RemoveEffects GoGetEmRemoveEffects()
{
	local X2Effect_RemoveEffects RemoveEffects;

	// remove other impairing mental effects
	RemoveEffects = new class'X2Effect_RemoveEffects'; 
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DazedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ObsessedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.BerserkName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ShatteredName);

	return RemoveEffects;
}

static function X2AbilityTemplate Valkyrie()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2AbilityCooldown_MercyClassMod_Valkyrie	Cooldown;
    local X2AbilityTargetStyle						TargetStyle;
	local X2Effect_MercyClassMod_Persistent			ValkyrieEffect;
	local X2Effect_MercyClassMod_GrantActionPoints	BonusActions;
	local X2Effect_MercyClassMod_Persistent			RideValkyriesDummyEffect;
	local X2Condition_AbilityProperty				RideValkyriesCondition;
	local X2Effect_MercyClassMod_PersistentStatChange	OdinShieldEffect;
	local X2Condition_AbilityProperty				OdinShieldCondition;
	local X2Effect_MercyClassMod_Valhalla			Valhalla;
	local X2Condition_AbilityProperty				ValhallaCondition;
	local X2Effect_MercyClassMod_HealingStream		OdinBlessingHealEffect;
	local X2Effect_RemoveEffectsByDamageType		OdinBlessingRemoveEffect;
	local X2Effect_MercyClassMod_OdinBlessing		OdinBlessingDamageEffect;
	local X2Effect_MercyClassMod_Regeneration		RegenerationValhalla;
	local X2Condition_AbilityProperty				OdinBlessingCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Valkyrie');

	Template.IconImage = "img:///UILibrary_MercyClassMod.Valkyrie";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.Hostility = eHostility_Offensive;	//force Valkyrie to break concealment
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_MercyClassMod_Valkyrie';
	Cooldown.iNumTurns = default.VALKYRIE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;

    TargetStyle = new class'X2AbilityTarget_Self';
    Template.AbilityTargetStyle = TargetStyle;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_MercyClassMod_Valkyrie');	//Don't allow Valkyrie to be used if it's still active
	Template.AddShooterEffectExclusions();

	ValkyrieEffect = new class'X2Effect_MercyClassMod_Persistent';
	ValkyrieEffect.EffectName = 'Valkyrie';
	ValkyrieEffect.DuplicateResponse = eDupe_Ignore;
	ValkyrieEffect.bRemoveWhenTargetDies = true;
	ValkyrieEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	ValkyrieEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	Template.AddTargetEffect(ValkyrieEffect);

	//Give a bonus action (or two if Sleipnir is unlocked)
	BonusActions = new class'X2Effect_MercyClassMod_GrantActionPoints';
	BonusActions.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(BonusActions);

	//With Valhalla, give an extra starting action (or two if Sleipnir is unlocked) for the next turn
	Valhalla = new class'X2Effect_MercyClassMod_Valhalla';
	Valhalla.BuildPersistentEffect(2, , , , eGameRule_PlayerTurnBegin);
	Valhalla.DuplicateResponse = eDupe_Ignore;
	ValhallaCondition = new class 'X2Condition_AbilityProperty';
	ValhallaCondition.OwnerHasSoldierAbilities.AddItem('Valhalla');
	Valhalla.TargetConditions.AddItem(ValhallaCondition);
	Template.AddTargetEffect(Valhalla);

	//If Ride of the Valkyries is unlocked, create dummy effect for it
	RideValkyriesDummyEffect = new class'X2Effect_MercyClassMod_Persistent';
	RideValkyriesDummyEffect.EffectName = 'RideValkyriesDummy';
	RideValkyriesDummyEffect.DuplicateResponse = eDupe_Ignore;
	RideValkyriesDummyEffect.bRemoveWhenTargetDies = true;
	RideValkyriesDummyEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	RideValkyriesDummyEffect.SetDisplayInfo(ePerkBuff_Bonus, "Ride of the Valkyries", "This unit is temporarily better at healing and damage buffing.", "img:///UILibrary_MercyClassMod.Valkyrie");
	RideValkyriesCondition = new class 'X2Condition_AbilityProperty';
	RideValkyriesCondition.OwnerHasSoldierAbilities.AddItem('RideOfTheValkyries');
	RideValkyriesDummyEffect.TargetConditions.AddItem(RideValkyriesCondition);
	Template.AddShooterEffect(RideValkyriesDummyEffect);

	//If Odin's Shield is unlocked, increase defense while Valkyrie is active
	OdinShieldEffect = new class'X2Effect_MercyClassMod_PersistentStatChange';
	OdinShieldEffect.EffectName = 'OdinShield';
	OdinShieldEffect.AddPersistentStatChange(eStat_Defense, default.ODIN_SHIELD_DEFENSE, MODOP_Addition);
	OdinShieldEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	OdinShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, "Odin's Shield", "This unit has increased defense while Valkyrie is active.", "img:///UILibrary_MercyClassMod.OdinShield");
	OdinShieldCondition = new class 'X2Condition_AbilityProperty';
	OdinShieldCondition.OwnerHasSoldierAbilities.AddItem('OdinShield');
	OdinShieldEffect.TargetConditions.AddItem(OdinShieldCondition);
	Template.AddTargetEffect(OdinShieldEffect);

	//If Odin's Blessing is unlocked, heal and damage buff Mercy when Valkyrie is activated
	OdinBlessingHealEffect = new class 'X2Effect_MercyClassMod_HealingStream';
	OdinBlessingHealEffect.PerUseHP = default.ODIN_BLESSING_HP;
	OdinBlessingRemoveEffect = class'X2Ability_SpecialistAbilitySet'.static.RemoveAllEffectsByDamageType();
	OdinBlessingDamageEffect = new class'X2Effect_MercyClassMod_OdinBlessing';
	OdinBlessingDamageEffect.BonusDamage = default.ODIN_BLESSING_DMG;
	OdinBlessingDamageEffect.BuildPersistentEffect(1, , false, , eGameRule_PlayerTurnBegin);
	OdinBlessingCondition = new class 'X2Condition_AbilityProperty';
	OdinBlessingCondition.OwnerHasSoldierAbilities.AddItem('OdinBlessing');
	OdinBlessingHealEffect.TargetConditions.AddItem(OdinBlessingCondition);
	OdinBlessingRemoveEffect.TargetConditions.AddItem(OdinBlessingCondition);
	OdinBlessingDamageEffect.TargetConditions.AddItem(OdinBlessingCondition);
	Template.AddTargetEffect(OdinBlessingHealEffect);
	Template.AddTargetEffect(OdinBlessingRemoveEffect);
	Template.AddTargetEffect(OdinBlessingDamageEffect);

	//For Odin's Blessing, also try healing the next turn; this effect doesn't do anything if Valhalla isn't unlocked.
	RegenerationValhalla = new class'X2Effect_MercyClassMod_Regeneration';
	RegenerationValhalla.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	RegenerationValhalla.HealAmount = default.ODIN_BLESSING_HP;
	RegenerationValhalla.TargetConditions.AddItem(OdinBlessingCondition);
	Template.AddTargetEffect(RegenerationValhalla);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	Template.ActivationSpeech = 'RestorativeMist';

	Template.SuperConcealmentLoss = 100;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Valkyrie'
	Template.AbilityConfirmSound = "Battlelord_Activate";
//END AUTOGENERATED CODE: Template Overrides 'Valkyrie'

	return Template;
}

static function X2AbilityTemplate GuardianAngel()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown					Cooldown;
	local X2AbilityTargetStyle				TargetStyle;
	local X2Effect_PersistentStatChange     PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GuardianAngel');

	Template.IconImage="img:///UILibrary_MercyClassMod.GuardianAngel";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.Hostility = eHostility_Neutral;
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
    Cooldown.iNumTurns = default.GUARDIAN_ANGEL_COOLDOWN;
    Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;

    TargetStyle = new class'X2AbilityTarget_Self';
    Template.AbilityTargetStyle = TargetStyle;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.EffectName = 'GuardianAngel';
	PersistentStatChangeEffect.DuplicateResponse = eDupe_Ignore;
	PersistentStatChangeEffect.bRemoveWhenTargetDies = true;
	PersistentStatChangeEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.GUARDIAN_ANGEL_MOVEMENT);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'GuardianAngel'
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Run_N_Gun";
//END AUTOGENERATED CODE: Template Overrides 'GuardianAngel'

	return Template;
}

static function X2AbilityTemplate SurprisingAmounts()
{
	local X2AbilityTemplate							Template;	
	local X2Effect_BonusWeaponDamage            DamageEffect;
	local X2Effect_ToHitModifier                HitModEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'SurprisingAmounts');

	Template.IconImage = "img:///UILibrary_MercyClassMod.SurprisingAmounts";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'X2Effect_BonusWeaponDamage';
	DamageEffect.BonusDmg = default.SURPRISING_AMOUNTS_DMG;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	HitModEffect = new class'X2Effect_ToHitModifier';
	HitModEffect.AddEffectHitModifier(eHit_Success, default.SURPRISING_AMOUNTS_AIM, Template.LocFriendlyName, , false, true, true, true);
	HitModEffect.BuildPersistentEffect(1, true, false, false);
	HitModEffect.EffectName = 'SurprisingAmountsAim';
	Template.AddTargetEffect(HitModEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate Resurrect()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2AbilityCost_Charges						ChargeCost;
	local X2AbilityCharges_MercyClassMod_Resurrect	Charges;
	local X2AbilityTargetStyle						TargetStyle;
	local X2Condition_UnitProperty					TargetProperty;
	local X2Effect_MercyClassMod_Resurrect			ResurrectHeal;
	local X2Effect_RemoveEffects					RemoveEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Resurrect');

	Template.IconImage = "img:///UILibrary_MercyClassMod.Resurrect";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	ChargeCost = new class'X2AbilityCost_Charges';
	Template.AbilityCosts.AddItem(ChargeCost);

	Charges = new class'X2AbilityCharges_MercyClassMod_Resurrect';
	Charges.BaseCharges = default.RESURRECT_CHARGES;
	Template.AbilityCharges = Charges;
	
	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = TargetStyle;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(TargetProperty);

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = 144.0f;	//same Unreal unit distance as the base game's Revive ability, which is also adjacency-based
	TargetProperty.ExcludeDead = false;
	TargetProperty.ExcludeAlive = false;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_MercyClassMod_Resurrect');

	ResurrectHeal = new class'X2Effect_MercyClassMod_Resurrect';
	ResurrectHeal.PerUseHP = default.RESURRECT_HP;
	Template.AddTargetEffect(ResurrectHeal);
	Template.AddTargetEffect(class'X2Ability_SpecialistAbilitySet'.static.RemoveAllEffectsByDamageType());
	Template.AddTargetEffect(new class'X2Effect_MercyClassMod_ResurrectPersistent');	//Used for the regaining consciousness animation

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
	RemoveEffects.bDoNotVisualize = true;
	Template.AddTargetEffect(RemoveEffects);

	Template.AddTargetEffect(new class'X2Effect_RestoreActionPoints');

	Template.ActivationSpeech = 'HealingAlly';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	Template.bShowPostActivation = true;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Resurrect'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CustomFireAnim = 'HL_Revive';
//END AUTOGENERATED CODE: Template Overrides 'Resurrect'

	return Template;
}

static function X2AbilityTemplate ProtectMe()
{
	local X2AbilityTemplate						Template;
	local X2Effect_CoveringFire                 CoveringEffect;

	Template = PurePassive('ProtectMe', "img:///UILibrary_MercyClassMod.ProtectMe", false, 'eAbilitySource_Perk', true);
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	CoveringEffect = new class'X2Effect_CoveringFire';
	CoveringEffect.BuildPersistentEffect(1, true, false, false);
	CoveringEffect.AbilityToActivate = 'ProtectMeTrigger';
	CoveringEffect.GrantActionPoint = 'Judgment';
	CoveringEffect.bPreEmptiveFire = false;
	CoveringEffect.bDirectAttackOnly = true;
	CoveringEffect.bOnlyDuringEnemyTurn = true;
	CoveringEffect.bUseMultiTargets = false;
	CoveringEffect.EffectName = 'ProtectMeWatchEffect';
	Template.AddTargetEffect(CoveringEffect);

	Template.AdditionalAbilities.AddItem('ProtectMeTrigger');

	return Template;
}

static function X2AbilityTemplate ProtectMeTrigger()
{	
	local X2AbilityTemplate								Template;
	local X2Effect_Persistent							ProtectMeDummyEffect;
	local X2AbilityCost_ReserveActionPoints				ActionPointCost;
	local X2Condition_UnitProperty						TargetCondition;
	local X2Effect_MercyClassMod_ProtectMeHolotarget	HolotargetEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ProtectMeTrigger');
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.IconImage = "img:///UILibrary_MercyClassMod.ProtectMe";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.AllowedTypes.Length = 0;
	ActionPointCost.AllowedTypes.AddItem('Judgment');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_MercyClassMod_ProtectMe');	//condition to prevent Protect Me from triggering more than once per turn
	Template.AddShooterEffectExclusions();

	//Dummy effect to prevent Protect Me from triggering more than once per turn
	ProtectMeDummyEffect = new class'X2Effect_Persistent';
	ProtectMeDummyEffect.EffectName = 'ProtectMeDummy';
	ProtectMeDummyEffect.DuplicateResponse = eDupe_Ignore;
	ProtectMeDummyEffect.bRemoveWhenTargetDies = true;
	ProtectMeDummyEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnEnd);
	Template.AddShooterEffect(ProtectMeDummyEffect);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeFriendlyToSource = true;
	TargetCondition.ExcludeHostileToSource = false;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	HolotargetEffect = new class 'X2Effect_MercyClassMod_ProtectMeHoloTarget';
	HolotargetEffect.HitMod = default.PROTECT_ME_AIM;
	HolotargetEffect.BuildPersistentEffect(1, , , , eGameRule_PlayerTurnBegin);
	HolotargetEffect.SetDisplayInfo(ePerkBuff_Penalty, "Callout", "This unit has drawn attention to itself and is temporarily easier to hit.", "img:///UILibrary_MercyClassMod.ProtectMe");
	HolotargetEffect.VisualizationFn = ProtectMe_Visualization;
	HolotargetEffect.bRemoveWhenTargetDies = true;
	Template.AddTargetEffect(HolotargetEffect);

	Template.CustomFireAnim = 'HL_SignalPoint';
	Template.bShowActivation = true;
	Template.CinescriptCameraType = "Skirmisher_Judgment";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	//BEGIN AUTOGENERATED CODE: Template Overrides 'ProtectMeTrigger'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.ActivationSpeech = 'Judgement';
	Template.CinescriptCameraType = "Skirmisher_Judgment";
	//END AUTOGENERATED CODE: Template Overrides 'ProtectMeTrigger'

	return Template;
}

static function ProtectMe_Visualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	if( EffectApplyResult != 'AA_Success' )
	{
		return;
	}
	if (XComGameState_Unit(ActionMetadata.StateObject_NewState) == none)
		return;

	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), "Defense lowered", '', eColor_Bad, "img:///UILibrary_MercyClassMod.ProtectMe");
}

static function X2AbilityTemplate Anesthetic()
{
	local X2AbilityTemplate				Template;
	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2AbilityCooldown             Cooldown;
	local X2AbilityTarget_Single		TargetStyle;
	local X2Condition_UnitProperty		TargetProperty;
	local X2Condition_UnitEffects		EffectsCondition;
	local X2Effect_PersistentStatChange	AnestheticEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Anesthetic');

	Template.IconImage = "img:///UILibrary_MercyClassMod.Anesthetic";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ANESTHETIC_COOLDOWN;
	Template.AbilityCooldown = Cooldown;
	
	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = TargetStyle;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeRobotic = true;
	TargetProperty.ExcludeTurret = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('Anesthetic', 'AA_UnitIsImmune');
	EffectsCondition.AddExcludeEffect('MimicBeaconEffect', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	AnestheticEffect = new class'X2Effect_PersistentStatChange';
	AnestheticEffect.EffectName = 'Anesthetic';
	AnestheticEffect.DuplicateResponse = eDupe_Ignore;
	AnestheticEffect.bRemoveWhenTargetDies = true;
	AnestheticEffect.BuildPersistentEffect(2, , false, , eGameRule_PlayerTurnBegin);
	AnestheticEffect.SetDisplayInfo(ePerkBuff_Bonus, "Anesthetic", "This unit has bonus shields and regains more HP from Healing Stream.", "img:///UILibrary_MercyClassMod.Anesthetic");
	AnestheticEffect.AddPersistentStatChange(eStat_ShieldHP, default.ANESTHETIC_SHIELD);
	Template.AddTargetEffect(AnestheticEffect);

	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_Teamwork';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.ActivationSpeech = 'HealingAlly';

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

//BEGIN AUTOGENERATED CODE: Template Overrides 'Anesthetic'
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
//END AUTOGENERATED CODE: Template Overrides 'Anesthetic'

	return Template;
}

static function X2AbilityTemplate SwiftResponse()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCooldown					Cooldown;
	local array<name>                       SkipExclusions;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SwiftResponse');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lightninghands";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.DisplayTargetHitChance = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SWIFT_RESPONSE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class 'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	Template.bAllowAmmoEffects = true; 	
	Template.bAllowBonusWeaponEffects = true;
	
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
	
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'SwiftResponse'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.ActivationSpeech = 'LightningHands';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
//END AUTOGENERATED CODE: Template Overrides 'SwiftResponse'

	return Template;
}

static function X2AbilityTemplate SelfTreatment()
{
	local X2AbilityTemplate			Template;
	local X2Effect_Regeneration		RegenerationEffect;
	local X2Effect_DamageImmunity	DamageImmunity;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SelfTreatment');

	Template.IconImage = "img:///UILibrary_MercyClassMod.SelfTreatment";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Build the regeneration effect
	RegenerationEffect = new class'X2Effect_Regeneration';
	RegenerationEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	RegenerationEffect.HealAmount = default.SELF_TREATMENT_HP;
	Template.AddTargetEffect(RegenerationEffect);

	// Build the immunities
	DamageImmunity = new class'X2Effect_DamageImmunity';
	DamageImmunity.BuildPersistentEffect(1, true, false, true);
	DamageImmunity.ImmuneTypes.AddItem('Fire');
	DamageImmunity.ImmuneTypes.AddItem('Poison');
	DamageImmunity.ImmuneTypes.AddItem('Acid');
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	Template.AddTargetEffect(DamageImmunity);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate WithYou()
{
	local X2AbilityTemplate					Template;
	local X2Condition_UnitProperty			TargetProperty;
	local X2Effect_MercyClassMod_WithYou	WithYouDummy;	//dummy effect for UI purposes
	local X2Effect_PersistentStatChange		WillEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'WithYou');

	Template.IconImage = "img:///UILibrary_MercyClassMod.WithYou";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTarget_AllAllies';

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeRobotic = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(TargetProperty);

	WithYouDummy = new class'X2Effect_MercyClassMod_WithYou';
	WithYouDummy.BuildPersistentEffect(1, true, true, false);
	Template.AddMultiTargetEffect(WithYouDummy);

	WillEffect = new class'X2Effect_PersistentStatChange';
	WillEffect.EffectName = 'WithYou';
	WillEffect.DuplicateResponse = eDupe_Ignore;
	WillEffect.bRemoveWhenTargetDies = false;
	WillEffect.BuildPersistentEffect(1, true, true, false);
	WillEffect.bEffectForcesBleedout = true;//AddPersistentStatChange(eStat_Will, default.WITH_YOU_WILL);
	Template.AddMultiTargetEffect(WillEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate Incision()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2Effect_MercyClassMod_Incision		IncisionEffect;
	local X2Effect_ToHitModifier				CritChanceEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Incision');

	Template.IconImage = "img:///UILibrary_MercyClassMod.Incision";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = default.DAMAGE_BUFF_DISTANCE * class'XComWorldData'.const.WORLD_StepSize;
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.ExcludeRobotic = false;
	TargetProperty.ExcludeTurret = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('Incision', 'AA_UnitIsImmune');
	EffectsCondition.AddExcludeEffect('MimicBeaconEffect', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	IncisionEffect = new class'X2Effect_MercyClassMod_Incision';
	IncisionEffect.ArmorPierce = default.INCISION_PIERCE;
	IncisionEffect.BuildPersistentEffect(1, , false, , eGameRule_PlayerTurnBegin);
	IncisionEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, "img:///UILibrary_MercyClassMod.Incision");
	Template.AddTargetEffect(IncisionEffect);

	CritChanceEffect = new class'X2Effect_ToHitModifier';
	CritChanceEffect.EffectName = 'Shadowstrike';
	CritChanceEffect.DuplicateResponse = eDupe_Ignore;
	CritChanceEffect.BuildPersistentEffect(1, true, false);
	CritChanceEffect.AddEffectHitModifier(eHit_Crit, default.INCISION_CRIT, Template.LocFriendlyName);
	Template.AddTargetEffect(CritChanceEffect);

	Template.bStationaryWeapon = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;

	Template.bOverrideWeapon = true;
	Template.CustomSelfFireAnim = 'NO_RevivalProtocol';

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Incision'
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
//END AUTOGENERATED CODE: Template Overrides 'Incision'

	return Template;
}

static function X2AbilityTemplate HeroesNeverDie()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('HeroesNeverDie', "img:///UILibrary_MercyClassMod.HeroesNeverDie", false);
	Template.PrerequisiteAbilities.AddItem('Resurrect');

	return Template;
}