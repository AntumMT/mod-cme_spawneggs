--[[ LICENSE HEADER

  The MIT License (MIT)

  Copyright © 2021 Jordan Irwin

  Permission is hereby granted, free of charge, to any person obtaining a copy of
  this software and associated documentation files (the "Software"), to deal in
  the Software without restriction, including without limitation the rights to
  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
  of the Software, and to permit persons to whom the Software is furnished to do
  so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

--]]

--- API
--
--  @module api.lua


--- Adds a craft recipe for an egg.
--
--  @function asm.addEggRecipe
--  @param name Name of spawnegg that will be created from recipe.
--  @param ingredients Items used for recipe in addition to `spawneggs:egg`. Can be string or list.
asm.addEggRecipe = function(name, ingredients)
	if type(ingredients) == "string" then
		ingredients = {ingredients,}
	end

	table.insert(ingredients, 1, "spawneggs:egg")
	core.register_craft({
		output = "spawneggs:" .. name,
		type = "shapeless",
		recipe = ingredients,
	})
end


--- Registers new egg in game.
--
--  @function asm.registerEgg
--  @param def `EggDef` table.
asm.registerEgg = function(def)
	local img = "spawneggs_" .. def.name .. ".png"
	if def.inventory_image then
		img = def.inventory_image
	end

	core.register_craftitem(":spawneggs:" .. def.name:lower(), {
		description = def.name:gsub("^%l", string.upper) .. " Spawn Egg",
		inventory_image = img,

		on_place = function(itemstack, placer, target)
			if target.type == "node" then
				local pos = target.above
				pos.y = pos.y + 1
				local ref = core.add_entity(pos, def.spawn)
				if ref and placer:is_player() then
					local entity = ref:get_luaentity()
					-- set owner
					if entity.ownable then entity.owner = placer:get_player_name() end
				end
				if not core.settings:get_bool("creative_mode") then
					itemstack:take_item()
				end

				return itemstack
			end
		end
	})

	if def.ingredients then
		asm.addEggRecipe(def.name:lower(), def.ingredients)
	end

	-- DEBUG
	asm.log("action", "Registered spawnegg for " .. def.spawn)
end

--- Alias for `asm.registerEgg`.
--
--  @function asm.addEgg
asm.addEgg = asm.registerEgg


--- Egg definition table.
--
--  @table EggDef
--  @field name Human readable name.
--  @field inventory_image Image displayed in inventory.
--  @field spawn Entity that will be spawned from egg.
--  @field ingredients Ingredients to us, in addition to `spawneggs:egg`, to register craft recipe (optional).
