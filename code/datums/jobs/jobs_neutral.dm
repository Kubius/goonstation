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
	items_in_belt = list(/obj/item/cloth/towel/clown, /obj/item/stamp/clown)
