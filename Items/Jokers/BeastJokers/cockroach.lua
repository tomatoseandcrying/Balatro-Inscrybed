local cockroach = {
    object_type = "Joker",
    name = "Cockroach",
    key = "cockroach",
    insc_type = "None",
    pos = { x = 3, y = 3 },
    config = { insc_sacrifice_sigils = { "Unkillable" }, extra = { chips = 0, chip_gain = 10, new_weight = 200 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 1,
    cost = 0,
    order = 1,
    weight = 10,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end

        if context.buying_card then
            if context.buying_self then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        G.GAME.insc_cockroach_bought = true
                        SMODS.scale_card(card, {
                            ref_table = card.ability.extra,
                            ref_value = "chips",
                            scalar_value = "chip_gain"
                        })
                        return true
                    end
                }))
            elseif context.card.config.center_key == card.config.center_key and context.card ~= card then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        SMODS.scale_card(card, {
                            ref_table = card.ability.extra,
                            ref_value = "chips",
                            scalar_value = "chip_gain"
                        })
                        return true
                    end
                }))
            end
        end
    end,
    get_weight = function(self, weight)
        local joker = SMODS.find_card("j_insc_cockroach")[1]
        if G.GAME and G.GAME.insc_cockroach_bought then
            return joker.ability.extra.new_weight
        end
    end,
    in_pool = function(self, args)
        return true, { allow_duplicates = true }
    end
}

return { name = { "BeastJokers" }, items = { cockroach } }
