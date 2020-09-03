ScriptName dse_mag_EffectTeleportSelect extends ActiveMagicEffect

;; public members.
;; these must be set in the spell script properties in ck.

Activator Property TeleporterPad Auto
Form Property CostItemType Auto
Int Property CostItemQty = 0 Auto

;; private members.

dse_mag_ActiTeleportSelect Property Here Auto Hidden
String Property KeyTeleportLocations = "DSEMAG.TeleportLocations" AutoReadOnly Hidden
String Property KeyTeleportName = "DSEMAG.TeleportName" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Target, Actor Caster)

	String LocationName = "Somewhere"
	Location LocationPlace

	If(self.CostItemQty > 0 && self.CostItemType != None)
		If(Caster.GetItemCount(self.CostItemType) < self.CostItemQty)
			Debug.MessageBox("Without " + self.CostItemQty + " " + self.CostItemType.GetName() + " the spell fizzles away.")
			self.Dispel()
			Return
		EndIf

		Caster.RemoveItem(self.CostItemType,self.CostItemQty)
	EndIf

	LocationPlace = Caster.GetCurrentLocation()
	If(LocationPlace != None)
		LocationName = LocationPlace.GetName()
	EndIf

	self.Here = Caster.PlaceAtMe(TeleporterPad,1,TRUE,TRUE) As dse_mag_ActiTeleportSelect
	self.Here.SetPosition(self.Here.GetPositionX(),self.Here.GetPositionY(),(self.Here.GetPositionZ() + 10))
	self.Here.Temporary = TRUE
	self.Here.LifeTime = 60.0
	self.Here.Target = Caster
	self.Here.Delay = self.Here.DefaultDelay
	self.Here.SetAngle(0.0,0.0,Caster.GetAngleZ())

	StorageUtil.FormListAdd(Game.GetPlayer(),self.KeyTeleportLocations,Here,FALSE)
	StorageUtil.SetStringValue(Here,self.KeyTeleportName,"[Temporal Origin Rune: " + LocationName + "]")

	self.Here.Enable()
	Return
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

	If(self.Here != None)
		self.Here.Destroy()
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

