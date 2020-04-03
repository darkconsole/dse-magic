ScriptName dse_mag_EffectTeleportRegister extends ActiveMagicEffect

Activator Property MarkerTeleportLocation Auto
String Property KeyTeleportLocations = "DSEMAG.TeleportLocations" AutoReadOnly Hidden
String Property KeyTeleportName = "DSEMAG.TeleportName" AutoReadOnly Hidden
Int Property MinimumDistance = 300 Auto Hidden

Form Property CostItemType Auto
Int Property CostItemQty = 0 Auto

Event OnEffectStart(Actor Target, Actor Caster)

	Actor Player = Caster
	ObjectReference Here
	ObjectReference There
	String LocationName = ""
	Location LocationPlace

	Int Iter
	Int Len

	;;;;;;;;

	If(self.CostItemQty > 0 && self.CostItemType != None)
		If(Caster.GetItemCount(self.CostItemType) < self.CostItemQty)
			Debug.MessageBox("This spell requires " + self.CostItemQty + " x " + self.CostItemType.GetName())
			self.Dispel()
			Return
		EndIf

		Caster.RemoveItem(self.CostItemType,self.CostItemQty)
	EndIf

	;;;;;;;;

	Here = Player.PlaceAtMe(self.MarkerTeleportLocation,1,TRUE,TRUE)

	;; do some cleanup on the registered point list in case something to deleted
	;; somehow or something.

	StorageUtil.FormListRemove(Player,self.KeyTeleportLocations,NONE,TRUE)

	;; first lets determine if this marker is actually really close to an existing one.
	;; if it is then we are actually going to move the existing one instead.

	Iter = 0
	Len = StorageUtil.FormListCount(Player,self.KeyTeleportLocations)

	While(Iter < Len)
		There = StorageUtil.FormListGet(Player,self.KeyTeleportLocations,Iter) As ObjectReference

		If(There != None)
			If(Here.GetDistance(There) < self.MinimumDistance)
				There.MoveTo(Here)
				
				Here.Disable()
				Here.Delete()

				Here = There
				Iter = Len
			EndIf
		EndIf

		Iter += 1
	EndWhile

	;; next we will register the waypoint, it is now ready to go.

	LocationPlace = Caster.GetCurrentLocation()
	If(LocationPlace != None)
		LocationName = LocationPlace.GetName()
	EndIf

	LocationName = self.MenuTextInput(LocationName)


	Here.SetAngle(0.0,0.0,Caster.GetAngleZ())
	Here.Enable()
	Here.RegisterForUpdate(900)
	StorageUtil.FormListAdd(Player,self.KeyTeleportLocations,Here,FALSE)
	StorageUtil.SetStringValue(Here,self.KeyTeleportName,LocationName)

	Return
EndEvent

String Function MenuTextInput(String DefaultText)
{rename this animal.}

	String Result

	UIExtensions.InitMenu("UITextEntryMenu")
	UIExtensions.SetMenuPropertyString("UITextEntryMenu","text",DefaultText)
	UIExtensions.OpenMenu("UITextEntryMenu")
	Result = UIExtensions.GetMenuResultString("UITextEntryMenu")

	Return Result
EndFunction