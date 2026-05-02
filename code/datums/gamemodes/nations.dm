/datum/game_mode/nations
	name = "Nations"
	config_tag = "nations"
	regular = FALSE
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0

/datum/game_mode/nations/announce()
	boutput(world, "<B>The current game mode is - Nations!</B>")
	boutput(world, "<B>Guide your nation's destiny among the stars!</B>")

/datum/game_mode/nations/pre_setup()
	if (global.map_setting != "NATIONS")
		message_admins("Nations gamemode is being started without the Nations map! Careful!")
		logTheThing(LOG_DEBUG, "Nations gamemode is being started without the Nations map! Careful!")
