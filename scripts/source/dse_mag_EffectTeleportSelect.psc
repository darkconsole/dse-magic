ScriptName dse_mag_EffectTeleportSelect extends ActiveMagicEffect

;; public members.
;; these must be set in the spell script properties in ck.

Activator Property TeleporterPad Auto
Form Property CostItemType Auto
Int Property CostItemQty = 0 Auto

;; private members.

dse_mag_ActiTeleportSelect Property Here Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Target, Actor Caster)

	If(self.CostItemQty > 0 && self.CostItemType != None)
		If(Caster.GetItemCount(self.CostItemType) < self.CostItemQty)
			Debug.MessageBox("Without " + self.CostItemQty + " " + self.CostItemType.GetName() + " the spell fizzles away.")
			self.Dispel()
			Return
		EndIf

		Caster.RemoveItem(self.CostItemType,self.CostItemQty)
	EndIf

	self.Here = Caster.PlaceAtMe(TeleporterPad,1,TRUE,TRUE) As dse_mag_ActiTeleportSelect
	self.Here.Temporary = TRUE
	self.Here.Target = Caster
	self.Here.Delay = self.Here.DefaultDelay
	self.Here.SetAngle(0.0,0.0,Caster.GetAngleZ())
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

