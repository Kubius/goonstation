/datum/nation
	var/name = "Independent Station-state of Cargonia"
	/// `icon_state` for custom-made passports.
	var/custom_passport = null
	var/passport_color = "#FF0000"
	var/passport_symbol = "generic-gold"

	var/datum/mind/leader = null
	var/list/datum/mind/citizens = list()

/datum/nation/un
	name = "United Nations"
	custom_passport = "passport-UN"
