class X2Effect_MercyClassMod_ProtectMe extends X2Effect_CoveringFire;

DefaultProperties
{
	EffectName = "ProtectMe"
	DuplicateResponse = eDupe_Ignore
	AbilityToActivate = "ProtectMeTrigger"
	GrantActionPoint = "Judgment"
	MaxPointsPerTurn = 1
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = true
}