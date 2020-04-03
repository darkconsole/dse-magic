ScriptName dse_mag_QuestStats extends Quest
{This script is designed to count various aspects of the spells you use so that
they can level up or whatever.}

Int StatMeteorCast = 0
Int Property MeteorCast
	Int Function Get()
		Return StatMeteorCast
	EndFunction
	Function Set(Int Value)
		Debug.Notification("Meteor Cast: " + Value)
		StatMeteorCast = Value
		Return
	EndFunction
EndProperty

Int StatMeteorCount = 0
Int Property MeteorCount
	Int Function Get()
		Return StatMeteorCount
	EndFunction
	Function Set(Int Value)
		Debug.Notification("Meteor Count: " + Value)
		StatMeteorCount = Value
		Return
	EndFunction
EndProperty

Event OnInit()

	StatMeteorCast = 0
	StatMeteorCount = 0

	Return
EndEvent

Function Bump(String What, Int Amount)

	If(What == "MeteorCount")
		self.MeteorCount += Amount
	ElseIf(What == "MetorCast")
		self.MeteorCast += Amount
	EndIf

	Return
EndFunction
