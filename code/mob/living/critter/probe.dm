///Precursor probe for Menhir random events
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
	say_language = LANGUAGE_CUBIC //if you're piloting one of these for gimmicks you don't want to ruin the bit by accident
	flags = TABLEPASS
	hand_count = 1

	health_brute = 100
	health_burn = 100
	use_stamina = FALSE
	can_lie = FALSE
	can_burn = FALSE
	isFlying = 1
	base_move_delay = 1.5
	base_walk_delay = 3.5
	var/disturbed = FALSE //we'd like to probe quietly. you get one oops.
	var/bonked = FALSE //being bonked is frustrating.

	var/tmp/turf/deployment_turf = null

	is_npc = TRUE
	ai_type = /datum/aiHolder/probe
	add_abilities = list(/datum/targetable/critter/flash,/datum/targetable/critter/fadeout/drone)

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.name = "gravitational projector"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.limb_name = "gravitational projector"
		HH.can_hold_items = 1

	emp_act()
		return

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		src.bonked = TRUE
		..()

	New()
		. = ..()
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE, src)
		src.remove_lifeprocess("gravity")
		src.deployment_turf = get_turf(src)
		src.name = "[pick("peculiar","quirky","strange","cold","intricate","odd","curious")] [pick("visage","proxy","interface","attendant")]"
		src.UpdateIcon()

	disposing()
		src.exit_procedure()
		. = ..()

	proc/exit_procedure()
		if(!src.oldmob && !src.disturbed && prob(42)) //drones which complete their probing without being disturbed may leave a gift
			playsound(src.loc, 'sound/effects/ring_happi.ogg', 35, 0, extrarange = 16, pitch = 0.6)
			var/list/gifts = list(/obj/item/reagent_containers/food/snacks/cube = 20, /obj/item/raw_material/cobryl = 12,\
				/obj/item/raw_material/miracle = 2, "artifact" = 1)
			var/thing2make = weighted_pick(gifts)
			if(ispath(thing2make))
				new thing2make(src.loc)
			else
				Artifact_Spawn(src.loc,forceartiorigin = "precursor")

/datum/projectile/laser/light/longrange/salvo
	shot_number = 5
	shot_volume = 55

/datum/limb/gun/energy/probe_light
	proj = new/datum/projectile/laser/light/longrange/salvo
	shots = 1
	current_shots = 1
	cooldown = 1 SECOND
	reload_time = 1 SECOND

///Bigger, more capable probe powered by what may or may not be a pocket singularity
/mob/living/critter/robotic/probe/arbitor
	name = "cold proxy"
	desc = "A faint shimmer continually courses over its surface."
	icon_state = "arbitor"
	flags = TABLEPASS | DOORPASS
	hand_count = 2

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/gun/energy/probe_light
		HH.name = "particle reallocator"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "lens"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	exit_procedure()
		return

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
	var/tmp/turf/last_cycle_turf = null

/datum/aiTask/timed/probe_idle/evaluate()
	. = 1

/datum/aiTask/timed/probe_idle/on_tick()
	var/mob/living/critter/robotic/probe/beepity = holder.owner
	if(!istype(beepity)) return
	var/turf/currentspot = get_turf(beepity)
	var/preflight = FALSE
	if(last_cycle_turf && beepity.deployment_turf && beepity.type == /mob/living/critter/robotic/probe)
		preflight = TRUE
	if(preflight && (GET_DIST(currentspot,last_cycle_turf) > 4 || beepity.bonked))
		var/returning = FALSE
		if(GET_DIST(currentspot,beepity.deployment_turf) > 4) returning = TRUE
		if(!beepity.disturbed)
			beepity.visible_message(SPAN_ALERT("<b>[beepity]<b> makes an irritated sound. It doesn't seem to like being shoved around."))
			playsound(beepity.loc, 'sound/effects/elec_bzzz.ogg', 40, 0, pitch = 0.5)
			beepity.disturbed = TRUE
		else
			beepity.visible_message(SPAN_ALERT("<b>[beepity] emits a searing flash[returning ? " as it teleports away" : null]!<b>"))
			for (var/mob/living/L in orange(3,beepity))
				random_burn_damage(L, rand(4,10))
				if (istype(L))
					L.flash(3 SECONDS)
					L.apply_flash(60, 0, misstep = 35, stamina_damage = 200)
			playsound(beepity.loc, 'sound/weapons/flashbang.ogg', 30, 1)
		if(returning)
			SPAWN(2)
				showswirl_out(get_turf(beepity))
				beepity.set_loc(beepity.deployment_turf)
				showswirl(beepity.deployment_turf)
			last_cycle_turf = beepity.deployment_turf
		beepity.bonked = FALSE
	else
		if(prob(30))
			beepity.move_dir = pick(cardinal)
			beepity.process_move()
			holder?.stop_move()
			holder?.owner.move_dir = null
		else
			beepity.dir = pick(cardinal)
			if(prob(30))
				playsound(beepity.loc, 'sound/machines/scan2.ogg', 40, 0, pitch = 0.6)
		last_cycle_turf = currentspot
