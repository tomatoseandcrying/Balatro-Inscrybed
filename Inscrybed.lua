----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas {
    key = "sigils",
    path = "SigilAtlas.png",
    px = 73,
    py = 97
}
SMODS.Atlas {
    key = "scribe_backs",
    path = "ChosenScribe.png",
    px = 73,
    py = 98
}
SMODS.Atlas {
    key = "sigilsextra",
    path = "SigilAtlasExtra.png",
    px = 73,
    py = 97
}
SMODS.Atlas {
    key = "insc_sacrifice_sign",
    path = "ShopSignAnimationTemp.png",
    px = 113,
    py = 57, 
    frames = 4,
    atlas_table = 'ANIMATION_ATLAS'
}
SMODS.Atlas { 
    key = "spectrals",
    path = "Spectrals.png",
    px = 71,
    py = 95
}
SMODS.Atlas { 
    key = "insc_events",
    path = "Events.png",
    px = 34,
    py = 34
}
SMODS.Atlas {
    key = "po3_cards",
    path = "po3_template.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "scribe_statues",
    path = "Statues.png",
    px = 142,
    py = 190
}
SMODS.Atlas {
    key = "leshy_cards",
    path = "beast_sprites.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "dcc",
    path = "Death_card_Mockup.png",
    px = 640,
    py = 720
}
SMODS.Atlas { 
    key = 'blinds', 
    path = 'BlindChips.png', 
    px = 34, 
    py = 34, 
    frames = 21, 
    atlas_table = 'ANIMATION_ATLAS' 
}
SMODS.Atlas({key = 'tech_border', path = 'JokerBorder.png', px = 71, py = 95})
SMODS.Shader({key = 'bordered', path = 'borderedeffect.fs'})
BalatroInscrybed = SMODS.current_mod
local mod_path = ''..BalatroInscrybed.path

Deathcard = {}
BalatroInscrybed.Sigils = {}
BalatroInscrybed.insc_Events = {}
G.shared_insc_scribes = {}

assert(SMODS.load_file("Utils/Utility.lua"))()
assert(SMODS.load_file("Utils/EventUI.lua"))() 
assert(SMODS.load_file("Utils/BaseEdits.lua"))()
assert(SMODS.load_file("Utils/Gameobjects.lua"))()
assert(SMODS.load_file("Utils/Contexts.lua"))()
assert(SMODS.load_file("Utils/Draw.lua"))()

local folders = NFS.getDirectoryItems(mod_path.."Items")
local objects = {}

local function collect_item_files(base_fs, rel, out)
    for _, name in ipairs(NFS.getDirectoryItems(base_fs)) do
        local abs = base_fs.."/"..name
        local info = NFS.getInfo(abs)
        if info and info.type == "directory" then
            collect_item_files(abs, rel.."/"..name, out)
        elseif info and info.type == "file" and name:match("%.lua$") then
            table.insert(out, rel.."/"..name)
        end
    end
end

local files = {}
collect_item_files(mod_path.."Items", "Items", files)

local function load_items(curr_obj)
    if curr_obj.init then curr_obj:init() end
    if not curr_obj.items then
        print("Warning: curr_obj has no items")
        return
    end
    for _, item in ipairs(curr_obj.items) do
        item.ignore = item.ignore or false
        if SMODS[item.object_type] and not item.ignore then
            SMODS[item.object_type](item)
        elseif BalatroInscrybed[item.object_type] and not item.ignore then
            BalatroInscrybed[item.object_type](item)
        elseif CardSleeves and CardSleeves[item.object_type] and not item.ignore then
            CardSleeves[item.object_type](item)
        elseif not item.ignore then
            print("Error loading item "..item.key.." of unknown type "..item.object_type)
        end
        ::continue::
    end
end

for _, rel in ipairs(files) do
    local f, err = SMODS.load_file(rel)
    if not f then
        print("Error loading item file '"..rel.."': "..tostring(err))
    else
        local ok, curr_obj = pcall(f)
        if ok then
            table.insert(objects, curr_obj)
        end
    end
end

table.sort(objects, function(a, b)
    local function get_lowest_order(obj)
        if not obj.items then return math.huge end
        local lowest = math.huge
        for _, item in ipairs(obj.items) do
            if item.order and item.order == 1 or not item.order then
                if item.insc_type then
                    if item.insc_type == 'None' then
                        item.order = 2
                    elseif item.insc_type == 'Insect' then
                        item.order = 52
                    elseif item.insc_type == 'Reptile' then
                        item.order = 102
                    elseif item.insc_type == 'Hooved' then
                        item.order = 152
                    elseif item.insc_type == 'Canine' then
                        item.order = 202
                    elseif item.insc_type == 'Avian' then
                        item.order = 252
                    elseif item.insc_type == 'Multiple' then
                        item.order = 252
                    end
                else
                    item.order = 352
                end
            end
            if item.order and item.order < lowest then
                lowest = item.order
            end
        end
        return lowest
    end
    return get_lowest_order(a) < get_lowest_order(b)
end)

for _, curr_obj in ipairs(objects) do
    load_items(curr_obj)
end

SMODS.Gradient {
    key = 'leshy',
    colours = {HEX("1e5e2c"), HEX("2c6638"), HEX("3b7748")},
    cycle = 5
}
SMODS.Gradient {
    key = 'po3',
    colours = {HEX("3cb4ff"), HEX("009cfd"), HEX("5ecefe")},
    cycle = 5
}
SMODS.Gradient {
    key = 'grimora',
    colours = {HEX("748d67"), HEX("839689"), HEX("86a367")},
    cycle = 5
}
SMODS.Gradient {
    key = 'magnificus',
    colours = {HEX("9af8e2"), HEX("ff5aee"), HEX("fee9c6")},
    cycle = 10
}

function SMODS.current_mod.reset_game_globals(run_start)
	if run_start then
		G.GAME.insc_extra_draw = 0
        G.shared_insc_scribes["Leshy"] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS["insc_scribe_backs"], {x=0,y=0})
        G.shared_insc_scribes["PO3"] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS["insc_scribe_backs"], {x=1,y=0})
        G.shared_insc_scribes["Grimora"] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS["insc_scribe_backs"], {x=0,y=1})
        G.shared_insc_scribes["Magnificus"] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS["insc_scribe_backs"], {x=1,y=1})
	end
end

--if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.beast
    
--end

--this is the template for all the other sigils, this was made BEFORE it was changed into it's own object, and is still a seal

--SMODS.Sigil { 
--    --creates the visuals and sets the local vars
--    name = "replaece me ",
--    key = "replace me",
--    badge_colour = HEX("9fff80"),
--    config = { },
--    loc_txt = {
--        label = "Sigil",
--        name = "NAME",
--        text = {
--            "text"
--        },
--    },
--    atlas = 'sigils',
--}















     

----------------------------------------------
------------MOD CODE END----------------------
