Scriptname _RespawnOverhaulMCM extends SKI_ConfigBase  

Quest property _RespawnOverhaulQuest auto

bool property _enableMod auto
bool enableMod = true
int pushKey
int property _pushKey auto
bool disableSaves = false
bool property _disableSaves auto
bool property _diabloMode auto
bool property _recommendedMode auto
bool diabloMode = false
bool recommendedMode = false

bool onlyTemple = true
bool nearestHold = false
bool nearestHome = false

bool property _onlyTemple auto
bool property _nearestHold auto
bool property _nearestHome auto
float property _respawnDelay auto
float respawnDelay

float property expPenaltyPercent auto
bool expPenalty10 = false
bool expPenalty25 = true
bool expPenalty50 = false
bool expPenalty75 = false
bool expPenalty100 = false

float property skillExpPenaltyPercent auto
bool skillExpPenalty10 = false
bool skillExpPenalty25 = true
bool skillExpPenalty50 = false
bool skillExpPenalty75 = false
bool skillExpPenalty100 = false
bool combatSkillsOnly = false
bool property _combatSkillsOnly auto

int dragonSoulsLost = 1
int property _dragonSoulsLost auto

float property _goldPenaltyMin auto
float property _goldPenaltyMax auto
float goldPenaltyMin = 0.0
float goldPenaltyMax = 100.0

float weaponPenalty = 0.0
float shieldPenalty = 0.0
float helmPenalty = 0.0
float armorPenalty = 0.0
float glovesPenalty = 0.0
float bootsPenalty = 0.0
float amuletPenalty = 0.0
float ringPenalty = 0.0
float inventoryPenalty = 0.0
bool excludeCreatures = false
float property _weaponPenalty auto
float property _shieldPenalty auto
float property _helmPenalty auto
float property _armorPenalty auto
float property _glovesPenalty auto
float property _bootsPenalty auto
float property _amuletPenalty auto
float property _ringPenalty auto
float property _inventoryPenalty auto
bool property _excludeCreatures auto

int iPushKey
int iEnableMod
int iOnlyTemple
int iNearestHold
int iNearestHome
int iRespawnDelay
int iGoldPenaltyMin
int iGoldPenaltyMax
int iWeaponPenalty
int iShieldPenalty
int iHelmPenalty
int iArmorPenalty
int iGlovesPenalty
int iBootsPenalty
int iAmuletPenalty
int iRingPenalty
int iInventoryPenalty
int iExcludeCreatures
int iExpPenaltyPercent10
int iExpPenaltyPercent25
int iExpPenaltyPercent50
int iExpPenaltyPercent75
int iExpPenaltyPercent100
int iSkillExpPenaltyPercent10
int iSkillExpPenaltyPercent25
int iSkillExpPenaltyPercent50
int iSkillExpPenaltyPercent75
int iSkillExpPenaltyPercent100
int iCombatSkillsOnly
int iDragonSoulsLost
int iDisableSaves
int iDiabloMode
int iRecommendedMode

int iUninstall

bool lastBed = false
bool property _lastBed auto
int iLastBed

bool resetEnemies = false
bool property _resetEnemies auto
int iResetEnemies

bool preventGoldStorage = false
bool property _preventGoldStorage auto
int iPreventGoldStorage

ObjectReference Property PlayerRespawnMarker  Auto  


Event OnConfigInit()
	Pages = new string[6]
	Pages[0] = "Respawn Locations"
	Pages[1] = "Inventory Penalties"
	Pages[2] = "EXP Penalties"
	Pages[3] = "Modes"
	Pages[4] = "Save Settings"
	Pages[5] = "Uninstall"
	
	_onlyTemple = onlyTemple
	_nearestHold = nearestHold
	_nearestHome = nearestHome
	_respawnDelay = respawnDelay
	
	_weaponPenalty = weaponPenalty
	_shieldPenalty = shieldPenalty
	_helmPenalty = helmPenalty
	_armorPenalty = armorPenalty
	_bootsPenalty = bootsPenalty
	_glovesPenalty = glovesPenalty
	_amuletPenalty = amuletPenalty
	_ringPenalty = ringPenalty
	_inventoryPenalty = inventoryPenalty
	_excludeCreatures = excludeCreatures
	
	_diabloMode = diabloMode
	_enableMod = enableMod
	
	_goldPenaltyMin = goldPenaltyMin
	_goldPenaltyMax = goldPenaltyMax
	
	if (expPenalty10)
		expPenaltyPercent = 0.1
	ElseIf (expPenalty25)
		expPenaltyPercent = 0.25
	ElseIf (expPenalty50)
		expPenaltyPercent = 0.5
	ElseIf (expPenalty75)
		expPenaltyPercent = 0.75
	ElseIf (expPenalty100)
		expPenaltyPercent = 1.0
	EndIf
	
	if (skillExpPenalty10)
		skillExpPenaltyPercent = 0.1
	ElseIf (skillExpPenalty25)
		skillExpPenaltyPercent = 0.25
	ElseIf (skillExpPenalty50)
		skillExpPenaltyPercent = 0.5
	ElseIf (skillExpPenalty75)
		skillExpPenaltyPercent = 0.75
	ElseIf (skillExpPenalty100)
		skillExpPenaltyPercent = 1.0
	EndIf
	
	_combatSkillsOnly = combatSkillsOnly
	
	_dragonSoulsLost = dragonSoulsLost
	
	_lastBed = lastBed
	_preventGoldStorage = preventGoldStorage
	_resetEnemies = resetEnemies

EndEvent

Event OnPageReset(string page)
	If (page == "Respawn Locations")
		Cell markerCell = PlayerRespawnMarker.GetParentCell()
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("Respawn Locations")
		iOnlyTemple = AddToggleOption("Only Temple of Kynareth", onlyTemple)
		iNearestHold = AddToggleOption("Nearest hold", nearestHold)
		iNearestHome = AddToggleOption("Nearest home", nearestHome)
		iRespawnDelay = AddSliderOption("Respawn delay (s)", respawnDelay)
		
		iLastBed = AddToggleOption("Last Bed  (" + markerCell.GetName() + ")", lastBed)

		;AddHeaderOption("Push key")
		;iPushKey = AddKeyMapOption("Push key", pushKey)
	ElseIf (page == ("Inventory Penalties"))
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Gold Penalty")
		iGoldPenaltyMin = AddSliderOption("Min gold penalty", goldPenaltyMin)
		iGoldPenaltyMax = AddSliderOption("Max gold penalty", goldPenaltyMax)
		iPreventGoldStorage = AddToggleOption("Prevent Gold Storage", preventGoldStorage)
		
		AddHeaderOption("Inventory Penalty")
		iWeaponPenalty = AddSliderOption("Lose equipped LHand %", weaponPenalty)
		iShieldPenalty = AddSliderOption("Lose equipped RHand %", shieldPenalty)
		iHelmPenalty = AddSliderOption("Lose helm %", helmPenalty)
		iArmorPenalty = AddSliderOption("Lose armor %", armorPenalty)
		iGlovesPenalty = AddSliderOption("Lose gloves %", glovesPenalty)
		iBootsPenalty = AddSliderOption("Lose boots %", bootsPenalty)
		iAmuletPenalty = AddSliderOption("Lose amulet %", amuletPenalty)
		iRingPenalty = AddSliderOption("Lose ring %", ringPenalty)
		iInventoryPenalty = AddSliderOption("Lose inventory %", inventoryPenalty)
		iExcludeCreatures = AddToggleOption("Exclude creatures", excludeCreatures)
	ElseIf (page == ("EXP Penalties"))
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Player level penalty")
		iExpPenaltyPercent10 = AddToggleOption("10%", expPenalty10)
		iExpPenaltyPercent25 = AddToggleOption("25%", expPenalty25)
		iExpPenaltyPercent50 = AddToggleOption("50%", expPenalty50)
		iExpPenaltyPercent75 = AddToggleOption("75%", expPenalty75)
		iExpPenaltyPercent100 = AddToggleOption("100%", expPenalty100)
		
		AddHeaderOption("Skill exp penalty")
		iCombatSkillsOnly = AddToggleOption("Combat skills only", combatSkillsOnly)
		iSkillExpPenaltyPercent10 = AddToggleOption("10%", skillExpPenalty10)
		iSkillExpPenaltyPercent25 = AddToggleOption("25%", skillExpPenalty25)
		iSkillExpPenaltyPercent50 = AddToggleOption("50%", skillExpPenalty50)
		iSkillExpPenaltyPercent75 = AddToggleOption("75%", skillExpPenalty75)
		iSkillExpPenaltyPercent100 = AddToggleOption("100%", skillExpPenalty100)
		
		AddHeaderOption("Dragon souls")
		iDragonSoulsLost = AddSliderOption("Dragon souls lost", dragonSoulsLost)

	ElseIf (page == ("Save Settings"))
		SetCursorFillMode(TOP_TO_BOTTOM)
		iDisableSaves = AddToggleOption("Disable Quicksaving", disableSaves)
	ElseIf (page == ("Modes"))
		Actor npc = (Game.GetCurrentCrosshairRef() as Actor)
		SetCursorFillMode(TOP_TO_BOTTOM)
		iRecommendedMode = AddToggleOption("Set Recommended Presets", false)
		iDiabloMode = AddToggleOption("Diablo Mode", diabloMode)
		iResetEnemies = AddToggleOption("Reset Nearby Non-Boss Enemies", resetEnemies)
		if (npc)
			AddTextOption("Targeted NPC", npc.GetName(), OPTION_FLAG_DISABLED)
			AddTextOption("Unique?", (npc.GetBaseObject() as ActorBase).IsUnique(), OPTION_FLAG_DISABLED)
			AddTextOption("Boss Keyword?", npc.HasRefType(locRefTypeBoss), OPTION_FLAG_DISABLED)
			AddTextOption("DLC2Boss1 Keyword?", npc.HasRefType(locRefTypeDLC2Boss1), OPTION_FLAG_DISABLED)
			AddTextOption("Hostile to player?", npc.IsHostileToActor(Game.GetPlayer()), OPTION_FLAG_DISABLED)
			AddTextOption("Player teammate?", npc.IsPlayerTeammate(), OPTION_FLAG_DISABLED)
		endif
	ElseIf(page == "Uninstall")
		iUninstall = AddToggleOption("Uninstall mod", false)
	EndIf
EndEvent



Event OnOptionSelect(int option)
	if (CurrentPage == "Respawn Locations")
		if (option == iOnlyTemple)
			onlyTemple = !onlyTemple
			SetToggleOptionValue(iOnlyTemple, onlyTemple)
			_onlyTemple = onlyTemple
			if (onlyTemple == true)
				nearestHold = false
				_nearestHold = false
				nearestHome = false
				_nearestHome = false
				SetToggleOptionValue(iNearestHold, false)
				SetToggleOptionValue(iNearestHome, false)
				lastBed = false
				_lastBed = false
				SetToggleOptionValue(iLastBed, false)
			EndIf
		ElseIf (option == iNearestHold)
			nearestHold = !nearestHold
			SetToggleOptionValue(iNearestHold, nearestHold)
			_nearestHold = nearestHold
			if (nearestHold == true)
				onlyTemple = false
				_onlyTemple = false
				SetToggleOptionValue(iOnlyTemple, false)
				lastBed = false
				_lastBed = false
				SetToggleOptionValue(iLastBed, false)
			EndIf
		ElseIf (option == iNearestHome)
			nearestHome = !nearestHome
			SetToggleOptionValue(iNearestHome, nearestHome)
			_nearestHome = nearestHome
			if (nearestHome == true)
				onlyTemple = false
				_onlyTemple = false
				SetToggleOptionValue(iOnlyTemple, false)
				lastBed = false
				_lastBed = false
				SetToggleOptionValue(iLastBed, false)
			EndIf
		ElseIf (option == iLastBed)
			lastBed = !lastBed
			SetToggleOptionValue(iLastBed, lastBed)
			_lastBed = lastBed
			if (lastBed == true)
				onlyTemple = false
				_onlyTemple = false
				SetToggleOptionValue(iOnlyTemple, false)
				nearestHold = false
				_nearestHold = false
				nearestHome = false
				_nearestHome = false
				SetToggleOptionValue(iNearestHold, false)
				SetToggleOptionValue(iNearestHome, false)
			EndIf
		EndIf
	ElseIf (CurrentPage == "Inventory Penalties")
		If (option == iExcludeCreatures)
			excludeCreatures = !excludeCreatures
			_excludeCreatures = excludeCreatures
			SetToggleOptionValue(iExcludeCreatures, excludeCreatures)
		elseif (option == iPreventGoldStorage)
			preventGoldStorage = !preventGoldStorage
			_preventGoldStorage = preventGoldStorage
			SetToggleOptionValue(iPreventGoldStorage, preventGoldStorage)
		EndIf
	ElseIf (CurrentPage == "EXP Penalties")
		if (option == iExpPenaltyPercent10)
			expPenalty10 = !expPenalty10
			SetToggleOptionValue(iExpPenaltyPercent10, expPenalty10)
			if (expPenalty10 == true)
				expPenaltyPercent = 0.1
				expPenalty25 = false
				expPenalty50 = false
				expPenalty75 = false
				expPenalty100 = false
				SetToggleOptionValue(iExpPenaltyPercent25, false)
				SetToggleOptionValue(iExpPenaltyPercent50, false)
				SetToggleOptionValue(iExpPenaltyPercent75, false)
				SetToggleOptionValue(iExpPenaltyPercent100, false)
			else
				expPenaltyPercent = 0
			EndIf
		elseIf (option == iExpPenaltyPercent25)
			expPenalty25 = !expPenalty25
			SetToggleOptionValue(iExpPenaltyPercent25, expPenalty25)
			if (expPenalty25 == true)
				expPenaltyPercent = 0.25
				expPenalty10 = false
				expPenalty50 = false
				expPenalty75 = false
				expPenalty100 = false
				SetToggleOptionValue(iExpPenaltyPercent10, false)
				SetToggleOptionValue(iExpPenaltyPercent50, false)
				SetToggleOptionValue(iExpPenaltyPercent75, false)
				SetToggleOptionValue(iExpPenaltyPercent100, false)
			else
				expPenaltyPercent = 0
			EndIf
		elseIf (option == iExpPenaltyPercent50)
			expPenalty50 = !expPenalty50
			SetToggleOptionValue(iExpPenaltyPercent50, expPenalty50)
			if (expPenalty50 == true)
				expPenaltyPercent = 0.5
				expPenalty10 = false
				expPenalty25 = false
				expPenalty75 = false
				expPenalty100 = false
				SetToggleOptionValue(iExpPenaltyPercent10, false)
				SetToggleOptionValue(iExpPenaltyPercent25, false)
				SetToggleOptionValue(iExpPenaltyPercent75, false)
				SetToggleOptionValue(iExpPenaltyPercent100, false)
			else
				expPenaltyPercent = 0
			EndIf
		elseIf (option == iExpPenaltyPercent75)
			expPenalty75 = !expPenalty75
			SetToggleOptionValue(iExpPenaltyPercent75, expPenalty75)
			if (expPenalty75 == true)
				expPenaltyPercent = 0.75
				expPenalty10 = false
				expPenalty25 = false
				expPenalty50 = false
				expPenalty100 = false
				SetToggleOptionValue(iExpPenaltyPercent10, false)
				SetToggleOptionValue(iExpPenaltyPercent25, false)
				SetToggleOptionValue(iExpPenaltyPercent50, false)
				SetToggleOptionValue(iExpPenaltyPercent100, false)
			else
				expPenaltyPercent = 0
			EndIf
		elseIf (option == iExpPenaltyPercent100)
			expPenalty100 = !expPenalty100
			SetToggleOptionValue(iExpPenaltyPercent100, expPenalty100)
			if (expPenalty100 == true)
				expPenaltyPercent = 1.0
				expPenalty10 = false
				expPenalty25 = false
				expPenalty50 = false
				expPenalty75 = false
				SetToggleOptionValue(iExpPenaltyPercent10, false)
				SetToggleOptionValue(iExpPenaltyPercent25, false)
				SetToggleOptionValue(iExpPenaltyPercent50, false)
				SetToggleOptionValue(iExpPenaltyPercent75, false)
			else
				expPenaltyPercent = 0
			EndIf
		elseIf (option == iSkillExpPenaltyPercent10)
			skillExpPenalty10 = !skillExpPenalty10
			SetToggleOptionValue(iSkillExpPenaltyPercent10, skillExpPenalty10)
			if (skillExpPenalty10 == true)
				skillExpPenaltyPercent = 0.1
				skillExpPenalty25 = false
				skillExpPenalty50 = false
				skillExpPenalty75 = false
				skillExpPenalty100 = false
				SetToggleOptionValue(iSkillExpPenaltyPercent25, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent50, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent75, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent100, false)
			else
				skillExpPenaltyPercent = 0
			EndIf
		elseIf (option == iSkillExpPenaltyPercent25)
			skillExpPenalty25 = !skillExpPenalty25
			SetToggleOptionValue(iSkillExpPenaltyPercent25, skillExpPenalty25)
			if (skillExpPenalty25 == true)
				skillExpPenaltyPercent = 0.25
				skillExpPenalty10 = false
				skillExpPenalty50 = false
				skillExpPenalty75 = false
				skillExpPenalty100 = false
				SetToggleOptionValue(iSkillExpPenaltyPercent10, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent50, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent75, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent100, false)
			else
				skillExpPenaltyPercent = 0
			EndIf
		elseIf (option == iSkillExpPenaltyPercent50)
			skillExpPenalty50 = !skillExpPenalty50
			SetToggleOptionValue(iSkillExpPenaltyPercent50, skillExpPenalty50)
			if (skillExpPenalty50 == true)
				skillExpPenaltyPercent = 0.5
				skillExpPenalty10 = false
				skillExpPenalty25 = false
				skillExpPenalty75 = false
				skillExpPenalty100 = false
				SetToggleOptionValue(iSkillExpPenaltyPercent10, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent25, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent75, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent100, false)
			else
				skillExpPenaltyPercent = 0
			EndIf
		elseIf (option == iSkillExpPenaltyPercent75)
			skillExpPenalty75 = !skillExpPenalty75
			SetToggleOptionValue(iSkillExpPenaltyPercent75, skillExpPenalty75)
			if (skillExpPenalty75 == true)
				skillExpPenaltyPercent = 0.75
				skillExpPenalty10 = false
				skillExpPenalty25 = false
				skillExpPenalty50 = false
				skillExpPenalty100 = false
				SetToggleOptionValue(iSkillExpPenaltyPercent10, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent25, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent50, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent100, false)
			else
				skillExpPenaltyPercent = 0
			EndIf
		elseIf (option == iSkillExpPenaltyPercent100)
			skillExpPenalty100 = !skillExpPenalty100
			SetToggleOptionValue(iSkillExpPenaltyPercent100, skillExpPenalty100)
			if (skillExpPenalty100 == true)
				skillExpPenaltyPercent = 1.0
				skillExpPenalty10 = false
				skillExpPenalty25 = false
				skillExpPenalty50 = false
				skillExpPenalty75 = false
				SetToggleOptionValue(iSkillExpPenaltyPercent10, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent25, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent50, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent75, false)
			else
				skillExpPenaltyPercent = 0
			EndIf
		elseIf (option == iCombatSkillsOnly)
			combatSkillsOnly = !combatSkillsOnly
			SetToggleOptionValue(iCombatSkillsOnly, combatSkillsOnly)
			_combatSkillsOnly = combatSkillsOnly
		EndIf
	ElseIf (CurrentPage == "Save Settings")
		if (option == iDisableSaves)
			disableSaves = !disableSaves
			SetToggleOptionValue(iDisableSaves, disableSaves)
			_disableSaves = disableSaves
		EndIf
	ElseIf (CurrentPage == "Modes")
		if (option == iDiabloMode)
			diabloMode = !diabloMode
			bool recOptions = false
			if (diabloMode == true)
				recOptions = ShowMessage("Set diablo presets?", true)
			EndIf
			SetToggleOptionValue(iDiabloMode, diabloMode)
			_diabloMode = diabloMode
			if (recOptions == true)
				goldPenaltyMin = 100
				goldPenaltyMax = 100
				_goldPenaltyMin = 100
				_goldPenaltyMax = 100
				SetSliderOptionValue(iGoldPenaltyMin, 100)
				SetSliderOptionValue(iGoldPenaltyMax, 100)
				weaponPenalty = 0	;100
				shieldPenalty = 0	;100
				helmPenalty = 0		;100
				armorPenalty = 0	;100
				glovesPenalty = 0	;100
				bootsPenalty = 0	
				ringPenalty = 0
				amuletPenalty = 0
				inventoryPenalty = 0
				_weaponPenalty = 0
				_shieldPenalty = 0
				_helmPenalty = 0
				_armorPenalty = 0
				_glovesPenalty = 0
				_bootsPenalty = 0
				_ringPenalty = 0
				_amuletPenalty = 0
				_inventoryPenalty = 0
				SetSliderOptionValue(iWeaponPenalty, 0)
				SetSliderOptionValue(iShieldPenalty, 0)
				SetSliderOptionValue(iHelmPenalty, 0)
				SetSliderOptionValue(iArmorPenalty, 0)
				SetSliderOptionValue(iGlovesPenalty, 0)
				SetSliderOptionValue(iBootsPenalty, 0)
				SetSliderOptionValue(iRingPenalty, 0)
				SetSliderOptionValue(iAmuletPenalty, 0)
				SetSliderOptionValue(iInventoryPenalty, 0)
				_dragonSoulsLost = 0
				dragonSoulsLost = 0
				SetSliderOptionValue(iDragonSoulsLost, 0)
			EndIf
		elseif (option == iResetEnemies)
			resetEnemies = !resetEnemies
			_resetEnemies = resetEnemies
			SetToggleOptionValue(iResetEnemies, resetEnemies)			
		ElseIf (option == iRecommendedMode)
			recommendedMode = ShowMessage("Set recommended presets?", true)
			SetToggleOptionValue(iRecommendedMode, recommendedMode)
			if (recommendedMode)
				_onlyTemple = false
				_nearestHold = true
				_nearestHome = true
				onlyTemple = false
				nearestHold = true
				nearestHome = true
				SetToggleOptionValue(iOnlyTemple, false)
				SetToggleOptionValue(iNearestHold, true)
				SetToggleOptionValue(iNearestHome, true)
				goldPenaltyMin = 100
				goldPenaltyMax = 100
				_goldPenaltyMin = 100
				_goldPenaltyMax = 100
				SetSliderOptionValue(iGoldPenaltyMin, 100)
				SetSliderOptionValue(iGoldPenaltyMax, 100)
				weaponPenalty = 0
				shieldPenalty = 0
				helmPenalty = 0
				armorPenalty = 0
				glovesPenalty = 0
				bootsPenalty = 0
				amuletPenalty = 0
				ringPenalty = 0
				inventoryPenalty = 100
				_weaponPenalty = 0
				_shieldPenalty = 0
				_helmPenalty = 0
				_armorPenalty = 0
				_glovesPenalty = 0
				_bootsPenalty = 0
				_amuletPenalty = 0
				_ringPenalty = 0
				_inventoryPenalty = 100
				SetSliderOptionValue(iWeaponPenalty, 0)
				SetSliderOptionValue(iShieldPenalty, 0)
				SetSliderOptionValue(iHelmPenalty, 0)
				SetSliderOptionValue(iArmorPenalty, 0)
				SetSliderOptionValue(iGlovesPenalty, 0)
				SetSliderOptionValue(iBootsPenalty, 0)
				SetSliderOptionValue(iRingPenalty, 0)
				SetSliderOptionValue(iAmuletPenalty, 0)
				SetSliderOptionValue(iInventoryPenalty, 100)
				expPenalty10 = false
				expPenalty25 = true
				expPenalty50 = false
				expPenalty75 = false
				expPenalty100 = false
				expPenaltyPercent = 0.25
				SetToggleOptionValue(iExpPenaltyPercent10, false)
				SetToggleOptionValue(iExpPenaltyPercent25, true)
				SetToggleOptionValue(iExpPenaltyPercent50, false)
				SetToggleOptionValue(iExpPenaltyPercent75, false)
				SetToggleOptionValue(iExpPenaltyPercent100, false)
				skillExpPenalty10 = false
				skillExpPenalty25 = true
				skillExpPenalty50 = false
				skillExpPenalty75 = false
				skillExpPenalty100 = false
				skillExpPenaltyPercent = 0.25
				SetToggleOptionValue(iSkillExpPenaltyPercent10, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent25, true)
				SetToggleOptionValue(iSkillExpPenaltyPercent50, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent75, false)
				SetToggleOptionValue(iSkillExpPenaltyPercent100, false)
				_dragonSoulsLost = 1
				dragonSoulsLost = 1
				SetSliderOptionValue(iDragonSoulsLost, 1)
				SetToggleOptionValue(iDiabloMode, false)
				diabloMode = false
				_diabloMode = false
			EndIf
		EndIf
	ElseIf (CurrentPage == "Uninstall")
		_RespawnOverhaulQuest.Stop()
		Game.GetPlayer().GetActorBase().SetEssential(false)
	EndIf
EndEvent

Event OnOptionSliderOpen(int option)
	If (CurrentPage == "Respawn Locations")
		if (option == iRespawnDelay)
			SetSliderDialogStartValue(respawnDelay)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0,50)
			SetSliderDialogInterval(0.1)
		EndIf
	ElseIf (CurrentPage == "EXP Penalties")
		if (option == iDragonSoulsLost)
			SetSliderDialogStartValue(dragonSoulsLost)
			SetSliderDialogDefaultValue(1)
			SetSliderDialogRange(0, 50)
			SetSliderDialogInterval(1.0)
		EndIf
	ElseIf (CurrentPage == "Inventory Penalties")
		if (option == iGoldPenaltyMin)
			SetSliderDialogStartValue(goldPenaltyMin)
			SetSliderDialogDefaultValue(25)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iGoldPenaltyMax)
			SetSliderDialogStartValue(goldPenaltyMax)
			SetSliderDialogDefaultValue(100)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iWeaponPenalty)
			SetSliderDialogStartValue(weaponPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iShieldPenalty)
			SetSliderDialogStartValue(shieldPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iHelmPenalty)
			SetSliderDialogStartValue(helmPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iArmorPenalty)
			SetSliderDialogStartValue(armorPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iGlovesPenalty)
			SetSliderDialogStartValue(glovesPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iBootsPenalty)
			SetSliderDialogStartValue(bootsPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iAmuletPenalty)
			SetSliderDialogStartValue(amuletPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iRingPenalty)
			SetSliderDialogStartValue(ringPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		ElseIf (option == iInventoryPenalty)
			SetSliderDialogStartValue(inventoryPenalty)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 100)
			SetSliderDialogInterval(1.0)
		EndIf
	EndIf
EndEvent

Event OnOptionSliderAccept(int option, float value)
	if (CurrentPage == "Respawn Locations")
		if (option == iRespawnDelay)
			respawnDelay = value
			_respawnDelay = respawnDelay
			SetSliderOptionValue(iRespawnDelay,respawnDelay)
		EndIf
	ElseIf (CurrentPage == "EXP Penalties")
		if (option == iDragonSoulsLost)
			dragonSoulsLost = Math.floor(value)
			_dragonSoulsLost = dragonSoulsLost
			SetSliderOptionValue(iDragonSoulsLost,dragonSoulsLost)
		EndIf
	ElseIf (CurrentPage == "Inventory Penalties")
		if (option == iGoldPenaltyMin)
			goldPenaltyMin = value
			_goldPenaltyMin = goldPenaltyMin
			SetSliderOptionValue(iGoldPenaltyMin, goldPenaltyMin)
			if (goldPenaltyMin > goldPenaltyMax)
				goldPenaltyMax = goldPenaltyMin
				SetSliderOptionValue(iGoldPenaltyMax, goldPenaltyMin)
				_goldPenaltyMax = goldPenaltyMin
			EndIf
		ElseIf (option == iGoldPenaltyMax)
			goldPenaltyMax = value
			_goldPenaltyMax = goldPenaltyMax
			SetSliderOptionValue(iGoldPenaltyMax, goldPenaltyMax)
			if (goldPenaltyMax < goldPenaltyMin)
				goldPenaltyMin = goldPenaltyMax
				SetSliderOptionValue(iGoldPenaltyMin, goldPenaltyMax)
				_goldPenaltyMin = goldPenaltyMax
			EndIf
		ElseIf (option == iWeaponPenalty)
			weaponPenalty = value
			_weaponPenalty = weaponPenalty
			SetSliderOptionValue(iWeaponPenalty, weaponPenalty)
		ElseIf (option == iShieldPenalty)
			shieldPenalty = value
			_shieldPenalty = shieldPenalty
			SetSliderOptionValue(iShieldPenalty, shieldPenalty)
		ElseIf (option == iHelmPenalty)
			helmPenalty = value
			_helmPenalty = helmPenalty
			SetSliderOptionValue(iHelmPenalty, helmPenalty)
		ElseIf (option == iArmorPenalty)
			armorPenalty = value
			_armorPenalty = armorPenalty
			SetSliderOptionValue(iArmorPenalty, armorPenalty)
		ElseIf (option == iGlovesPenalty)
			glovesPenalty = value
			_glovesPenalty = glovesPenalty
			SetSliderOptionValue(iGlovesPenalty, glovesPenalty)
		ElseIf (option == iBootsPenalty)
			bootsPenalty = value
			_bootsPenalty = bootsPenalty
			SetSliderOptionValue(iBootsPenalty, bootsPenalty)
		ElseIf (option == iAmuletPenalty)
			amuletPenalty = value
			_amuletPenalty = amuletPenalty
			SetSliderOptionValue(iAmuletPenalty, amuletPenalty)
		ElseIf (option == iRingPenalty)
			ringPenalty = value
			_ringPenalty = ringPenalty
			SetSliderOptionValue(iRingPenalty, ringPenalty)
		ElseIf (option == iInventoryPenalty)
			inventoryPenalty = value
			_inventoryPenalty = inventoryPenalty
			SetSliderOptionValue(iInventoryPenalty, inventoryPenalty)
		EndIf
	EndIf
EndEvent

Event OnKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
	if (option == iPushKey)
		bool continue = true
		if (conflictControl != "")
			string msg
			if (conflictName != "")
				msg = "This key is already mapped to:\n'"+conflictControl+"'\n("+conflictName+")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'"+conflictControl+"'\n\nAre you sure you want to comeinue?"
			EndIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		EndIf
		
		if (continue)
			pushKey = keyCode
			_pushKey = pushKey
			SetKeymapOptionValue(iPushKey, keyCode)
		EndIf
	EndIf
EndEvent

Event OnOptionHighlight(int option)
	if (option == iCombatSkillsOnly)
		SetInfoText("Will not lose exp in smithing, alchemy, enchanting, lockpicking, pickpocket, and speechcraft")
	ElseIf (option == iExcludeCreatures)
		SetInfoText("Animals and creatures will not take your gear and gold. EXP penalties will still apply.")
	ElseIf (option == iLastBed)
		SetInfoText("All deaths in Tamriel will have you respawn at the last bed you slept in.")
	ElseIf (option == iDisableSaves)
		SetInfoText("Disables quick saving. Auto-saves and Manual saves via menu are still available.")
	ElseIf (option == iOnlyTemple)
		SetInfoText("All deaths in Tamriel will have you respawn in Temple of Kynareth in Whiterun.")
	ElseIf (option == iNearestHold)
		SetInfoText("All deaths in Tamriel will have you respawn at the closest halls of the dead. Possible locations are Whiterun, Markarth, Solitude, Riften, Falkreath, and Windhelm.")
	ElseIf (option == iNearestHome)
		SetInfoText("Deaths in Tamriel will have you respawn at the nearest player home. If used in conjunction with nearest hold, it will bring you to the nearest hold if no home is available in that city.")
	ElseIf (option == iInventoryPenalty)
		SetInfoText("Deaths will see the player forfeit their entire inventory to the person who defeated them. They will hold on to the items so you can seek them out for a rematch and get your items back. Quest items should be unaffected.")
	ElseIf (option == iDiabloMode)
		SetInfoText("Emulates Diablo 2's death system: An ashpile will be left at the player's location when defeated and all equipped items and gold will be transferred into the ashpile. This may be a safer option if you're worried about your killers running off with your items. WARNING: This resets your inventory penalty settings to match a preset.")
	ElseIf (option == respawnDelay)
		SetInfoText("Seconds to wait until respawn functions run. Use this if you have other mods with death effects installed and you run them to run first. Note this doesn't work 100% of the time because bleedout state for player is quite gimmicky.")
	ElseIf (option == iResetEnemies)
		SetInfoText("All hostile non-boss NPCs in the cell will be resurrected and reset to their starting positions when the player dies.")
	ElseIf (option == iPreventGoldStorage)
		SetInfoText("Prevents the player from storing gold in containers or follower inventories, to increase the risk associated with dropping gold on death.")
	EndIf
EndEvent


LocationRefType property locRefTypeBoss auto
LocationRefType property locRefTypeDLC2Boss1 auto
