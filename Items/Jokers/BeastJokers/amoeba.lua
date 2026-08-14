local amoeba = {
    object_type = "Joker",
    name = "Amoeba",
    key = "amoeba",
    insc_type = "None",
    pos = { x = 4, y = 1 },
    config = { insc_sacrifice_sigils = { "amorphous" }, extra = { copies = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.copies } }
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
            if context.before and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
                local card_played = context.full_hand[1]
                local seal = SMODS.poll_seal({
                    guaranteed = true,
                    type_key = 'insc_amoeba'
                })
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        card_played:set_sigil("insc_airborne", nil, false)
                        return true
                    end
                }))
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.CHIPS,
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
    end
}
return { name = { "BeastJokers" }, items = { amoeba } }
