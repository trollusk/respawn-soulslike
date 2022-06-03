Scriptname _RespawnScript extends ReferenceAlias  

_RespawnOverhaulMCM property mcmOptions auto
Actor property player auto
Actor property lastEnemy auto
MiscObject property gold auto
Keyword property actorTypeAnimal auto
Keyword property actorTypeCreature auto
Faction property creatureFaction auto
Armor property defaultArmor auto
ObjectReference property ashPileObject auto
Actor property deathMarker auto
Quest property brawlQuest auto

Location property Sovangarde auto
Location property EastmarchHold auto ; WindhelmHold
Location property FalkreathHold auto
Location property HaafingarHold auto ; Solitude
Location property HjallmarchHold auto	; Morthal
Location property PaleHold auto 		;Dawnstar
Location property ReachHold	auto		; Markarth
Location property RiftHold auto
Location property WinterholdHold auto
Location property RavenRockHold auto
ObjectReference property altarTempleOfKynareth auto
ObjectReference property hallsOfTheDeadFalkreath auto
ObjectReference property hallsOfTheDeadMarkarth auto
ObjectReference property hallsfOfTheDeadRiften auto
ObjectReference property hallsOfTheDeadSolitude auto
ObjectReference property hallsOfTheDeadWindhelm auto
ObjectReference property ravenRock auto
ObjectReference property sovangardeRespawn auto
Cell property breezehomeCell auto
Cell property hjerimCell auto
Cell property honeysideCell auto
Cell property proudspireManorCell auto
Cell property severinManorCell auto
Cell property vlindrelHallCell auto
Cell property windstadManorCell auto
Cell property lakeviewManorCell auto
Cell property heljarchenHallCell auto
ObjectReference property breezehomeLocation auto
ObjectReference property hjerimLocation auto
ObjectReference property honeysideLocation auto
ObjectReference property proudspireManorLocation auto
ObjectReference property severinManorLocation auto
ObjectReference property vlindrelHallLocation auto
ObjectReference property windstadManorLocation auto
ObjectReference property lakeviewManorLocation auto
ObjectReference property heljarchenHallLocation auto
;ObjectReference savedObject
bool f5Pressed
Faction property playerFaction auto

;Areas that break quests or become inaccessible
Location property HalldirsCairn auto
Location property DimhallowCavern auto
Location property ShroudhearthBarrow auto
Location property SerpentsBluff auto
Location property ThalmorEmbassy auto
Location property Kolbjorn auto
Location property Gyldenhul auto
Location property AncestorGlave auto
Location property Skuldalfyn auto
Location property Folgunthr auto
Location property Volskygge auto
Location property EastEmpireCompany auto
Location property AbandonedHouse auto
Location property AzurasStarInterior auto
Location property Killkreath auto

; Werewolf/werebear/vampire
Race property werewolfRace auto
Race property werebearRace auto
Race property vampireRace auto

Location[] disabledLocations ; Set these locations for quest areas that might bug out.

Event OnInit()
	player = Game.GetPlayer()
	
	player.GetActorBase().SetEssential()
	player.SetNoBleedoutRecovery(false)
EndEvent

Event OnPlayerLoadGame()
	player = Game.GetPlayer()
	
	player.GetActorBase().SetEssential()
	player.SetNoBleedoutRecovery(false)
	RegisterForKey(63)
EndEvent

Event OnKeyDown(Int KeyCode)
	if (KeyCode == 63 && mcmOptions._disableSaves)
		Game.SetInChargen(true, false, true)
		f5Pressed = true
		RegisterForSingleUpdate(0.5)
	EndIf
EndEvent

Event OnUpdate()
;	bool keyPressed
;	If (keyPressed != Input.IsKeyPressed(mcmOptions._pushKey))
;		keyPressed = !keyPressed
;		if (keyPressed)
;			savedObject.PushActorAway(player, 3.0)
;		EndIf
;	EndIf
	if (!f5Pressed)
		if (player.IsBleedingOut())
			Game.ForceThirdperson()
			player.SetNoBleedoutRecovery(false)
			player.RestoreActorValue("health", 70)
			Game.EnablePlayerControls()
		EndIf
	Else
		RegisterForSingleUpdate(0.5)
		f5Pressed = false
	EndIf
	Game.SetInChargen(false, false, true)
EndEvent

Event OnEnterBleedout()
	player.SetNoBleedoutRecovery(true)
	; Make exceptions for brawls
	if (brawlQuest.GetStage() > 0 && brawlQuest.GetStage() < 250)
		return
	EndIf
	
	RegisterForSingleUpdate(15.0)
	; Allow delay for other mods scripts to run first if necessary
	Utility.Wait(mcmOptions._respawnDelay)
	if (!player.IsBleedingOut())
		return
	EndIf

	; Check for locations that might bug quests out.
	bool disabledLocationFound = CheckForDisabledLocation()
	
	if (IsTransformed() == false && disabledLocationFound == false && (mcmOptions._onlyTemple || mcmOptions._nearestHold || mcmOptions._nearestHome))
		
		Utility.Wait(0.5)
		RemoveExp()
		Utility.Wait(0.5)
		RemoveSkillExp()
		Utility.Wait(0.5)
		RemoveDragonSouls()
		Utility.Wait(0.5)
		Game.FadeOutGame(false, true, 5.0, 5.0)
		Game.DisablePlayerControls()
		SetAshPile()
		RemoveGold()
		RemoveGear()
		Utility.Wait(1.25)
		if (player.IsInLocation(Sovangarde) == false)
			if (mcmOptions._onlyTemple == true)
				RespawnToLocation(altarTempleOfKynareth)	
			ElseIf (mcmOptions._nearestHome == true)
				if (mcmOptions._nearestHold == false)
					if (player.IsInLocation(EastmarchHold))
						if (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						;ElseIF (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(FalkreathHold))
						;if (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						If (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(HaafingarHold))
						if (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(HjallmarchHold))
						;if (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						If (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(PaleHold))
						;if (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						If (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(ReachHold))
						if (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						ElseIf (honeysideLocation.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(RiftHold))
						if (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(WinterholdHold))
						;if (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						If (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					ElseIf (player.IsInLocation(RavenRockHold))
						if (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						ElseIf (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						;ElseIF (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					Else
						if (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						;ElseIf (lakeviewManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(lakeviewManorLocation)
						ElseIf (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						;ElseIf (windstadManorCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(windstadManorLocation)
						;ElseIf (heljarchenHallCell.GetFactionOwner() == playerFaction)
							;RespawnToLocation(heljarchenHallLocation)
						ElseIf (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						ElseIf (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						ElseIf (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						ElseIf (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					EndIf
				Else ; Nearest hold + nearest home
					if (player.IsInLocation(EastmarchHold))
						if (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						Else
							RespawnToLocation(hallsOfTheDeadWindhelm)
						EndIf
					ElseIf (player.IsInLocation(FalkreathHold))
						if  (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						Else
							RespawnToLocation(hallsOfTheDeadFalkreath)
						EndIf
					ElseIf (player.IsInLocation(HaafingarHold))
						if (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						Else
							RespawnToLocation(hallsOfTheDeadSolitude)
						EndIf
					ElseIf (player.IsInLocation(HjallmarchHold))
						if (proudspireManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(proudspireManorLocation)
						Else
							RespawnToLocation(hallsOfTheDeadSolitude)
						EndIf
					ElseIf (player.IsInLocation(PaleHold))
						if (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						Else
							RespawnToLocation(hallsOfTheDeadWindhelm)
						EndIf
					ElseIf (player.IsInLocation(ReachHold))
						if (vlindrelHallCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(vlindrelHallLocation)
						Else
							RespawnToLocation(hallsOfTheDeadMarkarth)
						EndIf
					ElseIf (player.IsInLocation(WinterholdHold))
						if (hjerimCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(hjerimLocation)
						Else
							RespawnToLocation(hallsOfTheDeadWindhelm)
						EndIf
					ElseIf (player.IsInLocation(RiftHold))
						if (honeysideCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(honeysideLocation)
						Else
							RespawnToLocation(hallsfOfTheDeadRiften)
						EndIf
					ElseIf (player.IsInLocation(RavenRockHold))
						if (severinManorCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(severinManorLocation)
						Else
							RespawnToLocation(ravenRock)
						EndIf
					Else
						if (breezehomeCell.GetFactionOwner() == playerFaction)
							RespawnToLocation(breezehomeLocation)
						Else
							RespawnToLocation(altarTempleOfKynareth)
						EndIf
					EndIf
				EndIf
			ElseIf (mcmOptions._nearestHold == true)
				if (player.IsInLocation(EastmarchHold) || player.IsInLocation(PaleHold) || player.IsInLocation(WinterholdHold))
					RespawnToLocation(hallsOfTheDeadWindhelm)
				ElseIf (player.IsInLocation(FalkreathHold))
					RespawnToLocation(hallsOfTheDeadFalkreath)
				ElseIf (player.IsInLocation(HaafingarHold) || player.IsInLocation(HjallmarchHold))
					RespawnToLocation(hallsOfTheDeadSolitude)
				ElseIf (player.IsInLocation(ReachHold))
					RespawnToLocation(hallsOfTheDeadMarkarth)
				ElseIf (player.IsInLocation(RiftHold))
					RespawnToLocation(hallsfOfTheDeadRiften)
				ElseIf (player.IsInLocation(RavenRockHold))
					RespawnToLocation(ravenRock)
				Else
					RespawnToLocation(altarTempleOfKynareth)
				EndIf	
			Else
				Debug.MessageBox("Something went wrong")
			EndIf
		Else
			RespawnToLocation(sovangardeRespawn)
		EndIf
	Else
		player.KillEssential()
	EndIf
EndEvent

Function RespawnToLocation(ObjectReference objectLocation)
	Game.ForceThirdperson()
	if (player.IsOnMount())
		player.Dismount()
	EndIf
	player.GetActorBase().SetInvulnerable(true)
	Game.EnableFastTravel()
	player.SetNoBleedoutRecovery(false)
	player.RestoreActorValue("health", 70)
	Game.ForceThirdperson()
	Game.FastTravel(objectLocation)
	player.MoveTo(objectLocation)
	player.GetActorBase().SetInvulnerable(false)
	objectLocation.PushActorAway(player, 1.5)
	MfgConsoleFunc.ResetPhonemeModifier(player)
	Game.EnablePlayerControls()
	if (lastEnemy.GetActorValue("health") > 0)
		lastEnemy.StopCombat()
	EndIf
	;savedObject = objectLocation
	;RegisterForUpdate(0.25)
EndFunction

;Event OnLocationChange(Location akOldLoc, Location akNewLoc)
;	if (savedObject.GetCurrentLocation() != akNewLoc && savedObject.GetCurrentLocation() != akNewLoc)
;		UnregisterForUpdate()
;	EndIf
;EndEvent

Function SetAshPile()
	if (mcmOptions._diabloMode)
		if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction)))
			deathMarker = player.PlaceActorAtMe(deathMarker.GetActorBase())
			deathMarker.RemoveAllItems()
			deathMarker.SetAlpha(0, false)
			deathMarker.KillEssential()
			lastEnemy = deathMarker
		EndIf
	EndIf
EndFunction

Function RemoveGold()
	if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction))) 
			if ((lastEnemy != None && !lastEnemy.IsDead()) || mcmOptions._diabloMode)
				int playerGoldCount = player.GetItemCount(gold)
				if (playerGoldCount > 0)
					float goldPenaltyPercent = Utility.RandomFloat(mcmOptions._goldPenaltyMin, mcmOptions._goldPenaltyMax)
					float goldLost = playerGoldCount * goldPenaltyPercent * 0.01
					int goldLostRounded = Math.Floor(goldLost)
					lastEnemy.AddItem(gold, goldLostRounded)
					player.RemoveItem(gold, goldLostRounded)
				EndIf
			EndIf
	
	EndIf
EndFunction

Function RemoveGear()
	if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction)))
		if ((lastEnemy != None && !lastEnemy.IsDead()) || mcmOptions._diabloMode)
			int weaponLostRNG = Utility.RandomInt(1, 100)
			int shieldLostRNG = Utility.RandomInt(1, 100)
			int helmLostRNG = Utility.RandomInt(1, 100)
			int armorLostRNG = Utility.RandomInt(1, 100)
			int glovesLostRNG = Utility.RandomInt(1, 100)
			int bootsLostRNG = Utility.RandomInt(1, 100)
			int amuletLostRNG = Utility.RandomInt(1, 100)
			int ringLostRNG = Utility.RandomInt(1, 100)
			int inventoryLostRNG = Utility.RandomInt(1, 100)
			if (inventoryLostRNG <= mcmOptions._inventoryPenalty)
				player.RemoveAllItems(lastEnemy, false, false)
				player.RemoveAllItems()
				player.AddItem(defaultArmor)
				player.EquipItem(defaultArmor)
			EndIf
			if (weaponLostRNG <= mcmOptions._weaponPenalty && player.GetEquippedWeapon() != None)
				lastEnemy.AddItem(player.GetEquippedWeapon())
				player.RemoveItem(player.GetEquippedWeapon())
				if (player.GetEquippedWeapon(true) != None)
					lastEnemy.AddItem(player.GetEquippedWeapon(true))
					player.RemoveItem(player.GetEquippedWeapon(true))
				EndIf
			EndIf
			if (shieldLostRNG <= mcmOptions._shieldPenalty && player.GetEquippedWeapon(true) != None)
				lastEnemy.AddItem(player.GetEquippedWeapon(true))
				player.RemoveItem(player.GetEquippedWeapon(true))
			EndIf
			if (helmLostRNG <= mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(30) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(30))
				player.RemoveItem(player.GetEquippedArmorInSlot(30))
			EndIf
			if (helmLostRNG <= mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(42) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(42))
				player.RemoveItem(player.GetEquippedArmorInSlot(42))
			EndIf
			if (armorLostRNG <= mcmOptions._armorPenalty && player.GetEquippedArmorInSlot(32) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(32))
				player.RemoveItem(player.GetEquippedArmorInSlot(32))
				player.AddItem(defaultArmor)
				player.EquipItem(defaultArmor)
			EndIf
			if (glovesLostRNG <= mcmOptions._glovesPenalty && player.GetEquippedArmorInSlot(33) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(33))
				player.RemoveItem(player.GetEquippedArmorInSlot(33))
			EndIf
			if (amuletLostRNG <= mcmOptions._amuletPenalty && player.GetEquippedArmorInSlot(35) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(35))
				player.RemoveItem(player.GetEquippedArmorInSlot(35))
			EndIf
			if (ringLostRNG <= mcmOptions._ringPenalty && player.GetEquippedArmorInSlot(36) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(36))
				player.RemoveItem(player.GetEquippedArmorInSlot(36))
			EndIf
			if (bootsLostRNG <= mcmOptions._bootsPenalty && player.GetEquippedArmorInSlot(37) != None)
				lastEnemy.AddItem(player.GetEquippedArmorInSlot(37))
				player.RemoveItem(player.GetEquippedArmorInSlot(37))
			EndIf
		EndIf
	EndIf
EndFunction

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if (akSource As Spell)
		if ((akSource As Spell).IsHostile())
			lastEnemy = akAggressor as Actor
		EndIf
	Else
		lastEnemy = akAggressor as Actor
	EndIf
EndEvent

Bool Function CheckForDisabledLocation()
	if (player.IsInLocation(HalldirsCairn))
		return true
	ElseIf (player.IsInLocation(DimhallowCavern))
		return true
	ElseIf (player.IsInLocation(ShroudhearthBarrow))
		return true
	ElseIf (player.IsInLocation(SerpentsBluff))
		return true
	ElseIf (player.IsInLocation(ThalmorEmbassy))
		return true
	ElseIf (player.IsInLocation(Kolbjorn))
		return true
	ElseIf (player.IsInLocation(Gyldenhul))
		return true
	ElseIf (player.IsInLocation(AncestorGlave))
		return true
	ElseIf (player.IsInLocation(Skuldalfyn))
		return true
	ElseIf (player.IsInLocation(Folgunthr))
		return true
	ElseIf (player.IsInLocation(Volskygge))
		return true
	ElseIf (player.IsInLocation(EastEmpireCompany))
		return true
	ElseIf (player.IsInLocation(AbandonedHouse))
		return true
	ElseIf (player.IsInLocation(AzurasStarInterior))
		return true
	ElseIf (player.IsInLocation(Killkreath))
		return true
	EndIf
	return false
EndFunction

Bool Function IsTransformed()
	if (player.GetRace() == werebearRace || player.GetRace() == werewolfRace || player.GetRace() == vampireRace)
		Return true
	Else
		Return false
	EndIf
EndFunction

Function RemoveExp()
	float expPenalty = mcmOptions.expPenaltyPercent
	float currentExp = Game.GetPlayerExperience()
	float expToLose = expPenalty * currentExp
	Game.SetPlayerExperience(currentExp - expToLose)
EndFunction

Function RemoveSkillExp()
	DoSkillExpCalc("OneHanded")
	DoSkillExpCalc("TwoHanded")
	DoSkillExpCalc("Marksman")
	DoSkillExpCalc("Block")
	DoSkillExpCalc("Sneak")
	DoSkillExpCalc("HeavyArmor")
	DoSkillExpCalc("LightArmor")
	DoSkillExpCalc("Alteration")
	DoSkillExpCalc("Conjuration")
	DoSkillExpCalc("Destruction")
	DoSkillExpCalc("Illusion")
	DoSkillExpCalc("Restoration")
	
	if (!mcmOptions._combatSkillsOnly)
		DoSkillExpCalc("Smithing")
		DoSkillExpCalc("Pickpocket")
		DoSkillExpCalc("LockPicking")
		DoSkillExpCalc("Alchemy")
		DoSkillExpCalc("SpeechCraft")
		DoSkillExpCalc("Enchanting")
	EndIf
EndFunction

Function DoSkillExpCalc(string skillName)
	float expPenalty = mcmOptions.skillExpPenaltyPercent
	ActorValueInfo skill = ActorValueInfo.GetActorValueInfoByName(skillName)
	float skillExp = skill.GetSkillExperience()
	float skillExpToLose = skillExp * expPenalty
	skill.SetSkillExperience(skillExp - skillExpToLose)
EndFunction

Function RemoveDragonSouls()
	int dragonSoulsToRemove = mcmOptions._dragonSoulsLost
	if (dragonSoulsToRemove > 0)
		ActorValueInfo dragonSouls = ActorValueInfo.GetActorValueInfoByName("DragonSouls")
		float currentSouls = dragonSouls.GetCurrentValue(player)
		player.SetActorValue("DragonSouls", dragonSoulsToRemove * -1)
		; Make sure we don't go negative
		if (dragonSouls.GetCurrentValue(player) < 0)
			player.SetActorValue("DragonSouls", 0)
		EndIf
	EndIf
EndFunction