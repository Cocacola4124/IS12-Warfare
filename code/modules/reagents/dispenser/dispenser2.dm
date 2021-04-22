/obj/machinery/chemical_dispenser
	name = "chemical dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	clicksound = "button"
	clickvol = 20

	var/list/spawn_cartridges = null // Set to a list of types to spawn one of each on New()

	var/list/cartridges = list() // Associative, label -> cartridge
	var/obj/item/reagent_containers/container = null

	var/ui_title = "Chemical Dispenser"

	var/accept_drinking = 0
	var/amount = 30

	use_power = 1
	idle_power_usage = 100
	density = 1
	anchored = 1
	obj_flags = OBJ_FLAG_ANCHORABLE

/obj/machinery/chemical_dispenser/New()
	..()

	if(spawn_cartridges)
		for(var/type in spawn_cartridges)
			add_cartridge(new type(src))

/obj/machinery/chemical_dispenser/examine(mob/user)
	. = ..()
	to_chat(user, "It has [cartridges.len] cartridges installed, and has space for [DISPENSER_MAX_CARTRIDGES - cartridges.len] more.")

/obj/machinery/chemical_dispenser/proc/add_cartridge(obj/item/reagent_containers/chem_disp_cartridge/C, mob/user)
	if(!istype(C))
		if(user)
			to_chat(user, SPAN_WARNING("\The [C] will not fit in \the [src]!"))
		return

	if(cartridges.len >= DISPENSER_MAX_CARTRIDGES)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] does not have any slots open for \the [C] to fit into!"))
		return

	if(!C.label)
		if(user)
			to_chat(user, SPAN_WARNING("\The [C] does not have a label!"))
		return

	if(cartridges[C.label])
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] already contains a cartridge with that label!"))
		return

	if(user)
		user.drop_from_inventory(C)
		to_chat(user, SPAN_NOTICE("You add \the [C] to \the [src]."))

	C.loc = src
	cartridges[C.label] = C
	cartridges = sortAssoc(cartridges)
	SSnanoui.update_uis(src)

/obj/machinery/chemical_dispenser/proc/remove_cartridge(label)
	. = cartridges[label]
	cartridges -= label
	SSnanoui.update_uis(src)

/obj/machinery/chemical_dispenser/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/chem_disp_cartridge))
		add_cartridge(W, user)

	else if(isScrewdriver(W))
		var/label = input(user, "Which cartridge would you like to remove?", "Chemical Dispenser") as null|anything in cartridges
		if(!label) return
		var/obj/item/reagent_containers/chem_disp_cartridge/C = remove_cartridge(label)
		if(C)
			to_chat(user, SPAN_NOTICE("You remove \the [C] from \the [src]."))
			C.loc = loc

	else if(istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food))
		if(container)
			to_chat(user, SPAN_WARNING("There is already \a [container] on \the [src]!"))
			return

		var/obj/item/reagent_containers/RC = W

		if(!accept_drinking && istype(RC,/obj/item/reagent_containers/food))
			to_chat(user, SPAN_WARNING("This machine only accepts beakers!"))
			return

		if(!RC.is_open_container())
			to_chat(user, SPAN_WARNING("You don't see how \the [src] could dispense reagents into \the [RC]."))
			return

		if(RC.w_class >= ITEM_SIZE_NORMAL)
			to_chat(user, SPAN_WARNING("This container is too big for this machine!"))
			return

		container =  RC
		user.drop_from_inventory(RC)
		RC.loc = src
		update_icon()
		to_chat(user, SPAN_NOTICE("You set \the [RC] on \the [src]."))
		SSnanoui.update_uis(src) // update all UIs attached to src

	else
		..()
	return

/obj/machinery/chemical_dispenser/ui_interact(mob/user, ui_key = "main",var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["isBeakerLoaded"] = container ? 1 : 0
	data["glass"] = accept_drinking
	var beakerD[0]
	if(container && container.reagents && container.reagents.reagent_list.len)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			beakerD[++beakerD.len] = list("name" = R.name, "volume" = R.volume)
	data["beakerContents"] = beakerD

	if(container)
		data["beakerCurrentVolume"] = container.reagents.total_volume
		data["beakerMaxVolume"] = container.reagents.maximum_volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for(var/label in cartridges)
		var/obj/item/reagent_containers/chem_disp_cartridge/C = cartridges[label]
		chemicals[++chemicals.len] = list("label" = label, "amount" = C.reagents.total_volume)
	data["chemicals"] = chemicals

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_disp.tmpl", ui_title, 390, 680)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/chemical_dispenser/OnTopic(user, href_list)
	if(href_list["amount"])
		amount = round(text2num(href_list["amount"]), 1) // round to nearest 1
		amount = max(0, min(120, amount)) // Since the user can actually type the commands himself, some sanity checking
		return TOPIC_REFRESH

	if(href_list["dispense"])
		var/label = href_list["dispense"]
		if(cartridges[label] && container && container.is_open_container())
			var/obj/item/reagent_containers/chem_disp_cartridge/C = cartridges[label]
			C.reagents.trans_to(container, amount)
			return TOPIC_REFRESH
		return TOPIC_HANDLED

	else if(href_list["ejectBeaker"])
		if(container)
			var/obj/item/reagent_containers/B = container
			B.dropInto(loc)
			container = null
			update_icon()
			return TOPIC_REFRESH
		return TOPIC_HANDLED

/obj/machinery/chemical_dispenser/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/chemical_dispenser/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/chemical_dispenser/update_icon()
	overlays.Cut()
	if(container)
		var/mutable_appearance/beaker_overlay
		beaker_overlay = image('icons/obj/chemical.dmi', src, "lil_beaker")
		beaker_overlay.pixel_x = rand(-10, 5)
		overlays += beaker_overlay
