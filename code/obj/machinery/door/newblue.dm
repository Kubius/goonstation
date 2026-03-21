/obj/machinery/door/unpowered/blue
	icon = 'icons/obj/doors/newblue.dmi';
	name = "glowing edifice"
	desc = "You can faintly make out a pattern of fissures and glowing seams along the surface."
	icon_state = "door1"
	opacity = 1
	density = 1
	hardened = 1

/obj/machinery/door/unpowered/blue/open()
	. = ..()
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)

/obj/machinery/door/unpowered/blue/close()
	. = ..()
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
