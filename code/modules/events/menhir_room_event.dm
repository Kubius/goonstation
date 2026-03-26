ABSTRACT_TYPE(/area/precursor/unspace)
/area/precursor/unspace
	sound_environment = 1
	///Do we have an east, or west entrance?
	var/local_facing = WEST
	///This tag should match the path of the prefab in allocated.dm, lowercase with underscores, and have a matching tagged landmark within the prefab.
	var/seek_tag = "fix"

	proc/update_visual_mirrors(turf/otherside_ref)
		//Find our landmark
		var/obj/anchor = locate(seek_tag)
		if(!anchor)
			boutput(world,"DEBUG DEBUG DEBUG")
			return
		var/anchor_x = anchor.x
		var/anchor_y = anchor.y
		var/anchor_z = anchor.z

		//Iteration goes up if we're east facing, and down if we're west facing
		var/dirsign = 1
		if(local_facing == WEST) dirsign = -1

		var/turf/T
		var/turf/otherside_turf
		for (var/horz = -1 to 10)
			var/oriented_horz = horz * dirsign
			var/clamped_horz = max(horz, 0)
			var/vertical = min((2 * clamped_horz), 15) //Follow the contour of the cone
			var/v_offset = min(clamped_horz, 7) //Bump the start lower according to contour
			for (var/vert = 0 to vertical)
				T = locate(anchor_x + (oriented_horz), anchor_y + (vertical - v_offset), anchor_z)
				otherside_turf = locate(otherside_ref.x + (oriented_horz), otherside_ref.y + (vertical - v_offset), otherside_ref.z)

				T.vis_contents = null// clear previously assigned vis_contents
				if (otherside_turf)
					otherside_turf.appearance_flags |= KEEP_TOGETHER
					if (!otherside_turf.listening_turfs)
						otherside_turf.listening_turfs = list()
					otherside_turf.listening_turfs += T

					T.vis_contents += otherside_turf
					T.density = otherside_turf.density
					T.opacity = otherside_turf.opacity
					for (var/atom/A as anything in otherside_turf)
						if (A.opacity)
							T.opacity = TRUE
							break
					T.name = otherside_turf.name
					T.desc = otherside_turf.desc
					T.icon = otherside_turf.icon
					T.icon_state = otherside_turf.icon_state
				else // past edge of map
					T.icon = null
					T.icon_state = null
					T.density = TRUE
					T.opacity = TRUE
					T.name = ""
					T.desc = ""
				T.RL_Init()

/area/precursor/unspace/medical
	name = "Soothing Chamber"
	local_facing = WEST
	seek_tag = "menhir_room_medical"

	mirror
		icon_state = "blue"
		force_fullbright = TRUE

/area/precursor/unspace/lounge
	name = "Secluded Alcove"
	local_facing = EAST
	seek_tag = "menhir_room_lounge"

	mirror
		icon_state = "blue"
		force_fullbright = TRUE

/area/precursor/unspace/botany
	name = "Damp Antechamber"
	local_facing = EAST
	seek_tag = "menhir_room_botany"

	mirror
		icon_state = "blue"
		force_fullbright = TRUE

/area/precursor/unspace/poolroom
	name = "Misty Cavern"
	local_facing = WEST
	seek_tag = "menhir_room_cavern"
	sound_environment = 10

	mirror
		icon_state = "blue"
		force_fullbright = TRUE

ABSTRACT_TYPE(/obj/menhir_room_objs)
/obj/menhir_room_objs
	name = ""
	desc = ""
	anchored = ANCHORED_ALWAYS

	ex_act()
		return

ABSTRACT_TYPE(/obj/menhir_room_objs/cross_dummy)
/obj/menhir_room_objs/cross_dummy
	invisibility = INVIS_ALWAYS
	var/turf/exit_turf
	var/required_dir

	New(newLoc, turf/exit)
		..()
		src.exit_turf = exit

	disposing()
		src.exit_turf = null
		..()

	Crossed(atom/movable/AM)
		if (istype(AM, /obj/projectile))
			var/obj/projectile/P = AM
			var/obj/projectile/new_proj = initialize_projectile(src.exit_turf, P.proj_data, P.xo, P.yo, P.shooter)
			new_proj.travelled = P.travelled
			new_proj.launch()
			P.die()
		else if (AM.dir == src.required_dir && !istype(AM, /obj/menhir_room_objs/cross_dummy))
			// makes it look like an animation glide
			AM.set_loc(get_step(src.exit_turf, turn(AM.dir, 180)))
			SPAWN(0.001) // just a really low value
				AM.set_loc(src.exit_turf)
				if (istype(AM, /obj/stool)) // i dont like this but buckled is weird as shit
					var/obj/stool/stool = AM
					if (stool.buckled_guy)
						stool.buckled_guy.set_loc(src.exit_turf)
		else
			return ..()

	east
		required_dir = EAST

	west
		required_dir = WEST

/obj/menhir_room_objs/mirror_update_dummy
	invisibility = INVIS_ALWAYS
	var/turf/otherside_ref
	var/entrance_loc

	New(newLoc, turf/otherside_ref, entrance_loc)
		..()
		src.otherside_ref = otherside_ref
		src.entrance_loc = entrance_loc

	disposing()
		src.otherside_ref = null
		..()

	Crossed(atom/movable/AM)
		if (isliving(AM) && !isintangible(AM))
			var/area/precursor/unspace/our_space = get_area(src)
			our_space.update_visual_mirrors(src.otherside_ref)
			return ..()
		return ..()

#ifdef MAP_OVERRIDE_MENHIR

ABSTRACT_TYPE(/datum/menhir_room_roll)
///Dataset for a particular room that can be summoned; provides path to prefab as well as context data
/datum/menhir_room_roll
	var/name = "cat gym"
	/// Which side the room is entered from; this may be EAST or WEST.
	/// * WEST entrance is allowed at west, northeast and southeast nodes.
	/// * EAST entrance is allowed at east, northwest and southwest nodes.
	var/entrance_side = EAST

	///Path to prefab we load in.
	var/map_path = null
	///Base weight of prefab.
	var/base_weight = 100
	///Areas to check for occupancy in the process of room selection (optional). Assigned value is weight added per person in that type of area.
	var/list/area_busy_checks = null
	///Some of the rooms that match more conventional functions maaaaaaay have had their contents appropriated from somewhere that misses it
	var/list/stole_from = null

	proc/get_weight()
		. = src.base_weight
		if(area_busy_checks)
			for (var/mob/living/carbon/human/H in mobs)
				for(var/A in area_busy_checks)
					if(istype(get_area(H),A))
						. += area_busy_checks[A]
		return

/datum/menhir_room_roll/medbay
	name = "soothing chamber (medical)"
	entrance_side = WEST
	map_path = /datum/mapPrefab/allocated/menhir_room_medical
	base_weight = 40
	area_busy_checks = list(/area/station/medical/medbay = 12,\
		/area/station/medical = 2,\
		/area/station/security = 2,\
		/area/station/crown = 2)
	stole_from = list("medical bay","medbay")

/datum/menhir_room_roll/lounge
	name = "secluded alcove (lounge)"
	entrance_side = EAST
	map_path = /datum/mapPrefab/allocated/menhir_room_lounge
	base_weight = 50
	area_busy_checks = list(/area/station/crew_quarters = 5,\
		/area/station/hallway/secondary = 2)
	stole_from = list("crew quarters","officers' lounge","cafeteria","bar")

/datum/menhir_room_roll/botany
	name = "damp antechamber (botany)"
	entrance_side = EAST
	map_path = /datum/mapPrefab/allocated/menhir_room_botany
	base_weight = 40
	area_busy_checks = list(/area/station/hydroponics = 6,\
		/area/station/ranch = 3,\
		/area/station/crew_quarters/cafeteria = 1)
	stole_from = list("hydroponics bay","botany department","agricultural wing")

/datum/menhir_room_roll/poolroom
	name = "misty cavern (pool)"
	entrance_side = WEST
	map_path = /datum/mapPrefab/allocated/menhir_room_cavern

/datum/random_event/menhir/room
	name = "The Crown Holds Court"
	message_delay = 1 MINUTE
	weight = 20
	customization_available = 1
	///Consumable pool of room data.
	var/list/room_pool = list()
	///Keep track of rooms we've created.
	var/list/rooms_made = list()

	New()
		for (var/R in concrete_typesof(/datum/menhir_room_roll))
			var/datum/room = new R
			src.room_pool += room
		. = ..()

	///Menhir room event scales its rate of appearance based on server population
	proc/update_weight()
		src.weight = 20 + (total_clients() * 2)

	///Evaluate the tag of a node to see which public exits it can make available for event
	proc/nodetagcheck(var/tag_to_check)
		. = 0
		if(tag_to_check == "WEST" || tag_to_check == "NORTHEAST" || tag_to_check == "SOUTHEAST")
			. = WEST
		if(tag_to_check == "EAST" || tag_to_check == "NORTHWEST" || tag_to_check == "SOUTHWEST")
			. = EAST
		return

	admin_call(var/source)
		if (..())
			return

		var/node2use = null
		if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) return

		var/list/nodenames = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
			nodenames += landmarks[LANDMARK_MENHIR_NODE][T]

		var/noderequest = input(usr,"Which node to spawn at?",src.name) as null|anything in nodenames
		if(!noderequest) return

		for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
			if (landmarks[LANDMARK_MENHIR_NODE][T] == noderequest)
				node2use = T
				break

		var/room2use = null
		room2use = input(usr,"What room would you like to spawn?",src.name) as null|anything in src.room_pool

		src.event_effect(source, node2use, room2use)
		return

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE
			if (length(rooms_made) > 1) //maximum of 2 rooms per round
				. = FALSE

	event_effect(source, node_override, room_override)
		///Node the room will spawn into
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///Datum that lets us know which room we're going to be spawning
		var/datum/menhir_room_roll/room_data = null

		///Records available directions from unused nodes, to determine which are available for spawns
		var/direction_eligibility = 0

		if (node_override)
			nodelandmark = node_override
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]
		else
			for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
				var/result = nodetagcheck(landmarks[LANDMARK_MENHIR_NODE][T])
				if(result) direction_eligibility |= result

			if (!direction_eligibility)
				logTheThing(LOG_DEBUG, null, "Menhir room event couldn't collect node directional information; aborting event.")
				message_admins("Menhir room event couldn't collect node directional information; aborting event.")

		if(room_override)
			room_data = room_override
		else
			///Our list of rooms may not always have spawnables that work for current directions
			var/list/currently_spawnable_rooms = list()

			for(var/datum/menhir_room_roll/RR in src.room_pool)
				if(direction_eligibility & RR.entrance_side)
					currently_spawnable_rooms[RR] = RR.get_weight()

			room_data = weighted_pick(currently_spawnable_rooms)

			if(!nodelandmark)
				var/list/eligible_nodes = list()
				for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
					var/result = nodetagcheck(landmarks[LANDMARK_MENHIR_NODE][T])
					if(result & room_data.entrance_side) eligible_nodes += T

				nodelandmark = pick(eligible_nodes)

		if (!room_data.map_path)
			logTheThing(LOG_DEBUG, null, "Menhir room '[room_data.name]' has invalid map_path configuration.")
			message_admins("Menhir room '[room_data.name]' has invalid map_path configuration.")

		var/datum/mapPrefab/allocated/room_handler = get_singleton(room_data.map_path)

		var/datum/allocated_region/spawned_room = room_handler.load()
		src.rooms_made += spawned_room
		src.initialize_entrance(room_data.entrance_side, nodelandmark, spawned_room)

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again
		src.room_pool -= room_data

		message_delay = rand(20 SECONDS, 50 SECONDS)
		..()

		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir room '[room_data.name]' entrance created at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir room '[room_data.name]' entrance created at [node_tag] arm - [log_loc(nodelandmark)]")

	proc/initialize_entrance(entrance_side, turf/nodelandmark, datum/allocated_region/pocket_region)
		var/region_tag = pocket_region.name
		var/turf/pocket_landmark = get_turf(locate(region_tag)) //Same position as the door

		var/otherway
		switch(entrance_side)
			if(EAST)
				otherway = WEST
			if(WEST)
				otherway = EAST

		var/turf/pocket_doormat = get_step(pocket_landmark,otherway)
		var/turf/pocket_midpoint = get_step(pocket_doormat,otherway) //Inside-to-outside cross dummy starts here
		var/turf/pocket_inside = get_step(pocket_midpoint,otherway) //Outside-to-inside cross dummy exits here

		var/turf/real_midpoint = get_step(nodelandmark,entrance_side) //Outside-to-inside cross dummy starts here
		var/turf/real_doormat = get_step(real_midpoint,entrance_side) //Inside-to-outside cross dummy exits here
		var/turf/door_here = get_step(real_doormat,entrance_side) //Inside-to-outside cross dummy exits here

		var/obj/menhir_room_objs/cross_dummy/inside_dummy

		switch (entrance_side)
			if (EAST)
				new /obj/menhir_room_objs/cross_dummy/west(real_midpoint, pocket_midpoint) //Moving west into the space
				inside_dummy = new /obj/menhir_room_objs/cross_dummy/east(pocket_doormat, real_doormat) //Moving east out of the space
			if (WEST)
				new /obj/menhir_room_objs/cross_dummy/east(real_midpoint, pocket_midpoint) //Moving east into the space
				inside_dummy = new /obj/menhir_room_objs/cross_dummy/west(pocket_doormat, real_doormat) //Moving west out of the space

		real_midpoint.reachable_turfs += pocket_inside
		pocket_midpoint.reachable_turfs += real_doormat

		//setup interiors
		for(var/row = 1 to 5)
			if(row == 3) continue //skip middle row
			for(var/column = 1 to 5)
				var/turf/paveover_target = locate(nodelandmark.x - 2 + column, nodelandmark.y - 2 + row, nodelandmark.z)
				paveover_target.ReplaceWith(/turf/unsimulated/wall/auto/adventure/icemooninterior)

		new /obj/machinery/door/unpowered/blue/vertical(door_here)

		SPAWN(20)
			var/area/precursor/unspace/our_space = get_area(inside_dummy)
			our_space.update_visual_mirrors(door_here)
			RL_UPDATE_LIGHT(real_doormat)
#endif
