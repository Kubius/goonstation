/mob/living/critter/robotic/probe
	name = "curious visage"
	desc = "It hovers in much the same way that bricks don't."
	icon = 'icons/mob/critter/robotic/precursor_drone.dmi'
	icon_state = "drone"
	voice_name = "strange voice"
	speech_verb_say = "intones"
	speech_verb_exclaim = "reverberates"
	speech_verb_ask = "inquires"
	speech_verb_gasp = "screeches"
	speech_verb_stammer = "stutters"
	//may want gib handler?
	mat_changename = FALSE
	mat_changedesc = FALSE
	see_invisible = INVIS_CLOAK

	health_brute = 100
	health_burn = 100
	use_stamina = FALSE
	can_lie = FALSE
	can_burn = FALSE
	isFlying = 1

	is_npc = TRUE
	ai_type = /datum/aiHolder/wanderer/floor_only
	add_abilities = list(/datum/targetable/critter/flash)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	emp_act()
		return

	New()
		. = ..()
		src.UpdateIcon()

/mob/living/critter/robotic/probe/update_icon()
	if (isalive(src))
		var/hover = FALSE
		if(src.client || (src.ai && src.ai.enabled)) hover = TRUE
		src.icon_state = "[initial(icon_state)][hover ? null : "-inactive"]"
		if(hover)
			var/image/glow = SafeGetOverlayImage("activeglow", 'icons/mob/critter/robotic/precursor_drone.dmi', "[initial(icon_state)]-glow", MOB_OVERLAY_BASE)
			glow.plane = PLANE_SELFILLUM
			glow.appearance_flags |= RESET_COLOR
			src.UpdateOverlays(glow,"activeglow")
		else
			src.ClearSpecificOverlays("activeglow")
	else
		src.icon_state = "[initial(icon_state)]-dead"
		src.ClearSpecificOverlays("activeglow")
