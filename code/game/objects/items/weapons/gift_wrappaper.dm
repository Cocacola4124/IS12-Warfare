/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	randpixel = 10

/obj/item/a_gift/New()
	..()
	if(w_class > 0 && w_class < ITEM_SIZE_HUGE)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	to_chat(user, SPAN_WARNING("You can't move."))

/obj/effect/spresent/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if(!isWirecutter(W))
		to_chat(user, SPAN_WARNING("I need wirecutters for that."))
		return

	to_chat(user, SPAN_NOTICE("You cut open the present."))

	for(var/mob/M in src) //Should only be one but whatever.
		M.dropInto(loc)
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)

/obj/item/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/contraband/poster,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/beach_ball,
		/obj/item/beach_ball/holoball,
		/obj/item/toy/water_balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/device/paicard,
		/obj/item/device/violin,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/*
 * Wrapping Paper and Gifts
 */

/obj/item/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"
	var/obj/item/gift = null
	item_state = "gift"
	w_class = ITEM_SIZE_NORMAL

/obj/item/gift/New(newloc, obj/item/wrapped = null)
	..(newloc)

	if(istype(wrapped))
		gift = wrapped
		w_class = gift.w_class
		gift.forceMove(src)

		//a good example of where we don't want to use the w_class defines
		switch(gift.w_class)
			if(1) icon_state = "gift1"
			if(2) icon_state = "gift1"
			if(3) icon_state = "gift2"
			if(4) icon_state = "gift2"
			if(5) icon_state = "gift3"

/obj/item/gift/attack_self(mob/user as mob)
	user.drop_item()
	if(src.gift)
		playsound(src, 'sound/items/poster_ripped.ogg', 100)
		var/obj/item/A = new gift(get_turf(user))
		user.put_in_active_hand(A)
		A.add_fingerprint(user)
		user.visible_message("<span class='bnotice'>[user] tears open the present!</pan>")
	else
		to_chat(user, SPAN_WARNING("The gift was empty!"))
	qdel(src)
	return

/obj/item/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	var/amount = 2.5*base_storage_cost(ITEM_SIZE_HUGE)

/obj/item/wrapping_paper/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (!( locate(/obj/structure/table, src.loc) ))
		to_chat(user, SPAN_WARNING("You MUST put the paper on a table!"))
	if (W.w_class < ITEM_SIZE_HUGE)
		if(isWirecutter(user.l_hand) || isWirecutter(user.r_hand))
			var/a_used = W.get_storage_cost()
			if (a_used == ITEM_SIZE_NO_CONTAINER)
				to_chat(user, SPAN_WARNING("You can't wrap that!"))//no gift-wrapping lit welders

				return
			if (src.amount < a_used)
				to_chat(user, SPAN_WARNING("You need more paper!"))
				return
			else
				if(istype(W, /obj/item/smallDelivery) || istype(W, /obj/item/gift)) //No gift wrapping gifts!
					return

				if(user.drop_from_inventory(W))
					var/obj/item/gift/G = new /obj/item/gift( src.loc, W )
					G.add_fingerprint(user)
					W.add_fingerprint(user)
					src.amount -= a_used

			if (src.amount <= 0)
				new /obj/item/c_tube( src.loc )
				qdel(src)
				return
		else
			to_chat(user, SPAN_WARNING("You need scissors!"))
	else
		to_chat(user, SPAN_WARNING("The object is FAR too large!"))
	return

/obj/item/wrapping_paper/examine(mob/user)
	if(..(user, 1))
		to_chat(user, text("There is about [] square units of paper left!", src.amount))

/obj/item/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!istype(target, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = target

	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present

			H.forceMove(present)
			admin_attack_log(user, H, "Used \a [src] to wrap their victim", "Was wrapepd with \a [src]", "used \the [src] to wrap")

		else
			to_chat(user, SPAN_WARNING("You need more paper."))
	else
		to_chat(user, "They are moving around too much. A straightjacket would help.")


/obj/item/gift/warfare
	var/list/possible_gifts = list(/obj/item/clothing/shoes/timbs, /obj/item/grenade/frag/warfare, /obj/item/device/multitool, /obj/item/reagent_containers/food/drinks/bottle/wine, /obj/item/storage/fancy/cigarettes/jerichos)

/obj/item/gift/warfare/New()
	if(prob(1))
		gift = /obj/item/device/cassette/tape/rare
	else if(prob(1))
		gift = /obj/item/device/boombox
	else
		gift = pick(possible_gifts)
	..()

