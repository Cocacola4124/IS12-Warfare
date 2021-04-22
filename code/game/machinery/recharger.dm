//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/recharger
	name = "recharger"
	desc = "An all-purpose recharger for a variety of devices."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 30 KILOWATTS
	var/obj/item/charging = null
	var/list/allowed_devices = list(/obj/item/melee/baton, /obj/item/cell, /obj/item/modular_computer/, /obj/item/device/suit_sensor_jammer, /obj/item/computer_hardware/battery_module, /obj/item/shield_diffuser, /obj/item/clothing/mask/smokable/ecig)
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0" //also when unpowered
	var/portable = 1

/obj/machinery/recharger/attackby(obj/item/G as obj, mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	var/allowed = 0
	for (var/allowed_type in allowed_devices)
		if (istype(G, allowed_type)) allowed = 1

	if(allowed)
		if(charging)
			to_chat(user, SPAN_WARNING("\A [charging] is already charging here."))
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			to_chat(user, SPAN_WARNING("The [name] blinks red as you try to insert the item!"))
			return
		if (istype(G, /obj/item/gun/energy/gun/nuclear) || istype(G, /obj/item/gun/energy/crossbow))
			to_chat(user, SPAN_NOTICE("Your gun's recharge port was removed to make room for a miniaturized reactor."))
			return
		if (istype(G, /obj/item/gun/energy/staff))
			return
		if(istype(G, /obj/item/modular_computer))
			var/obj/item/modular_computer/C = G
			if(!C.battery_module)
				to_chat(user, "This device does not have a battery installed.")
				return
		if(istype(G, /obj/item/device/suit_sensor_jammer))
			var/obj/item/device/suit_sensor_jammer/J = G
			if(!J.bcell)
				to_chat(user, "This device does not have a battery installed.")
				return

		if(user.unEquip(G))
			G.forceMove(src)
			charging = G
			playsound(src, 'sound/weapons/guns/interact/mag_load.ogg', 100)
			update_icon()
	else if(portable && isWrench(G))
		if(charging)
			to_chat(user, SPAN_WARNING("Remove [charging] first!"))
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

/obj/machinery/recharger/attack_hand(mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	..()

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()
		playsound(src, 'sound/weapons/guns/interact/mag_unload.ogg', 100)

/obj/machinery/recharger/Process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		update_use_power(0)
		icon_state = icon_state_idle
		return

	if(!charging)
		update_use_power(1)
		icon_state = icon_state_idle
	else
		var/cell = charging
		if(istype(charging, /obj/item/device/suit_sensor_jammer))
			var/obj/item/device/suit_sensor_jammer/J = charging
			charging = J.bcell
		else if(istype(charging, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = charging
			cell = B.bcell
		else if(istype(charging, /obj/item/modular_computer))
			var/obj/item/modular_computer/C = charging
			cell = C.battery_module.battery
		else if(istype(charging, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			cell = E.power_supply
		else if(istype(charging, /obj/item/computer_hardware/battery_module))
			var/obj/item/computer_hardware/battery_module/BM = charging
			cell = BM.battery
		else if(istype(charging, /obj/item/shield_diffuser))
			var/obj/item/shield_diffuser/SD = charging
			cell = SD.cell
		else if(istype(charging, /obj/item/clothing/mask/smokable/ecig))
			var/obj/item/clothing/mask/smokable/ecig/CIG = charging
			cell = CIG.cigcell

		if(istype(cell, /obj/item/cell))
			var/obj/item/cell/C = cell
			if(!C.fully_charged())
				icon_state = icon_state_charging
				C.give(active_power_usage*CELLRATE)
				update_use_power(2)
			else
				icon_state = icon_state_charged
				update_use_power(1)
			return

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/gun/energy))
		var/obj/item/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0

	..(severity)

obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle


/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	desc = "A heavy duty wall recharger specialized for energy weaponry."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 50 KILOWATTS	//It's more specialized than the standalone recharger (guns and batons only) so make it more powerful
	allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton)
	icon_state_charged = "wrecharger2"
	icon_state_charging = "wrecharger1"
	icon_state_idle = "wrecharger0"
	portable = 0
