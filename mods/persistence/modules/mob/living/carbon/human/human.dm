/mob/living/carbon/human
	var/obj/home_spawn		// The object we last safe-slept on. Used for moving characters to safe locations on loads.

/mob/living/carbon/human/before_save()
	. = ..()
	CUSTOM_SV_LIST(\
	"move_intent" = move_intent?.type, \
	"eye_color" = eye_colour, \
	"facial_hair_colour" = facial_hair_colour, \
	"hair_colour" = hair_colour, \
	"skin_colour" = skin_colour, \
	"skin_tone" = skin_tone, \
	)

/mob/living/carbon/human/after_deserialize()
	. = ..()
	backpack_setup = null //Make sure we don't repawn a new backpack

	if(ignore_persistent_spawn())
		return
	if(!loc) // We're loading into null-space because we were in an unsaved level or intentionally in limbo. Move them to the last valid spawn.
		if(istype(home_spawn))
			if(home_spawn.loc)
				forceMove(get_turf(home_spawn)) // Welcome home!
				return
			else // Your bed is in nullspace with you!
				QDEL_NULL(home_spawn)
		forceMove(get_spawn_turf()) // Sorry man. Your bed/cryopod was not set.

/mob/living/carbon/human/setup(species_name, datum/dna/new_dna)
	//If we're loading from save, go through setup using the existing dna loaded from save
	if(persistent_id && dna)
		. = ..(null, dna)
	else
		. = ..()

/mob/living/carbon/human/Initialize()
	. = ..()
	LATE_INIT_IF_SAVED

/mob/living/carbon/human/LateInitialize()
	. = ..()
	if(persistent_id)
		set_move_intent(GET_DECL(LOAD_CUSTOM_SV("move_intent")))

		//Apply saved appearance (appearance may differ from DNA)
		eye_colour         = LOAD_CUSTOM_SV("eye_colour")
		facial_hair_colour = LOAD_CUSTOM_SV("facial_hair_colour")
		hair_colour        = LOAD_CUSTOM_SV("hair_colour")
		skin_colour        = LOAD_CUSTOM_SV("skin_colour")
		skin_tone          = LOAD_CUSTOM_SV("skin_tone")

	for(var/obj/item/I in contents)
		I.hud_layerise()

	// Refresh the items in contents to make sure they show up.
	for(var/s in species.hud.gear)
		var/list/gear = species.hud.gear[s]
		var/obj/item/I = get_equipped_item(gear["slot"])
		if(istype(I))
			I.screen_loc = gear["loc"]
	
	//Important to regen icons here, since we skipped on that before load!
	refresh_visible_overlays()

	CLEAR_ALL_SV //Clear saved vars

/mob/living/carbon/human/should_save()
	. = ..()
	if(mind && !mind.finished_chargen)
		return FALSE // We don't save characters who aren't finished CG.

// Don't let it update icons during initialize
// Can't avoid upstream code from doing it, so just postpone it
/mob/living/carbon/human/update_icon()
	if(!(atom_flags & ATOM_FLAG_INITIALIZED))
		queue_icon_update() //Queue it later instead
		return
	. = ..()