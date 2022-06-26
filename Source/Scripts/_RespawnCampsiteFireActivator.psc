Scriptname _RespawnCampsiteFireActivator extends ObjectReference  

Actor property player auto
_RespawnScript property _RespawnQuest auto


Event OnActivate(ObjectReference who)
	if who == player
		_RespawnQuest.PlaceRespawnMarkerAtCampfire(true)
	endif
EndEvent
