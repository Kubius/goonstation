/datum/map_correctness_check/area_contents/quartermasters
	check_name = "Quartermasters Contents Check"
	target_areas = list(
		/area/station/quartermaster,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/manufacturer/general, 0),
		CONTENTS_EQ(/obj/machinery/manufacturer/hangar, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/medical, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/robotics, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/mining, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/qm, 1),
		CONTENTS_GT(/obj/machinery/computer/supplycomp, 1),
		CONTENTS_EQ(/obj/machinery/computer/announcement/station/cargo, 1),
		CONTENTS_EQ(/obj/noticeboard/persistent/cargo, 1),
		CONTENTS_EQ(/obj/machinery/computer/chem_requester/science, 1),
		CONTENTS_EQ(/obj/submachine/cargopad/qm, 1),
		CONTENTS_EQ(/obj/machinery/disposal/mail/qm, 1),
		CONTENTS_GT(/obj/machinery/navbeacon/mule, 1),
		CONTENTS_GT(/obj/machinery/phone, 0),
		CONTENTS_GT(/obj/item/device/radio/intercom/cargo, 0),
		CONTENTS_GT(/obj/machinery/cashreg, 0),
		CONTENTS_GT(/obj/machinery/cell_charger, 0),
		// Shipping (differs for Nadir)
		CONTENTS_GT(/obj/machinery/computer/barcode, 0),
		CONTENTS_GT(/obj/machinery/conveyor_switch, 1),
		CONTENTS_GT(/obj/machinery/door_control, 1),
		// Supplies
		CONTENTS_GT(/obj/storage/secure/closet/engineering/cargo, 0),
		CONTENTS_GT(/obj/item/cargotele, 0),
		CONTENTS_GT(/obj/item/hand_labeler, 0),
		CONTENTS_GT(/obj/item/stamp/qm, 0),
	)


/datum/map_correctness_check/area_contents/quartermasters/nadir
	only_check_on = list(
		/datum/map_settings/nadir,
	)
	skip_check_on = null

	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/manufacturer/general, 0),
		CONTENTS_EQ(/obj/machinery/manufacturer/hangar, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/medical, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/robotics, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/mining, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/qm, 1),
		CONTENTS_GT(/obj/machinery/computer/supplycomp, 1),
		CONTENTS_EQ(/obj/machinery/computer/announcement/station/cargo, 1),
		CONTENTS_EQ(/obj/noticeboard/persistent/cargo, 1),
		CONTENTS_EQ(/obj/machinery/computer/chem_requester/science, 1),
		CONTENTS_EQ(/obj/submachine/cargopad/qm, 1),
		CONTENTS_EQ(/obj/machinery/disposal/mail/qm, 1),
		CONTENTS_GT(/obj/machinery/navbeacon/mule, 1),
		CONTENTS_GT(/obj/machinery/phone, 0),
		CONTENTS_GT(/obj/item/device/radio/intercom/cargo, 0),
		CONTENTS_GT(/obj/machinery/cashreg, 0),
		CONTENTS_GT(/obj/machinery/cell_charger, 0),
		// Shipping (differs for Nadir)
		CONTENTS_GT(/obj/machinery/computer/barcode, 0),
		CONTENTS_GT(/obj/machinery/computer/transception, 1),
		CONTENTS_GT(/obj/machinery/transception_pad, 1),
		// Supplies
		CONTENTS_GT(/obj/storage/secure/closet/engineering/cargo, 0),
		CONTENTS_GT(/obj/item/cargotele, 0),
		CONTENTS_GT(/obj/item/hand_labeler, 0),
		CONTENTS_GT(/obj/item/stamp/qm, 0),
	)
