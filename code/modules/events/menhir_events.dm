#ifdef MAP_OVERRIDE_MENHIR
ABSTRACT_TYPE(/datum/random_event/menhir)
/datum/random_event/menhir
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY

	///Outreach turfs are locations that start open and are suitable for an event to occur at. Events should pick and check one blindly at first, and fall back to this if necessary.
	proc/get_open_outreach()
		. = FALSE
		var/list/eligible_sites = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(T,/turf/simulated/floor) && !is_blocked_turf(T))
				eligible_sites += T
		if(length(eligible_sites))
			. = pick(eligible_sites)

//pulled one out of cold storage for ya
/datum/random_event/menhir/gift
	name = "A Gift from the Crown"
	message_delay = 3 MINUTES

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nods remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the gift artifact spawns at; will be a node (external ball) if possible, adding a door to it and disqualifying node from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///A door landmark turf is selected to have a door into the node
		var/turf/doorlandmark = null
		///List of eligible walls in node mode
		var/list/eligible_walls = list()

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //fallback mode: pick a curated station tile instead
			nodelandmark = nodelandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
			if (!istype(nodelandmark,/turf/simulated/floor) || is_blocked_turf(nodelandmark))
				nodelandmark = get_open_outreach()
				if(!nodelandmark)
					logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a fallback turf after all nodes expended; aborting event.")
					message_admins("Menhir analysis event couldn't find a fallback turf after all nodes expended; aborting event.")
					return
		else
			nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

			for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
				if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
					eligible_walls += T

			if (!length(eligible_walls))
				logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find a wall for the selected door! This shouldn't happen.")
				message_admins("Menhir gift event couldn't find a node wall selected door! This shouldn't happen. Aborting event")
				return

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		if(node_tag)
			doorlandmark = pick(eligible_walls)
			var/save_dir = doorlandmark.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(doorlandmark)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4
			landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again
		else
			showswirl(nodelandmark)
		Artifact_Spawn(nodelandmark,"precursor")

		message_delay = rand(2 MINUTES, 3 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		if(node_tag)
			logTheThing(LOG_STATION, null, "Menhir gift event at [node_tag] arm - [log_loc(nodelandmark)]")
			message_admins("Menhir gift event triggered at [node_tag] arm - [log_loc(nodelandmark)]")
		else
			logTheThing(LOG_STATION, null, "Menhir gift event (fallback mode) at [log_loc(nodelandmark)]")
			message_admins("Menhir gift event triggered (fallback mode) - [log_loc(nodelandmark)]")

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
			if(!isalive(H) || !istype(get_area(H),/area/station) || !isturf(H.loc))
				continue

			if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && isalive(H))
				eligible_examinees += H

		if (length(eligible_examinees) < 1)
			logTheThing(LOG_DEBUG, null, "Menhir analysis event couldn't find anyone to take; aborting event.")
			message_admins("Menhir analysis event couldn't find anyone to take; aborting event.")
			return

		var/time_of_stay = rand(50 SECONDS,90 SECONDS)
		var/time_of_spook = time_of_stay * 0.3 + rand(0,15 SECONDS)
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
			if(prob(1))
				var/turf/nearby_spot = null
				for(var/D in alldirs)
					var/turf/proxturf = get_step(whisked_from,D)
					if(!is_blocked_turf(proxturf))
						nearby_spot = proxturf
						break
				SPAWN(6)
					showswirl(nearby_spot)
				SPAWN(8)
					var/obj/ourpop = new /obj/item/reagent_containers/food/snacks/candy/lollipop(nearby_spot)
					ourpop.icon_state = "lpop-5"
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

//the crown could just use a minute ok
/datum/random_event/menhir/closure
	name = "The Crown Reclusive"
	message_delay = 1 MINUTE
	weight = 30

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!locate("menhir_entrance_bluedoor")) //don't do this more than once a round
				. = FALSE

	event_effect()
		var/obj/machinery/door/unpowered/blue/entrance = locate("menhir_entrance_bluedoor")
		if (!entrance) //in case of manual call
			logTheThing(LOG_DEBUG, null, "Menhir closure event couldn't find the Crown's entrance door; aborting event.")
			message_admins("Menhir closure event couldn't find the Crown's entrance door; aborting event.")
			return
		var/turf/eventlandmark = get_turf(entrance)
		entrance.locked = TRUE
		var/delay = rand(2,12)
		SPAWN(delay)
			entrance.close()
		SPAWN(delay+38)
			entrance.revoke_door()
		SPAWN(rand(2 MINUTES, 3 MINUTES))
			playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 55, 0, extrarange = 24, pitch = 0.3)
			new /obj/machinery/door/unpowered/blue(eventlandmark)

		playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 45, 0, extrarange = 24, pitch = 0.3)

		message_delay = rand(20 SECONDS,30 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir closure event at [log_loc(eventlandmark)]")
		message_admins("Menhir closure event triggered at [log_loc(eventlandmark)]")

//some peace and quiet
/datum/random_event/menhir/apc_off
	name = "The Crown Seeks Silence"
	message_delay = 1 MINUTE
	weight = 30

	event_effect()
		var/list/station_areas = get_accessible_station_areas()
		var/list/candidate_areas = list()
		for (var/area_name in station_areas)
			var/area/A = station_areas[area_name]
			if(!istype(A,/area/station/hallway) && !istype(A,/area/station/maintenance) && istype(A.area_apc))
				candidate_areas += A

		var/report_string = ""

		for(var/i in 1 to rand(2,3))
			var/area/our_target = pick(candidate_areas)
			candidate_areas -= our_target
			if(i > 1) report_string += " | "
			report_string += our_target.name
			var/obj/machinery/power/apc/to_mess_with = our_target.area_apc
			to_mess_with.operating = FALSE
			to_mess_with.update()
			to_mess_with.UpdateIcon()

		message_delay = rand(18 SECONDS,36 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir apc_off event triggered for: [report_string]")
		message_admins("Menhir apc_off event triggered for: [report_string]")

//the crown tries out one of its more novel machines
/datum/random_event/menhir/powersink
	name = "A Spire of Synthesis"
	message_delay = 1 MINUTE
	weight = 15

	event_effect()
		///Location of "outreach".
		var/turf/eventlandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
		if (!istype(eventlandmark,/turf/simulated/floor) || is_blocked_turf(eventlandmark))
			eventlandmark = get_open_outreach()
			if(!eventlandmark)
				logTheThing(LOG_DEBUG, null, "Menhir powersink event couldn't find a turf to happen at; aborting event.")
				message_admins("Menhir powersink event couldn't find a turf to happen at; aborting event.")
				return

		showswirl(eventlandmark)
		playsound(eventlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0, extrarange = 24, pitch = 0.45)
		SPAWN(2)
			var/obj/sinkyboye = new /obj/machinery/artifact/synthesizer(eventlandmark)
			sinkyboye.anchored = ANCHORED //give it a sec
			SPAWN(1 SECOND)
				sinkyboye.ArtifactActivated()

		message_delay = rand(40 SECONDS,80 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir powersink event at [log_loc(eventlandmark)]")
		message_admins("Menhir powersink event triggered at [log_loc(eventlandmark)]")

////////////////////////////////////////////
//////BIG SPECIAL EVENTS////////////////////
////////////////////////////////////////////

//sometimes, the door just unlocks itself
/datum/random_event/menhir/road
	name = "The Crown Holds Court"
	message_delay = 30 SECONDS
	weight = 2

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1)
				. = FALSE //the road is already open

	event_effect()
		if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1) return //manual call safeguard
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
	weight = 1

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1)
				. = FALSE //they have already made their ingress

	event_effect()
		if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1) return //manual call safeguard
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
