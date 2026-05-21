ABSTRACT_TYPE(/datum/job/supply)
/datum/job/supply
	ui_colour = TGUI_COLOUR_BROWN
	slot_card = /obj/item/card/id/supply
	job_category = JOB_SUPPLY
	email_group = MGD_SUPPLY

/datum/job/supply/quartermaster
	name = "Quartermaster"
	limit = 3
	wages = PAY_TRADESMAN
	trait_list = list("training_quartermaster")
	access_string = "Quartermaster"
	slot_back = list(/obj/item/storage/backpack/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_jump = list(/obj/item/clothing/under/rank/cargo)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/quartermaster)
	slot_poc2 = list(/obj/item/device/appraisal)
	wiki_link = "https://wiki.ss13.co/Quartermaster"

/datum/job/supply/miner
	name = "Miner"
	#ifdef UNDERWATER_MAP
	limit = 6
	#else
	limit = 5
	#endif
	wages = PAY_TRADESMAN
	trait_list = list("training_miner")
	access_string = "Miner"
	invalid_antagonist_roles = list(ROLE_VAMPIRE)
	slot_back = list(/obj/item/storage/backpack/brown)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_belt = list(/obj/item/storage/belt/mining/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/miner)
	slot_poc1 = list(/obj/item/device/pda2/mining)
	#ifdef UNDERWATER_MAP
	slot_suit = list(/obj/item/clothing/suit/space/diving/engineering)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/mining,
							/obj/item/clothing/shoes/flippers,
							/obj/item/item_box/glow_sticker)
	#else
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	items_in_backpack = list(/obj/item/crowbar,
							/obj/item/paper/book/from_file/pocketguide/mining)
	#endif
	wiki_link = "https://wiki.ss13.co/Miner"
