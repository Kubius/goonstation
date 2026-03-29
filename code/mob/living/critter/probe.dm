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
	say_language = LANGUAGE_CUBIC
	flags = TABLEPASS | DOORPASS

	health_brute = 100
	health_burn = 100
	use_stamina = FALSE
	can_lie = FALSE
	can_burn = FALSE
	isFlying = 1
	base_move_delay = 1.5
	base_walk_delay = 3.5

	is_npc = TRUE
	ai_type = /datum/aiHolder/probe
	add_abilities = list(/datum/targetable/critter/flash,/datum/targetable/critter/fadeout/drone)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	emp_act()
		return

	New()
		. = ..()
		src.name = "[pick("peculiar","quirky","strange","cold","intricate","odd")] [pick("visage","proxy","interface","attendant")]"
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

/datum/aiHolder/probe
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/probe, list(src))

/datum/aiTask/prioritizer/critter/probe/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/probe_idle, list(src.holder, src))

/datum/aiTask/timed/probe_idle
	name = "observing"
	minimum_task_ticks = 35
	maximum_task_ticks = 50

/datum/aiTask/timed/probe_idle/evaluate()
	. = 1

/datum/aiTask/timed/probe_idle/on_tick()
	if(prob(30))
		holder.owner.move_dir = pick(cardinal)
		holder.owner.process_move()
		holder?.stop_move()
		holder?.owner.move_dir = null
	else
		holder.owner.dir = pick(cardinal)
		if(prob(30))
			playsound(holder.owner.loc, 'sound/machines/scan2.ogg', 30, 0, pitch = 0.6)
