/* How to Use:
Regular variant: Edit the ID of this helper. It will make door buttons (regular and remote) and poddoors/airlocks use its ID.

Area variant: Do not edit the ID. It will automatically turn the area name into an identifier.
This is useful if you only have one button-operated feature in an area.
*/
/obj/mapping_helper/button
	name = "door button helper"
	icon = 'icons/map-editing/airlocks.dmi'
	icon_state = "id"
	var/id = "FIXME"
	var/use_area_name = FALSE

	setup()
		var/turf/our_spot = get_turf(src)
		for (var/obj/O in our_spot)
			if(istype(O,/obj/machinery/door_control) || istype(O,/obj/machinery/r_door_control) || istype(O,/obj/machinery/door/airlock) || istype(O,/obj/machinery/door/poddoor))
				if(use_area_name)
					var/area/our_area = get_area(our_spot)
					O:id = ckey(our_area.name)
				else
					O:id = src.id

/obj/mapping_helper/button/area
	name = "area-name door button helper"
	icon_state = "id"
	use_area_name = TRUE

