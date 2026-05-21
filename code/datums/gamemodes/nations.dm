/datum/game_mode/nations
	name = "Nations"
	config_tag = "nations"
	regular = FALSE
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0

	/// A list of nation datums to assign minds to.
	var/list/datum/nation/nations = list()
	/// An associative list of job datum types and the leader antagonist role that they should be assigned.
	var/alist/leader_jobs_to_roles = alist()
	/// An associative list of job datum types and the antagonist role that they should be assigned.
	var/alist/jobs_to_roles = alist()
	/// An associative list of job categories and the antagonist role that they should be assigned.
	var/alist/cats_to_roles = alist()

/datum/game_mode/nations/announce()
	boutput(world, "<B>The current game mode is - Nations!</B>")
	boutput(world, "<B>Guide your nation's destiny among the stars!</B>")

/datum/game_mode/nations/pre_setup()
	. = TRUE
	if (global.map_setting != "NATIONS")
		logTheThing(LOG_DEBUG, src, "Nations gamemode is being started without the Nations map! Careful!")
		message_admins("Nations gamemode is being started without the Nations map! Careful!")

	for (var/nation_type as anything in global.concrete_typesof(/datum/nation))
		var/datum/nation/nation = global.get_singleton(nation_type)
		src.nations += nation
		src.leader_jobs_to_roles += nation.leader_jobs

		for (var/job_type as anything in (nation.leader_jobs + nation.citizen_jobs))
			src.jobs_to_roles[job_type] = nation.citizen_role

		for (var/job_category as anything in nation.citizen_job_categories)
			src.cats_to_roles[job_category] = nation.citizen_role

/datum/game_mode/nations/post_setup()
	var/list/datum/mind/client_minds = list()
	for (var/client/C as anything in global.clients)
		if (!isliving(C.mob) || !ismind(C.mob.mind))
			continue

		client_minds += C.mob.mind

	shuffle_list(client_minds)

	for (var/datum/mind/mind as anything in client_minds)
		src.assign_role(mind, global.find_job_in_controller_by_string(mind.assigned_role))

/datum/game_mode/nations/send_intercept(badguy_list)
	return

/datum/game_mode/nations/proc/assign_role(datum/mind/mind, datum/job/job)
	if (!istype(job))
		return

	var/leader_role = null
	var/role = null
	var/datum/job/job_type = job.type
	while (job_type != /datum/job)
		leader_role ||= src.leader_jobs_to_roles[job_type]
		role ||= src.jobs_to_roles[job_type]
		job_type = job_type::parent_type

	role ||= src.cats_to_roles[job.job_category]

	// If a leader role is found, assign that role to the mind and remove it from the list, so that it isn't assigned twice.
	if (leader_role)
		role = leader_role

		for (var/datum/job/leader_job_type as anything in src.leader_jobs_to_roles)
			if (src.leader_jobs_to_roles[leader_job_type] == leader_role)
				src.leader_jobs_to_roles -= leader_job_type

	if (role)
		mind.add_antagonist(role, respect_mutual_exclusives = FALSE)
		return TRUE

	return FALSE

/datum/game_mode/nations/proc/handle_latejoin(datum/mind/mind, datum/job/job)
	var/turf/spawn_turf = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, 1))
	var/obj/cryotron/latejoin_cryotron = locate(/obj/cryotron) in spawn_turf
	if (istype(latejoin_cryotron))
		latejoin_cryotron.add_person_to_queue(mind.current, job)
	else
		mind.current?.set_loc(spawn_turf)

	if (src.assign_role(mind, job))
		return

	logTheThing(LOG_GAMEMODE, mind.current, "attempted to latejoin and was not assigned to the UN or any nation!")
	message_admins("Nations: [key_name(mind)] attempted to latejoin and was not assigned to the UN or any nation!")
