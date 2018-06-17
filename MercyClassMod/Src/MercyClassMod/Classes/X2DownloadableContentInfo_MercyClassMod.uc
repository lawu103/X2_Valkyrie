//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_MercyClassMod.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_MercyClassMod extends X2DownloadableContentInfo config(GameData_MercyClassMod);

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	UpdateBullpupStorage();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}


static event OnLoadedSavedGameToStrategy()
{
	UpdateBullpupStorage();
}

static event OnPostTemplatesCreated()
{
	UpdateSchematic();
}

static function UpdateSchematic()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2SchematicTemplate> Templates;
	local X2SchematicTemplate Template;
	local StrategyRequirement AltReq, BeamReq;
	local X2ItemTemplate ItemTemplate;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	Templates = ItemTemplateManager.GetAllSchematicTemplates();

	foreach Templates(Template)
	{
		if(Template.ReferenceItemTemplate == 'Bullpup_MG')
		{
			AltReq.RequiredSoldierClass = 'MercyClassMod';
			AltReq.RequiredTechs.AddItem('MagnetizedWeapons');
			AltReq.RequiredEngineeringScore = 15;
			AltReq.bVisibleIfPersonnelGatesNotMet = true;
			Template.AlternateRequirements.AddItem(AltReq);
		}

		if(Template.ReferenceItemTemplate == 'Bullpup_BM')
		{
			BeamReq.RequiredSoldierClass = 'MercyClassMod';
			BeamReq.RequiredTechs.AddItem('PlasmaRifle');
			BeamReq.RequiredEngineeringScore = 25;
			BeamReq.bVisibleIfPersonnelGatesNotMet = true;
			Template.AlternateRequirements.AddItem(BeamReq);
		}


	}

	ItemTemplate = ItemTemplateManager.FindItemTemplate('Bullpup_CV');
	if(ItemTemplate != none)
	{
		ItemTemplate.StartingItem = true;
	}
}

// ******** HANDLE UPDATING STORAGE ************* //
// This handles updating storage in order to create variations of various SMGs based on techs unlocked
static function UpdateBullpupStorage()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Item NewItemState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating HQ Storage to add SMGs");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplate = ItemTemplateMgr.FindItemTemplate('Bullpup_CV');
	if(ItemTemplate != none)
	{
		if (!XComHQ.HasItem(ItemTemplate))
		{
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(NewItemState);
			XComHQ.AddItemToHQInventory(NewItemState);
			History.AddGameStateToHistory(NewGameState);
		} 
		else {
			History.CleanupPendingGameState(NewGameState);
		}

	}

	//schematics should be handled already, as the BuildItem UI draws from ItemTemplates, which are automatically loaded
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Type;
	local int TempInt;

	Type = name(InString);

	switch(Type)
	{
		case 'HEALING_STREAM_DISTANCE':
			TempInt = class'X2Ability_MercyClassMod'.default.HEALING_STREAM_DISTANCE;
			OutString = string(TempInt);
			return true;

		case 'HEALING_STREAM_HP':
			TempInt = class'X2Ability_MercyClassMod'.default.HEALING_STREAM_HP;
			OutString = string(TempInt);
			return true;

		case 'DAMAGE_BUFF_DISTANCE':
			TempInt = class'X2Ability_MercyClassMod'.default.DAMAGE_BUFF_DISTANCE;
			OutString = string(TempInt);
			return true;

		case 'DAMAGE_BUFF_DMG':
			TempInt = class'X2Ability_MercyClassMod'.default.DAMAGE_BUFF_DMG;
			OutString = string(TempInt);
			return true;

		case 'VALKYRIE_COOLDOWN':
			TempInt = class'X2Ability_MercyClassMod'.default.VALKYRIE_COOLDOWN - 1;	//Remember the way cooldown config values work
			OutString = string(TempInt);
			return true;

		case 'GUARDIAN_ANGEL_MOVEMENT':
			TempInt = class'X2Ability_MercyClassMod'.default.GUARDIAN_ANGEL_MOVEMENT;
			OutString = string(TempInt);
			return true;

		case 'GUARDIAN_ANGEL_COOLDOWN':
			TempInt = class'X2Ability_MercyClassMod'.default.GUARDIAN_ANGEL_COOLDOWN - 1;
			OutString = string(TempInt);
			return true;

		case 'SURPRISING_AMOUNTS_DAMAGE':
			TempInt = class'X2Ability_MercyClassMod'.default.SURPRISING_AMOUNTS_DMG;
			OutString = string(TempInt);
			return true;

		case 'SURPRISING_AMOUNTS_AIM':
			TempInt = class'X2Ability_MercyClassMod'.default.SURPRISING_AMOUNTS_AIM;
			OutString = string(TempInt);
			return true;

		case 'RESURRECT_HP':
			TempInt = class'X2Ability_MercyClassMod'.default.RESURRECT_HP;
			OutString = string(TempInt);
			return true;

		case 'RESURRECT_CHARGES':
			TempInt = class'X2Ability_MercyClassMod'.default.RESURRECT_CHARGES;
			OutString = string(TempInt);
			return true;

		case 'PROTECT_ME_HITMOD':
			TempInt = class'X2Ability_MercyClassMod'.default.PROTECT_ME_AIM;
			OutString = string(TempInt);
			return true;

		case 'ODIN_SHIELD_DEFENSE':
			TempInt = class'X2Ability_MercyClassMod'.default.ODIN_SHIELD_DEFENSE;
			OutString = string(TempInt);
			return true;

		case 'ANESTHETIC_SHIELD':
			TempInt = class'X2Ability_MercyClassMod'.default.ANESTHETIC_SHIELD;
			OutString = string(TempInt);
			return true;

		case 'ANESTHETIC_COOLDOWN':
			TempInt = class'X2Ability_MercyClassMod'.default.ANESTHETIC_COOLDOWN - 1;
			OutString = string(TempInt);
			return true;

		case 'SWIFT_RESPONSE_COOLDOWN':
			TempInt = class'X2Ability_MercyClassMod'.default.SWIFT_RESPONSE_COOLDOWN - 1;
			OutString = string(TempInt);
			return true;

		case 'ODIN_BLESSING_HP':
			TempInt = class'X2Ability_MercyClassMod'.default.ODIN_BLESSING_HP;
			OutString = string(TempInt);
			return true;

		case 'ODIN_BLESSING_DMG':
			TempInt = class'X2Ability_MercyClassMod'.default.ODIN_BLESSING_DMG;
			OutString = string(TempInt);
			return true;

		case 'SELF_TREATMENT_HP':
			TempInt = class'X2Ability_MercyClassMod'.default.SELF_TREATMENT_HP;
			OutString = string(TempInt);
			return true;

		case 'INCISION_PIERCE':
			TempInt = class'X2Ability_MercyClassMod'.default.INCISION_PIERCE;
			OutString = string(TempInt);
			return true;

		case 'INCISION_CRIT':
			TempInt = class'X2Ability_MercyClassMod'.default.INCISION_CRIT;
			OutString = string(TempInt);
			return true;

		case 'RAGNAROK_COOLDOWN':
			TempInt = class'X2Ability_MercyClassMod'.default.VALKYRIE_COOLDOWN - 2;
			OutString = string(TempInt);
			return true;
	}

	return false;
}