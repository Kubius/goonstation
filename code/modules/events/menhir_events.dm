#ifdef MAP_OVERRIDE_MENHIR
///List of people who are present on station for events, updated once a cycle for events to check. SHOULD NOT BE ACCESSED DIRECTLY - use helper.
var/global/list/menhir_local_event_candidates = list()
///Time at which the list of people present on station for events was last updated.
var/global/menhir_candidates_last_built = 0

//-----------Bitflags for filtering events------------
//Does our candidate need to be human?
#define EVFILTER_HUMAN 1
//Does our candidate need to be directly on a turf, and not inside anything else?
#define EVFILTER_ONTURF 2
//By default, anyone in Precursor areas counts as "present" as well. This filter prevents that.
#define EVFILTER_NO_MOON 4

///Grabs (and updates, if necessary) the list of people who are present for on-station events. Provide a filter to narrow the returned pool further.
/proc/get_menhir_event_candidates(var/filter = 0)
	//Build stage
	if(menhir_candidates_last_built < (world.time - 20 SECONDS) && !length(menhir_local_event_candidates))
		menhir_candidates_last_built = world.time
		menhir_local_event_candidates = list()

		for (var/mob/living/L in mobs)
			if(!isalive(L) || !L.client || ismobcritter(L))
				continue
			var/area/mobarea = get_area(L)
			if(istype(mobarea,/area/station) || istype(mobarea,/area/unspace) || istype(mobarea, /area/research_outpost) || istype(mobarea, /area/precursor))
				menhir_local_event_candidates += L
	. = menhir_local_event_candidates

	//Filter stage
	if(filter)
		for(var/mob/M in .)
			if(filter & EVFILTER_HUMAN && !istype(M,/mob/living/carbon/human))
				. -= M
				continue
			if(filter & EVFILTER_ONTURF && !isturf(M.loc))
				. -= M
				continue
			if(filter & EVFILTER_NO_MOON)
				var/area/mobarea = get_area(M)
				if(istype(mobarea,/area/precursor))
					. -= M
					continue

	return

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

//some little fellas!
/datum/random_event/menhir/probes
	name = "Emissaries of the Crown"
	message_delay = 1 MINUTE
	weight = 150
	var/list/deployed_probes = list()

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (length(src.deployed_probes)) //we're already deployed!
				. = FALSE

	event_effect()
		var/list/candidate_landmarks = list()
		for (var/turf/T in landmarks[LANDMARK_HALLOWEEN_SPAWN])
			candidate_landmarks += T
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(get_area(T),/area/station/maintenance)) continue
			candidate_landmarks += T

		var/probe_deployments = rand(8,11)
		var/have_deployed = 0
		SPAWN(1) //don't hold up other operations
			var/turf/rolling_target
			while(have_deployed < probe_deployments)
				have_deployed++
				rolling_target = pick(candidate_landmarks)
				candidate_landmarks -= rolling_target
				showswirl(rolling_target)
				var/mob/deployed_probe = new /mob/living/critter/robotic/probe(rolling_target)
				src.deployed_probes += deployed_probe
				sleep(1)

		SPAWN(rand(3 MINUTES, 5 MINUTES))
			for (var/mob/M in deployed_probes)
				if(!QDELETED(M))
					var/turf/T = get_turf(M)
					showswirl_out(T)
					deployed_probes -= M
					qdel(M)
					sleep(1)
			logTheThing(LOG_STATION, null, "Menhir probes event concluded.")
			message_admins("Menhir probes event concluded.")

		logTheThing(LOG_STATION, null, "Menhir probes event deployed [probe_deployments] probes.")
		message_admins("Menhir probes event deployed [probe_deployments] probes.")

		message_delay = rand(25 SECONDS,32 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

//pulled one out of cold storage for ya
/datum/random_event/menhir/gift
	name = "A Gift from the Crown"
	message_delay = 3 MINUTES

	event_effect()
		///Site the gift artifact spawns at; will sometimes be in a "node" (outer ball) if it can, adding a door to it and disqualifying node from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///A door landmark turf is selected to have a door into the node
		var/turf/doorlandmark = null
		///List of eligible walls in node mode
		var/list/eligible_walls = list()

		var/can_node = TRUE
		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) can_node = FALSE

		if(!can_node || prob(60)) //outreach mode: drop it somewhere on the station
			nodelandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
			if (!istype(nodelandmark,/turf/simulated/floor) || is_blocked_turf(nodelandmark))
				nodelandmark = get_open_outreach()
				if(!nodelandmark)
					logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find an outreach turf; aborting event.")
					message_admins("Menhir gift event couldn't find an outreach turf; aborting event.")
					return
		else //node mode: pick a ball, any ball
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
			logTheThing(LOG_STATION, null, "Menhir gift event (out-of-node) at [log_loc(nodelandmark)]")
			message_admins("Menhir gift event triggered (out-of-node) - [log_loc(nodelandmark)]")

//pick somebody out and see how they respond
/datum/random_event/menhir/analysis
	name = "The Crown Inquires"
	message_delay = 2 MINUTES
	weight = 80
	///Increase the minimum required candidates each time the event goes off, to a cap.
	var/required_candidates = 1

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

		var/list/eligible_examinees = get_menhir_event_candidates(EVFILTER_HUMAN | EVFILTER_ONTURF | EVFILTER_NO_MOON)
		var/candidate_num = length(eligible_examinees)

		if (candidate_num < src.required_candidates)
			logTheThing(LOG_STATION, null, "Menhir analysis event has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
			message_admins("Menhir analysis event has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
			return

		src.required_candidates = min(src.required_candidates + 2, 15)

		var/time_of_stay = rand(40 SECONDS,50 SECONDS)
		var/time_of_spook = time_of_stay * 0.3 + rand(0,15 SECONDS)
		var/mob/living/carbon/human/our_guest = pick(eligible_examinees)
		var/turf/whisked_from = get_turf(our_guest)
		showswirl_out(whisked_from)
		showswirl(nodelandmark)
		our_guest.set_loc(nodelandmark)
		SPAWN(time_of_spook) //mess with our guest a little to see how they respond
			if(our_guest)
				if(prob(60)) //sing them a little sound
					var/response_tester_sound = pick('sound/effects/explosionfar.ogg','sound/effects/explosionfar.ogg','sound/musical_instruments/Gong_Rumbling.ogg')
					our_guest.playsound_local_not_inworld(response_tester_sound, 80, 0)
				else //test chemical reaction
					var/response_tester_reagent = pick("love","colors","transparium","psilocybin","lumen","ethanol")
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
			if(our_guest)
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
		SPAWN(time_of_stay + 5)
			var/moved_objects = 0
			for(var/atom/movable/AM in range(2,nodelandmark))
				if(!AM.anchored)
					var/turf/dumpspot = pick(landmarks[LANDMARK_MENHIR_OUTREACH])
					showswirl(dumpspot)
					AM.set_loc(dumpspot)
					moved_objects++

			if(moved_objects)
				logTheThing(LOG_STATION, null, "Menhir analysis event relocated [moved_objects] atoms out of node post-event.")
				message_admins("Menhir analysis event relocated [moved_objects] atoms out of node post-event.")

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
	weight = 50

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

#define RAND_3_BY_3 1
#define RAND_3_BY_5 2
#define RAND_5_BY_3 3

//you like rooms, right?
/datum/random_event/menhir/extrusion
	name = "A Place of Paths Not Taken"
	message_delay = 3 MINUTES
	weight = 50

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_EXTRUSION] || length(landmarks[LANDMARK_MENHIR_EXTRUSION]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		var/turf/extlandmark = pick(landmarks[LANDMARK_MENHIR_EXTRUSION])
		var/alignment = landmarks[LANDMARK_MENHIR_EXTRUSION][extlandmark]
		var/are_we_west = FALSE
		if (alignment == "WEST") are_we_west = TRUE
		var/roomtype = rand(1,3)

		var/list/frametiles = src.get_walls(extlandmark, are_we_west, roomtype)
		var/list/to_area_swap = src.get_whole_coverage(extlandmark, are_we_west, roomtype)
		var/turf/rroom_site = src.get_room_spot(extlandmark, are_we_west, roomtype)

		var/area/hostarea
		if (are_we_west)
			hostarea = station_areas["Arrivals Auxiliary Arm"]
		else
			hostarea = station_areas["Escape Auxiliary Arm"]

		for (var/turf/T in to_area_swap)
			if(isarea(T.loc))
				var/area/A = T.loc
				A.contents -= T
			hostarea.contents += T

		for (var/turf/T in frametiles)
			T.ReplaceWithWall()
			leaveresidual(T)

		for (var/obj/O in extlandmark)
			if(O.anchored) qdel(O)
		extlandmark.ReplaceWithFloor()
		var/obj/newdoor = new /obj/machinery/door/airlock/pyro/classic(extlandmark)
		newdoor.dir = WEST

		var/obj/landmark/random_room/mark_plier
		switch(roomtype)
			if(RAND_3_BY_3) mark_plier = new /obj/landmark/random_room/size3x3(rroom_site)
			if(RAND_3_BY_5) mark_plier = new /obj/landmark/random_room/size3x5(rroom_site)
			if(RAND_5_BY_3) mark_plier = new /obj/landmark/random_room/size5x3(rroom_site)
		mark_plier.apply()

		if(prob(60))
			playsound(extlandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(extlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		message_delay = rand(1 MINUTE, 3 MINUTES)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		landmarks[LANDMARK_MENHIR_EXTRUSION].Remove(extlandmark)

		logTheThing(LOG_STATION, null, "Menhir extrusion event at [log_loc(extlandmark)]")
		message_admins("Menhir extrusion event triggered at [log_loc(extlandmark)]")

	///Retrieves the turfs to frame out the new room.
	proc/get_walls(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		if(offset_to_west)
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - 1, T.y - offset_V, T.z) //below, from far to close
			. += block(T.x - offset_H, T.y + offset_V, T.z, T.x - 1, T.y + offset_V, T.z) //above, from far to close
		else
			. += block(T.x + offset_H, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x + 1, T.y - offset_V, T.z, T.x + offset_H, T.y - offset_V, T.z) //below, from close to far
			. += block(T.x + 1, T.y + offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //above, from close to far
		return

	///Retrieves all turfs associated with the new room (for addition to associated area).
	proc/get_whole_coverage(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		if(offset_to_west)
			. = block(T.x - offset_H, T.y - offset_V, T.z, T.x - 1, T.y + offset_V, T.z)
		else
			. = block(T.x + 1, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z)
		return

	///Retrieves the turf the event should place a random room spawner onto.
	proc/get_room_spot(var/turf/T, var/offset_to_west, var/roomtype)
		var/horz_bump = 1
		if(offset_to_west)
			if(roomtype == RAND_5_BY_3)
				horz_bump = -5
			else
				horz_bump = -3

		if(roomtype == RAND_3_BY_5)
			. = locate(T.x + horz_bump, T.y - 2, T.z)
		else
			. = locate(T.x + horz_bump, T.y - 1, T.z)
		return

#undef RAND_3_BY_3
#undef RAND_3_BY_5
#undef RAND_5_BY_3

//little iffy on this one, probably need some better alternatives
/datum/random_event/menhir/apc_off
	name = "Quiet is the Chorus"
	message_delay = 1 MINUTE
	weight = 35
	var/list/ineligible_areas = list(
		/area/station/maintenance,
		/area/station/engine/core,
		/area/station/engine/hotloop,
		/area/station/engine/coldloop,
		/area/station/engine/combustion_chamber,
		/area/station/engine/monitoring,
		/area/station/engine/power,
		/area/station/crown
	)

	event_effect()
		var/list/station_areas = get_accessible_station_areas()
		var/list/candidate_areas = list()
		for (var/area_name in station_areas)
			var/area/A = station_areas[area_name]
			var/not_eligible = FALSE
			for (var/check_area in ineligible_areas)
				if (istype(A,check_area))
					not_eligible = TRUE
					break
			if (not_eligible) continue
			if (istype(A.area_apc))
				candidate_areas += A

		var/report_num = 0
		var/spare_areas = rand(8,16)
		SPAWN(1) //don't hold up other operations
			while(length(candidate_areas) > spare_areas)
				var/area/our_target = pick(candidate_areas)
				candidate_areas -= our_target
				report_num++
				var/obj/machinery/power/apc/to_mess_with = our_target.area_apc
				to_mess_with.operating = FALSE
				to_mess_with.update()
				to_mess_with.UpdateIcon()
				SPAWN(2)
					playsound(to_mess_with.loc, 'sound/effects/sparks1.ogg', 30, 0)
					FLICK("apc-spark", to_mess_with)
				SPAWN(rand(25 SECONDS, 30 SECONDS))
					to_mess_with.operating = TRUE
					to_mess_with.update()
					to_mess_with.UpdateIcon()
				sleep(1)
			logTheThing(LOG_STATION, null, "Menhir apc_off event triggered for [report_num] areas")
			message_admins("Menhir apc_off event triggered for [report_num] areas")

		message_delay = rand(9 SECONDS,15 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

//untangle the snare, untangle a prize
/datum/random_event/menhir/knot
	name = "A Receptacle of Reflection"
	message_delay = 3 MINUTES
	weight = 35

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the puzzle room spawns at
		var/turf/nodelandmark
		///Tag for the node the event is occurring in
		var/node_tag = null
		///List of walls associated with the node (we'll be installing doors onto these)
		var/list/walls_to_door = list()

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //fallback mode: pick a curated station tile instead
			logTheThing(LOG_DEBUG, null, "Menhir knot event couldn't find a fallback turf after all nodes expended; aborting event.")
			message_admins("Menhir knot event couldn't find a fallback turf after all nodes expended; aborting event.")
			return

		nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				walls_to_door += T

		if (length(walls_to_door) < 4)
			logTheThing(LOG_DEBUG, null, "Menhir knot event couldn't find expected door count! This shouldn't happen.")
			message_admins("Menhir knot event couldn't find expected door count! This shouldn't happen. Aborting event")
			return

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		for(var/D in cardinal)
			var/turf/onestep = get_step(nodelandmark, D)
			var/turf/twostep = get_step(onestep, D)
			var/obj/precursor_puzzle/rotator/speen = new /obj/precursor_puzzle/rotator(twostep)
			speen.id = node_tag
			speen.dir = D
			speen.opacity = 0

		new /obj/rack/precursor/pressure/knot(nodelandmark)

		var/obj/precursor_puzzle/controller/hub = new /obj/precursor_puzzle/controller(nodelandmark)
		hub.pixel_y = -15
		hub.layer = 3.2
		hub.id = "[node_tag]"
		hub.tag = "controller_[node_tag]"
		hub.self_removing = TRUE
		hub.opacity = 0

		for(var/D in alldirs)
			var/turf/proxturf = get_step(nodelandmark,D)
			var/obj/precursor_puzzle/shield/S = new /obj/precursor_puzzle/shield(proxturf)
			S.id = node_tag
			S.dir = D

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		for(var/turf/wallturf in walls_to_door)
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		message_delay = rand(2 MINUTES, 3 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir knot event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir knot event triggered at [node_tag] arm - [log_loc(nodelandmark)]")

//the crown tries out one of its more novel machines
/datum/random_event/menhir/powersink
	name = "A Spire of Synthesis"
	message_delay = 1 MINUTE
	weight = 15
	centcom_message = "A sustained period of elevated electromagnetic activity from TOREADOR-7I-22408 is currently underway. Personnel are advised to monitor station power grid and deactivate supply if anomalous behavior is detected."

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/list/eligible_caretakers = get_menhir_event_candidates()
			if (!length(eligible_caretakers))
				. = FALSE

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
			var/obj/sinkyboye = Artifact_Spawn(eventlandmark,forceartitype = /datum/artifact/synthesizer)
			sinkyboye.anchored = ANCHORED //give it a sec
			SPAWN(1 SECOND)
				sinkyboye.ArtifactActivated()

		message_delay = rand(12 SECONDS,16 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)
			SPAWN(message_delay + 20)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir powersink event at [log_loc(eventlandmark)]")
		message_admins("Menhir powersink event triggered at [log_loc(eventlandmark)]")

////////////////////////////////////////////
//////BIG SPECIAL EVENTS////////////////////
////////////////////////////////////////////

//sometimes, the door just unlocks itself
/datum/random_event/menhir/road
	name = "For Parted Are The Gates"
	message_delay = 30 SECONDS
	weight = 5

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
				showswirl(T)
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
	weight = 5

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/obj/machinery/door/unpowered/blue/seal = locate("vestibule_of_grief")
			if (!seal || seal.density) //the way has not been opened
				. = FALSE

			if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1)
				. = FALSE //they have already made their ingress

			var/list/eligible_caretakers = get_menhir_event_candidates()
			if (length(eligible_caretakers) < 8)
				. = FALSE

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
		var/remusic = 110 SECONDS
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

#undef EVFILTER_HUMAN
#undef EVFILTER_ONTURF
#undef EVFILTER_NO_MOON

#endif
