require("lua.events")

function ON_INIT()
	on_init()
end

function ON_CONFIGURATION_CHANGED(data)
	on_configuration_changed(data)
end	

function ON_GUI_CLICK(event)
	on_gui_click(event)
end

function ON_PLAYER_DIED(event)
	on_player_died(event)
end

function ON_PLAYER_JOINED_GAME(event)
	on_player_joined_game(event)
end


script.on_init(ON_INIT)
script.on_configuration_changed(ON_CONFIGURATION_CHANGED)
script.on_event(defines.events.on_gui_click,ON_GUI_CLICK)
script.on_event(defines.events.on_player_died,ON_PLAYER_DIED)
script.on_event(defines.events.on_player_joined_game,ON_PLAYER_JOINED_GAME)
