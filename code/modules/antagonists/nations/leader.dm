/datum/antagonist/nation_leader
	id = ROLE_NATION_LEADER
	display_name = "nation leader"
	// antagonist_icon = "gang_head"
	// antagonist_panel_tab_type = /datum/antagonist_panel_tab/gang

	/// The nation that this citizen is a leader of.
	var/datum/nation/nation
	/// The passport for this leader.
	var/obj/item/passport/passport
