SMODS.DrawStep {
    key = 'sigil',
    order = 34,
    func = function(self, layer)
        if self.sigil ~= nil and self.sigil[1] ~= nil and G.shared_sigils[self.sigil[1]] then
            G.shared_sigils[self.sigil[1]].role.draw_major = self
            G.shared_sigils[self.sigil[1]]:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'selected_scribe',
    order = 10,
    func = function(self)
        if G.GAME.selected_scrybe ~= "" and self.area == G.deck then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            G.shared_insc_scribes[G.GAME.selected_scrybe].role.draw_major = self
            G.shared_insc_scribes[G.GAME.selected_scrybe]:draw_shader('dissolve', nil, nil, true, self.children.center, 0.25*scale_mod, 0, nil, -0.1)
        end
    end,
    conditions = { vortex = false, facing = 'back' },
}

SMODS.DrawStep {
    key = 'sigilextra',
    order = 36,
    func = function(self, layer)
        if self.sigil ~= nil and self.sigil[2] ~= nil and G.shared_sigils2[self.sigil[2]] then
            G.shared_sigils2[self.sigil[2]].role.draw_major = self
            G.shared_sigils2[self.sigil[2]]:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'cicuit_shader',
    order = 15,
    func = function(self, layer)
        if self.ability.in_between_circuit ~= nil and self.ability.in_between_circuit then
            self.children.front:draw_shader('foil', nil, self.ARGS.send_to_shader)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'floating_sprite',
    order = 60,
    func = function(self)
        if self.config.center.soul_pos and self.children.floating_sprite ~= nil and (self.config.center.discovered or self.bypass_discovery_center) then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

            if type(self.config.center.soul_pos.draw) == 'function' then
                self.config.center.soul_pos.draw(self, scale_mod, rotate_mod)
            elseif self.ability.name == 'Hologram' then
            elseif self.config.center.soul_pos.holo then
                self.hover_tilt = self.hover_tilt*1.3
                self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 1.3*scale_mod, 0*rotate_mod)
                self.hover_tilt = self.hover_tilt/1.3
	            self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 1.3*scale_mod, 0*rotate_mod)
            else
                self.children.floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
                self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
            end
            if self.edition then 
                for k, v in pairs(G.P_CENTER_POOLS.Edition) do
                    if v.apply_to_float then
                        if self.edition[v.key:sub(3)] then
                            self.children.floating_sprite:draw_shader(v.shader, nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                        end
                    end
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep({
	key = "insc_extra_floating_sprites",
	order = 62,
	func = function(self)
		if self.config.center and self.config.center.inscrybed and self.config.center.inscrybed.soul_layers then
			for k, v in pairs(self.config.center.inscrybed.soul_layers) do
				local scale_mod = self.config.center.inscrybed.soul_layers[k].moving and 0.07 + 0.02*math.cos(1.8*G.TIMERS.REAL) + 0.00*math.cos((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3 or 0.07
				local rotate_mod = self.config.center.inscrybed.soul_layers[k].moving and 0.05*math.cos(1.219*G.TIMERS.REAL) + 0.00*math.cos((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2 or 0
				if self.children[k] then
                    if self.config.center.inscrybed.soul_layers[k].holo then
                        self.children[k]:draw_shader('dissolve', nil, nil, nil, self.children.center, 0.25*scale_mod, 0*rotate_mod) 
	                    self.children[k]:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 0.25*scale_mod, 0*rotate_mod)
                    else
					    self.children[k]:draw_shader(
						    "dissolve",
						    0,
						    nil,
						    nil,
						    self.children.center,
						    scale_mod,
						    rotate_mod,
						    nil,
						    self.config.center.inscrybed.soul_layers[k].moving and 0.1 + 0.03*math.cos(1.8*G.TIMERS.REAL) or 0.1,
						    nil,
						    0.6
					    )
					    self.children[k]:draw_shader(
						    "dissolve",
						    nil,
						    nil,
						    nil,
						    self.children.center,
						    scale_mod,
						    rotate_mod
					    )
                    end
				else
					local center = self.config.center
					self.children[k] = Sprite(
						self.T.x,
						self.T.y,
						self.T.w,
						self.T.h,
						G.ASSET_ATLAS[center.inscrybed.soul_layers[k].atlas or center.atlas or center.set],
						center.inscrybed.soul_layers[k].pos
					)
					self.children[k].role.draw_major = self
					self.children[k].states.hover.can = false
					self.children[k].states.click.can = false
                    
				end
				if not SMODS.draw_ignore_keys[k] then
					SMODS.draw_ignore_keys[k] = true
				end
			end
		end
	end,
	conditions = { vortex = false, facing = "front" },
})