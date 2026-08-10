--Ownerships
SMODS.Joker:take_ownership("joker", {
  deathcard = {
      effect = {
        mult = 4,
      },
      condition = "joker_main",
  },
}, true)
SMODS.Joker:take_ownership("greedy_joker", {
  deathcard = {
      effect = {
        mult = 3,
      },
      condition = {
        card_suit_scores = "Diamonds"
      },
  },
}, true)
SMODS.Joker:take_ownership("lusty_joker", {
  deathcard = {
      effect = {
        mult = 3,
      },
      condition = {
        card_suit_scores = "Hearts"
      },
  },
}, true)
SMODS.Joker:take_ownership("wrathful_joker", {
  deathcard = {
      effect = {
        mult = 3,
      },
      condition = {
        card_suit_scores = "Spades"
      },
  },
}, true)
SMODS.Joker:take_ownership("gluttenous_joker", {
  deathcard = {
      effect = {
        mult = 3,
      },
      condition = {
        card_suit_scores = "Clubs"
      },
  },
}, true)
SMODS.Joker:take_ownership("jolly", {
  deathcard = {
      effect = {
        mult = 8,
      },
      condition = {
        hand_contains = "Pair"
      },
  },
}, true)
SMODS.Joker:take_ownership("zany", {
  deathcard = {
      effect = {
        mult = 12,
      },
      condition = {
        hand_contains = "Three of a Kind"
      },
  },
}, true)
SMODS.Joker:take_ownership("mad", {
  deathcard = {
      effect = {
        mult = 10,
      },
      condition = {
        hand_contains = "Two Pair"
      },
  },
}, true)
SMODS.Joker:take_ownership("crazy", {
  deathcard = {
      effect = {
        mult = 12,
      },
      condition = {
        hand_contains = "Straight"
      },
  },
}, true)
SMODS.Joker:take_ownership("droll", {
  deathcard = {
      effect = {
        mult = 10,
      },
      condition = {
        hand_contains = "Flush"
      },
  },
}, true)
SMODS.Joker:take_ownership("sly", {
  deathcard = {
      effect = {
        chips = 50,
      },
      condition = {
        hand_contains = "Pair"
      },
  },
}, true)
SMODS.Joker:take_ownership("willy", {
  deathcard = {
      effect = {
        chips = 100,
      },
      condition = {
        hand_contains = "Three of a Kind"
      },
  },
}, true)
SMODS.Joker:take_ownership("clever", {
  deathcard = {
      effect = {
        chips = 80,
      },
      condition = {
        hand_contains = "Two Pair"
      },
  },
}, true)
SMODS.Joker:take_ownership("devious", {
  deathcard = {
      effect = {
        chips = 100,
      },
      condition = {
        hand_contains = "Straight"
      },
  },
}, true)
SMODS.Joker:take_ownership("crafty", {
  deathcard = {
      effect = {
       chips = 80,
      },
      condition = {
        hand_contains = "Flush"
      },
  },
}, true)
SMODS.Joker:take_ownership("half", {
  deathcard = {
      effect = {
       mult = 20,
      },
      condition = {
        full_hand_amount = 3
      },
  },
}, true)
SMODS.Joker:take_ownership("stencil", {
  deathcard = {
      effect = {
       multperjokerslot = 1 ,
      },
      condition = "joker_main",
  },
}, true)
SMODS.Joker:take_ownership("tribe", {
  deathcard = {
      effect = {
        xmult = 2,
      },
      condition = {
        hand_contains = "Flush"
      },
  },
}, true)

SMODS.Joker:take_ownership("order", {
  deathcard = {
      effect = {
        xmult = 3 ,
      },
      condition = {
        hand_contains = "Straight"
      },
  },
}, true)

SMODS.Joker:take_ownership("family", {
  deathcard = {
      effect = {
        xmult = 4,
      },
      condition = {
        hand_contains = "Four of a Kind"
      },
  },
}, true)