/datum/mind
	/// Currently held passport, for Nations.
	var/obj/item/passport/current_passport = null

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
	var/datum/nation/nation = null
	var/datum/mind/owner = null
	var/custom_name = FALSE

/obj/item/passport/New(datum/mind/owner_to_assign, datum/nation/nation_to_assign)
	. = ..()
	if (ismind(owner_to_assign))
		src.owner = owner_to_assign
	if (istype(nation_to_assign, /datum/nation))
		src.nation = nation_to_assign
	src.set_appearance()

/obj/item/passport/attack_self(mob/user as mob)
	if (ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
		return
	user.visible_message("[user] shows you [his_or_her(user)] [bicon(src)] [src.name].", "You show off your passport. [bicon(src)]")
	src.add_fingerprint(user)
	actions.start(new /datum/action/show_item(user, src, "passport", 5, 3), user)

/obj/item/passport/proc/set_appearance()
	if (!src.nation)
		src.name = "passport (STATELESS)"
		src.icon_state = "passport-stateless"
		src.ClearAllOverlays()
		return
	if (!src.custom_name)
		src.name = "passport ([src.nation.name])"
	if (length(src.nation.passport_icon_state) && istext(src.nation.passport_icon_state))
		src.icon_state = src.nation.passport_icon_state
		src.ClearAllOverlays()
		return
	var/image/cover_image = SafeGetOverlayImage("cover", src.icon, "passport-cover")
	cover_image.color = src.nation.passport_color
	src.UpdateOverlays(cover_image, "cover")
	var/image/symbol_image = SafeGetOverlayImage("symbol", src.icon, src.nation.passport_symbol)
	src.UpdateOverlays(symbol_image, "symbol")

/obj/item/passport/un
	name = "\improper United Nations laissez-passer"
	desc = "A passport-like document identifying the owner as an agent of the United Nations."
	icon_state = "passport-UN"
	custom_name = TRUE

/obj/item/passport/un/set_appearance()
	return
