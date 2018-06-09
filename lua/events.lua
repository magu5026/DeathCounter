require("lua.lib")

MODNAME = "DeathCounter"


local function Init()
	global.DeathCounter = global.DeathCounter or {}
	global.DeathCounter.Death = global.DeathCounter.Death or {}
	global.DeathCounter.Count = global.DeathCounter.Count or 0
	global.DeathCounter.Last = global.DeathCounter.Last or {}
	for index in pairs(game.players) do
		if not game.players[index].gui.top.deathcounter then
			game.players[index].gui.top.add{type = "button", name = "deathcounter", caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Count}}		
		else
			game.players[index].gui.top.deathcounter.caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Count}
		end
		global.DeathCounter.Death[index] = global.DeathCounter.Death[index] or {}
	end
end

local function Migration(data)
	if NeedMigration(data,MODNAME) then
		if GetOldVersion(data,MODNAME) < "00.00.00" then
		
		end
	end
end

local function DrawGuiPlayerDeath(player,death_list)
	local main_body = player.gui.center.dc.mainflow.mainheader.mainbody
	if main_body.deathlist then
		main_body.deathlist.destroy()
	end
	local death_list_table = main_body.add{type = "table", name = "deathlist", column_count = 2}
	death_list_table.add{type = "label", name = "causename", caption = {"deathcounter_deathlist_name"}}
	death_list_table.add{type = "label", name = "causecount", caption = {"deathcounter_deathlist_count"}}
	if #death_list == 0 then
		death_list_table.add{type = "label", name = "nocause", caption = "no death"}
	else
		for i,item in pairs(death_list) do
			death_list_table.add{type = "label", name = "causename"..i, caption = item.localised_name}
			death_list_table.add{type = "label", name = "causecount"..i, caption = item.count}	
		end
	end
end

local function GetPlayDeathList(player, player_index)
	local death_list = {}
	if player_index == 0 then
		for _,death in pairs(global.DeathCounter.Death) do
			for _,cause in pairs(death) do
				for index,item in pairs(death_list) do	
					if item.name == cause.name then
						death_list[index].count = death_list[index].count + cause.count
						goto continue
					end
				end
				table.insert(death_list,{name=cause.name, count=cause.count, localised_name = cause.localised_name })
				::continue::
			end
		end	
	else
		for _,cause in pairs(global.DeathCounter.Death[player_index]) do
			table.insert(death_list,{name=cause.name, count=cause.count, localised_name = cause.localised_name })
		end
	end
	DrawGuiPlayerDeath(player,death_list)
end

local function DrawGui(player)
	if player.gui.center.dc.mainflow then player.gui.center.dc.mainflow.destroy() end
	local main_flow = player.gui.center.dc.add{type = "flow", name = "mainflow", direction = "horizontal"}
	local main_header = main_flow.add{type = "flow", name = "mainheader", direction = "vertical"}
	main_flow.add{type = "sprite-button", name = "closedc", style = "red_slot_button", sprite = "utility/set_bar_slot"}
	main_header.add{type = "label", name = "mainheaderlabel", caption = {"deathcounter_deathlist"}}
	main_header.mainheaderlabel.style.font = "default-button"
	local main_body = main_header.add{type = "flow", name = "mainbody", direction = "horizontal"}
	local player_list = main_body.add{type = "flow", name = "playerlist", direction = "vertical"}
	if #global.DeathCounter.Death > 0 then
		player_list.add{type = "button", name = "player0", caption = {"deathcounter_all_player"}}
	end
	for index,_ in pairs(global.DeathCounter.Death) do
		player_list.add{type = "button", name = "player"..index, caption = game.players[index].name}
	end
end

local function GuiClick(event)
	local player = game.players[event.player_index]
	if event.element.name == "deathcounter" then
		if player.gui.center.dc then
			player.gui.center.dc.destroy()
		else
			player.gui.center.add{type = "frame", name = "dc"}
			DrawGui(player)
		end
		return
	end
	if event.element.name == "closedc" then
		if player.gui.center.dc then
			player.gui.center.dc.destroy()
		end
		return
	end
	if event.element.name:match("player(%d+)") then
		local index_string = event.element.name:sub(7)
		local index = tonumber(index_string)
		global.DeathCounter.Last[event.player_index] = index
		GetPlayDeathList(player,index)
		return
	end
end

local function PlayerDied(event)
	global.DeathCounter.Count = global.DeathCounter.Count + 1
	local index = event.player_index
	local player = game.players[index]
	local cause = event.cause or {name = "undefined", localised_name = {"deathcounter_undefined_localised_name"}}
	if not global.DeathCounter.Death[index][cause.name] then
		global.DeathCounter.Death[index][cause.name] = {count = 1, name = cause.name, localised_name = cause.localised_name}
	else
		global.DeathCounter.Death[index][cause.name].count = global.DeathCounter.Death[index][cause.name].count + 1
	end
	for i in pairs(game.players) do
		game.players[i].gui.top.deathcounter.caption = {"", {"deathcounter_button"}, " : ", global.DeathCounter.Count}
		if game.players[i].gui.center.dc then
			local last_index = global.DeathCounter.Last[i]
			if last_index then
				GetPlayDeathList(game.players[i],last_index)
			end
		end
	end
end

local function ReGui()
	for index,player in pairs(game.players) do
		if player.gui.center.dc then
			DrawGui(player)
			local last_index = global.DeathCounter.Last[index]
			if last_index then
				GetPlayDeathList(player,last_index)
			end
		end
	end
end







function on_init()
	Init()
end

function on_configuration_changed(data)
	Init()
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