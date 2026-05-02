/*
	TO DO:
	* guarantee leaders for each nation if a player is assigned to it
	* manual assignment of players to a nation
 */

/// Initially populated with the default nation types.
var/list/roundstart_nation_types = list(
	/datum/nation/engineering,
	/datum/nation/medical,
	/datum/nation/research,
	/datum/nation/service,
	/datum/nation/supply,
)

/datum/game_mode/nations
	name = "Nations"
	config_tag = "nations"
	regular = FALSE
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0

	var/list/datum/nation/nations = list()

	var/list/datum/mind/UN_personnel = list()

	/// List of jobs assigned to the UN at roundstart. Checked FIRST. As /datum/job types.
	var/list/UN_jobs = list(
		/datum/job/civilian/AI,
		/datum/job/civilian/cyborg,
		/datum/job/command/captain,
		/datum/job/command/head_of_security,
	)
	/// List of jobs categories assigned to the UN at roundstart. Checked SECOND. See `_std/defines/job.dm`.
	var/list/UN_job_categories = list(
		JOB_SECURITY,
		JOB_NANOTRASEN,
	)

/datum/game_mode/nations/announce()
	boutput(world, "<B>The current game mode is - Nations!</B>")
	boutput(world, "<B>Guide your nation's destiny among the stars!</B>")

/datum/game_mode/nations/pre_setup()
	. = TRUE
	if (global.map_setting != "NATIONS")
		logTheThing(LOG_DEBUG, src, "Nations gamemode is being started without the Nations map! Careful!")
		message_admins("Nations gamemode is being started without the Nations map! Careful!")

/datum/game_mode/nations/post_setup()
	var/list/datum/mind/candidates = list()
	for (var/datum/mind/candidate_mind)
		candidates += candidate_mind

	for (var/nation_type in roundstart_nation_types)
		var/datum/nation/new_nation = new nation_type()
		src.nations += new_nation

	candidates = src.populate_UN(candidates)
	candidates = src.populate_nations(candidates)

	var/list/nation_populations = list()
	for (var/datum/nation/nation in src.nations)
		if (!length(nation.citizens))
			continue
		nation_populations += "[nation.name] ([length(nation.citizens)])"
	if (length(nation_populations))
		logTheThing(LOG_GAMEMODE, src, "set up the following nations: [english_list(nation_populations)]")
		message_admins("Nations: Set up the following nations: [english_list(nation_populations)]")
	if (length(src.UN_personnel))
		logTheThing(LOG_GAMEMODE, src, "assigned [length(src.UN_personnel)] to the UN.")
		message_admins("Nations: Assigned [length(src.UN_personnel)] to the UN.")

	if (length(candidates))
		var/list/remaining_candidates = list()
		for (var/datum/mind/candidate in candidates)
			remaining_candidates += "[candidate.current] (ckey: [candidate.ckey])"
		logTheThing(LOG_GAMEMODE, src, "has a non-empty list of candidates (length: [length(candidates)]) after assigning UN and nations roles \
			([english_list(remaining_candidates)])!")
		message_admins("Nations: A non-empty list of candidates (length: [length(candidates)]) was left after assigning UN and nations roles!")

	// todo: check if all nations have leaders

/datum/game_mode/nations/send_intercept(badguy_list)
	return

/datum/game_mode/nations/proc/populate_UN(list/datum/mind/candidates)
	logTheThing(LOG_GAMEMODE, src, "attempting to populate the UN.")
	message_admins("Nations: Attempting to populate the UN.")
	if (!length(candidates))
		logTheThing(LOG_GAMEMODE, src, "was unable to populate the UN as no valid candidates were found!")
		message_admins("Nations: Unable to populate the UN as no valid candidates were found!")
		return
	for (var/datum/mind/candidate_mind in candidates)
		if (!src.assign_to_UN(candidate_mind))
			continue
		candidates -= candidate_mind
		if (iscarbon(candidate_mind.current))
			src.issue_passport(candidate_mind.current, /obj/item/passport/un)
	return candidates

/datum/game_mode/nations/proc/populate_nations(list/datum/mind/candidates)
	logTheThing(LOG_GAMEMODE, src, "attempting to populate each nation.")
	message_admins("Nations: Attempting to populate each nation.")
	if (!length(src.nations))
		logTheThing(LOG_GAMEMODE, src, "was unable to populate the nations as they don't seem to exist! Aborting!")
		message_admins("Nations: Unable to populate the nations as they don't seem to exist! Aborting!")
		return
	if (!length(candidates))
		logTheThing(LOG_GAMEMODE, src, "was unable to populate the nations as no valid candidates were found!")
		message_admins("Nations: Unable to populate the nations as no valid candidates were found!")
		return
	shuffle_list(candidates)
	for (var/datum/mind/candidate_mind in candidates)
		if (!src.assign_to_a_nation(candidate_mind))
			continue
		if (!iscarbon(candidate_mind.current))
			continue
		var/mob/living/carbon/candidate_mob = candidate_mind.current
		candidates -= candidate_mind
		if (iscarbon(candidate_mind.current))
			src.issue_passport(candidate_mob)
	return candidates

/datum/game_mode/nations/proc/assign_to_UN(datum/mind/candidate_mind)
	. = TRUE
	if (!ismind(candidate_mind))
		return FALSE
	var/datum/job/mind_job = find_job_in_controller_by_string(candidate_mind.current.job)
	if (mind_job in src.UN_jobs)
		UN_personnel += candidate_mind
		return
	if (mind_job.job_category in src.UN_job_categories)
		UN_personnel += candidate_mind
		return
	. = FALSE

/datum/game_mode/nations/proc/assign_to_a_nation(datum/mind/candidate_mind)
	. = TRUE
	if (!ismind(candidate_mind))
		return FALSE
	var/datum/job/mind_job = find_job_in_controller_by_string(candidate_mind.current.job)
	for (var/datum/nation/nation in src.nations)
		if ((mind_job.type in nation.leader_jobs) && !nation.leader)
			nation.add_leader(candidate_mind.current.mind)
			return
		if ((mind_job.type) in nation.citizen_jobs)
			nation.add_citizen(candidate_mind.current.mind)
			return
		if (mind_job.job_category in nation.citizen_job_categories)
			nation.add_citizen(candidate_mind.current.mind)
			return
	. = FALSE

/datum/game_mode/nations/proc/issue_passport(mob/living/carbon/passport_owner, passport_type)
	if (!iscarbon(passport_owner))
		return
	var/obj/item/passport/new_passport
	if (istype(passport_type, /obj/item/passport))
		new_passport = new passport_type(passport_owner.mind, src.get_nation(passport_owner))
	else
		new_passport = new /obj/item/passport(passport_owner.mind, src.get_nation(passport_owner))
	passport_owner.put_in_hand_or_drop(new_passport)

/datum/game_mode/nations/proc/get_nation(mob/living/carbon/target)
	. = null
	if (!iscarbon(target))
		return
	for (var/datum/nation/nation in src.nations)
		if (!(target.mind in nation.citizens))
			continue
		return nation
