ScriptName dse_mag_ActiTeleportSelect extends ObjectReference

String Property KeyTeleportLocations = "DSEMAG.TeleportLocations" AutoReadOnly Hidden
String Property KeyTeleportName = "DSEMAG.TeleportName" AutoReadOnly Hidden
String Property KeyTeleportEvent = "DSEMAG.TeleportTrigger" AutoReadOnly Hidden

EffectShader Property TeleportEffect Auto
ObjectReference Property Waypoint Auto Hidden
Bool Property RestoreFirstPerson Auto Hidden

Actor Property Target Auto Hidden
Bool Property Temporary = FALSE Auto Hidden
Float Property Delay = -1.0 Auto Hidden
Float Property DefaultDelay = 2.0 AutoReadOnly Hidden

Event OnLoad()

	If(self != None && self.Delay > 0.0 && self.Target != None)
		Debug.Trace("[DWMAG] ActiTeleportSelect.OnLoad " + self.Delay + " " + self.Target)
		self.RegisterForSingleUpdate(self.Delay)
	EndIf

	Return
EndEvent

Event OnUpdate()
	self.Activate(self.Target)
	Return
EndEvent

Event OnActivate(ObjectReference What)

	Actor Who = What As Actor

	If(Who == None)
		Return
	EndIf

	self.Waypoint = self.MenuTeleportList(Who) As ObjectReference
	self.RestoreFirstPerson = (Game.GetCameraState() == 0)

	If(self.Waypoint != None)
		self.RegisterForAnimationEvent(Who,self.KeyTeleportEvent)
		Game.DisablePlayerControls()
		Game.SetPlayerAIDriven(TRUE)
		Game.ForceThirdPerson()

		If(Who.IsWeaponDrawn())
			Who.SheatheWeapon()
			Utility.Wait(2.5)
		EndIf

		Who.MoveTo(self)
		self.TeleportEffect.Play(Who,8.0)		
		Debug.SendAnimationEvent(Who,"dse-mag-teleport01-a1")

		If(self.Temporary)
			
		EndIf
	Else
		Debug.Notification("[DSEMAG] Waypoint not found.")
	EndIf

	Return
EndEvent

Event OnAnimationEvent(ObjectReference What, String EventName)

	If(EventName == self.KeyTeleportEvent)
		self.UnregisterForAnimationEvent(What,EventName)
		What.MoveTo(self.Waypoint)
		self.TeleportEffect.Stop(What)
		Game.SetPlayerAIDriven(FALSE)
		Game.EnablePlayerControls()

		If(self.RestoreFirstPerson)
			Game.ForceFirstPerson()
		EndIf

		If(self.Temporary)
			self.Destroy()
		EndIf
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Destroy()

	self.PlayGamebryoAnimation("mEnd")
	Utility.Wait(4.0)
	self.Disable()
	self.Delete()

	Return
EndFunction

Function WowManuallyImplementedSyncedSort(Form[] ItemList, String[] ItemName)
{setting UIListMenu sort property to TRUE not only does not sort items but it
also makes the items unselectable. so now i've had to implement my own bubble
sort that will keep these two lists in sync lol.}

	Form TmpForm
	String TmpName
	Int Iter
	Bool Changed = TRUE

	While(Changed)
		Iter = 0
		Changed = FALSE

		While(Iter < (ItemList.Length - 1))

			If(ItemName[Iter] > ItemName[(Iter+1)])
				TmpForm = ItemList[Iter]
				TmpName = ItemName[Iter]
				ItemList[Iter] = ItemList[(Iter+1)]
				ItemName[Iter] = ItemName[(Iter+1)]
				ItemList[(Iter+1)] = TmpForm
				ItemName[(Iter+1)] = TmpName
				Changed = TRUE
			EndIf

			Iter += 1
		EndWhile
	EndWhile

	Return
EndFunction

Form Function MenuTeleportList(Actor Who)

	Int Result = 0
	Int Len = 0
	Form[] TeleportList = StorageUtil.FormListToArray(Who,self.KeyTeleportLocations)
	String[] TeleportNames = Utility.CreateStringArray(TeleportList.Length)

	If(TeleportList.Length == 0)
		Debug.MessageBox(Who.GetDisplayName() + " has no teleport locations yet.")
		Return None
	EndIf

	Len = TeleportList.Length
	While(Len > 0)
		Len -= 1
		TeleportNames[Len] = StorageUtil.GetStringValue(TeleportList[Len],self.KeyTeleportName)
	EndWhile

	self.WowManuallyImplementedSyncedSort(TeleportList,TeleportNames)

	;;;;;;;;

	Result = self.MenuFromList(TeleportNames)

	If(Result < 0)
		Return None
	EndIf

	Return TeleportList[Result]
EndFunction

Int Function MenuFromList(String[] Items)
{display a list from an array of items.}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1
	Int Iter = 0
	Int Result

	;;;;;;;;

	While(Iter < Items.Length)
		Menu.AddEntryItem(Items[Iter],NoParent)
		Iter += 1
	EndWhile

	;;;;;;;;

	Menu.SetPropertyBool("sort",FALSE)
	Menu.OpenMenu()
	Result = Menu.GetResultInt()

	If(Result < 0)
		Return -1
	EndIf

	Return Result
EndFunction
