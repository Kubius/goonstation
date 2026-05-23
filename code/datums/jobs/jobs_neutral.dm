ABSTRACT_TYPE(/datum/job/neutral)
/datum/job/neutral
	ui_colour = TGUI_COLOUR_OLIVE
	slot_card = /obj/item/card/id
	job_category = JOB_NEUTRAL

/datum/job/neutral/mail_courier
	name = "Mail Courier"
	alias_names = "Mailman"
	wages = PAY_TRADESMAN
	access_string = "Mail Courier"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	slot_poc1 = list(/obj/item/pinpointer/mail_recepient)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	items_in_backpack = list(/obj/item/wrapping_paper, /obj/item/satchel/mail, /obj/item/scissors, /obj/item/stamp)
	alt_names = list("Head of Deliverying", "Mail Bringer")
	wiki_link = "https://wiki.ss13.co/Mailman"

/datum/job/neutral/journalist
	name = "Journalist"
	limit = 3
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/red)
	slot_head = list(/obj/item/clothing/head/fedora)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_poc1 = list(/obj/item/camera)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	items_in_backpack = list(/obj/item/camera_film/large)
	special_spawn_location = LANDMARK_JOURNALIST_SPAWN
	wiki_link = "https://wiki.ss13.co/Jobs#Gimmick_Jobs"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/device/camera_viewer/public(B))
			B.storage.add_contents(new /obj/item/clothing/head/helmet/camera(B))
			B.storage.add_contents(new /obj/item/device/audio_log(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

		return

/datum/job/neutral/inspector
	name = "Inspector"
	wages = PAY_IMPORTANT
	limit = 0
	request_cost = PAY_EXECUTIVE * 4
	access_string = "Inspector"
	receives_miranda = TRUE
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	badge = /obj/item/clothing/suit/security_badge/nanotrasen
	slot_card = /obj/item/card/id/nanotrasen
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/ntofficial)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/black) // so they can slam tables
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/inspector)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_suit = list(/obj/item/clothing/suit/armor/NT)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_rhan = list(/obj/item/device/ticket_writer)
	items_in_backpack = list(/obj/item/device/flash)
	wiki_link = "https://wiki.ss13.co/Inspector"
	email_group = MGD_COMMAND

	get_default_miranda()
		return "You have been found to be in breach of Nanotrasen corporate regulation [rand(1,100)][pick(uppercase_letters)]. You are allowed a grace period of 5 minutes to correct this infringement before you may be subjected to disciplinary action including but not limited to: strongly worded tickets, reduction in pay, and being buried in paperwork for the next [rand(10,20)] standard shifts."

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/instrument/whistle(B))
			var/obj/item/clipboard/with_pen/inspector/clipboard = new /obj/item/clipboard/with_pen/inspector(B)
			B.storage.add_contents(clipboard)
			clipboard.set_owner(M)
		return

/datum/job/neutral/diplomat
	name = "Diplomat"
	wages = PAY_TRADESMAN
	access_string = "Diplomat"
	limit = 0
	request_limit = 0 // you don't request them, they come to you
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Diplomat", "Ambassador")
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	change_name_on_spawn = TRUE

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		SPAWN(0)
			var/selection = null
			var/list/options = list(/datum/mutantrace/lizard::name = /datum/mutantrace/lizard,
									/datum/mutantrace/skeleton::name  = /datum/mutantrace/skeleton,
									/datum/mutantrace/ithillid::name = /datum/mutantrace/ithillid,
									/datum/mutantrace/martian::name = /datum/mutantrace/martian,
									/datum/mutantrace/amphibian::name = /datum/mutantrace/amphibian,
									/datum/mutantrace/blob::name  = /datum/mutantrace/blob,
									/datum/mutantrace/cow::name = /datum/mutantrace/cow)

			selection = tgui_input_list(M,"Pick a Mutantrace. Cancel to be Human.","Pick a Mutantrace. Cancel to be Human.",options)
			var/datum/mutantrace/morph = options[selection]
			M.set_mutantrace(morph)
			if (istype(M.mutantrace, /datum/mutantrace/martian) || istype(M.mutantrace, /datum/mutantrace/blob))
				M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)
			else
				if (M.l_store)
					M.stow_in_available(M.l_store)
				M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)

/datum/job/neutral/clown
	name = "Clown"
	limit = 4
	wages = PAY_DUMBCLOWN
	request_limit = 3 //this is definitely a bad idea
	request_cost = PAY_TRADESMAN*4
	trait_list = list("training_clown")
	access_string = "Clown"
	ui_colour = TGUI_COLOUR_PINK
	slot_back = list()
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_jump = list(/obj/item/clothing/under/misc/clown)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes)
	slot_lhan = list(/obj/item/instrument/bikehorn)
	slot_poc1 = list(/obj/item/device/pda2/clown)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	slot_card = /obj/item/card/id/clown
	slot_ears = list(/obj/item/device/radio/headset/clown)
	items_in_belt = list(/obj/item/cloth/towel/clown)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Clown"

	faction = list(FACTION_CLOWN)


/datum/job/neutral/clown/ringmaster
	name = "THE RINGMASTER"
	limit = 1
	slot_head = list(/obj/item/clothing/head/that/gold)
	items_in_belt = list(/obj/item/cloth/towel/clown, /obj/item/stamp/clown)
