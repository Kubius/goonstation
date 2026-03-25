#ifdef MAP_OVERRIDE_MENHIR
ABSTRACT_TYPE(/datum/random_event/menhir)
/datum/random_event/menhir
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY

//pulled one out of cold storage for ya
/datum/random_event/menhir/gift
	name = "A Gift from the Crown"
	message_delay = 4 MINUTES

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nods remain, do not trigger event
				. = FALSE

	event_effect()
		///Center of a node (artifact peripheral ball); gift artifact spawns here, and the node is removed from eligibility
		var/turf/nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		///Tag for the node the event is occurring in
		var/node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]
		///A door landmark turf is selected to have a door into the node
		var/turf/doorlandmark = null

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

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node so future events won't select it again
		Artifact_Spawn(nodelandmark,"precursor")

		message_delay = rand(2 MINUTES, 4 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir gift event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir gift event triggered at [node_tag] arm - [log_loc(nodelandmark)]")

//pick somebody out and see how they respond
/datum/random_event/menhir/analysis
	name = "The Crown Inquires"
	message_delay = 2 MINUTES

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (emergency_shuttle.direction == SHUTTLE_DIRECTION_TO_STATION && emergency_shuttle.timeleft() < (SHUTTLEARRIVETIME / 2))
				. = FALSE //it's very rude to steal people when they've got somewhere to be
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
				. = FALSE //or when their ride is here
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1)
				. = FALSE //or into a room where they can just walk out

	event_effect()
		///Center of a node (artifact peripheral ball); event's "guest" is moved here and then moved back out. This does NOT disqualify the node from future events
		var/turf/nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		///Tag for the node the event is occurring in
		var/node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

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

		var/time_of_stay = rand(90 SECONDS,2 MINUTES)
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

/*
/datum/random_event/menhir/draw_dry
	name = "Tribute to the Crown"
	message_delay = 2 MINUTES

	event_effect()


*/

////////////////////////////////////////////
//////BIG SPECIAL EVENTS////////////////////
////////////////////////////////////////////

//sometimes, the door just unlocks itself
/datum/random_event/menhir/road
	name = "The Crown Holds Court"
	message_delay = 30 SECONDS
	weight = 4

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1)
				. = FALSE //the road is already open

	event_effect()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_PASSAGE])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				Artifact_Spawn(T,"precursor")

		playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 45, 0, 0.45)

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir road event triggered.")
		message_admins("Menhir road event triggered.")

//the ancient ones remembered in the deep of the Crown have noticed your presence. and SHIT IS GOIN DOWN
/datum/random_event/menhir/shadow
	name = "Of Memory Is Borne Lament"
	message_delay = 30 SECONDS
	required_elapsed_round_time = 22 MINUTES
	centcom_headline = "ARTIFACT CONDITION ALERT"
	centcom_message = "A massive spike in electromagnetic activity that does not match prior readings has been detected from TOREADOR-7I-22408. All personnel should immediately make ready for hazardous conditions."
	weight = 4

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1)
				. = FALSE //the road is already open

	event_effect()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_DARK])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				SPAWN(rand(0,200))
					new /mob/living/critter/shade/invader(T)

		playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)
		var/remusic = 115 SECONDS
		SPAWN(remusic)
			playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)

		SPAWN(rand(2 SECONDS, 3 SECONDS))
			playsound_global(world, pick(list('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg')), 60)
			for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
				if (!istype(apc.area,/area/station/hallway/primary))
					continue
				apc.overload_lighting()

		for_by_tcl(light,/obj/map/light/cyan/menhir)
			SPAWN(rand(1,10))
				light.alterlight(0.42,0.3,0.3)

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 15)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 30)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)

		logTheThing(LOG_STATION, null, "Menhir shadow event triggered.")
		message_admins("Menhir shadow event triggered.")
#endif
