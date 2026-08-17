local amoeba = {
    object_type = "Joker",
    name = "Amoeba",
    key = "amoeba",
    insc_type = "None",
    pos = { x = 4, y = 1 },
    config = { insc_sacrifice_sigils = { "Amorphous" }, extra = { copies = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.copies, colours = { HEX("9fff80") } } }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 3,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
            local card_played = context.full_hand[1]
            local sigil_pool = {}
            for _, sigil_cen in pairs(G.P_CENTER_POOLS["Sigil"]) do
                sigil_pool[#sigil_pool + 1] = sigil_cen
            end
            local sigil = pseudorandom_element(sigil_pool, 'insc_amoeba')
            if sigil and card_played.sigil == nil then
                SMODS.calculate_effect(
                    { message = localize('insc_amoeba_sigild'), colour = HEX("9fff80") }, card
                )
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        play_sound('tarot1')
                        card:juice_up(0.3, 0.5)
                        card_played:set_sigil(sigil.key, nil, nil)
                        card_played:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            else
                SMODS.calculate_effect(
                    { message = localize('k_nope_ex'), colour = G.C.PURPLE }, card
                )
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        play_sound('tarot1')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.calculate_context({
                                playing_card_added = true,
                                cards = { card_played }
                            })
                            return true
                        end
                    }))
                end
            }
        end
    end
}
return { name = { "BeastJokers" }, items = { amoeba } }
