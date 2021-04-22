/obj/machinery/giga_drill
	name = "alien drill"
	desc = "A giant, alien drill mounted on long treads."
	icon = 'icons/obj/mining.dmi'
	icon_state = "gigadrill"
	var/active = 0
	var/drill_time = 10
	var/turf/drilling_turf
	density = 1
	layer = ABOVE_OBJ_LAYER		//to go over ores

/obj/machinery/giga_drill/attack_hand(mob/user as mob)
	if(active)
		active = 0
		icon_state = "gigadrill"
		to_chat(user, SPAN_NOTICE("You press a button and \the [src] slowly spins down."))
	else
		active = 1
		icon_state = "gigadrill_mov"
		to_chat(user, SPAN_NOTICE("You press a button and \the [src] shudders to life."))

/obj/machinery/giga_drill/Bump(atom/A)
	if(active && !drilling_turf)
		if(istype(A,/turf/simulated/mineral))
			var/turf/simulated/mineral/M = A
			drilling_turf = get_turf(src)
			src.visible_message(SPAN_NOTICE("\The [src] begins to drill into \the [M]."))
			anchored = 1
			spawn(drill_time)
				if(get_turf(src) == drilling_turf && active)
					M.GetDrilled()
					src.loc = M
				drilling_turf = null
				anchored = 0
