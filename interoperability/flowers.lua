-- flowers (comes with Minetest Game)
--
-- Author  Various Minetest Game developers and contributors
-- Forums  https://forum.luanti.org/viewtopic.php?t=9724
-- VCS     https://github.com/minetest/minetest_game


local add = hunger_ng.add_hunger_data

add('flowers:mushroom_brown', { satiates = 1 })
add('flowers:mushroom_red',   { satiates = 1, heals = -2 })
