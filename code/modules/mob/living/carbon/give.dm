/mob/living/carbon/human/proc/give(var/mob/living/target)
	if(incapacitated())
		return
	if(!istype(target) || target.incapacitated() || target.client == null)
		return

	var/obj/item/I = usr.get_active_hand()
	if(!I)
		return

	if(istype(I, /obj/item/grab))
		to_chat(usr, SPAN_WARNING("You can't give someone a grab."))
		return

	if(I.loc != usr || (usr.l_hand != I && usr.r_hand != I))
		return

	if(target.r_hand != null && target.l_hand != null)
		to_chat(usr, SPAN_WARNING("Their hands are full."))
		return

	if(usr.unEquip(I))
		target.put_in_hands(I) // If this fails it will just end up on the floor, but that's fitting for things like dionaea.
		target.visible_message(SPAN_NOTICE("\The [usr] handed \the [I] to \the [target]."))
