balanced_nutrients = fmod.create()

local hp_attribute = player_attributes.get_bounded_attribute("hp")
local regen_effect = std_effects.regen
local strength_effect = std_effects.strength
local stamina_attribute = staminoid.stamina_attribute
local stamina_regen_effect = staminoid.stamina_regen_effect

local function is_werewolf(player)
	if std_effects.werewolf then
		return std_effects.werewolf:value(player)
	elseif balanced_nutrients.has.petz then
		return petz.is_werewolf(player)
	end
end

balanced_diet.register_nutrient("fat", { -- raises maximum health, makes you slower
	apply_value = function(player, value)
		if value > 0 then
			hp_attribute:add_max(player, "balanced_nutrients:fat", value)
			player_monoids.speed:add_change(player, 1 - math.min(1 / 6, value / 16), "balanced_nutrients:fat")
		else
			hp_attribute:clear_max(player, "balanced_nutrients:fat")
			player_monoids.speed:del_change(player, "balanced_nutrients:fat")
		end
	end,
})

balanced_diet.register_nutrient("protein", { -- raises health regeneration, makes you stronger
	apply_value = function(player, value)
		if value > 0 then
			if regen_effect then
				regen_effect:add(player, "balanced_nutrients:protein", value / 2)
			end
			if strength_effect then
				strength_effect:add(player, "balanced_nutrients:protein", value / 2)
			end
		else
			if regen_effect then
				regen_effect:clear(player, "balanced_nutrients:protein")
			end
			if strength_effect then
				strength_effect:clear(player, "balanced_nutrients:protein")
			end
		end
	end,
})

balanced_diet.register_nutrient("carbohydrate", { -- raises maximum stamina
	apply_value = function(player, value)
		if value > 0 and not is_werewolf(player) then
			stamina_attribute:add_max(player, "balanced_nutrients:carbohydrate", 10 * value)
		else
			stamina_attribute:clear_max(player, "balanced_nutrients:carbohydrate")
		end
	end,
})
balanced_diet.register_nutrient("vitamin", { -- raises stamina regeneration
	apply_value = function(player, value)
		if value > 0 then
			stamina_regen_effect:add(player, "balanced_nutrients:vitamin", value / 2)
		else
			stamina_regen_effect:clear(player, "balanced_nutrients:vitamin")
		end
	end,
})

balanced_diet.register_nutrient("raw_meat", { -- poison for regular players, raises stamina/stamina regen for werewolves
	on_eat = function(player, value)
		if not is_werewolf(player) then
			if std_effects.poison then
				std_effects.poison:add_time(player, "balanced_nutrients:raw_meat", 1, value)
			end
		end
	end,
	apply_value = function(player, value)
		if value > 0 and is_werewolf(player) then
			stamina_attribute:add_max(player, "balanced_nutrients:raw_meat", 10 * value)
			stamina_regen_effect:add(player, "balanced_nutrients:raw_meat", value)
		else
			stamina_attribute:clear_max(player, "balanced_nutrients:raw_meat")
			stamina_regen_effect:clear(player, "balanced_nutrients:raw_meat")
		end
	end,
})
