/obj/effects/menhir_fog
	name = "fog of war"
	layer = 3.1
	invisibility = INVIS_AI_EYE
#ifdef IN_MAP_EDITOR
	icon_state = "fpart"
#else
	icon_state = "dark"
#endif

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
		usr.see_invisible = initial(usr.see_invisible)
	else
		usr.see_invisible = 7
		activated = TRUE

	boutput(usr, SPAN_NOTICE("<b>Vision [activated ? "altered." : "restored to default."]</b>"))

	logTheThing(LOG_ADMIN, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.")
	logTheThing(LOG_DIARY, usr, "has [(activated ? "activated" : "deactivated")] see_invisible override.", "admin")
	message_admins("[key_name(usr)] has [(activated ? "activated" : "deactivated")] see_invisible override.")
