Scriptname dse_mag_BookTeleportSpells extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto

Spell Property SpellRegister Auto
Spell Property SpellScrub Auto
Spell Property SpellOrigin Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnRead()

	If(!self.Player.HasSpell(self.SpellRegister))
		self.Player.AddSpell(self.SpellRegister)
	EndIf

	If(!self.Player.HasSpell(self.SpellScrub))
		self.Player.AddSpell(self.SpellScrub)
	EndIf

	If(!self.Player.HasSpell(self.SpellOrigin))
		self.Player.AddSpell(self.SpellOrigin)
	EndIf

	Return
EndEvent
