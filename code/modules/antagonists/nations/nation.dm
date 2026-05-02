/datum/nation
	var/name = "\the Independent Station-state of Cargonia"

	var/datum/mind/leader = null
	var/list/datum/mind/citizens = list()

	/// List of jobs which provide valid candidates for the nation's leader at roundstart.
	var/list/leader_jobs = list()
	/// List of jobs which are assigned regular citizenship to this nation at roundstart. Checked FIRST. As /datum/job types.
	var/list/citizen_jobs = list()
	/// List of jobs categories which are assigned regular citizenship to this nation at roundstart. Checked SECOND. See `_std/defines/job.dm`.
	var/list/citizen_job_categories = list()

	/// `icon_state` for premade passports.
	var/passport_icon_state = null
	// Custom passports
	var/passport_color = "#FF0000"
	var/passport_symbol = "generic-gold"

/datum/nation/proc/add_leader(datum/mind/new_leader)
	if (src.leader == new_leader)
		return
	if (src.leader)
		var/datum/mind/old_leader = src.leader
		logTheThing(LOG_GAMEMODE, src, "removed [old_leader.current] (ckey: [old_leader.ckey]) as leader of [src.name]!")
		src.leader = new_leader
	src.add_citizen(new_leader)
	logTheThing(LOG_GAMEMODE, src, "installed [new_leader.current] (ckey: [new_leader.ckey]) as leader of [src.name]!")

/datum/nation/proc/add_citizen(datum/mind/new_citizen)
	if (new_citizen in src.citizens)
		return
	src.citizens += new_citizen
	logTheThing(LOG_GAMEMODE, src, "assigned [new_citizen.current] (ckey: [new_citizen.ckey]) to the nation of [src.name]!")

/datum/nation/engineering
	name = "Engistan"
	leader_jobs = list(/datum/job/command/chief_engineer)
	citizen_job_categories = list(JOB_ENGINEERING)
	passport_icon_state = "passport-engineering"

/datum/nation/medical
	name = "Asclepius"
	leader_jobs = list(/datum/job/command/medical_director)
	citizen_job_categories = list(JOB_MEDICAL)
	passport_icon_state = "passport-medical"

/datum/nation/research
	name = "Erudite"
	leader_jobs = list(/datum/job/command/research_director)
	citizen_job_categories = list(JOB_RESEARCH)
	passport_icon_state = "passport-research"

/datum/nation/service
	name = "\the Grey Horde"
	leader_jobs = list(/datum/job/command/head_of_personnel)
	citizen_job_categories = list(
		JOB_CIVILIAN,
		JOB_CLOWN,
	)
	passport_icon_state = "passport-service"

/datum/nation/supply
	name = "\the Independent Station-state of Cargonia"
	citizen_jobs = list(
		/datum/job/engineering/miner,
		/datum/job/engineering/quartermaster,
	)
	passport_icon_state = "passport-supply"
