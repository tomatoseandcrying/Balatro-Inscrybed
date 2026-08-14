local ant_queen = {
    object_type = "Joker",
    name = "Ant Queen",
    key = "ant_queen",
    insc_type = "None",
    deathcard = {
        effect = {},
        condition = {},
        rarity = {},

    },
    pos = { x = 1, y = 1 },
    config = { extra = {} },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 2,
    cost = 6,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.ending_shop and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local ants = {
                --'j_guh_worker',
                --'j_guh_flying',
                'j_joker',
                'j_chaos'
            }
            G.E_MANAGER:add_event(Event({
                func = function()
                    local randomcard = pseudorandom_element(ants, 'inscrybed_ant_queen')
                    G.GAME.joker_buffer = G.GAME.joker_buffer + ((#ants + 1) - #ants)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card {
                                set = 'Joker',
                                key_append = 'inscrybed_ant_queen',
                                key = randomcard,
                            }
                            G.GAME.joker_buffer = 0
                            return true
                        end
                    }))
                    return true
                end
            }))
        end
    end
}
return { name = { "BeastJokers" }, items = { ant_queen } }
