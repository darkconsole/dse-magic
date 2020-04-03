ScriptName dse_mag_EffectTeleportDelete extends ActiveMagicEffect

String Property KeyTeleportLocations = "DSEMAG.TeleportLocations" AutoReadOnly Hidden
String Property KeyTeleportName = "DSEMAG.TeleportName" AutoReadOnly Hidden
Int Property MinimumDistance = 300 Auto

Event OnEffectStart(Actor Target, Actor Caster)

	Int Len = StorageUtil.FormListCount(Caster,self.KeyTeleportLocations)
	ObjectReference There

	While(Len > 0)
		Len -= 1

		There = StorageUtil.FormListGet(Caster,self.KeyTeleportLocations,Len) As ObjectReference
		If(There != None && There.GetDistance(Caster) < self.MinimumDistance)
			Len = 0

			StorageUtil.UnsetStringValue(There,self.KeyTeleportName)
			StorageUtil.FormListRemove(Caster,self.KeyTeleportLocations,There,TRUE)

			There.PlayGamebryoAnimation("mEnd")
			Utility.Wait(4)
			There.UnregisterForUpdate()
			There.Disable()
			There.Delete()
		EndIf
	EndWhile

	Return
EndEvent
