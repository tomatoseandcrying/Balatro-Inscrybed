local dire_wolf_pup = {
    object_type = "Joker",
    name = "Dire Wolf Pup",
    key = "dire_wolf_pup",
    insc_type = "Canine",
    pos = { x = 6, y = 2 },
    config = {
        insc_sacrifice_sigils = { "fledgling", "digger" },
        extra = { age_rounds = 0, total_rounds = 2 }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_insc_dire_wolf
        return { vars = { card.ability.extra.age_rounds, card.ability.extra.total_rounds } }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 1,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.selling_self and (cae.age_rounds >= cae.total_rounds) then
            if #G.jokers.cards < G.jokers.config.card_limit then
                local dire = SMODS.create_card({
                    set = 'Joker',
                    area = G.jokers,
                    key = 'j_insc_dire_wolf',
                    key_append = 'dire_wolf_pup',
                    no_edition = true,
                    edition = card.edition,
                })
                card:juice_up(0.3, 0.5)
                dire:add_to_deck()
                G.jokers:emplace(dire)
                dire:start_materialize()
                G.GAME.joker_buffer = 0
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            cae.age_rounds = cae.age_rounds + 1
            if cae.age_rounds == cae.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
            end
            return {
                message = (cae.age_rounds < cae.total_rounds) and
                    (cae.age_rounds .. '/' .. cae.total_rounds) or
                    localize('k_active_ex'),
                colour = G.C.FILTER
            }
        end
    end
}
return { name = { "BeastJokers" }, items = { dire_wolf_pup } }
