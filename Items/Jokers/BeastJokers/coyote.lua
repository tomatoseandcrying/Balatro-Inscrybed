local coyote = {
    object_type = "Joker",
    name = "Coyote",
    key = "coyote",
    insc_type = "Canine",
    pos = { x = 4, y = 3 },
    config = { insc_sacrifice_sigils = {}, extra = { copies = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    yes_pool_flag = 'insc_beast_card',
    discovered = false,
    rarity = 1,
    cost = 0,
    order = 1,
    blueprint_compat = false,
    atlas = "leshy_cards",
    calculate = function(self, card, context)
        card.ability.tagged = false
        if context.setting_blind and context.blind.boss then
            local eval = function() return not context.end_of_round and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.tag_added and card.ability.tagged then
            card.ability.tagged = false
        end
        if context.end_of_round and context.beat_boss and context.main_eval then
            if not card.ability.tagged then
                --random tag script from Ortalab
                card.ability.tagged = true
                local available_tags = get_current_pool('Tag')
                local selected_tags = {}
                for i = 1, card.ability.extra.copies do
                    local tag = pseudorandom_element(available_tags, pseudoseed('insc_coyote'))
                    while tag == 'UNAVAILABLE' do
                        tag = pseudorandom_element(available_tags, pseudoseed('insc_coyote_reroll'))
                    end
                    selected_tags[i] = tag
                end

                G.E_MANAGER:add_event(Event({
                    func = (function()
                        for _, tag in pairs(selected_tags) do
                            add_tag(Tag(tag, false, 'Small'))
                        end
                        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)

                        return true
                    end)
                }))
                return nil, true
            end
        end
    end
}
return { name = { "BeastJokers" }, items = { coyote } }
