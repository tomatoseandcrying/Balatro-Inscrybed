local dire_wolf = {
    object_type = "Joker",
    name = "Dire Wolf",
    key = "dire_wolf",
    insc_type = "Canine",
    pos = { x = 5, y = 0 },
    config = { insc_sacrifice_sigils = { "double" }, extra = { repetitions = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 2,
    cost = 0,
    order = 1,
    blueprint_compat = true,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local lowest_card = nil
            local id = 15
            for i = 1, #G.play.cards do
                if id >= G.play.cards[i].base.id and not SMODS.has_no_rank(G.play.cards[i]) then
                    lowest_card = G.play.cards[i]
                    id = G.play.cards[i].base.id
                end
            end
            if lowest_card == context.other_card then
                if context.other_card.debuff then
                    return { message = localize('k_debuffed'), colour = G.C.RED }
                else
                    return { repetitions = math.floor(card.ability.extra.repetitions * (id / 2)) }
                end
            end
        end
    end
}
return { name = { "BeastJokers" }, items = { dire_wolf } }
