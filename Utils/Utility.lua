-- sigil collection UI stuff
SMODS.current_mod.custom_collection_tabs = function()
	return { UIBox_button {
        count = G.ACTIVE_MOD_UI and modsCollectionTally(G.P_CENTER_POOLS["Sigil"]),
        button = 'your_collection_sigil',
        label = {"Sigils"}, minw = 5, id = 'your_collection_sigil'
    }}
end

G.FUNCS.your_collection_sigil = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = create_UIBox_your_collection_sigil(),
    }
end

create_UIBox_your_collection_sigil = function()
    return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Sigil, {5,5}, {
        snap_back = true,
        infotip = localize('ml_edition_sigil_enhancement_explanation'),
        hide_single_page = true,
        collapse_single_page = true,
        center = 'c_base',
        h_mod = 1.03,
        modify_card = function(card, center)
            card:set_sigil(center.key, 1)
        end,
    })
end

function can_apply_sigil(card, sigil_name)
    local tempcard = card
    if tempcard.sigil == nil then return true end
    if not tempcard.sigil then return true end

    if tempcard.sigil[1] == nil then
        tempcard.sigil[1] = false
    end
    if tempcard.sigil[2] == nil then
        tempcard.sigil[2] = false
    end

    if tempcard.sigil[1] == "insc_" .. sigil_name[1] or tempcard.sigil[2] == "insc_" .. sigil_name[1] then
        return false
    end
    if tempcard.sigil[1] == "insc_" .. sigil_name[2] or tempcard.sigil[2] == "insc_" .. sigil_name[2] then
        return false
    end

    if not tempcard.sigil[1] or not tempcard.sigil[2] then
        return true
    end

    return false
end


function Card:get_sigil(index)
	if self.sigil == nil then
        return false
    end
    if self.sigil[index] ~= nil then
        return self.sigil[index]
    end
    return false
end

function create_consumable(card_type,tag,message,extra, thing1, thing2)
    extra=extra or {}
    
    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.0,
        func = (function()
                local card = create_card(card_type,G.consumeables, nil, nil, thing1, thing2, extra.forced_key or nil, tag)
                card:add_to_deck()
                if extra.edition~=nil then
                    card:set_edition(extra.edition,true,false)
                end
                if extra.eternal~=nil then
                    card.ability.eternal=extra.eternal
                end
                if extra.perishable~=nil then
                    card.ability.perishable = extra.perishable
                    if tag=='v_epilogue' then
                        card.ability.perish_tally=get_voucher('epilogue').config.extra
                    else card.ability.perish_tally = G.GAME.perishable_rounds
                    end
                end
                if extra.extra_ability~=nil then
                    card.ability[extra.extra_ability]=true
                end
                G.consumeables:emplace(card)
                G.GAME.consumeable_buffer = 0
                if message~=nil then
                    card_eval_status_text(card,'extra',nil,nil,nil,{message=message})
                end
        return true
    end)}))
end

function create_joker(card_type,tag,message,extra, rarity)
    extra=extra or {}
    
    G.GAME.joker_buffer = G.GAME.joker_buffer + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.0,
        func = (function()
                local card = create_card(card_type, G.joker, nil, rarity, nil, nil, extra.forced_key or nil, tag)
                card:add_to_deck()
                if extra.edition~=nil then
                    card:set_edition(extra.edition,true,false)
                end
                if extra.eternal~=nil then
                    card.ability.eternal=extra.eternal
                end
                if extra.perishable~=nil then
                    card.ability.perishable = extra.perishable
                    if tag=='v_epilogue' then
                        card.ability.perish_tally=get_voucher('epilogue').config.extra
                    else card.ability.perish_tally = G.GAME.perishable_rounds
                    end
                end
                if extra.extra_ability~=nil then
                    card.ability[extra.extra_ability]=true
                end
                G.jokers:emplace(card)
                G.GAME.joker_buffer = 0
                if message~=nil then
                    card_eval_status_text(card,'extra',nil,nil,nil,{message=message})
                end
        return true
    end)}))
end

insc_ability_calculate = function(card, equation, extra_value, exclusions, inclusions, do_round, only, extra_search)
  if do_round == nil then do_round = true end
  if only == nil then only = false end

  local operators = {
    ["+"] = function(a, b) return a + b end,
    ["-"] = function(a, b) return a - b end,
    ["*"] = function(a, b) return a * b end,
    ["/"] = function(a, b) return a / b end,
    ["%"] = function(a, b) return a % b end,
    ["="] = function(a, b) return b end,
  }
  
  local function round_int(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
  end

  local function round_hundredth(x)
    if x >= 0 then
      return math.floor(x * 100 + 0.5) / 100
    else
      return math.ceil(x * 100 - 0.5) / 100
    end
  end

  local function process_value(val)
    if type(val) == "number" then
      local res = operators[equation](val, extra_value)
      if do_round then
        if val % 1 ~= 0 then
          return round_hundredth(res)
        else
          return round_int(res)
        end
      else
        return res
      end
    else
      return val
    end
  end

  local function should_process(key, value)
    if type(key) ~= "string" then return true end
    if inclusions and next(inclusions) then
      local valid = false
      for _, prefix in ipairs(inclusions) do
        if (not only and key:sub(1, #prefix) == prefix) or (only and key == prefix) then
          valid = true; break
        end
      end
      if not valid then return false end
    end
    if exclusions and exclusions[key] ~= nil then
      if exclusions[key] == true or value == exclusions[key] then
        return false
      end
    end
    return true
  end

  local function process_table(t)
    for key, value in pairs(t) do
      if value ~= nil and should_process(key, value) then
        if type(value) == "number" then
          t[key] = process_value(value)
        elseif type(value) == "table" then
          process_table(value)
        end
      end
    end
  end

  local search_table = extra_search and card[extra_search] or card.ability

  if search_table then
    if type(search_table) == "number" then
      search_table = process_value(search_table)
    elseif type(search_table) == "table" then
      process_table(search_table)
    end
  end
end


insc_ability_get_items = function(card, equation, extra_value, exclusions, inclusions, do_round, only, extra_search)
  if do_round == nil then do_round = true end
  if only == nil then only = false end

  local keys = {}
  local values = {}

  local operators = {
    ["+"] = function(a, b) return a + b end,
    ["-"] = function(a, b) return a - b end,
    ["*"] = function(a, b) return a * b end,
    ["/"] = function(a, b) return a / b end,
    ["%"] = function(a, b) return a % b end,
    ["="] = function(a, b) return b end,
    ["nil"] = function(a, b) return a end,
  }

  local function round_int(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
  end
  local function round_hundredth(x)
    if x >= 0 then
      return math.floor(x * 100 + 0.5) / 100
    else
      return math.ceil(x * 100 - 0.5) / 100
    end
  end

  local function process_value(val)
    if type(val) == "number" then
      local res = operators[equation](val, extra_value)
      if do_round then
        if val % 1 ~= 0 then
          return round_hundredth(res)
        else
          return round_int(res)
        end
      else
        return res
      end
    else
      return val
    end
  end

  local function should_process(key, value)
    if type(key) ~= "string" then return true end
    if inclusions and next(inclusions) then
      local valid = false
      for _, prefix in ipairs(inclusions) do
        if (not only and key:sub(1, #prefix) == prefix) or (only and key == prefix) then
          valid = true; break
        end
      end
      if not valid then return false end
    end
    if exclusions and exclusions[key] ~= nil then
      if exclusions[key] == true or value == exclusions[key] then
        return false
      end
    end
    return true
  end

  local search_table = extra_search and card[extra_search] or card.ability

  if search_table then
    if type(search_table) == "number" then
      table.insert(keys, extra_search or "ability")
      table.insert(values, process_value(search_table))
    elseif type(search_table) == "table" then
      for key, value in pairs(search_table) do
        if value ~= nil and should_process(key, value) then
          table.insert(keys, key)
          table.insert(values, process_value(value))
        end
      end
    end
  end

  return keys, values
end

function toNum(big)
    big = tostring(big)
    big = big:gsub(",", "")
  return tonumber(big) or 0
end

function insc_add_custom_round_eval_row(name, foot, intrest, the_colour, sprite)
    the_colour = the_colour or HEX("bebebe")
    local width = G.round_eval.T.w - 0.51
    local scale = 0.9
    total_cashout_rows = (total_cashout_rows or 0) + 1
    delay(0.4)
    local rand = math.floor(math.random() * 100)
    if sprite == nil then
        sprite = false
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'before',delay = 0.5,
        func = function()
            local left_text = {}
            if intrest then
                table.insert(left_text, {n=G.UIT.T, config={text = intrest, scale = 0.8*scale, colour = the_colour, shadow = true, juice = true}})
            end
            if intrest then
                table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = name, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
            else
                table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = name, colours = {the_colour}, shadow = true, pop_in = 0, scale = 0.6*scale, silent = true})}})
            end
            local full_row = {n=G.UIT.R, config={align = "cm", minw = 5}, nodes={
                {n=G.UIT.C, config={padding = 0.05, minw = width*0.55, minh = 0.61, align = "cl"}, nodes=left_text},
                {n=G.UIT.C, config={padding = 0.05,minw = width*0.45, align = "cr"}, nodes={{n=G.UIT.C, config={align = "cm", id = 'dollar_insc_'..name .. tostring(total_cashout_rows).. tostring(rand)},nodes={}}}}
            }}
            G.round_eval:add_child(full_row,G.round_eval:get_UIE_by_ID('bonus_round_eval'))
            play_sound('cancel', 1)
            play_sound('highlight1', 1, 0.2)
            return true
        end
    }))
    if not sprite then
        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.38,
            func = function()
                    G.round_eval:add_child(
                            {n=G.UIT.R, config={align = "cm", id = 'dollar_row_insc_'..name .. tostring(total_cashout_rows).. tostring(rand)}, nodes={
                                {n=G.UIT.O, config={object = DynaText({string = {foot}, colours = {the_colour}, shadow = true, pop_in = 0, scale = 0.65, float = true})}}
                            }},
                            G.round_eval:get_UIE_by_ID('dollar_insc_'..name .. tostring(total_cashout_rows).. tostring(rand)))
                play_sound('coin3', 0.9+0.2*math.random(), 0.7)
                play_sound('coin6', 1.3, 0.8)
                return true
            end
        }))
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.38,
            func = function()
                    G.round_eval:add_child(
                            {n=G.UIT.R, config={align = "cm", id = 'dollar_row_insc_'..name .. tostring(total_cashout_rows).. tostring(rand)}, nodes={
                                {n=G.UIT.O, config={w=0.5,h=0.5 , object = sprite, hover = true, can_collide = false}},
                                {n=G.UIT.O, config={object = DynaText({string = {foot}, colours = {the_colour}, shadow = true, pop_in = 0, scale = 0.65, float = true})}},
                            }},
                            G.round_eval:get_UIE_by_ID('dollar_insc_'..name .. tostring(total_cashout_rows).. tostring(rand)))
                play_sound('coin3', 0.9+0.2*math.random(), 0.7)
                play_sound('coin6', 1.3, 0.8)
                return true
            end
        }))
    end
end

function UIBox:get_UIE_by_button(name)
  for _, uie in ipairs(self.nodes) do
    if uie.config and uie.config.button == name then
      return uie
    end
  end
end

function UIBox:get_UIE_by_func(fn_name)
  for _, uie in ipairs(self.nodes) do
    if uie.config and uie.config.func == fn_name then
      return uie
    end
  end
end



-- Death card stuff

local PO3 = nil

local deathcard_choosing = "condition"
BalatroInscrybed.PO3 = nil
function BalatroInscrybed.get_name()
  for o, p in pairs(G.P_CENTER_POOLS['Joker']) do
    if p.key == "j_insc_deathcard" then
      return p.name
    end
  end
    
end
    
function BalatroInscrybed.save_to_joker()
  if G.PROFILES[G.SETTINGS.profile].BalatroInscrybed_deathcard then
  local deathcard_ = G.PROFILES[G.SETTINGS.profile].BalatroInscrybed_deathcard
    for o, p in ipairs(G.P_CENTER_POOLS['Joker']) do
      if p.key == "j_insc_deathcard" then
        if deathcard_.condition ~= nil then
          p.deathcard_stats.condition = deathcard_.condition
        end
        if deathcard_.effect ~= nil then
          p.deathcard_stats.effect = deathcard_.effect 
        end
        if deathcard_.rarity ~= nil then
          p.rarity = deathcard_.rarity
        end
        if deathcard_.name ~= nil then
          p.name = deathcard_.name
        end
      end
    end
  else
    local deathcard_ = {}
  end
    

    
end

local inject_hook = SMODS.injectItems
function SMODS.injectItems(...)
   inject_hook()
   BalatroInscrybed.save_to_joker()
end

function BalatroInscrybed.save_deathcard_to_profile()
local deathcard = G.PROFILES[G.SETTINGS.profile].BalatroInscrybed_deathcard 
	for o, p in ipairs(G.P_CENTER_POOLS['Joker']) do
    if p.key == "j_insc_deathcard" then
      deathcard.condition = p.deathcard_stats.condition
      deathcard.effect = p.deathcard_stats.effect
      deathcard.rarity = p.rarity
      deathcard.name = p.name
    end
  end
  if not G.PROFILES[G.SETTINGS.profile].BalatroInscrybed_deathcard then
		G.PROFILES[G.SETTINGS.profile].BalatroInscrybed_deathcard = deathcard
	end
    
end

function deathcard_condtion(context, condition)
  if condition == nil then
    return false
  end
  if type(condition) == "table" then
    for i,v in pairs(condition) do
      if i == "hand_contains" then
        if context.joker_main and next(context.poker_hands[v]) then
          return true
        end
      end
      if i == "card_suit_scores" then
        if context.individual and context.cardarea == G.play then
          if context.other_card:is_suit(v) then 
            return true
          end
        end
      end
      if i == "full_hand_amount" then
        if context.joker_main and #context.full_hand <= v then
          return true
        end
      end
    end
    return false
  end
  if condition == "joker_main" then
    if context.joker_main then
      return true
    end
  end
  return false
end

function deathcard_effect(effect)
  if effect == nil then
    return {}
  end
  if type(effect) == "table" then
    for i,v in pairs(effect) do
      if i == "mult" then
        return { mult = v }
      end
      if i == "xmult" then
        return { xmult = v }
      end
      if i == "chips" then
        return { chips = v }
      end
      if i == "xchips" then
        return { xchips = v }
      end
      if i == "multperjokerslot" then
        local x_mult = (G.jokers.config.card_limit - #G.jokers.cards)
          for i = 1, #G.jokers.cards do
              if G.jokers.cards[i].ability.name == 'Joker Stencil' then x_mult = x_mult + 1 end
              if G.jokers.cards[i].ability.name == 'insc-deathcard' then x_mult = x_mult + 1 end
          end
        if (G.jokers.config.card_limit - #G.jokers.cards) > 0 then
            return {
                xmult = x_mult  
            }
        end
      end
    end
    return {}
  end
  return {}
end


G.FUNCS.deathcard_select = function(e)
  local card = e.config.ref_table
  if deathcard_choosing == "condition" then
    deathcard_choosing = "effect"
    BalatroInscrybed.death_card_area.cards[1].config.center.deathcard_stats.condition = card.config.center.deathcard.condition
    G.FUNCS.draw_from_card_area_to_card_area(BalatroInscrybed.chose_card_one, BalatroInscrybed.joker_holding)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        blocking = false,
        func = (function()
            if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot') then 
                local quip, extra = SMODS.quip("deathcard")
                extra.x = 0
                extra.y = 5
                PO3.ui_object_updated = true
                PO3:add_speech_bubble("insc_deathcard3" , nil, {quip = true}, extra)
                PO3:say_stuff((extra and extra.times) or 5, false, "insc_deathcard3")
                end
            return true
        end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.0,
      func = (function()
        BalatroInscrybed.joker_holding:shuffle()
        local card_count = math.min(#BalatroInscrybed.joker_holding.cards, 3) 
        for i=1, card_count do
          draw_card(BalatroInscrybed.joker_holding, BalatroInscrybed.chose_card_one, i*100/card_count,'down', nil, nil,  0.08)
        end
      return true
    end)}))
  elseif deathcard_choosing == "effect" then
    deathcard_choosing = "rarity"
    G.FUNCS.draw_from_card_area_to_card_area(BalatroInscrybed.chose_card_one, BalatroInscrybed.joker_holding)
    BalatroInscrybed.death_card_area.cards[1].config.center.deathcard_stats.effect = card.config.center.deathcard.effect
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        blocking = false,
        func = (function()
            if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot') then 
                local quip, extra = SMODS.quip("deathcard")
                extra.x = 0
                extra.y = 5
                PO3.ui_object_updated = true
                PO3:add_speech_bubble("insc_deathcard4" , nil, {quip = true}, extra)
                PO3:say_stuff((extra and extra.times) or 5, false, "insc_deathcard4")
                end
            return true
        end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.0,
      func = (function()
        BalatroInscrybed.joker_holding:shuffle()
        local card_count = math.min(#BalatroInscrybed.joker_holding.cards, 3) 
        for i=1, card_count do
          draw_card(BalatroInscrybed.joker_holding, BalatroInscrybed.chose_card_one, i*100/card_count,'down', nil, nil,  0.08)
        end
      return true
    end)}))
  elseif deathcard_choosing == "rarity" then
    BalatroInscrybed.death_card_area.cards[1].config.center.rarity = card.config.center.rarity
    local cards_to_delete = {}
    for i = #BalatroInscrybed.chose_card_one, 1, -1 do
        local card = BalatroInscrybed.chose_card_one.cards[i]
        
        if card.config.center.deathcard == nil then
            table.insert(cards_to_delete, card)
        end
    end
    for i = #BalatroInscrybed.joker_holding, 1, -1 do
        local card = BalatroInscrybed.joker_holding.cards[i]
        
        if card.config.center.deathcard then
            table.insert(cards_to_delete, card)
        end
    end
    SMODS.destroy_cards(cards_to_delete)
    G.OVERLAY_MENU:remove()
    G.OVERLAY_MENU = nil
    G.SETTINGS.paused = false
    G.FUNCS.overlay_menu({
            definition = Deathcard.create_UIBox_select_summon_materials_2(card_)
        })
    SMODS.add_card{
        key = "j_insc_deathcard",
        area = BalatroInscrybed.death_card_area
    }
  
    



      PO3 = nil
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 2.5,
      blocking = false,
      func = (function()
          if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot') then 
              local quip, extra = SMODS.quip("deathcard")
              extra.x = 0
              extra.y = 5
              BalatroInscrybed.PO3 = Card_Character(extra)
              local spot = G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot')
              spot.config.object:remove()
              spot.config.object = BalatroInscrybed.PO3
              BalatroInscrybed.PO3.ui_object_updated = true
              local extra = {x = 0, y = 5}
              BalatroInscrybed.PO3:add_speech_bubble("insc_deathcard5", nil, {quip = true}, extra)
              BalatroInscrybed.PO3:say_stuff((extra and extra.times) or 5, false, "insc_deathcard5")
              end
          return true
      end)
      }))
      
  end

end

G.FUNCS.can_select_deathcard = function(e)
  if e.config.ref_table.area == BalatroInscrybed.chose_card_one then 
      e.config.colour = G.C.GREEN
      e.config.button = 'deathcard_select'
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.can_deathcard = function(e)
  if G.GAME.did_deathcard == false then 
      e.config.colour = G.C.ORANGE
      e.config.button = "death_card_start"
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end





Deathcard.create_UIBox_select_summon_materials = function(card)

    local amount = 3
    BalatroInscrybed.death_card_area = CardArea(0, 10, G.CARD_W, G.CARD_H*3.4, 
    {card_limit = 1, type = 'title', highlight_limit = 1})
    BalatroInscrybed.chose_card_one = CardArea(0, 0, 7*G.CARD_W, G.CARD_H*0.95, 
    {card_limit = amount, type = 'joker', highlight_limit = 1})
    BalatroInscrybed.joker_holding = CardArea(0, 0, 7*G.CARD_W, G.CARD_H*0.95, 
    {card_limit = 50, type = 'joker', highlight_limit = 1})


    return {
        n = G.UIT.ROOT, config = {align = "tm", minw = G.ROOM.T.w, minh = G.ROOM.T.h, padding = 0, r = 0.1, colour = HEX("3F4A61")}, nodes = {
            {n=G.UIT.R, config={align = "tm", minh = G.CARD_H },nodes={
            }},
            {n=G.UIT.R, config={align = "tm"},nodes={
                {n=G.UIT.C, config={align = "tm", padding    =-.5},nodes={
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 12, 12, G.ASSET_ATLAS['insc_dcc'], {x=0,y=0}), hover = true, can_collide = false}},
                }},
                {n=G.UIT.C, config={align = "tm", padding =-.5},nodes={
                    {n=G.UIT.O, config = {object = BalatroInscrybed.death_card_area, hover = true, can_collide = false}},
                }},     
                {n=G.UIT.C, config={align = "tm", padding =-.5},nodes={ 
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 12, 12, G.ASSET_ATLAS['insc_dcc'], {x=1,y=0}), hover = true, can_collide = false}}, 
                }},
                {n=G.UIT.C, config={align = "cl", padding = -5, },nodes={
                  {n=G.UIT.O, config = {id = "deathcard_tutorial_spot", object = Moveable(0,0,G.CARD_W*1.1, G.CARD_H*1.1), colour = HEX("FFE600"), hover = true, can_collide = true}},   
                }},               
            }},
            {n=G.UIT.R, config={align = "tm"},nodes={
              {n=G.UIT.R, config={align = "tm", padding = -2, minh = G.CARD_H },nodes={
                  {n=G.UIT.O, config = {object = BalatroInscrybed.chose_card_one, hover = true, can_collide = false}},
              }},
              {n=G.UIT.R, config={align = "bm", minh = G.CARD_H },nodes={
                  {n=G.UIT.O, config = {object = BalatroInscrybed.joker_holding, hover = true, can_collide = false}},
              }},
            }},

        },}
end

Deathcard.create_UIBox_select_summon_materials_2 = function(card)

    local amount = 3
    BalatroInscrybed.death_card_area = CardArea(0, 10, G.CARD_W, G.CARD_H*3.4, 
    {card_limit = 1, type = 'title', highlight_limit = 1})
    local deathcard_center
    for o, p in pairs(G.P_CENTER_POOLS['Joker']) do
      if p.key == "j_insc_deathcard" then
        deathcard_center = p
      end
	  end
    BalatroInscrybed.joker_holding = CardArea(0, 0, 7*G.CARD_W, G.CARD_H*0.95, 
    {card_limit = 50, type = 'joker', highlight_limit = 1})


    local ui = {
        n = G.UIT.ROOT, config = {align = "tm", id = "deathcard_ui", minw = G.ROOM.T.w, minh = G.ROOM.T.h, padding = 0, r = 0.1, colour = HEX("3F4A61")}, nodes = {
            {n=G.UIT.R, config={align = "tm", minh = G.CARD_H },nodes={
            }},
            {n=G.UIT.R, config={align = "tm"},nodes={
                {n=G.UIT.C, config={align = "tm", padding    =-.5},nodes={
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 12, 12, G.ASSET_ATLAS['insc_dcc'], {x=0,y=0}), hover = true, can_collide = false}},
                }},
                {n=G.UIT.C, config={align = "tm", padding =-.5},nodes={
                    {n=G.UIT.O, config = {object = BalatroInscrybed.death_card_area, hover = true, can_collide = false}},
                }},     
                {n=G.UIT.C, config={align = "tm", padding =-.5},nodes={ 
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 12, 12, G.ASSET_ATLAS['insc_dcc'], {x=1,y=0}), hover = true, can_collide = false}}, 
                }},
                {n=G.UIT.C, config={align = "cl", padding = -5, },nodes={
                  {n=G.UIT.O, config = {id = "deathcard_tutorial_spot", object = Moveable(0,0,G.CARD_W*1.1, G.CARD_H*1.1), colour = HEX("FFE600"), hover = true, can_collide = true}},   
                }},
                               
            }},
            {n=G.UIT.R, config={align = "tm", id = "deathcard_element_spot"},nodes={
              {n=G.UIT.R, config={align = "tm"},nodes={
                {n=G.UIT.C, config={align = "tm", minh = G.CARD_H },nodes={
                  {n=G.UIT.R, config={align = "tm",},nodes={
                    create_text_input({
                      w = 4, align = "tm", max_length = 999, id = "deathcard_text_input", prompt_text = localize('k_enter_name'),
                      ref_table = deathcard_center, padding = 0.5, ref_value = 'name',extended_corpus = true, keyboard_offset = 1,
                      callback = function() 
                      end}),
                  }},
                  {n=G.UIT.R, config={align = "cm", minw = 5, padding = 0.1, r = 0.1, hover = true, colour = G.C.ORANGE, button = "apply_name" , shadow = true, focus_args = {nav = 'wide', snap_to = true}}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true, maxw = 4.8}, nodes={
                      {n=G.UIT.T, config={text = "Next", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                  }},
                }},
              }},
              
              {n=G.UIT.R, config={align = "bm", minh = G.CARD_H },nodes={
                  {n=G.UIT.O, config = {object = BalatroInscrybed.joker_holding, hover = true, can_collide = false}},
              }},
            }},

        },}
    return ui 
end


G.FUNCS.draw_from_card_area_to_card_area = function(card_area, card_area2)
    local hand_count = #card_area.cards
    for i=1, hand_count do
        draw_card(card_area, card_area2, i*100/hand_count,'down', nil, nil,  0.08)
    end
end


SMODS.JimboQuip{
  key = "deathcard1",
  type = 'deathcard',
  extra = {center = "j_insc_squirrel"},
  filter = function(quip, type) 
      if type == "deathcard" then return true, {override_base_checks = true} end
  end
}
G.FUNCS.apply_name = function(e)
  BalatroInscrybed.save_deathcard_to_profile()
  G.FUNCS.DT_lose_game()
end
G.FUNCS.death_card_start = function(e)
    G.GAME.did_deathcard = true
    G.OVERLAY_MENU:remove()
    G.OVERLAY_MENU = nil
    G.SETTINGS.paused = false
    G.FUNCS.overlay_menu({
            definition = Deathcard.create_UIBox_select_summon_materials(card)
        })
    SMODS.add_card{
        key = "j_insc_deathcard",
        area = BalatroInscrybed.death_card_area
    }
    local cards_to_delete = {}
    for i = #G.jokers.cards, 1, -1 do
        local card = G.jokers.cards[i]
        
        if card.config.center.deathcard == nil then
            table.insert(cards_to_delete, card)
        end
    end
    SMODS.destroy_cards(cards_to_delete)
    G.FUNCS.draw_from_card_area_to_card_area(G.jokers, BalatroInscrybed.joker_holding)

    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.0,
      func = (function()
        BalatroInscrybed.joker_holding:shuffle()
        local card_count = math.min(#BalatroInscrybed.joker_holding.cards, 3) 
        for i=1, card_count do
          draw_card(BalatroInscrybed.joker_holding, BalatroInscrybed.chose_card_one, i*100/card_count,'down', nil, nil,  0.08)
        end
      return true
    end)}))



    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 2.5,
        blocking = false,
        func = (function()
            if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot') then 
                local quip, extra = SMODS.quip("deathcard")
                extra.x = 0
                extra.y = 5
                PO3 = Card_Character(extra)
                local spot = G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot')
                spot.config.object:remove()
                spot.config.object = PO3
                PO3.ui_object_updated = true
                PO3:add_speech_bubble(quip, nil, {quip = true}, extra)
                PO3:say_stuff((extra and extra.times) or 5, false, "deathcard time MF")
                end
            return true
        end)
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 10,
        blocking = false,
        func = (function()
            if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('deathcard_tutorial_spot') then 
                local quip, extra = SMODS.quip("deathcard")
                extra.x = 0
                extra.y = 5
                PO3.ui_object_updated = true
                PO3:add_speech_bubble("insc_deathcard2" , nil, {quip = true}, extra)
                PO3:say_stuff((extra and extra.times) or 5, false, "insc_deathcard2")
                end
            return true
        end)
    }))
    deathcard_choosing = "condition"

    -- G.E_MANAGER:add_event(Event({
    --     trigger = 'after',
    --     delay = 5,
    --     blocking = false,
    --     func = (function()
    --           PO3:remove_speech_bubble()
    --           local quip, extra = SMODS.quip("deathcard")
    --           PO3:add_speech_bubble(quip, nil, {quip = true}, extra)
    --           PO3:say_stuff((extra and extra.times) or 5, false, "deathcard time MF")
    --         return true
    --     end)
    -- }))
end

