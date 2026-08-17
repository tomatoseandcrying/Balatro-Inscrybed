local cuckoo = {
    object_type = "Joker",
    name = "Cuckoo",
    key = "cuckoo",
    insc_type = "Avian",
    pos = { x = 6, y = 3 },
    config = { insc_sacrifice_sigils = { "Airborne", "Brood Parasite" }, extra = { odds = 2, copies = 1 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_egg
        local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'insc_cuckoo')
        return { vars = { num, denom } }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 2,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.joker_type_destroyed and context.card.config.center_key ~= 'j_egg' then
            for i = 1, card.ability.extra.copies do
                if #G.jokers.cards < G.jokers.config.card_limit then
                    local egg = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_egg', 'cuckoo')
                    SMODS.calculate_effect({ message = localize('insc_cuckoo_egg') }, card)
                    card:juice_up(0.3, 0.5)
                    egg:add_to_deck()
                    G.jokers:emplace(egg)
                    egg:start_materialize()
                    G.GAME.joker_buffer = 0
                end
            end
        end
        if context.remove_playing_cards then
            for _, randomvariablethatwontevergetusedsoicannameitwhateveriwant in ipairs(context.removed) do
                if SMODS.pseudorandom_probability(card, 'insc_cuckoo', 1, card.ability.extra.odds) then
                    for i = 1, card.ability.extra.copies do
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            local egg = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_egg', 'cuckoo')
                            SMODS.calculate_effect({ message = localize('insc_cuckoo_egg') }, card)
                            card:juice_up(0.3, 0.5)
                            egg:add_to_deck()
                            G.jokers:emplace(egg)
                            egg:start_materialize()
                            G.GAME.joker_buffer = 0
                        end
                    end
                end
            end
        end
    end
}
return { name = { "BeastJokers" }, items = { cuckoo } }
