Scriptname _deathMarkerAshPile extends Actor  

float property fDelay = 0.75 auto
									{time to wait before Spawning Ash Pile}
float property fDelayEnd = 1.65 auto
									{time to wait before Removing Base Actor}
float property ShaderDuration = 0.00 auto
									{Duration of Effect Shader.}
Activator property AshPileObject auto
									{The object we use as a pile.}
EffectShader property MagicEffectShader auto
									{The Effect Shader we want.}
Bool property bSetAlphaZero = True auto
									{The Effect Shader we want.}
Bool property bSetAlphaToZeroEarly = False Auto
									{Use this if we want to set the acro to invisible somewhere before the effect shader is done.}
_RespawnScript property respawnScript auto
									
Event OnDeath(Actor Killer)
			
		Self.SetCriticalStage(self.CritStage_DisintegrateStart)
			if	MagicEffectShader != none
				MagicEffectShader.play(Self,ShaderDuration)
			endif
			if bSetAlphaToZeroEarly
				Self.SetAlpha (0.0,True)
			endif
		utility.wait(fDelay)     
		Self.AttachAshPile(AshPileObject)
		utility.wait(fDelayEnd)
			if	MagicEffectShader != none
				MagicEffectShader.stop(Self)
			endif
			if bSetAlphaZero == True
				Self.SetAlpha (0.0,True)
			endif
		Self.SetCriticalStage(Self.CritStage_DisintegrateEnd)
		Utility.Wait(3600) ; Wait 1 hour before ash pile disappears.
		
EndEvent