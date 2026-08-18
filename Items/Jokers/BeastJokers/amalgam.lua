local amalgam = {
    object_type = "Joker",
    name = "Amalgam",
    key = "amalgam",
    insc_type = "Multiple",
    pos = { x = 0, y = 0 },
    config = { insc_sacrifice_sigils = {}, extra = { xmult = 1, xmult_gain = 0.25 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        local wild_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_wild') then
                    wild_tally = wild_tally + 1
                end
            end
        end
        return {
            vars = {
                card.ability.extra.xmult_gain,
                card.ability.extra.xmult + card.ability.extra.xmult_gain * wild_tally
            }
        }
    end,
    yes_pool_flag = 'insc_beast_card', --i guess????
    discovered = false,
    rarity = 3,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.joker_main then
            local wild_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_wild') then
                    wild_tally = wild_tally + 1
                end
            end
            return {
                xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain * wild_tally,
            }
        end
    end
}
return { name = { "BeastJokers" }, items = { amalgam } }
