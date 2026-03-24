#ifdef MAP_OVERRIDE_MENHIR

/datum/random_event/minor/menhir
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY

	proc/get_open_node()
		var/turf/prospective_turf = pick_landmark(LANDMARK_MENHIR_NODE)
		if (landmarks[LANDMARK_MENHIR_NODE][prospective_turf] == null)
			for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
				if (landmarks[LANDMARK_MENHIR_NODE][T] != null)
					prospective_turf = T
		if (prospective_turf)
			return prospective_turf
		else
			logTheThing(LOG_DEBUG, null, "Menhir random event was unable to find an open node; this should only happen in long rounds.")
			message_admins("Menhir random event was unable to find an open node; aborting event.")
			return

/datum/random_event/minor/menhir/gift
	name = "A Gift from the Crown"
	message_delay = 4 MINUTES

	event_effect()
		///Tag for which node (artifact peripheral ball) the event is occurring in
		var/node_tag = FALSE
		///Center of the node; artifact spawns here, and its tag is removed after the fact, disqualifying it from future events
		var/turf/nodelandmark = get_open_node()
		///A door landmark turf is selected to have a door into the node
		var/turf/doorlandmark = null

		if (!nodelandmark)
			return //reporting handled by get_open_node
		else
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

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

		landmarks[LANDMARK_MENHIR_NODE][nodelandmark] = null //"expend" the node so future events won't select it again
		Artifact_Spawn(nodelandmark,"precursor")

		message_delay = rand(2 MINUTES, 4 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		if (random_events.announce_events) //this should maybe be baked into events but eh
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir gift event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir gift event triggered at [node_tag] arm - [log_loc(nodelandmark)]")

/datum/random_event/minor/menhir/analysis
	name = "The Crown Inquires"
	message_delay = 2 MINUTES

	event_effect()
		///Tag for which node (artifact peripheral ball) the event is occurring in
		var/node_tag = FALSE
		///Center of the node; event's "guest" is moved here and then moved back out. This does NOT disqualify the node from future events
		var/turf/nodelandmark = get_open_node()

		if (!nodelandmark)
			return //reporting handled by get_open_node
		else
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		var/eligible_examinees = list()

		for (var/mob/living/carbon/human/H in mobs)
			if(!isalive(H) || !istype(get_area(H),/area/station))
				continue

			if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && isalive(H))
				eligible_examinees += H

		if (length(eligible_examinees) < 1)
			logTheThing(LOG_DEBUG, null, "Menhir analysis event couldn't find anyone to take; aborting event.")
			message_admins("Menhir analysis event couldn't find anyone to take; aborting event.")
			return

		var/time_of_stay = rand(1.5 MINUTES,2 MINUTES)
		var/time_of_spook = time_of_stay * 0.3 + rand(0,150)
		var/mob/living/carbon/human/our_guest = pick(eligible_examinees)
		var/turf/whisked_from = get_turf(our_guest)
		showswirl_out(whisked_from)
		showswirl(nodelandmark)
		our_guest.set_loc(nodelandmark)
		SPAWN(time_of_spook) //mess with our guest a little to see how they respond
			if(prob(40)) //sing them a little sound
				var/response_tester_sound = pick('sound/effects/explosionfar.ogg','sound/effects/explosionfar.ogg','sound/musical_instruments/Gong_Rumbling.ogg')
				our_guest.playsound_local_not_inworld(response_tester_sound, 60, 0)
			else //test chemical reaction
				var/response_tester_reagent = pick("ants","love","colors","transparium","psilocybin","lumen","ethanol")
				var/quantity = 10
				switch(response_tester_reagent)
					if("transparium")
						quantity = 40
					if("lumen")
						quantity = 30
				our_guest.reagents.add_reagent(response_tester_reagent, quantity)
				our_guest.playsound_local_not_inworld('sound/items/hypo.ogg', 30, 0)
				boutput(our_guest,SPAN_ALERT("You feel a small poke and see a tiny mechanical arm receding into the floor.[pick(" That can't be good."," What the hell?","")]"))
		SPAWN(time_of_stay)
			showswirl(whisked_from)
			showswirl_out(nodelandmark)
			our_guest.set_loc(whisked_from)

		SPAWN(5)
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45, extrarange = 24)

		message_delay = time_of_stay + rand(15 SECONDS,30 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir analysis event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir analysis event triggered at [node_tag] arm - [log_loc(nodelandmark)]")
#endif
