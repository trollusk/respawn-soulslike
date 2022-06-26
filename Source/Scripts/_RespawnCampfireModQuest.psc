Scriptname _RespawnCampfireModQuest extends ReferenceAlias  

Actor property player auto
_RespawnScript property _RespawnQuest auto
Furniture property _CampfireModFire1 auto
Furniture property _CampfireModFire2 auto
Furniture property _CampfireModFire3 auto


Event OnSit(ObjectReference furn)
	Form furnBase = furn.GetBaseObject()
	;debug.Notification("(CM) Sitting on base =" + furnBase + "  " + furnBase.GetName())
		
	if ((furnBase == _CampfireModFire1) || (furnBase == _CampfireModFire2) || (furnBase == _CampfireModFire3))
		;debug.Notification("Sitting at campfire! (Campfire.esm)")
		_RespawnQuest.PlaceRespawnMarkerAtCampfire(true)
		return
	endif
	
	;debug.Notification("(CM) No campfire detected")
EndEvent
