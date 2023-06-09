balanced_nutrients = fmod.create()

local S = balanced_nutrients.S

local hp_attribute = player_attributes.get_bounded_attribute("hp")
local regen_effect = regen_effect.effect
local strength_effect = strength_effect.effect
local stamina_attribute = staminoid.stamina_attribute
local stamina_regen_effect = staminoid.stamina_regen_effect

local function is_werewolf(player)
	if balanced_diet.has.lycanthropy_effect then
		return lycanthropy_effect.werewolf:value(player)
	elseif balanced_nutrients.has.petz and petz.settings.lycanthropy then
		return petz.is_werewolf(player)
	end
end

balanced_diet.register_nutrient("fat", { -- raises maximum health, makes you slower
	description = S("fat"),
	apply_value = function(player, value)
		if value > 0 then
			hp_attribute:add_max(player, "balanced_nutrients:fat", math.round(value))
			player_monoids.speed:add_change(player, 1 - (value / 64), "balanced_nutrients:fat")
			player_monoids.jump:add_change(player, 1 - (value / 128), "balanced_nutrients:fat")
		else
			hp_attribute:clear_max(player, "balanced_nutrients:fat")
			player_monoids.speed:del_change(player, "balanced_nutrients:fat")
			player_monoids.jump:del_change(player, "balanced_nutrients:fat")
		end
	end,
})

balanced_diet.register_nutrient("protein", { -- raises health regeneration, makes you stronger
	description = S("protein"),
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
	description = S("carbohydrate"),
	apply_value = function(player, value)
		if value > 0 and not is_werewolf(player) then
			stamina_attribute:add_max(player, "balanced_nutrients:carbohydrate", 10 * value)
		else
			stamina_attribute:clear_max(player, "balanced_nutrients:carbohydrate")
		end
	end,
})
balanced_diet.register_nutrient("vitamin", { -- raises stamina regeneration
	description = S("vitamin"),
	apply_value = function(player, value)
		if value > 0 and not is_werewolf(player) then
			stamina_regen_effect:add(player, "balanced_nutrients:vitamin", value)
		else
			stamina_regen_effect:clear(player, "balanced_nutrients:vitamin")
		end
	end,
})

balanced_diet.register_nutrient("raw_meat", { -- poison for regular players, raises stamina/stamina regen for werewolves
	description = S("raw meat"),
	on_eat = function(player, value)
		if not is_werewolf(player) then
			if balanced_nutrients.has.poison_effect then
				poison_effect.effect:add_time(player, "balanced_nutrients:raw_meat", 1, value)
			end
		end
	end,
	apply_value = function(player, value)
		if value > 0 and is_werewolf(player) then
			stamina_attribute:add_max(player, "balanced_nutrients:raw_meat", 10 * value)
			stamina_regen_effect:add(player, "balanced_nutrients:raw_meat", 2 * value)
			if regen_effect then
				regen_effect:add(player, "balanced_nutrients:raw_meat", value / 2)
			end
			if strength_effect then
				strength_effect:add(player, "balanced_nutrients:raw_meat", value / 2)
			end
		else
			stamina_attribute:clear_max(player, "balanced_nutrients:raw_meat")
			stamina_regen_effect:clear(player, "balanced_nutrients:raw_meat")
			if regen_effect then
				regen_effect:clear(player, "balanced_nutrients:raw_meat")
			end
			if strength_effect then
				strength_effect:clear(player, "balanced_nutrients:raw_meat")
			end
		end
	end,
})

staminoid.register_on_exhaust_player(function(player, amount, reason)
	local current_stamina = staminoid.stamina_attribute:get(player)
	if current_stamina < amount then
		balanced_diet.advance_eaten_time(player, 5 * (amount - current_stamina))
	end
end)
