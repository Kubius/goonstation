/datum/random_event/minor/menhir
	name = "A Gift from the Crown"

	event_effect()
		..()
		var/heard = FALSE // prefer an audience, if we can have one
		var/turf/doorlandmark = pick_landmark(LANDMARK_MENHIR_DOOR)
		var/turf/nodelandmark = null

		if (!doorlandmark)
			logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a LANDMARK_MENHIR_DOOR!")
			message_admins("Menhir gift event couldn't find a LANDMARK_MENHIR_DOOR! Aborting event")
			return

		if (length(hearers(5, doorlandmark)) != 0 && istype(doorlandmark,/turf/unsimulated/wall))
			for (var/mob/living/C in hearers(7, doorlandmark))
				if (C.client && !isdead(C) && !isintangible(C)) // we've got an audience
					heard = TRUE
					break

		if (!heard)
			var/firstdoorlandmark = doorlandmark
			var/heardlandmarks = list(doorlandmark)
			var/maxtests = 12

			while (length(heardlandmarks) < maxtests && heard)
				doorlandmark = pick_landmark(LANDMARK_MENHIR_DOOR, ignorespecific = heardlandmarks)
				heardlandmarks += doorlandmark
				heard = FALSE
				if (!istype(doorlandmark,/turf/unsimulated/wall))
					continue
				for (var/mob/living/C in hearers(7, doorlandmark))
					if (C.client && !isdead(C) && !isintangible(C))
						heard = TRUE

			if (!heard)
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

		var/obj/newdoor = new /obj/machinery/door/unpowered/blue(doorlandmark)
		if (save_dir == "interior-3") //vertical wall detection
			newdoor.dir = 4
		Artifact_Spawn(nodelandmark,"precursor")


		logTheThing(LOG_STATION, null, "Menhir gift event at [the_tag] arm -  [log_loc(nodelandmark)]")
		message_admins("Menhir gift event triggered at [the_tag] arm - [log_loc(nodelandmark)]")
