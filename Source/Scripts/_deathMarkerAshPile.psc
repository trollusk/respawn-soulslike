Scriptname _deathMarkerAshPile extends Actor  

; this script is attached to the NPC _DeathMarker

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
Quest Property deathMarkerQuest Auto  


Event OnInit()
    deathMarkerQuest = Quest.GetQuest("_RespawnDeathMarkerQuest")
	AshPileObject = RespawnAshPile
EndEvent


Event OnPlayerLoadGame()
    deathMarkerQuest = Quest.GetQuest("_RespawnDeathMarkerQuest")
	AshPileObject = RespawnAshPile
EndEvent


Event OnDeath(Actor Killer)
		; xxx (re)activate the death marker quest, allowing player to locate the grave
		deathMarkerQuest.Stop()
		(deathMarkerQuest.GetAliasByName("DeathMarkerRef") as ReferenceAlias).ForceRefTo(self)
		utility.wait(0.1)    
		deathMarkerQuest.Start()
		deathMarkerQuest.SetObjectiveDisplayed(10)
		deathMarkerQuest.SetStage(10)
		
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


; xxx
Event OnActivate(ObjectReference opener)
	if (opener == Game.GetPlayer())
		deathMarkerQuest.SetStage(20)
		deathMarkerQuest.CompleteQuest()
		deathMarkerQuest.SetObjectiveDisplayed(10,false)
		self.Disable(true)
	Endif
EndEvent
