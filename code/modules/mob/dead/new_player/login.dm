/mob/dead/new_player/Login()
	if(!client)
		return
	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()
		client.set_db_player_flags()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	. = ..()
	if(!. || !client)
		return FALSE

	var/list/locinfo = client.get_loc_info()

	to_chat(src,  {"<span class='greenannounce'> ================================</span>
<span class='greenannounce'> >> WHITE DREAM UAC</span>
<span class='greenannounce'> >> ПОЛЬЗОВАТЕЛЬ: [capitalize(client.ckey)]</span>
<span class='greenannounce'> >> СТРАНА: [capitalize(locinfo["country"])]</span>
<span class='greenannounce'> >> ИГРОВОЕ ВРЕМЯ: [capitalize(client.get_exp_living())]</span>
<span class='greenannounce'> >> ВХОД РАЗРЕШЁН</span>
<span class='greenannounce'> ================================</span>"})

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	if(GLOB.admin_notice)
		to_chat(src, "<span class='notice'> >> <b>ВАЖНАЯ ЗАМЕТКА:</b>\n \t [GLOB.admin_notice]</span>")

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, "<span class='notice'> >> <b>Сервер сообщает:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]</span>")

	sight |= SEE_TURFS

	new_player_panel()
	client.playtitlemusic()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		var/postfix
		if(tl > 0)
			postfix = "через [DisplayTimeText(tl)]"
		else
			postfix = "скоро"
		to_chat(src, " >> Пожалуйста, настройте своего персонажа и нажмите кнопку \"Готов\". Игра начнётся [postfix].")

	if (!GLOB.donators[ckey]) //It doesn't exist yet
		load_donator(ckey)

	client.update_metabalance_cache()
	client.proverka_na_pindosov()
	client.proverka_na_obemky()

	fit_lobbyscreen_or_die()

// looping it
/mob/dead/new_player/proc/fit_lobbyscreen_or_die()
	if (!client || !src)
		return
	if (client.view != "19x15")
		spawn(10)
			fit_lobbyscreen_or_die()
			spawn(100)
				if (client.view != "19x15" && src && client) // double recursion
					fit_lobbyscreen_or_die()
	client.view = "19x15"
	client.fit_viewport()
