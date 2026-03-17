TYPEINFO(/obj/effects/menhir_fog)
	var/list/connects_to = null
TYPEINFO_NEW(/obj/effects/menhir_fog)
	. = ..()
	connects_to = typecacheof(list(/obj/effects/menhir_fog))
/obj/effects/menhir_fog
	name = "fog of war"
	icon = 'icons/effects/fogofwar.dmi'
	layer = 3.1
	anchored = ANCHORED
	invisibility = INVIS_AI_EYE
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
	if(usr.see_invisible == 7)
		usr.see_invisible = INVIS_SPOOKY //this should revert to a saved pre-change state eventually
	else
		usr.see_invisible = 7
		activated = TRUE

	boutput(usr, SPAN_NOTICE("<b>Vision [activated ? "altered." : "restored to default."]</b>"))

	logTheThing(LOG_ADMIN, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.")
	logTheThing(LOG_DIARY, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.", "admin")
	message_admins("[key_name(usr)] has [(activated ? "activated" : "deactivated")] see_invisible override.")
#endif
