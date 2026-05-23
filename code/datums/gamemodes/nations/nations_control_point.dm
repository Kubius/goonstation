// Cargo cult from Pod Wars.
/datum/nations_control_point
	var/name = "Control Point"
	var/area/capture_area

	var/datum/game_mode/nations/mode
	var/datum/nation/owner_nation
	var/obj/nations_control_point_computer/computer

/datum/nations_control_point/New(obj/nations_control_point_computer/computer, area/capture_area, name, datum/game_mode/nations/mode)
	..()
	src.computer = computer
	computer.control_point = src
	src.capture_area = capture_area
	src.name = name
	src.mode = mode

/datum/nations_control_point/proc/capture(datum/nation/capturing_nation, mob/capturer, silent = FALSE)
	if (!istype(capturing_nation, /datum/nation))
		return

	var/datum/nation/former_nation
	if (src.owner_nation)
		former_nation = src.owner_nation
		former_nation.control_points -= src

	src.owner_nation = capturing_nation
	capturing_nation.control_points |= src

	if (length(src.capture_area.dynamic_map_colour_group))
		global.minimap_renderer.recolor_area(src.capture_area.dynamic_map_colour_group, src.owner_nation.nation_color)

	if (silent || !ismob(capturer))
		return

	message_ghosts("<b>[capturer]</b> successfully captured [src] for [capturing_nation.get_short_name()] [log_loc(src.computer, ghostjump=TRUE)].")

	var/capture_announcement = "[capturing_nation.get_short_name()] has captured [src][former_nation ? " from [former_nation.get_short_name()]" : ""]!"
	command_alert(capture_announcement, title = "Territory Captured!", sound_to_play = 'sound/machines/proximity_alarm.ogg', alert_origin = ALERT_UNITED_NATIONS)

/datum/nations_control_point/proc/neutralize(mob/neutralizer, silent = FALSE)
	if (src.owner_nation)
		src.owner_nation.control_points -= src
	src.owner_nation = null

	if (silent || !ismob(neutralizer))
		return

	message_ghosts("<b>[neutralizer]</b> successfully neutralized [src] [log_loc(src.computer, ghostjump=TRUE)].")

	var/neutralization_announcement = "[src] has been restored as a neutral territory!"
	command_alert(neutralization_announcement, title = "Territory Neutralized!", sound_to_play = 'sound/machines/proximity_alarm.ogg', alert_origin = ALERT_UNITED_NATIONS)

/obj/nations_control_point_computer
	name = "control point"
	desc = "A computer terminal; control of which determines the owner of this territory."
	icon = 'icons/obj/nations_control_point_computer.dmi'
	icon_state = "control_point_computer"
	density = 1
	anchored = ANCHORED

	/// Override area-based naming for the control point.
	var/control_point_name = ""
	var/list/control_area_typepaths

	/// As type path.
	var/datum/nation/roundstart_owner
	var/datum/nations_control_point/control_point

	var/image/screen_image
	var/image/screen_image_light

/obj/nations_control_point_computer/New()
	..()

	src.update_name()
	src.update_screen()

	START_TRACKING

/obj/nations_control_point_computer/disposing()
	STOP_TRACKING

	. = ..()

/obj/nations_control_point_computer/get_desc(dist, mob/user)
	. = ..()
	. += " It [src.control_point.owner_nation ? "is controlled by [src.control_point.owner_nation.get_short_name()]" : "is neutral territory"]."

/obj/nations_control_point_computer/ex_act()
	return

/obj/nations_control_point_computer/meteorhit(obj/O)
	return

/obj/nations_control_point_computer/proc/update_name()
	if (!src.control_point)
		return

	var/owner_short_name = src.control_point.owner_nation?.get_short_name()
	var/control_point_name = src.control_point.name
	src.name = "[length(owner_short_name) ? "[owner_short_name] " : ""]control point[length(control_point_name) ? " ([control_point_name])" : ""]"

/obj/nations_control_point_computer/proc/update_screen()
	var/screen_image_icon_state = ""
	var/list/final_light_color = list()

	if (istype(src.control_point?.owner_nation, /datum/nation))
		screen_image_icon_state = src.control_point.owner_nation.control_point_icon_state
		final_light_color = hex_to_rgb_list(src.control_point.owner_nation.nation_color)
	else
		screen_image_icon_state = "screen"
		final_light_color = hex_to_rgb_list("#ffffff")

	// There's no equivalent helper for getting an rgba list.
	final_light_color = list(final_light_color[1], final_light_color[2], final_light_color[3], 255)

	src.add_sm_light("screen_light", final_light_color)

	src.screen_image = image(src.icon, screen_image_icon_state)
	src.UpdateOverlays(src.screen_image, "screen_image")

	src.screen_image_light = image(src.icon, screen_image_icon_state)
	src.screen_image_light.plane = PLANE_LIGHTING
	src.screen_image_light.blend_mode = BLEND_ADD
	src.screen_image_light.layer = LIGHTING_LAYER_BASE
	src.UpdateOverlays(src.screen_image_light, "screen_image_light")

/obj/nations_control_point_computer/proc/capture(datum/nation/capturing_nation, mob/user, silent = FALSE)
	if (!capturing_nation || !capturing_nation.can_capture)
		src.control_point.neutralize(user, silent)
	else
		src.control_point.capture(capturing_nation, user, silent)
	src.update_name()
	src.update_screen()

/obj/nations_control_point_computer/attack_hand(mob/user)
	var/datum/nation/user_nation = src.control_point.mode.get_nation(user.mind)

	if (!istype(user_nation, /datum/nation))
		boutput(user, SPAN_ALERT("You can't think of anything else to do on this console..."))
		return

	if (!user_nation.can_capture && !src.control_point.owner_nation)
		if (user_nation.is_leader(user.mind))
			src.print_passport_slip(user, "This is already neutral territory.")
		else
			boutput(user, SPAN_ALERT("You are above such petty territorial squabbles!"))

		return

	if (user_nation == src.control_point.owner_nation)
		if (user_nation.is_leader(user.mind))
			src.print_passport_slip(user, "Your nation already owns this control point.")
		else
			boutput(user, SPAN_ALERT("Your nation already owns this control point!"))

		return

	var/duration = user_nation.is_leader(user.mind) ? 10 SECONDS : 20 SECONDS

	if (!ON_COOLDOWN(src, "ghostalert", 10 SECONDS))
		message_ghosts("<b>[user]</b> is trying to [user_nation.can_capture ? "capture" : "neutralize"] <b>[src]</b> [log_loc(src, ghostjump=TRUE)]!")

	var/datum/action/bar/icon/callback/nation_control/capture_actionbar = new /datum/action/bar/icon/callback/nation_control(
		user, src, duration, /obj/nations_control_point_computer/proc/capture, list(user_nation, user),\
		null, null, "[user] successfully enters [his_or_her(user)] command code into \the [src]!", null
	)
	actions.start(capture_actionbar, user)

/obj/nations_control_point_computer/proc/set_emergency_lights(is_on)
	for(var/obj/machinery/light/emergency/light in by_cat[TR_CAT_STATION_EMERGENCY_LIGHTS])
		var/area/A = get_area(light)
		if (A.type in src.control_area_typepaths)
			light.seton(is_on)
		LAGCHECK(LAG_LOW)

/obj/nations_control_point_computer/proc/emergency_lights_on()
	src.set_emergency_lights(TRUE)

/obj/nations_control_point_computer/proc/emergency_lights_off()
	src.set_emergency_lights(FALSE)

/obj/nations_control_point_computer/proc/print_passport_slip(mob/user, message)
	playsound(src, 'sound/machines/keyboard3.ogg', 30, TRUE)
	if (global.tgui_alert(user, "[message] Print a passport slip?", "Confirmation", list("Yes", "No")) != "Yes")
		return

	playsound(src, 'sound/machines/printer_thermal.ogg', 50, TRUE)
	SPAWN(3 SECONDS)
		new /obj/item/paper/passport_slip(get_turf(src))


/obj/nations_control_point_computer/clown
	roundstart_owner = /datum/nation/clown
	control_area_typepaths = list(
		/area/station/crew_quarters/clown,
		/area/station/maintenance/storage,
	)

/obj/nations_control_point_computer/engineering
	control_point_name = "Engineering"
	roundstart_owner = /datum/nation/engineering
	control_area_typepaths = list(
		/area/station/engine,
		/area/station/storage/tech,
		/area/station/maintenance/outer/east,
		/area/station/crewquarters/cryotron/eng,
		/area/station/security/checkpoint/east,
		/area/station/hangar/engine,
		/area/station/hallway/secondary/east,
		/area/station/crew_quarters/quarters_south,
		/area/station/crew_quarters/quartersB,
		/area/station/storage/emergencyinternals,
	)

/obj/nations_control_point_computer/medical
	control_point_name = "Medical"
	roundstart_owner = /datum/nation/medical
	control_area_typepaths = list(
		/area/station/medical,
		/area/station/security/checkpoint/medical,
		/area/station/hangar/medical,
		/area/station/storage/emergency,
		/area/station/crew_quarters/quartersA,
		/area/station/crew_quarters/quarters_west,
		/area/station/hallway/secondary/southwest,
		/area/station/hallway/secondary/west,
		/area/station/medical/head,
		/area/station/medical/head/private,
		/area/station/crewquarters/cryotron/med,
		/area/station/maintenance/outer/west,
	)

/obj/nations_control_point_computer/research
	control_point_name = "Research"
	roundstart_owner = /datum/nation/research
	control_area_typepaths = list(
		/area/station/science,
		/area/station/crew_quarters/hor/horprivate,
		/area/station/crew_quarters/hor,
		/area/station/hangar/science,
		/area/station/security/checkpoint/research,
		/area/station/maintenance/outer/south,
		/area/station/crew_quarters/tenebrae,
		/area/station/crew_quarters/quarters,
		/area/station/crewquarters/cryotron/sci,
		/area/station/storage/auxillary,
	)

/obj/nations_control_point_computer/service
	control_point_name = "Service"
	roundstart_owner = /datum/nation/service
	control_area_typepaths = list(
		/area/station/crew_quarters/pool,
		/area/station/crew_quarters/showers,
		/area/station/maintenance/north,
		/area/station/chapel,
		/area/station/storage/emergency2,
		/area/station/maintenance/north,
		/area/station/crew_quarters/baroffice,
		/area/station/crew_quarters/catering,
		/area/station/crew_quarters/kitchen/freezer,
		/area/station/crew_quarters/fitness,
		/area/station/hallway/secondary/construction,
		/area/station/crew_quarters/toilets,
		/area/station/crewquarters/cryotron/civ,
		/area/station/maintenance/outer/north,
		/area/station/security/checkpoint/chapel,
		/area/station/hangar/catering,
		/area/station/hydroponics,
		/area/station/storage/hydroponics,
		/area/station/ranch,
		/area/station/crew_quarters/hop,
		/area/station/janitor/office,
		/area/station/crew_quarters/quarters_north,
		/area/station/hallway/secondary/north,
		/area/station/hallway/secondary/northwest,
	)

/obj/nations_control_point_computer/supply
	control_point_name = "Supply"
	roundstart_owner = /datum/nation/supply
	control_area_typepaths = list(
		/area/station/quartermaster,
		/area/station/mining,
		/area/station/storage/northeast,
		/area/station/crew_quarters/quartersC,
		/area/station/crewquarters/cryotron/cargo,
		/area/station/hallway/secondary/northeast,
		/area/station/storage/warehouse,
		/area/station/hangar/qm,
		/area/station/maintenance/northeast,
		/area/station/security/checkpoint/cargo,
		/area/station/crew_quarters/quarters_east,
		/area/station/maintenance/outer/ne,
	)

/datum/action/bar/icon/callback/nation_control
	var/obj/nations_control_point_computer/my_computer

	New(owner, target, duration, proc_path, proc_args, icon, icon_state, end_message, interrupt_flags, call_proc_on)
		. = ..()
		src.my_computer = target

	onUpdate()
		. = ..()
		if (!ON_COOLDOWN(src.my_computer, "capture_alarm", 4 SECONDS))
			playsound(src.my_computer, 'sound/machines/warning-buzzer.ogg', 150, FALSE, flags = SOUND_IGNORE_SPACE)

	onStart()
		. = ..()
		src.my_computer.emergency_lights_on()

	onInterrupt(flag)
		. = ..()
		src.my_computer.emergency_lights_off()

	onEnd()
		. = ..()
		src.my_computer.emergency_lights_off()
