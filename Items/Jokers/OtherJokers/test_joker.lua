local deathcard = {
    object_type = "Joker",
    --ignore = true,
    name = "insc-deathcard",
    key = "deathcard",
    pos = { x = 0, y = 0 },
    deathcard_stats = {
        effect = {
        },
        condition = nil,
        rarity = {},
    },
    soul_pos = {
        x = 1, 
        y = 0,
        holo = true
    },
    insc_num_layer = {
        x = 2, 
        y = 0,
        holo = true,
    },
    config = { insc_sacrifice_sigils = {"trinket"}, extra = { } },
    loc_vars = function(self, info_queue, center)
        return { vars = {BalatroInscrybed.get_name()} }
    end,
    rarity = 1,
    cost = 20,
    blueprint_compat = true,
    atlas = "po3_cards",
    calculate = function(self, card, context)
        if deathcard_condtion(context, card.config.center.deathcard_stats.condition) then
            return deathcard_effect(card.config.center.deathcard_stats.effect)
        end
    end
}

return {name = {"OtherJoker"}, items = {deathcard}}