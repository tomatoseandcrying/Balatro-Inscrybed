local bee = {
    object_type = "Joker",
    name = "Bee",
    key = "bee",
    insc_type = "Insect",
    pos = { x = 0, y = 1 },
    config = { insc_sacrifice_sigils = { "airborne" }, extra = { perma_bonus = 5, perma_bonus_mod = 5 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_insc_beehive
        info_queue[#info_queue + 1] = G.P_SIGILS.insc_bees_within
        return {
            vars = {
                card.ability.extra.perma_bonus_mod,
                card.ability.extra.perma_bonus,
                colours = { HEX("9fff80") }
            }
        }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 1,
    cost = 4,
    order = 1,
    blueprint_compat = true,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 12 then
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus +
                    card.ability.extra.perma_bonus
                return {
                    extra = { message = localize('k_upgrade_ex'), colour = G.C.CHIPS },
                    card = context.other_card
                }
            end
        end
    end,
    update = function(self, card, dt)
        local bees_within = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_sigil(1) == 'insc_bees_within' then
                    bees_within = bees_within + 1
                elseif playing_card:get_sigil(2) == 'insc_bees_within' then
                    bees_within = bees_within + 1
                end
            end
        end
        if G.jokers ~= nil then
            card.ability.extra.perma_bonus =
                (bees_within + #SMODS.find_card("j_insc_bee") + #SMODS.find_card("j_insc_beehive")) *
                card.ability.extra.perma_bonus_mod
        end
    end
}
return { name = { "BeastJokers" }, items = { bee } }
