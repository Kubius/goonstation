TYPEINFO(/obj/effects/menhir_fog)
	var/list/connects_to = null
TYPEINFO_NEW(/obj/effects/menhir_fog)
	. = ..()
	connects_to = typecacheof(list(/obj/effects/menhir_fog))
///Menhir's "fog of war". Provides an (imperfect) visual shroud to somewhat preserve the mystique of the Crown.
/obj/effects/menhir_fog
	name = "peculiar fog"
	desc = "Something has chosen not to be seen."
	icon = 'icons/effects/fogofwar.dmi'
	layer = 3.9
	mouse_opacity = 1
	anchored = ANCHORED
	invisibility = INVIS_FLOCK //selected so as not to block out AI more than for any particular lore implication
#ifdef IN_MAP_EDITOR
	icon_state = "editor"
#else
	icon_state = "0"
#endif

	New()
		..()
		if (current_state > GAME_STATE_WORLD_NEW)
			SPAWN(0)
				src.UpdateIcon()
				if(istype(src))
					src.update_neighbors()
		else
			worldgenCandidates += src

	proc/generate_worldgen()
		src.UpdateIcon()

	update_icon()
		var/typeinfo/turf/simulated/wall/auto/tpnf = get_typeinfo()
		var/connectdir = get_connected_directions_bitflag(tpnf.connects_to, null, connect_diagonal = 1)
		var/the_state = "[connectdir]"
		src.icon_state = the_state

	proc/update_neighbors()
		for (var/obj/effects/menhir_fog/mfog in orange(1,src))
			mfog.UpdateIcon()

//convenient shorthand for don't blow up this floor
/turf/simulated/floor/shuttle/menhir_arm
	name = "blue floor"
	desc = "This floor looks awfully strange."
	icon = 'icons/misc/worlds.dmi'
	pryable = FALSE
#ifdef IN_MAP_EDITOR
	icon_state = "old_floor2"
#else
	icon_state = "bluefloor"
#endif

/area/station/crown // stole this code from the void definition
	name = "The Crown"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/setpieces/bluefloor"
	sound_environment = 5
	sound_loop = 'sound/ambience/industrial/Precursor_Drone1.ogg'
	teleport_blocked = 2
	do_not_irradiate = 1
	requires_power = FALSE

/area/station/crown/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/station/crown/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/station/crown/area_process()
	if(prob(20))
		var/weirdnoise = pick('sound/ambience/industrial/Precursor_Drone2.ogg',\
			'sound/ambience/industrial/Precursor_Choir.ogg',\
			'sound/ambience/industrial/Precursor_Drone3.ogg',\
			'sound/ambience/industrial/Precursor_Bells.ogg')

		var/turf/noisy_turf = pick(get_area_turfs(/area/station/crown))
		playsound(noisy_turf, weirdnoise, 70, 1)

#ifdef MAP_OVERRIDE_MENHIR

/client/proc/cmd_admin_vislayer()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Menhir Visibility Toggle"
	set desc = "Alters your see_invisible layer to allow slipping below Menhir's \"fog of war\"."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!ismob(usr))
		return

	var/activated = FALSE
	if(usr.see_invisible == INVIS_AI_EYE)
		usr.see_invisible = INVIS_SPOOKY // this could revert to a saved pre-change state eventually
	else
		usr.see_invisible = INVIS_AI_EYE // highest level that's still beneath the fog
		activated = TRUE

	boutput(usr, SPAN_NOTICE("<b>Vision [activated ? "altered." : "restored to default."]</b>"))

	logTheThing(LOG_ADMIN, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.")
	logTheThing(LOG_DIARY, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.", "admin")
	message_admins("[key_name(usr)] has [(activated ? "activated" : "deactivated")] see_invisible override.")

#endif

