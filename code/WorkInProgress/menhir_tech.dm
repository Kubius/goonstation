/obj/effects/menhir_fog
	name = "fog of war"
	icon = 'icons/effects/fogofwar.dmi'
	layer = 3.1
	invisibility = INVIS_AI_EYE
#ifdef IN_MAP_EDITOR
	icon_state = "editor"
#else
	icon_state = "0"
#endif

	New()
		..()
		SPAWN(1)
			src.UpdateIcon()
			if(istype(src))
				src.update_neighbors()

	update_icon()
		var/connectdir = get_connected_directions_bitflag(list(/obj/effects/menhir_fog), cross_areas = TRUE, connect_diagonal = 1, turf_only = FALSE)
		var/the_state = "[connectdir]"
		src.icon_state = the_state

	proc/update_neighbors()
		for (var/obj/effects/menhir_fog/mfog in orange(1,src))
			mfog.UpdateIcon()


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
