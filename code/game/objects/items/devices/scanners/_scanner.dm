/obj/item/device/scanner
	name = "handheld scanner"
	desc = "A hand-held scanner of some sort. You shouldn't be seeing it."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	item_flags = ITEM_FLAG_NO_BLUDGEON
	matter = list(MATERIAL_ALUMINIUM = 30,MATERIAL_GLASS = 20)
	var/scan_title
	var/scan_data
	//For displaying scans
	var/window_width = 450
	var/window_height = 600
	
/obj/item/device/scanner/attack_self(mob/user)
	show_results(user)

/obj/item/device/scanner/proc/show_results(mob/user)
	var/datum/browser/popup = new(user, "scanner", scan_title, window_width, window_height)
	popup.set_content("[get_header()]<hr>[scan_data]")
	popup.open()

/obj/item/device/scanner/proc/get_header()
	return "<a href='?src=\ref[src];print=1'>Print Report</a>"

/obj/item/device/scanner/proc/can_use(mob/user)
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	return TRUE

/obj/item/device/scanner/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(!can_use(user))
		return
	if(is_valid_scan_target(A) && A.simulated)
		user.visible_message("<span class='notice'>[user] runs \the [src] over \the [A].</span>", range = 2)
		scan(A, user)
		if(!scan_title)
			scan_title = "[capitalize(name)] scan - [A]"
	else
		to_chat(user, "You cannot get any results from \the [A] with \the [src].")

/obj/item/device/scanner/proc/is_valid_scan_target(atom/O)
	return FALSE

/obj/item/device/scanner/proc/scan(atom/A, mob/user)

/obj/item/device/scanner/proc/print_report_verb()
	set name = "Print Report"
	set category = "Object"
	set src = usr

	var/mob/user = usr
	if(!istype(user))
		return
	if (user.incapacitated())
		return
	print_report(user)

/obj/item/device/scanner/OnTopic(var/user, var/list/href_list)
	if(href_list["print"])
		print_report(user)
		return 1

/obj/item/device/scanner/proc/print_report(var/mob/living/user)
	if(!scan_data)
		to_chat(user, "There is no scan data to print.")
		return
	var/obj/item/weapon/paper/P = new(get_turf(src), scan_data, "paper - [scan_title]")
	user.put_in_hands(P)
	user.visible_message("\The [src] spits out a piece of paper.")