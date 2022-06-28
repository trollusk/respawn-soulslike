Scriptname _RespawnScript extends ReferenceAlias  

; this script is attached to a player alias inside the quest _RespawnQuest

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
; XXX
ObjectReference property graveContainer auto
ObjectReference property graveActivator auto
ObjectReference property graveLight auto
Quest Property deathMarkerQuest Auto      ; quest given to player, to retrieve belongings from grave
ReferenceAlias property deathMarkerQuestTarget auto
Spell property healingSpell auto			; failsafe in case respawning takes too long due to script lag
Spell property areaCalmSpell auto

Quest property brawlQuest auto
FormList property itemsToLose auto

Location property Sovangarde auto
Location property EastmarchHold auto ; WindhelmHold
Location property FalkreathHold auto
Location property HaafingarHold auto ; Solitude
Location property HjallmarchHold auto   ; Morthal
Location property PaleHold auto         ;Dawnstar
Location property ReachHold auto        ; Markarth
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
Location property HalldirsCairn auto				; 0x019192
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
Location property DeadMensRespite auto

; Werewolf/werebear/vampire
Race property werewolfRace auto
Race property werebearRace auto
Race property vampireRace auto

Location[] disabledLocations ; Set these locations for quest areas that might bug out.

ObjectReference Property PlayerRespawnMarker  Auto  
Cell Property PlayerRespawnMarkerCell  Auto  
LocationRefType property locRefTypeBoss auto
LocationRefType property locRefTypeDLC2Boss1 auto

; FormLists must exist in the esp!
FormList property bossRaces auto
FormList property namedBosses auto
FormList property noResetNPCs auto
FormList property noResetLocations auto
bool Property playerRespawnMarkerInitialized auto

; Furniture property _RBCModFire1 auto
; Furniture property _RBCModFire2 auto
; Furniture property _SBMModFire1 auto
; Furniture property _SBMModFire2 auto
; Furniture property _CampfireModFire1 auto
; Furniture property _CampfireModFire2 auto
; Furniture property _CampfireModFire3 auto
; Furniture property _CampfireSBMFire1 auto
; Furniture property _CampfireSBMFire2 auto
; Furniture property _CampfireSBMFire3 auto

Static property MapMarker auto
FormList property campfireMarkerList auto
Int property campfireMarkerNextAvailable auto
ObjectReference property playerBuiltCampfireMarker auto

VisualEffect property deathScreen auto
ObjectReference property deathLocationMarker  auto  


Event OnInit()
    player = Game.GetPlayer()
    
    player.GetActorBase().SetEssential()
    player.SetNoBleedoutRecovery(false)

	;PopulateBossRaceList()
	PopulateNamedBossList()
	PopulateNoResetNPCList()
	PopulateNoResetLocationList()
	
    RegisterForSleep()
	AddInventoryEventFilter(gold)
EndEvent

Event OnPlayerLoadGame()
    player = Game.GetPlayer()
    
    player.GetActorBase().SetEssential()
    player.SetNoBleedoutRecovery(false)
	
	;PopulateBossRaceList()
	PopulateNamedBossList()
	PopulateNoResetNPCList()
	PopulateNoResetLocationList()
	
	if (PlayerRespawnMarker.GetParentCell() == PlayerRespawnMarkerCell)
		;debug.notification("PlayerRespawnMarker not initialized, moving to player...")
		PlayerRespawnMarker.moveto(player)
		playerRespawnMarkerInitialized = true
	endif

    RegisterForKey(63)
    RegisterForSleep()
	AddInventoryEventFilter(gold)
EndEvent


Event OnKeyDown(Int KeyCode)
    if (KeyCode == 63 && mcmOptions._disableSaves)
        Game.SetInChargen(true, false, true)
        f5Pressed = true
        RegisterForSingleUpdate(0.5)
    EndIf
EndEvent

Event OnUpdate()
;   bool keyPressed
;   If (keyPressed != Input.IsKeyPressed(mcmOptions._pushKey))
;       keyPressed = !keyPressed
;       if (keyPressed)
;           savedObject.PushActorAway(player, 3.0)
;       EndIf
;   EndIf
    if (!f5Pressed)
        if (player.IsBleedingOut())
            Game.ForceThirdperson()
            player.SetNoBleedoutRecovery(false)
			player.GetActorBase().SetInvulnerable(false)
			AddInventoryEventFilter(gold)
            player.RestoreActorValue("health", 1000000)
			player.RestoreActorValue("stamina", 1000000)
			player.RestoreActorValue("magicka", 1000000)
            Game.EnablePlayerControls()
        EndIf
    Else
        RegisterForSingleUpdate(0.5)
        f5Pressed = false
    EndIf
    Game.SetInChargen(false, false, true)
EndEvent


; Event OnDying(Actor killer)
    ; debug.notification("Player dying, killer = " + killer)
; EndEvent


Event OnEnterBleedout()
    player.SetNoBleedoutRecovery(true)
	RemoveAllInventoryEventFilters()
	
    ; Make exceptions for brawls
    if (brawlQuest.GetStage() > 0 && brawlQuest.GetStage() < 250)
        return
    EndIf
    
	; purpose of deathLocationMarker is to have a steadier camera for the death screen,
	; since the player usually jiggles around in their death throes. Doesn't seem to work however
	;deathLocationMarker.moveto(player, abMatchRotation = true)
	;deathLocationMarker.SetAngle(player.GetAngleX(), player.GetAngleY(), player.GetAngleZ())
	;deathScreen.play(deathLocationMarker, 2.0, none)
	;deathScreen.play(player, 1.0, none)
	
    RegisterForSingleUpdate(15.0)
    ; Allow delay for other mods scripts to run first if necessary
    Utility.Wait(mcmOptions._respawnDelay)
    if (!player.IsBleedingOut())
		AddInventoryEventFilter(gold)
        return
    EndIf

    ; Check for locations that might bug quests out.
    bool disabledLocationFound = CheckForDisabledLocation()
    
    if (IsTransformed() == false && disabledLocationFound == false && (mcmOptions._onlyTemple || mcmOptions._nearestHold || mcmOptions._nearestHome || mcmOptions._lastBed))
        Location loc = player.GetCurrentLocation()
		
		if lastEnemy
			lastEnemy.StopCombat()
		endif
		player.StopCombatAlarm()

		healingSpell.Cast(player)
		;areaCalmSpell.Cast(player)
		
        ;Utility.Wait(0.5)
        RemoveExp()
        ;Utility.Wait(0.5)
        RemoveSkillExp()
        ;Utility.Wait(0.5)
        RemoveDragonSouls()
        ;Utility.Wait(0.5)
		;ConsoleUtil.PrintMessage("about to disable player controls")
        Game.DisablePlayerControls()
		;ConsoleUtil.PrintMessage("about to fade in")
        Game.FadeOutGame(false, true, 5.0, 5.0)		; wait 5s, then fade IN for 5s
		;ConsoleUtil.PrintMessage("about to make grave and remove items")
        SetAshPile()				; also sets lastenemy = deathmarker if Diablo mode, or not in combat
        RemoveGold()
        RemoveGear()
        RemoveInventory()
		
		if mcmOptions._diabloMode || !player.IsInCombat() || lastEnemy == none
			; delete the grave if it's empty
			if graveContainer.GetNumItems() < 1
				graveActivator.Disable()
				;graveLight.Disable()
				deathMarkerQuest.Stop()
			elseif mcmOptions._giveDeathMarkerQuest
				deathMarkerQuest.Stop()
				;(deathMarkerQuest.GetAliasByName("DeathMarkerRef") as ReferenceAlias).ForceRefTo(self)
				;deathMarkerQuestTarget.ForceRefTo(self)
				utility.wait(0.1)    
				deathMarkerQuest.Start()
				deathMarkerQuest.SetObjectiveDisplayed(10)
				deathMarkerQuest.SetStage(10)
			endif
		endif
		
        ; Reset the state of all non-boss NPCs in the cell.
        ; Also resets bosses if they have not been killed.
		if (mcmOptions._resetEnemies)
			; don't reset if location is "cleared". Outdoor locations may return a Location of "none".
			if (!loc || !(loc.IsCleared()))
				;ConsoleUtil.PrintMessage("about to reset enemies")
				ResetEnemiesInCell()
			endif
        endif
		
        ;Utility.Wait(1.25)
		TravelToRespawnPoint()
    Else
        player.KillEssential()
    EndIf
EndEvent


Function TravelToRespawnPoint()
	if (player.IsInLocation(Sovangarde) == false)
		if (mcmOptions._lastBed == true)
			if PlayerRespawnMarker.GetParentCell() == PlayerRespawnMarkerCell
				; respawn marker is still in the "Elsweyr" default cell
				debug.notification("No bed or campfire has been set as a respawn point. Respawning to Temple of Kynareth instead.")
				RespawnToLocation(altarTempleOfKynareth)
			else
				RespawnToLocation(PlayerRespawnMarker)
			endif
		ElseIf (mcmOptions._onlyTemple == true)
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
EndFunction


Function RespawnToLocation(ObjectReference objectLocation)
    ;Game.ForceThirdperson()
    player.GetActorBase().SetInvulnerable(true)
    Game.EnableFastTravel()
    ; player.SetNoBleedoutRecovery(false)  - - moved below
	player.RestoreActorValue("health", 1000000)
	player.RestoreActorValue("stamina", 1000000)
	player.RestoreActorValue("magicka", 1000000)
    Game.ForceThirdperson()
	;ConsoleUtil.PrintMessage("about to fast travel")
    Game.FastTravel(objectLocation)
    player.MoveTo(objectLocation)
	;ConsoleUtil.PrintMessage("about to re-enable bleedout recovery")
	player.SetNoBleedoutRecovery(false)
    player.GetActorBase().SetInvulnerable(false)
	player.DispelAllSpells()
	AddInventoryEventFilter(gold)
    objectLocation.PushActorAway(player, 1.5)
    MfgConsoleFunc.ResetPhonemeModifier(player)
	;ConsoleUtil.PrintMessage("about to re-enable player controls")
    Game.EnablePlayerControls()
    ;savedObject = objectLocation
    ;RegisterForUpdate(0.25)
EndFunction

; Create an ashpile and set lastEnemy to point to it
; We only do this if (a) Diblo mode is active, or (2) the player is not in combat (died from drowning, DOT etc)
; since in the latter instance lastEnemy could be 'none' or could point to an enemy at the other end of Skyrim

Function SetAshPile()
    if mcmOptions._diabloMode || !player.IsInCombat() || lastEnemy == none
		graveActivator.moveto(player)
		graveActivator.Enable()
		;graveLight.Disable()
		;graveLight.moveto(player, 0.0, 0.0, 50.0)
		;graveLight.Enable()
				
		if mcmOptions._destroyAshpileOnDeath
			graveContainer.RemoveAllItems()
		endif
    EndIf
EndFunction


Function RemoveGold()
	int playerGoldCount = player.GetItemCount(gold)
	int goldPenaltyPercent = Utility.RandomInt(Math.Floor(mcmOptions._goldPenaltyMin), Math.Floor(mcmOptions._goldPenaltyMax))
	int goldLost = Math.Floor(playerGoldCount * goldPenaltyPercent * 0.01)
	
	if (playerGoldCount > 0)
		if mcmOptions._diabloMode || !player.IsInCombat() || lastEnemy == None
			; send gold to grave
			graveContainer.AddItem(gold, goldLost)
			player.RemoveItem(gold, goldLost, true)
		elseif !mcmOptions._excludeCreatures || !lastEnemy.IsInFaction(creatureFaction)
			; give gold to lastenemy
			lastEnemy.AddItem(gold, goldLost)
			player.RemoveItem(gold, goldLost, true)
		endif
	endif
	
    ; if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction))) 
		; if (mcmOptions._diabloMode || !player.IsInCombat() || (lastEnemy != None && !lastEnemy.IsDead()))
			; int playerGoldCount = player.GetItemCount(gold)
			; if (playerGoldCount > 0)
				; float goldPenaltyPercent = Utility.RandomFloat(mcmOptions._goldPenaltyMin, mcmOptions._goldPenaltyMax)
				; float goldLost = playerGoldCount * goldPenaltyPercent * 0.01
				; int goldLostRounded = Math.Floor(goldLost)
				; lastEnemy.AddItem(gold, goldLostRounded)
				; player.RemoveItem(gold, goldLostRounded)
			; EndIf
		; EndIf 
    ; EndIf
EndFunction


Function RemoveInventory()
	int inventoryLostRNG = Utility.RandomInt(1, 100)
	int invIndex = 0
	int numItemsInInventory = 0
	ObjectReference dest
	
	; player inventory contains Forms, not ObjectReferences
	; solution 1: removeitem, playeralias.OnItemRemoved
	; solution 2: powerof3 papyrus extender player.GetQuestItems()
	
	if mcmOptions._diabloMode || !player.IsInCombat() || lastEnemy == None
		; send gear to grave
		dest = graveContainer
	elseif !mcmOptions._excludeCreatures || !lastEnemy.IsInFaction(creatureFaction)
		; give gear to lastenemy
		dest = lastEnemy
	else
		; in combat, but enemy is a creature, and excludecreatures is true
		return
	endif

	while invIndex < player.GetNumItems()
		numItemsInInventory = player.GetNumItems()
		Form itemBase = player.GetNthForm(invIndex) 
		
		if player.IsEquipped(itemBase) 
			; do nothing - item is equipped
		elseif itemBase == gold 
			; do nothing - item is gold
		else
			; not equipped, not gold
			if Utility.RandomInt(1, 100) < mcmOptions._inventoryPenalty
				int itemCount = player.GetItemCount(itemBase)
				int numToLose = Utility.RandomInt(1, itemCount)
				player.RemoveItem(itemBase, numToLose, true, dest)
				if player.GetNumItems() < numItemsInInventory
					; lost a whole item, so do not advance the index
					invIndex -= 1
				endif
			endif
		endif
		invIndex += 1
	endWhile
	
	; invIndex = itemsToLose.GetSize()
	; debug.notification("Losing " + invIndex + " items into grave...")
	; while invIndex > 0
		; invIndex -= 1
		; ObjectReference item = itemsToLose.GetAt(invIndex) as ObjectReference
		; int numToLose = Utility.RandomInt(1, player.GetItemCount(item))
		; debug.notification("Losing " + numToLose + "x " + item)
		; player.RemoveItem(item, numToLose, false, lastEnemy)
	; endwhile
	
	; if (inventoryLostRNG < mcmOptions._inventoryPenalty)
		; player.RemoveAllItems(lastEnemy, false, false)
		; player.RemoveAllItems()
		; player.AddItem(defaultArmor)
		; player.EquipItem(defaultArmor)
	; EndIf
EndFunction


Function RemoveGear()
	ObjectReference dest
	int weaponLostRNG = Utility.RandomInt(0, 100)
	int shieldLostRNG = Utility.RandomInt(0, 100)
	int helmLostRNG = Utility.RandomInt(0, 100)
	int armorLostRNG = Utility.RandomInt(0, 100)
	int glovesLostRNG = Utility.RandomInt(0, 100)
	int bootsLostRNG = Utility.RandomInt(0, 100)
	int amuletLostRNG = Utility.RandomInt(0, 100)
	int ringLostRNG = Utility.RandomInt(0, 100)

	if mcmOptions._diabloMode || !player.IsInCombat() || lastEnemy == None
		; send gear to grave
		dest = graveContainer
	elseif !mcmOptions._excludeCreatures || !lastEnemy.IsInFaction(creatureFaction)
		; give gear to lastenemy
		dest = lastEnemy
	else
		; in combat, but enemy is a creature, and excludecreatures is true
		return
	endif
	
    ; if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction)))
        ; if ((lastEnemy != None && !lastEnemy.IsDead()) || mcmOptions._diabloMode || !player.IsInCombat())
	
	if (mcmOptions._weaponPenalty > 0 && weaponLostRNG < mcmOptions._weaponPenalty && player.GetEquippedWeapon() != None)
		dest.AddItem(player.GetEquippedWeapon())
		player.RemoveItem(player.GetEquippedWeapon(), 1, true)
		if (player.GetEquippedWeapon(true) != None)
			dest.AddItem(player.GetEquippedWeapon(true))
			player.RemoveItem(player.GetEquippedWeapon(true), 1, true)
		EndIf
	EndIf
	if (mcmOptions._shieldPenalty > 0 && shieldLostRNG < mcmOptions._shieldPenalty && player.GetEquippedWeapon(true) != None)
		dest.AddItem(player.GetEquippedWeapon(true))
		player.RemoveItem(player.GetEquippedWeapon(true), 1, true)
	EndIf
	if (mcmOptions._helmPenalty > 0 && helmLostRNG < mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(30) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(30))
		player.RemoveItem(player.GetEquippedArmorInSlot(30), 1, true)
	EndIf
	if (mcmOptions._helmPenalty > 0 && helmLostRNG < mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(42) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(42))
		player.RemoveItem(player.GetEquippedArmorInSlot(42), 1, true)
	EndIf
	if (mcmOptions._armorPenalty > 0 && armorLostRNG < mcmOptions._armorPenalty && player.GetEquippedArmorInSlot(32) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(32))
		player.RemoveItem(player.GetEquippedArmorInSlot(32), 1, true)
		player.AddItem(defaultArmor)
		player.EquipItem(defaultArmor)
	EndIf
	if (mcmOptions._glovesPenalty > 0 && glovesLostRNG < mcmOptions._glovesPenalty && player.GetEquippedArmorInSlot(33) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(33))
		player.RemoveItem(player.GetEquippedArmorInSlot(33), 1, true)
	EndIf
	if (mcmOptions._amuletPenalty > 0 && amuletLostRNG < mcmOptions._amuletPenalty && player.GetEquippedArmorInSlot(35) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(35))
		player.RemoveItem(player.GetEquippedArmorInSlot(35), 1, true)
	EndIf
	if (mcmOptions._ringPenalty > 0 && ringLostRNG < mcmOptions._ringPenalty && player.GetEquippedArmorInSlot(36) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(36))
		player.RemoveItem(player.GetEquippedArmorInSlot(36), 1, true)
	EndIf
	if (mcmOptions._bootsPenalty > 0 && bootsLostRNG < mcmOptions._bootsPenalty && player.GetEquippedArmorInSlot(37) != None)
		dest.AddItem(player.GetEquippedArmorInSlot(37))
		player.RemoveItem(player.GetEquippedArmorInSlot(37), 1, true)
	EndIf
        ; EndIf
    ; EndIf
EndFunction

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    lastEnemy = akAggressor as Actor
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
    ElseIf (player.IsInLocation(DeadMensRespite))
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
    float expPenalty = mcmOptions._expPenaltyPercent / 100.0
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
    float expPenalty = mcmOptions._skillExpPenaltyPercent / 100.0
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


Function ResetEnemiesInCell()
	Actor[] npcs = MiscUtil.ScanCellNPCs(player, 0.0, IgnoreDead=false)
	int npcIndex = 0
	int locationIndex = noResetLocations.GetSize()
	;debug.notification("ResetNPCs: found " + npcs.Length + " NPCs in cell")
	
	; Ensure we are not in a blacklisted location
	while locationIndex > 0
		locationIndex -= 1
		if player.IsInLocation(noResetLocations.GetAt(locationIndex) as Location)
			return
		endif
	endWhile
	
	while (npcIndex < npcs.Length)
		Actor npc = npcs[npcIndex]
		if (npc == deathMarker || npc == player || npc.GetActorBase() == deathMarker.GetActorBase() )
			;debug.notification("ResetNPCs: player or deathmarker - ignore: " + npc)
		Elseif (npc.IsPlayerTeammate())
			;debug.notification("ResetNPCs: follower - ignore: " + npc)
			; ?or if npc.GetRelationshipRank(player) > 0
			npc.ResetHealthAndLimbs()
		Elseif (IsBoss(npc) || (npc.GetActorBase()).IsUnique())
			; only reset bosses and "unique" npcs if they are still alive
			if (!(npc.IsDead()))
				if BlacklistedForReset(npc) 
					; Boss is blacklisted - do not reset or relocate, just heal
					debug.notification("Boss NPC '" + npc.GetDisplayName() + "' is on 'no reset' blacklist.")
					npc.ResetHealthAndLimbs()
				elseif !(mcmOptions._resetBosses) 
					npc.ResetHealthAndLimbs()
					npc.MoveToMyEditorLocation()
				else
					;debug.notification("ResetNPCs: boss and not dead - RESET: " + npc)
					ResetEnemy(npc)
					Utility.Wait(0.1)
				endif
			else
				;debug.notification("ResetNPCs: dead boss - ignore: " + npc)
			endif
		Elseif BlacklistedForReset(npc) 
			; not a boss, but still blcklisted for reset
			; don't resurrect if dead, and don't call .Reset or relocate
			if !(npc.IsDead())
				npc.ResetHealthAndLimbs()
			endif
		else
			; non-boss NPC
			;debug.notification("ResetNPCs: non-boss NPC - RESET: " + npc)
			;npc.Reset()
			;Utility.Wait(0.1)
			if (npc.IsDead())
				npc.Resurrect()
			endif
			ResetEnemy(npc)
			Utility.Wait(0.1)
		Endif
		npcIndex += 1
	endWhile
EndFunction


Function ResetEnemy(Actor npc)
	; EXPERIMENTAL
	npc.Reset()
	Utility.Wait(0.1)
	npc.MoveToMyEditorLocation()
	npc.SetUnconscious(false)

	; may need to also reset the following Actor Values:
	; Magicka, Stamina, HealRate, StaminaRate, MagickaRate
	; AI stuff: Aggression, Confidence, Energy, Morality, Mood, Assistance, WaitingForPlayer
	; actor.SetActorValue(name, actor.GetBaseActorValue(name))
	
	;; WORKING:
	;;npc.ResetHealthAndLimbs()
	;;npc.MoveToMyEditorLocation()
	;;npc.EvaluatePackage()
EndFunction


; Function PopulateBossRaceList()
	; bossRaces.Revert()
	; bossRaces.AddForm(Race.GetRace("DragonRace"))
	; bossRaces.AddForm(Race.GetRace("DragonPriestRace"))
	; bossRaces.AddForm(Race.GetRace("GiantRace"))
	; bossRaces.AddForm(Race.GetRace("MammothRace"))
	; bossRaces.AddForm(Race.GetRace("AlduinRace"))
	; bossRaces.AddForm(Race.GetRace("SkeletonNecroPriestRace"))
	; bossRaces.AddForm(Race.GetRace("UndeadDragonRace"))
	; bossRaces.AddForm(Race.GetRace("DLC1VampireBeastRace"))
	; bossRaces.AddForm(Race.GetRace("DLC1GargoyleVariantBossRace"))
	; bossRaces.AddForm(Race.GetRace("DLC1UndeadDragonRace"))
	; bossRaces.AddForm(Race.GetRace("DLC1LD_ForgemasterRace"))
	; bossRaces.AddForm(Race.GetRace("dlc2SpectralDragonRace"))
	; bossRaces.AddForm(Race.GetRace("DragonBlackRace"))
	; bossRaces.AddForm(Race.GetRace("DLC2DragonBlackRace"))
	; bossRaces.AddForm(Race.GetRace("DLC2AcolyteDragonPriestRace"))
	; bossRaces.AddForm(Race.GetRace("DLC2MiraakRace"))
; EndFunction

Function PopulateNamedBossList()
	namedBosses.Revert()
	AddFormFromEditorID(namedBosses, "ValsVeran")
	;namedBosses.AddForm(Game.GetForm(0x019FE6))		 ; ValsVeran
	AddFormFromEditorID(namedBosses, "MercerFrey")
	AddFormFromEditorID(namedBosses, "LvlBanditBossCommonerF")
	AddFormFromEditorID(namedBosses, "LvlBanditBossCommonerM")
	AddFormFromEditorID(namedBosses, "LvlBanditBossEvenTonedF")
	AddFormFromEditorID(namedBosses, "LvlBanditBossEvenTonedM")
	AddFormFromEditorID(namedBosses, "LvlBanditBossNordF")
	AddFormFromEditorID(namedBosses, "LvlBanditBossNordM")
	AddFormFromEditorID(namedBosses, "LvlBanditBossOrcM")
	AddFormFromEditorID(namedBosses, "Telrav")
	AddFormFromEditorID(namedBosses, "JyrikGauldurson")
	AddFormFromEditorID(namedBosses, "DA03Wizard")
	AddFormFromEditorID(namedBosses, "DunLostKnifeBanditBoss")
	AddFormFromEditorID(namedBosses, "TitusMedeII")
	AddFormFromEditorID(namedBosses, "TitusMedeIIDecoy")
	AddFormFromEditorID(namedBosses, "dunBrokenOarHargar")
	AddFormFromEditorID(namedBosses, "Ancano")
	AddFormFromEditorID(namedBosses, "dunAnsilvundLuahAlSkaven")
	AddFormFromEditorID(namedBosses, "EncHagraven")
	AddFormFromEditorID(namedBosses, "Drascua")
	AddFormFromEditorID(namedBosses, "MS06Potema")
	AddFormFromEditorID(namedBosses, "MS06NecromancerLeader")
	AddFormFromEditorID(namedBosses, "dunHarmugstahlWarlock")
	AddFormFromEditorID(namedBosses, "DA13Orchendor")
	AddFormFromEditorID(namedBosses, "dunHaemarsShame_LvlVampireBoss")
	AddFormFromEditorID(namedBosses, "dunForsakenCaveCuralmil")
	AddFormFromEditorID(namedBosses, "dunDarklightSilvia")
	AddFormFromEditorID(namedBosses, "MG03Caller")
	AddFormFromEditorID(namedBosses, "dunRannLvlWarlockBoss")
	AddFormFromEditorID(namedBosses, "EncC06WolfSpirit")
	AddFormFromEditorID(namedBosses, "dunBloodletThroneVampireBoss")
	AddFormFromEditorID(namedBosses, "dunHalldirsBoss")
	AddFormFromEditorID(namedBosses, "dunIronBindBossName")
	AddFormFromEditorID(namedBosses, "Linwe")
	AddFormFromEditorID(namedBosses, "DA02Champion")
	AddFormFromEditorID(namedBosses, "dunMovarthVampireBoss")
	AddFormFromEditorID(namedBosses, "dunMistwatchFjola")
	AddFormFromEditorID(namedBosses, "MS09LvllThalmorBoss")
	AddFormFromEditorID(namedBosses, "dunGeirmundSigdis")
	AddFormFromEditorID(namedBosses, "LvlSilverhandBoss")
	AddFormFromEditorID(namedBosses, "dunFolgunthur_MikrulGauldurson")
	AddFormFromEditorID(namedBosses, "LvlDraugrBossMale")
	AddFormFromEditorID(namedBosses, "LvlDraugrAmbushBossMale")
	AddFormFromEditorID(namedBosses, "WEBountyHunterBoss")
	AddFormFromEditorID(namedBosses, "DA06GiantBoss")
	AddFormFromEditorID(namedBosses, "dunRebelsCairnLvlDraugrBossRedEagle")
	AddFormFromEditorID(namedBosses, "dunShimmermistFalmerBoss")
	AddFormFromEditorID(namedBosses, "dunFortNeugrad_LvlBanditBossAmbush")
	AddFormFromEditorID(namedBosses, "dunFrostmereCryptPaleLady")
	AddFormFromEditorID(namedBosses, "dunCragslaneButcher")
	AddFormFromEditorID(namedBosses, "LvlDraugrBossMaleNoDragonPriest")
	AddFormFromEditorID(namedBosses, "LvlDraugrAmbushBossMaleNoDragonPriest")
	AddFormFromEditorID(namedBosses, "dunWhiteRiverWatchBanditLeaderName")
	AddFormFromEditorID(namedBosses, "dunWhiteRiverWatchLvlBanditBoss")
	AddFormFromEditorID(namedBosses, "dunDaintySload_LvlSailorCaptain")
	AddFormFromEditorID(namedBosses, "dunDrelas_LvlWarlockElementalAggro1024")
	AddFormFromEditorID(namedBosses, "CR13FarkasWolfSpirit")
	AddFormFromEditorID(namedBosses, "CR13VilkasWolfSpirit")
	AddFormFromEditorID(namedBosses, "PlayerWolfSpirit")
	AddFormFromEditorID(namedBosses, "DunVolunruudBoss")
	AddFormFromEditorID(namedBosses, "dunMS06PotemaSkeleton")
	AddFormFromEditorID(namedBosses, "DLC1AlthadanVyrthur")
	AddFormFromEditorID(namedBosses, "DLC1Harkon")
	AddFormFromEditorID(namedBosses, "DLC1RuunvaldWarlockBoss")
	AddFormFromEditorID(namedBosses, "DLC2dunKarstaag")
	AddFormFromEditorID(namedBosses, "DLC2dunHaknir")
	AddFormFromEditorID(namedBosses, "DLC2MiraakMQ01")
	AddFormFromEditorID(namedBosses, "DLC2MiraakMQ02")
	AddFormFromEditorID(namedBosses, "DLC2MiraakMQ04")
	AddFormFromEditorID(namedBosses, "DLC2dunNorthshoreLandingCrabBoss")
	AddFormFromEditorID(namedBosses, "DLC2MiraakTest")
	AddFormFromEditorID(namedBosses, "DLC2MiraakMQ06")
	AddFormFromEditorID(namedBosses, "DLC2dunHorkerIslandEncHorker")
	AddFormFromEditorID(namedBosses, "DLC2EbonyWarrior")
EndFunction


bool Function BlacklistedForReset (Actor npc)
	return noResetNPCs.HasForm(npc.GetActorBase()) 
EndFunction


Function PopulateNoResetNPCList()
	noResetNPCs.Revert()
	;noResetNPCs.AddForm(0x0C14B3)		; dunRebelsCairnLvlDraugrBossRedEagle 
	;noResetNPCs.AddForm(0x0A02FE)		; northwatch interrogator (Northwatch Keep)
	AddFormFromEditorID(noResetNPCs, "MS09LvllThalmorBoss")	; northwatch interrogator (Northwatch Keep)
	AddFormFromEditorID(noResetNPCs, "dunRebelsCairnLvlDraugrBossRedEagle")	; Red Eagle
	if Game.GetModByName("Vigilant.esm") != 255
		AddFormFromEditorID(noResetNPCs, "zzzAoMm01Whore")			; Lusine NPC, Bloodsucker quest
		AddFormFromEditorID(noResetNPCs, "zzzAoMWhore")
	endif
EndFunction


; Get editor ID for the given form
; if it exists, add the form to the given formlist
; return true if form was found
bool Function AddFormFromEditorID(FormList flist, string eid)
	Form gotform = PO3_SKSEFunctions.GetFormFromEditorID(eid)
	if gotform
		flist.AddForm(gotform)
	endif
	;consoleutil.printmessage("editor ID '" +eid+ "' -> " + gotform.GetFormID() + ", formlist length now = " + flist.GetSize())
	return (gotform != none)
EndFunction


Function PopulateNoResetLocationList()
	noResetLocations.Revert()
	;AddFormFromEditorID(noResetLocations, "RebelsCairn01")
EndFunction


; XXX return true if the given actor is a 'boss' and therefore should not respawn if dead.
Bool Function IsBoss(Actor npc)
    ; blacklist TODO
    ; boss races TODO list of races such as Dragon
    ;actor.GetRace()
    ; Registered as a "boss" for this location
    if (npc.HasRefType(locRefTypeBoss))
		Return true
    Elseif (npc.HasRefType(locRefTypeDLC2Boss1))
		Return true
	Elseif bossRaces.HasForm(npc.GetRace())
		Return true
	Elseif namedBosses.HasForm(npc)
		Return true
	Else
		Return false
	Endif
EndFunction

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
    PlayerRespawnMarker.moveto(player)
EndEvent


; count * item removed from "me" (player) and put in dest. itemReference is ignored.
; we need to reverse the transfer if item is gold and dest is anything other than "none" or a vendor inventory.
; ie if dest is a follower, or a chest etc.
; dest.IsInFaction(MerchantFaction) >= 0
; dest.IsPlayerTeammate()

Event OnItemRemoved(Form itemBase, int count, ObjectReference itemReference, ObjectReference dest)
	
	if player.IsBleedingOut() 
		; We are here because we are moving items from player inventory to grave, during bleedout
		; We need to check if the item is a quest item, and if so, reverse the move
		if itemReference.GetNumReferenceAliases() > 0
			debug.Notification("Prevented loss of quest item from player inventory.")
			dest.RemoveItem(itemBase, count, false, Game.GetPlayer())
		endif
	elseif itemBase == gold && (mcmOptions._preventGoldStorage)
		if (!dest)
			;debug.Notification("Destination is empty, so allow.")
			; do nothing - gold was "consumed"
		elseif (dest as Actor)
			if ((dest as Actor).IsPlayerTeammate())
				debug.Notification("Followers are not allowed to carry your gold.")
				dest.RemoveItem(itemBase, count, false, Game.GetPlayer())
			elseif ((dest as Actor).IsDead())
				debug.Notification("You are not allowed to store gold in corpses.")
				dest.RemoveItem(itemBase, count, false, Game.GetPlayer())
			else
				;Not clear how this would arise
				;debug.Notification("Destination actor is not follower - allow")
			endif
		elseif (dest.GetBaseObject() as Container)
			if (UI.isMenuOpen("BarterMenu"))
				; when trading with merchants, the player actually interacts with the
				; merchant's owned container
				;debug.Notification("Destination is merchant's container (bartermenu) - allow")
			else
				; move it back
				debug.Notification("You are not allowed to store gold in containers.")
				dest.RemoveItem(itemBase, count, false, Game.GetPlayer())
			endif
		else	
			debug.Notification("Gold destination is not actor or container: " + dest)
		endif
	else
		;debug.Notification("Respawn mod is not set to prevent gold storage.")
	endif
EndEvent


Function PlaceRespawnMarkerAtCampfire(bool playerBuilt = false)
	PlayerRespawnMarker.moveto(player)
	playerRespawnMarkerInitialized = true
	debug.Notification("You will respawn at this campfire if you are killed.")
	PlaceCampfireMapMarker(playerBuilt)
EndFunction


; MapMarker refs cannot be created at runtime.
; So we must use a pre-existing list of marker refs that we can move around.
; If playerBuilt is true, then this is a "Campfire mod" campfire that has been placed by the player.

Function PlaceCampfireMapMarker(bool playerBuilt = false)

	if (player.IsInInterior())
		;Debug.Notification("Cannot place marker in interior cells.")
		return
	elseif (Game.FindClosestReferenceOfTypeFromRef((campfireMarkerList.GetAt(0) as ObjectReference).GetBaseObject(), player, 200.0))
		;debug.Notification("There's already a map marker nearby.")
		return
	else
		ObjectReference marker
		if (!playerBuilt && campfireMarkerNextAvailable >= campfireMarkerList.GetSize())
			; start reusing old markers
			campfireMarkerNextAvailable = 0
		endif
		if (playerBuilt)
			marker = playerBuiltCampfireMarker
		else
			marker = (campfireMarkerList.GetAt(campfireMarkerNextAvailable) as ObjectReference)
			campfireMarkerNextAvailable += 1
		endif
		
		if (!marker)
			;debug.Notification("Could not get marker!")
		else
			;debug.Notification("Moving marker " + campfireMarkerNextAvailable + " to player: " + marker)
			marker.moveto(player) 
			marker.SetDisplayName("Campfire - '" + player.GetParentCell().GetName() + "'")		; doesn't seem to work
			marker.Enable()
			marker.AddToMap(true)
		endif
	endif
EndFunction


; Function DumpFormListToConsole ()
	; int x = noResetNPCs.GetSize()
	; consoleutil.printmessage("dumping noResetNPCs:")
	; while x > 0
		; x -= 1
		; consoleutil.printmessage("noResetNPCs[" +x+ "]: " + noResetNPCs.GetAt(x).GetFormID() + "  " + PO3_SKSEFunctions.GetFormEditorID(noResetNPCs.GetAt(x)))
	; endwhile
; EndFunction

