/*
	TO DO:
	* guarantee leaders for each nation if a player is assigned to it
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

/datum/game_mode/nations/announce()
	boutput(world, "<B>The current game mode is - Nations!</B>")
	boutput(world, "<B>Guide your nation's destiny among the stars!</B>")

/datum/game_mode/nations/pre_setup()
	. = TRUE
	if (global.map_setting != "NATIONS")
		message_admins("Nations gamemode is being started without the Nations map! Careful!")
		logTheThing(LOG_DEBUG, src, "Nations gamemode is being started without the Nations map! Careful!")

/datum/game_mode/nations/post_setup()
	for (var/nation_type in roundstart_nation_types)
		var/datum/nation/new_nation = new nation_type()
		src.nations += new_nation
	src.populate_nations()

/datum/game_mode/nations/send_intercept(badguy_list)
	return

/datum/game_mode/nations/proc/populate_nations()
	logTheThing(LOG_GAMEMODE, src, "attempting to populate each nation.")
	if (!length(src.nations))
		logTheThing(LOG_GAMEMODE, src, "was unable to populate the nations as they don't seem to exist! Aborting!")
		return
	var/list/client/candidates = list()
	for (var/client/candidate_client)
		if (!istype(candidate_client.mob, /mob/living/carbon))
			continue
		candidates += candidate_client
	if (!length(candidates))
		logTheThing(LOG_GAMEMODE, src, "was unable to populate the nations as no valid candidates were found!")
		return
	shuffle_list(candidates)
	for (var/client/candidate_client in candidates)
		if (!src.sort_candidate_to_nation(candidate_client))
			continue
		var/mob/living/carbon/candidate_mob = candidate_client.mob
		src.issue_passport(candidate_mob)

/datum/game_mode/nations/proc/sort_candidate_to_nation(client/candidate_client)
	. = TRUE
	if (!isclient(candidate_client))
		return FALSE
	var/datum/job/client_job = find_job_in_controller_by_string(candidate_client.mob.job)
	var/datum/nation/assigned_nation = null
	for (var/datum/nation/nation in src.nations)
		if ((client_job.type in nation.leader_jobs) && !nation.leader)
			nation.leader = candidate_client.mob.mind
			nation.citizens += candidate_client.mob.mind
			assigned_nation = nation
			break
		if ((client_job.type) in nation.citizen_jobs)
			nation.citizens += candidate_client.mob.mind
			assigned_nation = nation
			break
		if (client_job.job_category in nation.citizen_job_categories)
			nation.citizens += candidate_client.mob.mind
			assigned_nation = nation
			break
	if (assigned_nation)
		logTheThing(LOG_GAMEMODE, src, "assigned [candidate_client.mob] (ckey: [candidate_client.ckey]) to the nation of [assigned_nation.name]!")

/datum/game_mode/nations/proc/issue_passport(mob/living/carbon/passport_owner)
	if (!iscarbon(passport_owner))
		return
	var/obj/item/passport/new_passport = new /obj/item/passport(passport_owner.mind, src.get_nation(passport_owner))
	passport_owner.put_in_hand_or_drop(new_passport)

/datum/game_mode/nations/proc/get_nation(mob/living/carbon/target)
	. = null
	if (!iscarbon(target))
		return
	for (var/datum/nation/nation in src.nations)
		if (!(target.mind in nation.citizens))
			continue
		return nation
