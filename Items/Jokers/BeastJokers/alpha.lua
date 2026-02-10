local alpha = {
    object_type = "Joker",
    name = "Alpha",
    key = "alpha",
    insc_type = "Canine",
    pos = { x = 1, y = 2 },
    config = { insc_sacrifice_sigils = {"leader"}, extra = { id_check = 0, mult = 7 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 2,
    cost = 6,
    order = 1,
    blueprint_compat = true,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            for i = 1, #context.scoring_hand do
                if i == 1 then
                    card.ability.extra.id_check = context.scoring_hand[i]:get_id()
                end
            end
            if context.other_card:get_id() < card.ability.extra.id_check then
                return {
				    mult = card.ability.extra.mult,
				    card = context.other_card
			    }
            end
        end
    end,
}
return {name = {"BeastJokers"}, items = {alpha}}