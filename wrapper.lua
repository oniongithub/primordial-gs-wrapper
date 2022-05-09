local entity = {} entity.__index = entity

entity.get_local_player = function()
    local local_player = entity_list.get_local_player()

    if (local_player and local_player:is_player()) then
        return local_player:get_index()
    end
end

entity.get_all = function(classname)
    if (classname and type(classname) == "string") then
        return entity_list.get_entities_by_name(classname)
    else
        local indicies = {}
        
        for i = 1, entity_list.get_highest_entity_index() do
            local ent = entity_list.get_entity(i)

            if (ent) then
                table.insert(indicies, i)
            end
        end
    end
end

entity.get_players = function(enemies_only)
    return entity_list.get_players(type(enemies_only) ~= "boolean" and false or enemies_only)
end

entity.get_game_rules = function()
    return { type = 3 }
end

entity.get_player_resource = function()
    return { type = 2 }
end

entity.get_classname = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent) then
        return ent:get_class_name()
    end
end

entity.set_prop = function(ent, propname, value, array_index)
    if (type(ent) == "table") then
        if (ent.type == 3) then
            game_rules.set_prop(propname, value, array_index)
        else
            player_resource.set_prop(propname, value, array_index)
        end
    else
        ent = entity_list.get_entity(ent)

        if (ent) then
            ent:set_prop(propname, value, array_index)
        end
    end
end

entity.get_prop = function(ent, propname, array_index)
    if (type(ent) == "table") then
        if (ent.type == 3) then
            game_rules.get_prop(propname, array_index)
        else
            player_resource.get_prop(propname, array_index)
        end
    else
        ent = entity_list.get_entity(ent)

        if (ent) then
            ent:get_prop(propname, array_index)
        end
    end
end

entity.is_enemy = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent and ent:is_player()) then
        return ent:is_enemy()
    end

    return false
end

entity.is_alive = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent and ent:is_player()) then
        return ent:is_alive()
    end

    return false
end

entity.is_dormant = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent) then
        return ent:is_dormant()
    end

    return false
end

entity.get_player_name = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent and ent:is_player()) then
        return ent:get_name()
    end

    return ""
end

entity.get_player_weapon = function(ent)
    ent = entity_list.get_entity(ent)

    if (ent and ent:is_player() and ent:is_alive() and not ent:is_dormant()) then
        local weap = ent:get_active_weapon()

        if (weap and weap:is_weapon()) then
            return weap:get_index()
        end
    end
end

entity.hitbox_position = function(player, hitbox)
    player = entity_list.get_entity(player)

    if (player and player:is_player() and player:is_alive() and not player:is_dormant()) then
        if (type(hitbox) == "number") then
            local pos = player:get_hitbox_pos(hitbox)
            return pos.x, pos.y, pos.z
        else
            -- gs documentation is so dogshit the string hitboxes aren't listed.
        end
    end
end

entity.get_origin = function(player)
    player = entity_list.get_entity(player)

    if (player and player:is_player() and player:is_alive() and not player:is_dormant()) then
        local pos = player:get_render_origin()
        return pos.x, pos.y, pos.z
    end
end

local globals = {} globals.__index = globals

globals.realtime = global_vars.real_time
globals.curtime = global_vars.cur_time
globals.frametime =global_vars.frame_time
globals.absoluteframetime = global_vars.absolute_frame_time
globals.maxplayers = global_vars.max_clients
globals.tickcount = global_vars.tick_count
globals.tickinterval = global_vars.interval_per_tick
globals.framecount = global_vars.frame_count
globals.mapname = engine.get_level_name_short
globals.lastoutgoingcommand = engine.get_last_outgoing_command
globals.oldcommandack = engine.get_last_acknowledged_command
globals.commandack = engine.get_last_acknowledged_command
globals.chokedcommands = engine.get_choked_commands

local renderer = {} renderer.__index = renderer
renderer.fonts = {
    segoe_large = render.create_font("Segoe UI", 16, 250, e_font_flags.ANTIALIAS),
    segoe_regular = render.create_font("Segoe UI", 12, 250, e_font_flags.ANTIALIAS),
    segoe_small = render.create_font("Segoe UI", 8, 250, e_font_flags.ANTIALIAS),
}

renderer.measure_text = function(flags, ...)
    local text_table, text = {...}, ""

    for i = 1, #text_table do
        if (type(text_table[i]) == "string") then
            text = text .. text_table[i]
        end
    end

    local font = renderer.fonts.segoe_regular

    if (type(flags) == "string" and flags ~= "") then
        if (string.find(flags, "-")) then 
            font = renderer.fonts.segoe_small
        elseif (string.find(flags, "+")) then
            font = renderer.fonts.segoe_large
        end
    end

    local text_size = render.get_text_size(font, text)
    return text_size.x, text_size.y
end

renderer.text = function(x, y, r, g, b, a, flags, max_width, ...)
    local font, text_table, text, color = renderer.fonts.segoe_regular, {...}, "", color_t(r, g, b, a)

    for i = 1, #text_table do
        if (type(text_table[i]) == "string") then
            text = text .. text_table[i]
        end
    end

    if (type(flags) == "string" and flags ~= "") then
        if (string.find(flags, "-")) then 
            font = renderer.fonts.segoe_small
        elseif (string.find(flags, "+")) then
            font = renderer.fonts.segoe_large
        end
    end

    local text_size, pos = render.get_text_size(font, text), vec2_t(x, y)

    if (type(flags) == "string" and flags ~= "") then
        if (string.find(flags, "c")) then 
            pos = vec2_t(pos.x - text_size.x / 2, pos.y - text_size.y / 2)
        end
    end

    if (max_width and max_width > 0) then
        render.push_clip(pos, vec2_t(text_size.y, max_width))
    end

    -- not using centering arg cause we need the pos anyway for the clip
    render.text(font, text, pos, color, false)

    render.pop_clip()
end

renderer.rectangle = function(x, y, w, h, r, g, b, a)
    render.rect_filled(vec2_t(x, y), vec2_t(w, h), color_t(r, g, b, a))
end

renderer.line = function(xa, ya, xb, yb, r, g, b, a)
    render.line(vec2_t(xa, ya), vec2_t(xb, yb), color_t(r, g, b, a))
end

renderer.gradient = function(x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, horizontal)
    render.rect_fade(vec2_t(x, y), vec2_t(w, h), color_t(r1, g1, b1, a1), color_t(r2, g2, b2, a2), horizontal)
end

-- will make a custom poly function later
renderer.circle = function(x, y, r, g, b, a, radius, start_degrees, percentage)
    render.circle_filled(vec2_t(x, y), radius, color_t(r, g, b, a))
end

-- same for this
renderer.circle_outline = function(x, y, r, g, b, a, radius, start_degrees, percentage, thickness)
    render.circle(vec2_t.new(x, y), radius, color_t.new(r, g, b, a), thickness)
end

renderer.triangle = function(x0, y0, x1, y1, x2, y2, r, g, b, a)
    render.polygon({ vec2_t(x0, y0), vec2_t(x1, y1), vec2_t(x2, y2) }, color_t(r, g, b, a))
end

renderer.world_to_screen = function(x, y, z)
    local pos = render.world_to_screen(vec3_t(x, y, z))

    if (pos) then
        return pos.x, pos.y
    end
end

renderer.load_svg = function(contents, width, height)
    return render.load_image_buffer(contents)
end

renderer.load_png = function(contents, width, height)
    return render.load_image_buffer(contents)
end

renderer.load_jpg = function(contents, width, height)
    return render.load_image_buffer(contents)
end

renderer.load_rgba = function(contents, width, height)
    return render.load_image_buffer(contents)
end

renderer.texture = function(id, x, y, w, h, r, g, b, a, mode)
    render.texture(id, vec2_t(x, y), vec2_t(w, h), color_t(r, g, b, a))
end

local client = {} client.__index = client
client.callback_table = {
    { "paint", e_callbacks.PAINT },
    { "run_command", e_callbacks.SETUP_COMMAND },
    { "setup_command", e_callbacks.RUN_COMMAND },
    { "aim_hit", e_callbacks.AIMBOT_HIT },
    { "aim_fire", e_callbacks.AIMBOT_SHOOT },
    { "aim_miss", e_callbacks.AIMBOT_MISS },
}

client.set_event_callback = function(event_name, callback)
    for i = 1, #client.callback_table do
        if (event_name == client.callback_table[i][1]) then
            if (event_name == "run_command") then
                callbacks.add(e_callbacks.SETUP_COMMAND, function(ctx)
                    callback({ chokedcommands = engine.get_choked_commands(), command_number = ctx.command_number })
                end)
            elseif (event_name == "aim_hit") then
                callbacks.add(e_callbacks.AIMBOT_HIT, function(ctx)
                    callback({ id = ctx.id, target = ctx.player:get_index(), hit_chance = ctx.aim_hitchance, hitgroup = ctx.aim_hitgroup, damage = ctx.aim_damage })
                end)
            elseif (event_name == "aim_fire") then
                callbacks.add(e_callbacks.AIMBOT_SHOOT, function(ctx)
                    callback({ id = ctx.id, target = ctx.player:get_index(), hit_chance = ctx.hitchance, hitgroup = ctx.hitgroup, damage = ctx.damage, backtrack = ctx.backtrack_ticks, high_priority = false, interpolated = false, extrapolated = extrapolated_ticks > 0 and true or false, teleported = false, tick = global_vars.tick_count(), x = ctx.hitpoint_pos.x, y = ctx.hitpoint_pos.y, z = ctx.hitpoint_pos.z })
                end)
            elseif (event_name == "aim_miss") then
                callbacks.add(e_callbacks.AIMBOT_MISS, function(ctx)
                    callback({ id = ctx.id, target = ctx.player:get_index(), hit_chance = ctx.aim_hitchance, hitgroup = ctx.aim_hitgroup, reason = ctx.reason_string })
                end)
            else
                callbacks.add(client.callback_table[i][2], function(ctx)
                    callback(ctx)
                end)
            end
        end
    end
end

client.unset_event_callback = function()
    -- to do
end

client.log = function(...)
    local text, text_table = "", {...}

    for i = 1, #text_table do
        if (type(text_table[i] == "string")) then
            text = text .. text_table[i]
        end
    end

    client.log(text)
end

client.color_log = function(r, g, b, ...)
    local text, text_table = "", {...}

    for i = 1, #text_table do
        if (type(text_table[i] == "string")) then
            text = text .. text_table[i]
        end
    end

    client.log(color_t(r, g, b), text)
end

client.error_log = function(...)
    local text, text_table = "", {...}

    for i = 1, #text_table do
        if (type(text_table[i] == "string")) then
            text = text .. text_table[i]
        end
    end

    client.log(color_t(255, 0, 0), "error - " .. text)
end

client.exec = function(...)
    local text, text_table = "", {...}

    for i = 1, #text_table do
        if (type(text_table[i] == "string")) then
            text = text .. text_table[i]
        end
    end

    engine.execute_cmd(text)
end

client.userid_to_entindex = function(userid)
    local ent = entity_list.get_player_from_userid(userid)

    if (ent and ent:is_player()) then
        return ent:get_index()
    end
end

client.draw_debug_text = function()
    -- who the fuck uses this
end

client.draw_hitboxes = function()
    -- and who the fuck uses this either
end
