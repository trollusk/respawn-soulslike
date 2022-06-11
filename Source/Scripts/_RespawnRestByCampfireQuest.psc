Scriptname _RespawnRestByCampfireQuest extends ReferenceAlias  

Actor property player auto
_RespawnScript property _RespawnQuest auto
Furniture property _RBCModFire1 auto
Furniture property _RBCModFire2 auto


Event OnSit(ObjectReference furn)
	Form furnBase = furn.GetBaseObject()
	;debug.Notification("(RBC) Sitting on base =" + furnBase + "  " + furnBase.GetFormID() + "  " + furnBase.GetName())
		
	if ((furnBase == _RBCModFire1) || (furnBase == _RBCModFire2))
		;debug.Notification("Sitting at campfire! (Rest By Campfire.esp)")
		_RespawnQuest.PlaceRespawnMarkerAtCampfire()
		return
	endif
	
	;debug.Notification("(RBC) No campfire detected")
EndEvent
