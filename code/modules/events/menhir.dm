#ifdef MAP_OVERRIDE_MENHIR
/datum/random_event/minor/menhir
	name = "A Gift from the Crown"

	event_effect()
		..()
		var/found_wall = FALSE //don't put a door where one already exists.
		var/turf/doorlandmark = pick_landmark(LANDMARK_MENHIR_DOOR)
		var/turf/nodelandmark = null

		if (!doorlandmark)
			logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a LANDMARK_MENHIR_DOOR!")
			message_admins("Menhir gift event couldn't find a LANDMARK_MENHIR_DOOR! Aborting event")
			return

		if (istype(doorlandmark,/turf/unsimulated/wall))
			found_wall = TRUE

		if (!found_wall)
			var/firstdoorlandmark = doorlandmark
			var/scanned_landmarks = list(doorlandmark)
			var/maxtests = 16

			while (length(scanned_landmarks) < maxtests && !found_wall)
				doorlandmark = pick_landmark(LANDMARK_MENHIR_DOOR, ignorespecific = scanned_landmarks)
				scanned_landmarks += doorlandmark
				if (istype(doorlandmark,/turf/unsimulated/wall))
					found_wall = TRUE

			if (!found_wall)
				doorlandmark = firstdoorlandmark // goes back to the first option if none are available

		var/the_tag = landmarks[LANDMARK_MENHIR_DOOR][doorlandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
			if (landmarks[LANDMARK_MENHIR_NODE][T] == the_tag)
				nodelandmark = T
				break

		if (!nodelandmark)
			logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a node for the selected door!")
			message_admins("Menhir gift event couldn't find a node for selected door! Aborting event")
			return

		var/save_dir = doorlandmark.icon_state

		playsound(doorlandmark, 'sound/musical_instruments/Vuvuzela_1.ogg', 40, 0, pitch = 0.2)
		if (found_wall)
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(doorlandmark)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		var/atom/movable/thing = locate(/atom/movable in nodelandmark)
		if(thing && thing.density)
			var/turf/alternate_spawn = get_step_truly_rand(nodelandmark)
			Artifact_Spawn(alternate_spawn,"precursor")
		else
			Artifact_Spawn(nodelandmark,"precursor")

		logTheThing(LOG_STATION, null, "Menhir gift event at [the_tag] arm -  [log_loc(nodelandmark)]")
		message_admins("Menhir gift event triggered at [the_tag] arm - [log_loc(nodelandmark)]")
#endif
