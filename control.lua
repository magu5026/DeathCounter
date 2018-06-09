MODNAME = "DeathCounter"

local function NeedMigration(data)
	if data 
	 and data.mod_changes 
	 and data.mod_changes[MODNAME] 
	 and data.mod_changes[MODNAME].old_version then 
		return true 
	end
	return false
end

function FormatVersion(version)
	return string.format("%02d.%02d.%02d", string.match(version, "(%d+).(%d+).(%d+)"))
end

function GetOldVersion(data)
	return FormatVersion(data.mod_changes[MODNAME].old_version)
end


local function Init()
	global.DeathCounter = global.DeathCounter or {}
	global.DeathCounter.Death = global.DeathCounter.Death or {}
	global.DeathCounter.Counter = global.DeathCounter.Counter or {}
	global.DeathCounter.Counter["sum"] = global.DeathCounter.Counter["sum"] or 0
	global.DeathCounter.Last = global.DeathCounter.Last or {}
	
	for index,player in pairs(game.players) do
		if not player.gui.top.deathcounter then
			player.gui.top.add{type = "button", name = "deathcounter", caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Counter["sum"]}}		
		else
			player.gui.top.deathcounter.caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Counter["sum"]}
		end
		global.DeathCounter.Death[index] = global.DeathCounter.Death[index] or {}
	end
end


local function Migration(data)
	if NeedMigration(data) then
		local old_version = GetOldVersion(data)
		if old_version < "00.16.02" then
			local death = global.DeathCounter.Count
			game.print(death)
			global.DeathCounter.Counter["sum"] = death
			for index,player in pairs(game.players) do
				local i = 0
				for _,cause in pairs(global.DeathCounter.Death[index]) do
					i = i + cause.count
				end
				global.DeathCounter.Counter[index] = i
			end
		end
	end
end


local function GetAllCauseList()
	local cause_list = {}
	for _,death in pairs(global.DeathCounter.Death) do
		for _,cause in pairs(death) do
			for index,item in pairs(cause_list) do	
				if item.name == cause.name then
					cause_list[index].count = cause_list[index].count + cause.count
					goto continue
				end
			end
			table.insert(cause_list,{name=cause.name, count=cause.count, localised_name = cause.localised_name})
			::continue::
		end
	end
	return cause_list
end


local function DrawGuiPlayerDeath(me,player_index)
	local main_body = me.gui.center.dc.mainflow.mainheader.mainbody
	if main_body.deathlist then main_body.deathlist.destroy() end
	local death_list = main_body.add{type = "flow", name = "deathlist", direction = "horizontal"}
	
	if player_index == 0 then
		local player_list_frame = death_list.add{type = "frame", name = "playerlistframe"}
		local player_list_table = player_list_frame.add{type = "table", name = "playerlisttable", column_count = 2}
		local death_list_frame = death_list.add{type = "frame", name = "deathlistframe"}
		local death_list_table = death_list_frame.add{type = "table", name = "deathlisttable", column_count = 2}
		player_list_table.add{type = "label", name = "playername", caption = {"deathcounter_deathlist_pla_name"}}
		player_list_table.add{type = "label", name = "deathcount", caption = {"deathcounter_deathlist_pla_count"}}
		for index,player in pairs(game.players) do
			player_list_table.add{type = "label", name = "player"..index, caption = player.name}
			local death = 0
			if global.DeathCounter.Counter[index] then
				death = global.DeathCounter.Counter[index]
			end
			player_list_table.add{type = "label", name = "death"..index, caption = death}
		end
		death_list_table.add{type = "label", name = "causename", caption = {"deathcounter_deathlist_name"}}
		death_list_table.add{type = "label", name = "causecount", caption = {"deathcounter_deathlist_count"}}
		local cause_list = GetAllCauseList()
		if #cause_list == 0 then
			death_list_table.add{type = "label", name = "nocause", caption = "no death"}
		else
			for i,cause in pairs(cause_list) do
				death_list_table.add{type = "label", name = "cause"..i, caption = cause.localised_name}
				death_list_table.add{type = "label", name = "causecount"..i, caption = cause.count}
			end
		end
	else
		local death_list_frame = death_list.add{type = "frame", name = "deathlistframe", caption = {"", game.players[player_index].name, " : ", global.DeathCounter.Counter[player_index]}}
		local death_list_table = death_list_frame.add{type = "table", name = "deathlisttable", column_count = 2}
		death_list_table.add{type = "label", name = "causename", caption = {"deathcounter_deathlist_name"}}
		death_list_table.add{type = "label", name = "causecount", caption = {"deathcounter_deathlist_count"}}
		if not global.DeathCounter.Counter[player_index] then
			death_list_table.add{type = "label", name = "nocause", caption = "no death"}
		else
			for i,cause in pairs(global.DeathCounter.Death[player_index]) do
				death_list_table.add{type = "label", name = "cause"..i, caption = cause.localised_name}
				death_list_table.add{type = "label", name = "causecount"..i, caption = cause.count}	
			end
		end
	end
end


local function DrawGui(me)
	if me.gui.center.dc.mainflow then me.gui.center.dc.mainflow.destroy() end
	local main_flow = me.gui.center.dc.add{type = "flow", name = "mainflow", direction = "horizontal"}
	local main_header = main_flow.add{type = "flow", name = "mainheader", direction = "vertical"}
	main_flow.add{type = "sprite-button", name = "closedc", style = "red_slot_button", sprite = "utility/set_bar_slot"}
	main_header.add{type = "label", name = "mainheaderlabel", caption = {"deathcounter_deathlist"}}
	main_header.mainheaderlabel.style.font = "default-button"
	local main_body = main_header.add{type = "flow", name = "mainbody", direction = "horizontal"}
	local player_list = main_body.add{type = "flow", name = "playerlist", direction = "vertical"}
	
	local combo = player_list.add{type = "drop-down", name = "playercombo"}
	combo.add_item({"deathcounter_all_player"})
	for _,player in pairs(game.players) do
		combo.add_item(player.name)
	end
	
	local last_index = global.DeathCounter.Last[me.index]
	if last_index then
		combo.selected_index = last_index + 1
	else
		combo.selected_index = 1
	end
end


local function ReGui()
	for index,player in pairs(game.players) do
		player.gui.top.deathcounter.caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Counter["sum"]}
		if player.gui.center.dc then
			DrawGui(player)
			local last_index = global.DeathCounter.Last[index]
			if last_index then
				DrawGuiPlayerDeath(player,last_index)
			else
				DrawGuiPlayerDeath(player,0)
			end
		end
	end
end


local function PlayerDied(event)
	global.DeathCounter.Counter["sum"] = global.DeathCounter.Counter["sum"] + 1
	local index = event.player_index
	local cause = event.cause or {name = "undefined", localised_name = {"deathcounter_undefined_localised_name"}}
	if not global.DeathCounter.Counter[index] then
		global.DeathCounter.Counter[index] = 1
	else
		global.DeathCounter.Counter[index] = global.DeathCounter.Counter[index] + 1
	end	
	if not global.DeathCounter.Death[index][cause.name] then
		global.DeathCounter.Death[index][cause.name] = {count = 1, name = cause.name, localised_name = cause.localised_name}
	else
		global.DeathCounter.Death[index][cause.name].count = global.DeathCounter.Death[index][cause.name].count + 1
	end
	ReGui()
end


local function GuiClick(event)
	local me = game.players[event.player_index]
	if event.element.name == "deathcounter" then
		if me.gui.center.dc then
			me.gui.center.dc.destroy()
		else
			me.gui.center.add{type = "frame", name = "dc"}
			DrawGui(me)
			DrawGuiPlayerDeath(me,0)
		end
	elseif event.element.name == "closedc" then
		if me.gui.center.dc then
			me.gui.center.dc.destroy()
		end
	end
end


local function SelectionChanged(event)
	local element = event.element
	local me = game.players[event.player_index]
	if element.name == "playercombo" then
		index = element.selected_index - 1
		global.DeathCounter.Last[event.player_index] = index
		DrawGuiPlayerDeath(me,index)
	end
end








function on_init()
	Init()
end

function on_configuration_changed(data)
	Init()
	Migration(data)
	ReGui()
end	

function on_gui_click(event)
	GuiClick(event)
end

function on_player_died(event)
	PlayerDied(event)
end

function on_player_joined_game(event)
	Init()
	ReGui()
end

function on_gui_selection_state_changed(event)
	SelectionChanged(event)
end



script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_gui_click,on_gui_click)
script.on_event(defines.events.on_player_died,on_player_died)
script.on_event(defines.events.on_player_joined_game,on_player_joined_game)
script.on_event(defines.events.on_gui_selection_state_changed,on_gui_selection_state_changed)