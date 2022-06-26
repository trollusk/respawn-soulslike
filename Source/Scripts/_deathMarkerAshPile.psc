Scriptname _deathMarkerAshPile extends Actor  

; this script is attached to the NPC _DeathMarker

_RespawnOverhaulMCM property mcmOptions auto

float property fDelay = 0.75 auto
									{time to wait before Spawning Ash Pile}
float property fDelayEnd = 1.65 auto
									{time to wait before Removing Base Actor}
float property ShaderDuration = 0.00 auto
									{Duration of Effect Shader.}
Activator property AshPileObject auto
									{The object we use as a pile.}

Activator property RespawnAshPile auto

EffectShader property MagicEffectShader auto
									{The Effect Shader we want.}
Bool property bSetAlphaZero = True auto
									{The Effect Shader we want.}
Bool property bSetAlphaToZeroEarly = False Auto
									{Use this if we want to set the acro to invisible somewhere before the effect shader is done.}
_RespawnScript property respawnScript auto
			
; XXX
Quest Property deathMarkerQuest Auto      ; quest given to player, to retrieve belongings from grave
ObjectReference Property GraveActivator  Auto  
ObjectReference property GraveContainer auto


Event OnInit()
    ;deathMarkerQuest = Quest.GetQuest("_RespawnDeathMarkerQuest")
	AshPileObject = RespawnAshPile
EndEvent


Event OnPlayerLoadGame()
    ;deathMarkerQuest = Quest.GetQuest("_RespawnDeathMarkerQuest")
	AshPileObject = RespawnAshPile
EndEvent


Event OnDeath(Actor Killer)
		; (re)activate the death marker quest, allowing player to locate the grave
		if mcmOptions._giveDeathMarkerQuest
			deathMarkerQuest.Stop()
			(deathMarkerQuest.GetAliasByName("DeathMarkerRef") as ReferenceAlias).ForceRefTo(self)
			utility.wait(0.1)    
			deathMarkerQuest.Start()
			deathMarkerQuest.SetObjectiveDisplayed(10)
			deathMarkerQuest.SetStage(10)
		endif
		
		Self.SetCriticalStage(self.CritStage_DisintegrateStart)
		if	MagicEffectShader != none
			MagicEffectShader.play(Self,ShaderDuration)
		endif
		if bSetAlphaToZeroEarly
			Self.SetAlpha (0.0,True)
		endif
		utility.wait(fDelay)     
		Self.AttachAshPile(AshPileObject)
		utility.wait(fDelayEnd)
			if	MagicEffectShader != none
				MagicEffectShader.stop(Self)
			endif
			if bSetAlphaZero == True
				Self.SetAlpha (0.0,True)
			endif
		Self.SetCriticalStage(Self.CritStage_DisintegrateEnd)
		Utility.Wait(36000) ; Wait 10 hours before ash pile disappears.
		
EndEvent


Event OnActivate(ObjectReference opener)
	if opener == Game.GetPlayer() 
		if mcmOptions._giveDeathMarkerQuest
			deathMarkerQuest.SetStage(20)
			deathMarkerQuest.CompleteQuest()
			deathMarkerQuest.SetObjectiveDisplayed(10,false)
			;self.Disable(true)
		endif
		if self.GetNumItems() == 0
			self.Disable(true)
		endif
	Endif
EndEvent


; If player is taking items from their grave, then check if the grave is empty,
; and if so delete it.

Event OnItemRemoved(Form base, int count, ObjectReference itemRef, ObjectReference dest)
    if dest == Game.GetPlayer()
        ;debug.notification("Item added to player inventory from grave")
        if self.GetNumItems() == 0
            ;debug.notification("Grave is empty, disabling")
            self.Disable(true)
        endif
    endif
EndEvent


