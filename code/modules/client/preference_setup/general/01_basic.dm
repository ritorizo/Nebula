/datum/preferences
	var/gender = MALE					//gender of character (well duh)
	var/spawnpoint = "Default" 			//where this character will spawn (0-2).
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round

/datum/category_item/player_setup_item/physical/basic
	name = "Basic"
	sort_order = 1

/datum/category_item/player_setup_item/physical/basic/load_character(var/savefile/S)
	from_file(S["gender"],                pref.gender)
	from_file(S["spawnpoint"],            pref.spawnpoint)
	from_file(S["real_name"],             pref.real_name)
	from_file(S["name_is_always_random"], pref.be_random_name)

/datum/category_item/player_setup_item/physical/basic/save_character(var/savefile/S)
	to_file(S["gender"],                  pref.gender)
	to_file(S["spawnpoint"],              pref.spawnpoint)
	to_file(S["real_name"],               pref.real_name)
	to_file(S["name_is_always_random"],   pref.be_random_name)

/datum/category_item/player_setup_item/physical/basic/sanitize_character()
	var/decl/species/S =   get_species_by_key(pref.species) || get_species_by_key(GLOB.using_map.default_species)
	pref.gender             = sanitize_inlist(pref.gender, S.genders, pick(S.genders))
	pref.spawnpoint         = sanitize_inlist(pref.spawnpoint, spawntypes(), initial(pref.spawnpoint))
	pref.be_random_name     = sanitize_integer(pref.be_random_name, 0, 1, initial(pref.be_random_name))

/datum/category_item/player_setup_item/physical/basic/content()
	. = list()
	. += "<b>Name:</b> "
	. += "<a href='?src=\ref[src];rename=1'><b>[pref.real_name]</b></a><br>"
	. += "<a href='?src=\ref[src];random_name=1'>Randomize Name</A><br>"
	. += "<a href='?src=\ref[src];always_random_name=1'>Always Random Name: [pref.be_random_name ? "Yes" : "No"]</a>"
	. += "<hr>"

	var/decl/pronouns/G = get_pronouns_by_gender(pref.gender)
	. += "<b>Gender:</b> <a href='?src=\ref[src];gender=1'>[capitalize(G.name)]</a><br>"
	. += "<b>Spawn point</b>: <a href='?src=\ref[src];spawnpoint=1'>[pref.spawnpoint]</a>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/physical/basic/OnTopic(var/href,var/list/href_list, var/mob/user)
	var/decl/species/S = get_species_by_key(pref.species)

	if(href_list["rename"])
		var/raw_name = input(user, "Choose your character's name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))

			var/decl/cultural_info/check = GET_DECL(pref.cultural_info[TAG_CULTURE])
			var/new_name = check.sanitize_name(raw_name, pref.species)
			if(filter_block_message(user, new_name))
				return TOPIC_NOACTION

			if(new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				to_chat(user, "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>")
				return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = pref.get_random_name()
		return TOPIC_REFRESH

	else if(href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	else if(href_list["gender"])
		var/new_gender = input(user, "Choose your character's gender:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.gender) as null|anything in S.genders
		S = get_species_by_key(pref.species)
		if(new_gender && CanUseTopic(user) && (new_gender in S.genders))
			pref.gender = new_gender
			if(!(pref.f_style in S.get_facial_hair_styles(pref.gender)))
				ResetFacialHair()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["spawnpoint"])
		var/list/spawnkeys = list()
		for(var/spawntype in spawntypes())
			spawnkeys += spawntype
		var/choice = input(user, "Where would you like to spawn when late-joining?") as null|anything in spawnkeys
		if(!choice || !spawntypes()[choice] || !CanUseTopic(user))	return TOPIC_NOACTION
		pref.spawnpoint = choice
		return TOPIC_REFRESH

	return ..()
