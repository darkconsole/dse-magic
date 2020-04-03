Scriptname dse_mag_ProjectilesFromTheHeavens extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; form references ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Static Property FormMarker Auto
{set this to the XMarker in the game, and invisible placeholder.}

Spell Property FormSpellProjectile Auto
{the projectile spell we will cast down from the heavens.}

Hazard Property FormHazard Auto
{the Hazard object that renders the ground effect showing where the projectiles
will be cast. the Hazard can also do other things like cast spells on people in
it remember.}

Perk Property FormTrackingPerk Auto
{the perk that grants tracking ability for this spell.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property Radius = 100 Auto
{Default: 100u - the radius of error in targeting the projectile.}

String Property ProjSkill = "Destruction" Auto
{Default: Destruction - what skill can increase the projectile count.}

Float Property ProjSkillDivisor = 33.3 Auto
{Deafult: 33.3 - how many levels of the skill are required for another projectile.}

Int Property ProjCount = 1 Auto
{Default: 1 - how many projectiles should be shot.}

Float Property ProjDelayLow = 0.25 Auto
{Default: 0.25s - soonest a projectile should come after the previous randomised between High.}

Float Property ProjDelayHigh = 0.75 Auto
{Default: 0.75s - latest a projectile should come after the previous randomised between Low.}

Float Property ProjHeight = 5000.0 Auto
{Deafult: 5000.0u - how far up the projectiles should come from.}

Float Property ScriptCleanupDelay = 4.0 Auto
{Default: 4.0s - how long after firing the last projectile before this script
should clean itself up and vanish. if you are throwing slow projectiles you may
need to increase this - if the emitters are deleted before the projectile hits
they will not have their damage calculated.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stat tracking ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_mag_QuestStats Property StatQuest Auto
{stat tracking quest.}

String Property StatNameCast = "None" Auto
{name of the stat to track for each casting.}

String Property StatNameProj = "None" Auto
{name of the stat to track for each projectile.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; internal properties ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Property Raining = FALSE Auto Hidden
ObjectReference Property Emitter = None Auto Hidden
ObjectReference Property Area = None Auto Hidden
ObjectReference Property Target = None Auto Hidden
Actor Property Caster = None Auto Hidden
Actor Property Player = None Auto Hidden

Event OnLoad()

	If(self.Raining)
		;; the reason for this was amazing. it turns out that every time
		;; the spawner is moved, that will re-trigger the OnLoad event.
		;; i spent like 3 days trying to figure out why my rainstorms would
		;; last for infinity, slowly increase in intensity, and slowly drift
		;; across the plain, until the game gave up and crashed.
		Return
	EndIf
	self.Raining = TRUE

	If(self.IsInInterior())
		;; if we are inside you cannot use this spell. at least not unless
		;; someone invents a way to have them smash through roofs lol.
		self.Disable()
		self.Delete()
		Return
	EndIf

	;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;

	self.Caster = Game.GetPlayer()
	self.Player = Game.GetPlayer()

	;; yes, i know. what i have not figured out yet is how to determine the
	;; source that placed this activator (the explosion). the game knows
	;; that you should get credit for the explosion, but it doesn't do anything
	;; smart like SetActorOwner on this activator for you to know who caused
	;; it. but i am writing this script in a way so that when i do figure
	;; something out for this, one line is all that will need to be changed.
	;; i have not devoted as much time as i should to figure this out but most
	;; of the time the player will be the only one casting this custom spell
	;; anyway unless someone goes out of their way to teach it to a follower.

	Int Iter
	Float[] PosMod = new Float[2]

	;; give credit for the casting.

	If(self.StatQuest != None && self.Caster == self.Player)
		self.StatQuest.Bump(self.StatNameCast,1)
	EndIf

	;; place the aoe visuals

	If(self.FormHazard != None)
		self.Area = self.PlaceAtMe(self.FormHazard,1,FALSE,FALSE)
	Else
		self.Area = self.PlaceAtMe(self.FormMarker,1,FALSE,FALSE)
	EndIf

	;; scale number of projectiles with destruction level.
	;; you get another meteor at 34, 67, 100, etc.

	self.ProjCount += Math.floor(Caster.GetActorValue(self.ProjSkill) / self.ProjSkillDivisor) 

	;; determine where/what we want to throw projectiles at.

	If(Caster.HasPerk(self.FormTrackingPerk))
		;; find the nearest actor to track them.
		Target = Game.FindClosestActorFromRef(self.Area,self.Radius) as ObjectReference
	EndIf

	If(self.Target == None)
		;; target our area point if none selected.
		self.Target = self.Area
	EndIf

	;; place the emitter way up high.

	self.Emitter = self.PlaceAtMe(self.FormMarker,1,FALSE,FALSE)
	self.Emitter.MoveTo(self,0,0,self.ProjHeight)
	
	Iter = 0
	While(Iter < self.ProjCount)

		;; move the emitter and activator around, offsetting their positions
		;; from eachother so that if we are using physical projectiles like
		;; arrows they do not bounce perfectly right back straight up if they
		;; hit a rock because it looked super stupid when they all do it.

		PosMod[0] = Utility.RandomInt(-self.Radius,self.Radius)
		PosMod[1] = Utility.RandomInt(-self.Radius,self.Radius)

		;; using the target location for the aim fuzzing will allow us to create
		;; a moving cloud of fuck over a tracked target if the target is indeed
		;; one which is moving.

		self.SetPosition((self.Target.X + PosMod[0]),(self.Target.Y + PosMod[1]),self.Target.Z)
		self.Emitter.MoveTo(self,(-PosMod[0]*2),(-PosMod[1]*2),self.ProjHeight)

		;; cast spell which shoots projectiles at target.

		self.FormSpellProjectile.RemoteCast(self.Emitter,self.Caster,self)

		;; get credit for the meteor.

		If(self.StatQuest != None && self.Caster == self.Player)
			self.StatQuest.Bump(self.StatNameProj,1)
		EndIf

		;; randomise how fast they come down.

		Utility.Wait(Utility.RandomFloat(self.ProjDelayLow,self.ProjDelayHigh))
		Iter += 1
	EndWhile

	;; if the emitters are deleted before a projectile hits, the projectile will
	;; not have its damage applied on hit! i spent so long debugging this omg.

	Utility.Wait(self.ScriptCleanupDelay)

	;; and finally gtfo.

	If(self.FormHazard == None)
		;; hazards take care of themselves. markers do not.
		self.Area.Disable()
		self.Area.Delete()
	EndIf

	self.Emitter.Disable()
	self.Emitter.Delete()

	self.Disable()
	self.Delete()

	Return
EndEvent
