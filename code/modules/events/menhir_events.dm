#ifdef MAP_OVERRIDE_MENHIR
/datum/random_event/minor/menhir_gift
	name = "A Gift from the Crown"
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY
	message_delay = 4 MINUTES

	event_effect()
		var/turf/doorlandmark = null
		var/turf/nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)

		///Tag for which node the event is occurring in (door and node landmarks have this tag, node landmark has it removed on event completion)
		var/node_tag = FALSE

		if (landmarks[LANDMARK_MENHIR_NODE][nodelandmark] == null)
			for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
				if (landmarks[LANDMARK_MENHIR_NODE][T] != null)
					nodelandmark = T
					node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]
					break
		else
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		if (!node_tag)
			logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find an unused node; aborting event. This should only happen in long rounds.")
			message_admins("Menhir gift event couldn't find an unused node; aborting event.")
			return

		var/list/eligible_walls = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				eligible_walls += T

		if (!length(eligible_walls))
			logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a wall for the selected door! This shouldn't happen.")
			message_admins("Menhir gift event couldn't find a node wall selected door! This shouldn't happen. Aborting event")
			return

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 55, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 55, 0, extrarange = 24)

		doorlandmark = pick(eligible_walls)
		var/save_dir = doorlandmark.icon_state
		var/obj/newdoor = new /obj/machinery/door/unpowered/blue(doorlandmark)
		if (save_dir == "interior-3") //vertical wall detection
			newdoor.dir = 4

		landmarks[LANDMARK_MENHIR_NODE][nodelandmark] = null //expend the node so future events won't select it again
		Artifact_Spawn(nodelandmark,"precursor")

		message_delay = rand(2 MINUTES, 4 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		logTheThing(LOG_STATION, null, "Menhir gift event at [node_tag] arm -  [log_loc(nodelandmark)]")
		message_admins("Menhir gift event triggered at [node_tag] arm - [log_loc(nodelandmark)]")
/*
/datum/random_event/minor/menhir_analysis
	name = "The Crown Inquires"
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY
	message_delay = 3 MINUTES

	event_effect()
		message_delay = rand(2 MINUTES, 3 MINUTES)
		..()
*/
#endif
