Scriptname _GraveContainer extends ObjectReference

_RespawnOverhaulMCM property mcmOptions auto
Quest Property deathMarkerQuest Auto      ; quest given to player, to retrieve belongings from grave
ObjectReference property graveActivator auto
ObjectReference property graveLight auto


; Activation will be passed on to us by GraveActivator

Event OnActivate(ObjectReference opener)
	if opener == Game.GetPlayer() 
		if mcmOptions._giveDeathMarkerQuest
			deathMarkerQuest.SetStage(20)
			deathMarkerQuest.CompleteQuest()
			deathMarkerQuest.SetObjectiveDisplayed(10,false)
			;self.Disable(true)
		endif
		if self.GetNumItems() == 0
			graveActivator.Disable(true)
			graveLight.Disable(true)
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
            graveActivator.Disable(true)
			graveLight.Disable(true)
        endif
    endif
EndEvent

