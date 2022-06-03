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
Quest property brawlQuest auto

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

; Werewolf/werebear/vampire
Race property werewolfRace auto
Race property werebearRace auto
Race property vampireRace auto

Location[] disabledLocations ; Set these locations for quest areas that might bug out.

ObjectReference Property PlayerRespawnMarker  Auto  
Cell Property PlayerRespawnMarkerCell  Auto  
LocationRefType property locRefTypeBoss auto
LocationRefType property locRefTypeDLC2Boss1 auto

FormList bossRaces
FormList namedBosses
bool Property playerRespawnMarkerInitialized auto

Static property MapMarker auto
FormList property campfireMarkerList auto
Int property campfireMarkerNextAvailable auto
ObjectReference property playerBuiltCampfireMarker auto

Event OnInit()
    player = Game.GetPlayer()
    
    player.GetActorBase().SetEssential()
    player.SetNoBleedoutRecovery(false)

	PopulateBossRaceList()
	PopulateNamedBossList()
	
    RegisterForSleep()
	AddInventoryEventFilter(gold)
EndEvent

Event OnPlayerLoadGame()
    player = Game.GetPlayer()
    
    player.GetActorBase().SetEssential()
    player.SetNoBleedoutRecovery(false)
	
	PopulateBossRaceList()
	PopulateNamedBossList()
	
	if (PlayerRespawnMarker.GetParentCell() == PlayerRespawnMarkerCell)
		debug.notification("PlayerRespawnMarker not initialized, moving to player...")
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
    
    if (IsTransformed() == false && disabledLocationFound == false && (mcmOptions._onlyTemple || mcmOptions._nearestHold || mcmOptions._nearestHome || mcmOptions._lastBed))
        Location loc = player.GetCurrentLocation()
		
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
        
        ; XXX Reset the state of all non-boss NPCs in the cell.
        ; Also resets bosses if they have not been killed.
		if (mcmOptions._resetEnemies)
			; don't reset if location is "cleared". Outdoor locations may return a Location of "none".
			if (!loc || !(loc.IsCleared()))
				ResetEnemiesInCell()
			endif
        endif
		
        Utility.Wait(1.25)
        if (player.IsInLocation(Sovangarde) == false)
            if (mcmOptions._lastBed == true)
                RespawnToLocation(PlayerRespawnMarker)
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
    Else
        player.KillEssential()
    EndIf
EndEvent

Function RespawnToLocation(ObjectReference objectLocation)
    Game.ForceThirdperson()
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
    lastEnemy.StopCombat()
    player.StopCombatAlarm()
    ;savedObject = objectLocation
    ;RegisterForUpdate(0.25)
EndFunction

;Event OnLocationChange(Location akOldLoc, Location akNewLoc)
;   if (savedObject.GetCurrentLocation() != akNewLoc && savedObject.GetCurrentLocation() != akNewLoc)
;       UnregisterForUpdate()
;   EndIf
;EndEvent

Function SetAshPile()
	Actor old_deathmarker = deathMarker
    if (mcmOptions._diabloMode)
        if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction)))
            ; XXX hide and delete any existing ash pile
            if (old_deathmarker)
                old_deathmarker.Disable()
            Endif
            deathMarker = player.PlaceActorAtMe(old_deathmarker.GetActorBase())
            deathMarker.Enable()
            deathMarker.RemoveAllItems()
            deathMarker.SetAlpha(0, false)
            deathMarker.KillEssential()
            lastEnemy = deathMarker
			old_deathmarker.Delete()
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

; XXX stop gear being occasionally removed even if chance was set to 0

Function RemoveGear()
    if (!mcmOptions._excludeCreatures || (mcmOptions._excludeCreatures && !lastEnemy.IsInFaction(creatureFaction)))
        if ((lastEnemy != None && !lastEnemy.IsDead()) || mcmOptions._diabloMode)
            int weaponLostRNG = Utility.RandomInt(0, 100)
            int shieldLostRNG = Utility.RandomInt(0, 100)
            int helmLostRNG = Utility.RandomInt(0, 100)
            int armorLostRNG = Utility.RandomInt(0, 100)
            int glovesLostRNG = Utility.RandomInt(0, 100)
            int bootsLostRNG = Utility.RandomInt(0, 100)
            int amuletLostRNG = Utility.RandomInt(0, 100)
            int ringLostRNG = Utility.RandomInt(0, 100)
            int inventoryLostRNG = Utility.RandomInt(0, 100)
            if (inventoryLostRNG < mcmOptions._inventoryPenalty)
                player.RemoveAllItems(lastEnemy, false, false)
                player.RemoveAllItems()
                player.AddItem(defaultArmor)
                player.EquipItem(defaultArmor)
            EndIf
            if (mcmOptions._weaponPenalty > 0 && weaponLostRNG < mcmOptions._weaponPenalty && player.GetEquippedWeapon() != None)
                lastEnemy.AddItem(player.GetEquippedWeapon())
                player.RemoveItem(player.GetEquippedWeapon())
                if (player.GetEquippedWeapon(true) != None)
                    lastEnemy.AddItem(player.GetEquippedWeapon(true))
                    player.RemoveItem(player.GetEquippedWeapon(true))
                EndIf
            EndIf
            if (mcmOptions._shieldPenalty > 0 && shieldLostRNG < mcmOptions._shieldPenalty && player.GetEquippedWeapon(true) != None)
                lastEnemy.AddItem(player.GetEquippedWeapon(true))
                player.RemoveItem(player.GetEquippedWeapon(true))
            EndIf
            if (mcmOptions._helmPenalty > 0 && helmLostRNG < mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(30) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(30))
                player.RemoveItem(player.GetEquippedArmorInSlot(30))
            EndIf
            if (mcmOptions._helmPenalty > 0 && helmLostRNG < mcmOptions._helmPenalty && player.GetEquippedArmorInSlot(42) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(42))
                player.RemoveItem(player.GetEquippedArmorInSlot(42))
            EndIf
            if (mcmOptions._armorPenalty > 0 && armorLostRNG < mcmOptions._armorPenalty && player.GetEquippedArmorInSlot(32) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(32))
                player.RemoveItem(player.GetEquippedArmorInSlot(32))
                player.AddItem(defaultArmor)
                player.EquipItem(defaultArmor)
            EndIf
            if (mcmOptions._glovesPenalty > 0 && glovesLostRNG < mcmOptions._glovesPenalty && player.GetEquippedArmorInSlot(33) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(33))
                player.RemoveItem(player.GetEquippedArmorInSlot(33))
            EndIf
            if (mcmOptions._amuletPenalty > 0 && amuletLostRNG < mcmOptions._amuletPenalty && player.GetEquippedArmorInSlot(35) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(35))
                player.RemoveItem(player.GetEquippedArmorInSlot(35))
            EndIf
            if (mcmOptions._ringPenalty > 0 && ringLostRNG < mcmOptions._ringPenalty && player.GetEquippedArmorInSlot(36) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(36))
                player.RemoveItem(player.GetEquippedArmorInSlot(36))
            EndIf
            if (mcmOptions._bootsPenalty > 0 && bootsLostRNG < mcmOptions._bootsPenalty && player.GetEquippedArmorInSlot(37) != None)
                lastEnemy.AddItem(player.GetEquippedArmorInSlot(37))
                player.RemoveItem(player.GetEquippedArmorInSlot(37))
            EndIf
        EndIf
    EndIf
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


Function ResetEnemiesInCell()
	Actor[] npcs = MiscUtil.ScanCellNPCs(player, 0.0, IgnoreDead=false)
	int npcIndex = 0
	debug.notification("ResetNPCs: found " + npcs.Length + " NPCs in cell")
	while (npcIndex < npcs.Length)
		Actor npc = npcs[npcIndex]
		if (npc == deathMarker || npc == player)
			debug.notification("ResetNPCs: player or deathmarker - ignore: " + npc)
		Elseif (npc.IsPlayerTeammate())
			debug.notification("ResetNPCs: follower - ignore: " + npc)
			; ?or if npc.GetRelationshipRank(player) > 0
			npc.ResetHealthAndLimbs()
		Elseif (IsBoss(npc) || (npc.GetBaseObject() as ActorBase).IsUnique())
			; reset bosses and "unique" npcs, unless they are dead
			if (!(npc.IsDead()))
				debug.notification("ResetNPCs: boss and not dead - RESET: " + npc)
				ResetEnemy(npc)
				Utility.Wait(0.1)
			else
				debug.notification("ResetNPCs: dead boss - ignore: " + npc)
			endif
		Else
			; non-boss NPC
			debug.notification("ResetNPCs: non-boss NPC - RESET: " + npc)
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


Function PopulateBossRaceList()
	bossRaces.Revert()
	bossRaces.AddForm(Race.GetRace("DragonRace"))
	bossRaces.AddForm(Race.GetRace("DragonPriestRace"))
	bossRaces.AddForm(Race.GetRace("GiantRace"))
	bossRaces.AddForm(Race.GetRace("MammothRace"))
	bossRaces.AddForm(Race.GetRace("AlduinRace"))
	bossRaces.AddForm(Race.GetRace("SkeletonNecroPriestRace"))
	bossRaces.AddForm(Race.GetRace("UndeadDragonRace"))
	bossRaces.AddForm(Race.GetRace("DLC1VampireBeastRace"))
	bossRaces.AddForm(Race.GetRace("DLC1GargoyleVariantBossRace"))
	bossRaces.AddForm(Race.GetRace("DLC1UndeadDragonRace"))
	bossRaces.AddForm(Race.GetRace("DLC1LD_ForgemasterRace"))
	bossRaces.AddForm(Race.GetRace("dlc2SpectralDragonRace"))
	bossRaces.AddForm(Race.GetRace("DragonBlackRace"))
	bossRaces.AddForm(Race.GetRace("DLC2DragonBlackRace"))
	bossRaces.AddForm(Race.GetRace("DLC2AcolyteDragonPriestRace"))
	bossRaces.AddForm(Race.GetRace("DLC2MiraakRace"))
EndFunction

Function PopulateNamedBossList()
	namedBosses.Revert()
	namedBosses.AddForm(Game.GetForm(0x019FE6))		 ; ValsVeran
	namedBosses.AddForm(Game.GetForm(0x01B07C))		 ; MercerFrey
	namedBosses.AddForm(Game.GetForm(0x01B0D8))		 ; LvlBanditBossCommonerF
	namedBosses.AddForm(Game.GetForm(0x01B0DB))		 ; LvlBanditBossCommonerM
	namedBosses.AddForm(Game.GetForm(0x01B0DC))		 ; LvlBanditBossEvenTonedF
	namedBosses.AddForm(Game.GetForm(0x01B0DD))		 ; LvlBanditBossEvenTonedM
	namedBosses.AddForm(Game.GetForm(0x01B0DE))		 ; LvlBanditBossNordF
	namedBosses.AddForm(Game.GetForm(0x01B0D1))		 ; LvlBanditBossNordM
	namedBosses.AddForm(Game.GetForm(0x01B0EB))		 ; LvlBanditBossOrcM
	namedBosses.AddForm(Game.GetForm(0x01BA08))		 ; Telrav
	namedBosses.AddForm(Game.GetForm(0x01BB28))		 ; JyrikGauldurson
	namedBosses.AddForm(Game.GetForm(0x01C4E5))		 ; DA03Wizard
	namedBosses.AddForm(Game.GetForm(0x01C902))		 ; DunLostKnifeBanditBoss
	namedBosses.AddForm(Game.GetForm(0x01D4B9))		 ; TitusMedeII
	namedBosses.AddForm(Game.GetForm(0x01D4BA))		 ; TitusMedeIIDecoy
	namedBosses.AddForm(Game.GetForm(0x01E38B))		 ; dunBrokenOarHargar
	namedBosses.AddForm(Game.GetForm(0x01E7D7))		 ; Ancano
	namedBosses.AddForm(Game.GetForm(0x02333A))		 ; dunAnsilvundLuahAlSkaven
	namedBosses.AddForm(Game.GetForm(0x023AB0))		 ; EncHagraven
	namedBosses.AddForm(Game.GetForm(0x0240D7))		 ; Drascua
	namedBosses.AddForm(Game.GetForm(0x026C52))		 ; MS06Potema
	namedBosses.AddForm(Game.GetForm(0x0284F2))		 ; MS06NecromancerLeader
	namedBosses.AddForm(Game.GetForm(0x039BB7))		 ; dunHarmugstahlWarlock
	namedBosses.AddForm(Game.GetForm(0x045F78))		 ; DA13Orchendor
	namedBosses.AddForm(Game.GetForm(0x046283))		 ; dunHaemarsShame_LvlVampireBoss
	namedBosses.AddForm(Game.GetForm(0x048B55))		 ; dunForsakenCaveCuralmil
	namedBosses.AddForm(Game.GetForm(0x04B0AE))		 ; dunDarklightSilvia
	namedBosses.AddForm(Game.GetForm(0x04D246))		 ; MG03Caller
	namedBosses.AddForm(Game.GetForm(0x05197F))		 ; dunRannLvlWarlockBoss
	namedBosses.AddForm(Game.GetForm(0x058303))		 ; EncC06WolfSpirit
	namedBosses.AddForm(Game.GetForm(0x05B830))		 ; dunBloodletThroneVampireBoss
	namedBosses.AddForm(Game.GetForm(0x064B1C))		 ; dunHalldirsBoss
	namedBosses.AddForm(Game.GetForm(0x06CD59))		 ; dunIronBindBossName
	namedBosses.AddForm(Game.GetForm(0x07D679))		 ; Linwe
	namedBosses.AddForm(Game.GetForm(0x0834FE))		 ; DA02Champion
	namedBosses.AddForm(Game.GetForm(0x08BB91))		 ; dunMovarthVampireBoss
	namedBosses.AddForm(Game.GetForm(0x090739))		 ; dunMistwatchFjola
	namedBosses.AddForm(Game.GetForm(0x09F360))		; MS09LvllThalmorBoss
	namedBosses.AddForm(Game.GetForm(0x0A6842))		 ; dunGeirmundSigdis
	namedBosses.AddForm(Game.GetForm(0x0A9548))		 ; LvlSilverhandBoss
	namedBosses.AddForm(Game.GetForm(0x0AB6FF))		 ; dunFolgunthur_MikrulGauldurson
	namedBosses.AddForm(Game.GetForm(0x0B7988))		 ; LvlDraugrBossMale
	namedBosses.AddForm(Game.GetForm(0x0B7989))		 ; LvlDraugrAmbushBossMale
	namedBosses.AddForm(Game.GetForm(0x0BC09F))		 ; WEBountyHunterBoss
	namedBosses.AddForm(Game.GetForm(0x0C0BE5))		 ; DA06GiantBoss
	namedBosses.AddForm(Game.GetForm(0x0C1908))		 ; dunRebelsCairnLvlDraugrBossRedEagle
	namedBosses.AddForm(Game.GetForm(0x0CB11B))		 ; dunShimmermistFalmerBoss
	namedBosses.AddForm(Game.GetForm(0x0CC59B))		 ; dunFortNeugrad_LvlBanditBossAmbush
	namedBosses.AddForm(Game.GetForm(0x0D37F4))		 ; dunFrostmereCryptPaleLady
	namedBosses.AddForm(Game.GetForm(0x0D823E))		 ; dunCragslaneButcher
	namedBosses.AddForm(Game.GetForm(0x0DD9D7))		 ; LvlDraugrBossMaleNoDragonPriest
	namedBosses.AddForm(Game.GetForm(0x0DD9D9))		 ; LvlDraugrAmbushBossMaleNoDragonPriest
	namedBosses.AddForm(Game.GetForm(0x0E1642))		 ; dunWhiteRiverWatchBanditLeaderName
	namedBosses.AddForm(Game.GetForm(0x0E1F81))		 ; dunWhiteRiverWatchLvlBanditBoss
	namedBosses.AddForm(Game.GetForm(0x0E5F37))		 ; dunDaintySload_LvlSailorCaptain
	namedBosses.AddForm(Game.GetForm(0x0E76C9))		 ; dunDrelas_LvlWarlockElementalAggro1024
	namedBosses.AddForm(Game.GetForm(0x0F6087))		 ; CR13FarkasWolfSpirit
	namedBosses.AddForm(Game.GetForm(0x0F6089))		 ; CR13VilkasWolfSpirit
	namedBosses.AddForm(Game.GetForm(0x0F608C))		 ; PlayerWolfSpirit
	namedBosses.AddForm(Game.GetForm(0x1019C6))		 ; DunVolunruudBoss
	namedBosses.AddForm(Game.GetForm(0x10349B))		 ; dunMS06PotemaSkeleton
	namedBosses.AddForm(Game.GetForm(0x003788))		 ; DLC1AlthadanVyrthur
	namedBosses.AddForm(Game.GetForm(0x003BA7))		 ; DLC1Harkon
	namedBosses.AddForm(Game.GetForm(0x013823))		 ; DLC1RuunvaldWarlockBoss
	namedBosses.AddForm(Game.GetForm(0x019665))		 ; DLC2dunKarstaag
	namedBosses.AddForm(Game.GetForm(0x01A373))		 ; DLC2dunHaknir
	namedBosses.AddForm(Game.GetForm(0x017936))		 ; DLC2MiraakMQ01
	namedBosses.AddForm(Game.GetForm(0x017938))		 ; DLC2MiraakMQ02
	namedBosses.AddForm(Game.GetForm(0x017F81))		 ; DLC2MiraakMQ04
	namedBosses.AddForm(Game.GetForm(0x01D77A))		 ; DLC2dunNorthshoreLandingCrabBoss
	namedBosses.AddForm(Game.GetForm(0x01F998))		 ; DLC2MiraakTest
	namedBosses.AddForm(Game.GetForm(0x01FB98))		 ; DLC2MiraakMQ06
	namedBosses.AddForm(Game.GetForm(0x026196))		 ; DLC2dunHorkerIslandEncHorker
	namedBosses.AddForm(Game.GetForm(0x0285C3))		 ; DLC2EbonyWarrior
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


Event OnLocationChange(Location oldLoc, Location newLoc)
	; debug.notification("Player moved to new location: " + newLoc)
	; if PlayerMarker in starting "Elsweyr" cell then move it to player
	if (PlayerRespawnMarker.GetParentCell() == PlayerRespawnMarkerCell)
		; respawn marker is still in default cell (Elsweyr)
		debug.notification("PlayerRespawnMarker moved to player")
		PlayerRespawnMarker.moveto(player)
		playerRespawnMarkerInitialized = true
	endif
EndEvent

; count * item removed from "me" (player) and put in dest. itemReference is ignored.
; we need to reverse the transfer if item is gold and dest is anything other than "none" or a vendor inventory.
; ie if dest is a follower, or a chest etc.
; dest.IsInFaction(MerchantFaction) >= 0
; dest.IsPlayerTeammate()
Event OnItemRemoved(Form item, int count, ObjectReference itemReference, ObjectReference dest)
	debug.Notification("Trying to remove gold from player...")
	if (mcmOptions._preventGoldStorage)
		if (!dest)
			debug.Notification("Destination is empty, so allow.")
			; do nothing - gold was "consumed"
		elseif (dest as Actor)
			if ((dest as Actor).IsPlayerTeammate())
				debug.Notification("Followers are not allowed to carry your gold.")
				dest.RemoveItem(item, count, false, Game.GetPlayer())
			elseif ((dest as Actor).IsDead())
				debug.Notification("You are not allowed to store gold in corpses.")
				dest.RemoveItem(item, count, false, Game.GetPlayer())
			else
				;Not clear how this would arise
				debug.Notification("Destination actor is not follower - allow")
			endif
		elseif (dest.GetBaseObject() as Container)
			if (UI.isMenuOpen("BarterMenu"))
				; when trading with merchants, the player actually interacts with the
				; merchant's owned container
				debug.Notification("Destination is merchant's container (bartermenu) - allow")
			else
				; move it back
				debug.Notification("You are not allowed to store gold in containers.")
				dest.RemoveItem(item, count, false, Game.GetPlayer())
			endif
		else	
			debug.Notification("Destination is not actor or container: " + dest)
		endif
	else
		debug.Notification("Gold Is XP is not set to prevent gold storage.")
	endif
EndEvent


Event OnSit(ObjectReference furn)
	int furnID = Math.LogicalAnd(furn.GetBaseObject().GetFormID(), 0x0FFFFF)
	
	debug.Notification("~Sitting on base type = " + furnID + " " + furn.GetBaseObject().GetName())
	debug.Notification("Furn ID = " + furnID)
	
	if (Game.GetModByName("DSMenuCampfire.esp") != 255)
		; remove first 2 hex digits from formID when using with GetFormFromFile
		int fireID1 = 0x0B1800
		int fireID2 = 0x0B1801
		int fireID3 = 0
		
		if ((furnID == fireID1) || (furnID == fireID2))
			debug.Notification("Sitting at campfire! (DSMenuCampfire.esp)")
			PlayerRespawnMarker.moveto(player)
			playerRespawnMarkerInitialized = true
			PlaceCampfireMapMarker()
			return
		elseif (Game.GetModByName("SBM-Campfire Patch.esp") != 255)
			fireID1 = 0x39577
			fireID2 = 0x536e7
			fireID3 = 0x7bea2
			if ((furnID == fireID1) || (furnID == fireID2) || (furnID == fireID3))
				debug.Notification("Sitting at campfire! (SBM-Campfire Patch.esp)")
				PlayerRespawnMarker.moveto(player)
				playerRespawnMarkerInitialized = true
				PlaceCampfireMapMarker()
				return
			endif
		endif
	endif      ; souls bonfire menu
	
	if (Game.GetModByName("Campfire.esm") != 255)
		int fireID1 = 0x39577
		int fireID2 = 0x536e7
		int fireID3 = 0x7bea2
		if ((furnID == fireID1) || (furnID == fireID2) || (furnID == fireID3))
			debug.Notification("Sitting at campfire! (Campfire.esm)")
			PlayerRespawnMarker.moveto(player)
			playerRespawnMarkerInitialized = true
			PlaceCampfireMapMarker()
			return
		endif
	endif
	debug.Notification("No campfire detected")
	
EndEvent



; MapMarker refs cannot be created at runtime.
; So we must use a pre-existing list of marker refs that we can move around.
; If playerBuilt is true, then this is a "Campfire mod" campfire that has been placed by the player.

Function PlaceCampfireMapMarker(bool playerBuilt = false)

	if (player.IsInInterior())
		Debug.Notification("Cannot place marker in interior cells.")
		return
	elseif (campfireMarkerNextAvailable >= campfireMarkerList.GetSize())
		debug.Notification("Out of campfire map markers.")
		return
	elseif (Game.FindClosestReferenceOfTypeFromRef((campfireMarkerList.GetAt(0) as ObjectReference).GetBaseObject(), player, 200.0))
		debug.Notification("There's already a map marker nearby.")
		return
	else
		ObjectReference marker
		if (playerBuilt)
			marker = playerBuiltCampfireMarker
		else
			marker = (campfireMarkerList.GetAt(campfireMarkerNextAvailable) as ObjectReference)
		endif
		
		if (!marker)
			debug.Notification("Could not get marker!")
		else
			debug.Notification("Moving marker " + campfireMarkerNextAvailable + " to player: " + marker)
			if (!playerBuilt)
				campfireMarkerNextAvailable += 1
			endif
			marker.moveto(player) 
			marker.SetDisplayName("Campfire - '" + player.GetParentCell().GetName() + "'")
			marker.Enable()
			marker.AddToMap(true)
		endif
	endif
	;marker.AddToMap(true)
	;return
EndFunction
