local ant_queen = {
    object_type = "Joker",
    name = "Ant Queen",
    key = "ant_queen",
    insc_type = "Insect",
    pos = { x = 1, y = 1 },
    config = { insc_sacrifice_sigils = { "ant", "ant_spawner" }, extra = { copies = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 2,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        local ants = {
            --'j_insc_worker_ant',
            --'j_insc_flying_ant',
            'j_joker',
            'j_joker',
            'j_joker',
            'j_chaos'
        }
        if context.ending_shop then
            for i = 1, card.ability.extra.copies do
                if #G.jokers.cards < G.jokers.config.card_limit then
                    local randomcard = pseudorandom_element(ants, 'insc_ant_queen')
                    local ant = create_card('Joker', G.jokers, nil, nil, nil, nil, randomcard, 'ant_queen')
                    card:juice_up(0.3, 0.5)
                    ant:add_to_deck()
                    G.jokers:emplace(ant)
                    ant:start_materialize()
                    G.GAME.joker_buffer = 0
                end
            end
        end
    end
}
return { name = { "BeastJokers" }, items = { ant_queen } }
