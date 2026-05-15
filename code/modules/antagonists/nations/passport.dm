/datum/mind
	/// Currently held passport, for Nations.
	var/obj/item/passport/passport = null

/obj/item/passport
	name = "passport"
	desc = "An identity document confirming its owner's citizenship or lack thereof."
	icon = 'icons/obj/items/passport.dmi'
	icon_state = "passport-base"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "book"
	w_class = W_CLASS_TINY
	layer = OBJ_LAYER
	throwforce = 0
	throw_speed = 3
	throw_range = 15

	var/datum/nation/nation_type = null
	var/datum/mind/owner = null
	var/custom_name = FALSE

/obj/item/passport/New(newLoc, datum/mind/owner_to_assign)
	. = ..()

	if (!src.custom_name && src.nation_type)
		src.name = "passport ([src.nation_type::name])"

	if (ismind(owner_to_assign))
		src.owner = owner_to_assign
		src.owner.passport = src

		src.name = "[src.owner.current.real_name]’s [src.name]"

/obj/item/passport/disposing()
	src.owner?.passport = null
	. = ..()

/obj/item/passport/attack_self(mob/user as mob)
	if (ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
		return

	user.visible_message("[user] shows you [his_or_her(user)] [bicon(src)] [src.name].", "You show off your passport. [bicon(src)]")
	src.add_fingerprint(user)
	actions.start(new /datum/action/show_item(user, src, "passport", 5, 3), user)

/obj/item/passport/un
	name = "\improper United Nations laissez-passer"
	desc = "A passport-like document identifying the owner as an agent of the United Nations."
	icon_state = "passport-UN"
	nation_type = /datum/nation/un
	custom_name = TRUE

/obj/item/passport/engineering
	icon_state = "passport-engineering"
	nation_type = /datum/nation/engineering

/obj/item/passport/medical
	icon_state = "passport-medical"
	nation_type = /datum/nation/medical

/obj/item/passport/research
	icon_state = "passport-research"
	nation_type = /datum/nation/research

/obj/item/passport/service
	icon_state = "passport-service"
	nation_type = /datum/nation/service

/obj/item/passport/supply
	icon_state = "passport-supply"
	nation_type = /datum/nation/supply

/obj/item/passport/stateless
	name = "passport (STATELESS)"
	icon_state = "passport-stateless"
	custom_name = TRUE
