/obj/machinery/door/unpowered/blue
	icon = 'icons/obj/doors/newblue.dmi';
	name = "glowing edifice"
	desc = "You can faintly make out a pattern of fissures and glowing seams along the surface."
	icon_state = "door1"
	opacity = 1
	density = 1
	hardened = 1
	var/friendly_object = null
	var/friend_obj_is_precursor = TRUE

	New()
		. = ..()
		if(src.friendly_object)
			src.locked = TRUE

	attackby(obj/item/W, mob/user)
		..()
		if(src.locked && src.friendly_object)
			if(istype(W,/obj/item/artifact) && friend_obj_is_precursor)
				if(!W.artifact.artitype.name == "precursor")
					user.visible_message(SPAN_ALERT("[src] sounds oddly hollow as it's struck."))
					return
			else if(!istype(W,src.friendly_object))
				user.visible_message(SPAN_ALERT("[src] sounds oddly hollow as it's struck."))
				return
			user.visible_message(SPAN_NOTICE("<B>[src] [pick("rings", "dings", "chimes","vibrates","oscillates")] [pick("faintly", "softly", "loudly", "weirdly", "scarily", "eerily")].</B>"))
			var/door_note = 'sound/musical_instruments/WeirdChime_0.ogg'
			playsound(src.loc, door_note, 60, 0)
			src.locked == FALSE


/obj/machinery/door/unpowered/blue/open()
	. = ..()
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)

/obj/machinery/door/unpowered/blue/close()
	. = ..()
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
