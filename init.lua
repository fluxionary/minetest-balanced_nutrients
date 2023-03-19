balanced_nutrients = fmod.create()

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
			hp_monoids.hp_max:add_change(player, value / 2, "balanced_nutrients:fat")
			player_monoids.speed:add_change(player, -value / 8, "balanced_nutrients:fat")
		else
			hp_monoids.hp_max:del_change(player, "balanced_nutrients:fat")
			player_monoids.speed:del_change(player, "balanced_nutrients:fat")
		end
	end,
})

balanced_diet.register_nutrient("protein", { -- raises health regeneration, makes you stronger
	apply_value = function(player, value)
		if value > 0 then
			hp_monoids.heal:add_change(player, value / 2, "balanced_nutrients:protein")
			if std_effects.strength then
				std_effects.strength:add(player, value / 2, "balanced_nutrients:protein")
			end
		else
			hp_monoids.heal:del_change(player, "balanced_nutrients:protein")
			if std_effects.strength then
				std_effects.strength:clear(player, "balanced_nutrients:protein")
			end
		end
	end,
})

balanced_diet.register_nutrient("carbohydrate", { -- raises maximum stamina
	apply_value = function(player, value)
		if value > 0 and not is_werewolf(player) then
			staminoid.stamina_max_monoid:add_change(player, value / 2, "balanced_nutrients:carbohydrate")
		else
			staminoid.stamina_max_monoid:del_change(player, "balanced_nutrients:carbohydrate")
		end
	end,
})
balanced_diet.register_nutrient("vitamin", { -- rises stamina regeneration
	apply_value = function(player, value)
		if value > 0 then
			staminoid.stamina_regen_monoid:add_change(player, value / 2, "balanced_nutrients:vitamin")
		else
			staminoid.stamina_regen_monoid:del_change(player, "balanced_nutrients:vitamin")
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
			staminoid.stamina_max_monoid:add_change(player, value / 2, "balanced_nutrients:raw_meat")
			staminoid.stamina_regen_monoid:add_change(player, value / 2, "balanced_nutrients:raw_meat")
		else
			staminoid.stamina_max_monoid:del_change(player, "balanced_nutrients:raw_meat")
			staminoid.stamina_regen_monoid:del_change(player, "balanced_nutrients:raw_meat")
		end
	end,
})
