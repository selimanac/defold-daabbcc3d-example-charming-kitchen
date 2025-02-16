---@class daabbcc3d
daabbcc3d = {
	UPDATE_INCREMENTAL = 0,
	UPDATE_FULLREBUILD = 1,
	UPDATE_PARTIALREBUILD = 2
}

---@alias rebuildType integer
---| 'UPDATE_INCREMENTAL' [# No rebuild. Default. ]
---| 'UPDATE_FULLREBUILD' [# Full Rebuild.   ]
---| 'UPDATE_PARTIALREBUILD' [# Partial rebuild. Recommended for lots of moving AABBs   ]


---New empty group for AABBs. Every group is a seperate [Dynamic Tree](https://box2d.org/documentation/md_collision.html#autotoc_md46).
---@param rebuild_type? rebuildType Rebuilds the tree after each [update](https://github.com/selimanac/defold-daabbcc/wiki/Utilities#daabbccupdate_frequencyfrequency) for moving gameobject positions. The tree will only be rebuilt if there is at least one gameobject present.
---@return integer group_id New group ID
function daabbcc3d.new_group(rebuild_type) end

---Removes the group and all associated AABBs and Gameobjects.
---@param group_id integer  Group ID
function daabbcc3d.remove_group(group_id) end

---Insert AABB into the group.
---@param group_id integer Group ID
---@param position vector3  Position of AABB.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer Depth of AABB.
---@param category_bit? integer Single category bit which aabb belongs to. Default is **all**
---@return integer aabb_id New aabb ID
function daabbcc3d.insert_aabb(group_id, position, width, height, depth, category_bit) end

---Insert Gameobject and the associated AABB into a group.Most suitable for constantly moving gameobjects. If your gameobject is static then use `daabbcc3d.insert_aabb()` instead.
---@param group_id integer Group ID
---@param go_url url  URL of Gameobject.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer depth of AABB.
---@param category_bit? integer Single category bit which aabb belongs to. Default is **all**
---@param get_world_position? boolean Get world position of gameobject. Default is **false**
---@return integer aabb_id New aabb ID
function daabbcc3d.insert_gameobject(group_id, go_url, width, height, depth, category_bit, get_world_position) end

---Updates the AABB position and size when you change its position or/and size.Does not effect Gameobject position, Gameobject AABB positions will be overwritten by internal update.
---@param group_id integer Group ID
---@param aabb_id integer AABB ID.
---@param position vector3  position of AABB.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer depth of AABB.
function daabbcc3d.update_aabb(group_id, aabb_id, position, width, height, depth) end

---Updates the AABB size related to the Gameobject.
---@param group_id integer Group ID
---@param aabb_id integer AABB ID.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer depth of AABB.
function daabbcc3d.update_gameobject_size(group_id, aabb_id, width, height, depth) end

---Removes the AABB and Gameobject from group.
---@param group_id integer Group ID
---@param aabb_id integer AABB ID.
function daabbcc3d.remove(group_id, aabb_id) end

---Query the possible overlaps using raw AABB.
---@param group_id integer Group ID
---@param position vector3  position of AABB.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer depth of AABB.
---@param mask_bits? integer  Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABB IDs.
---@return integer Count of `result` table.
function daabbcc3d.query_aabb(group_id, position, width, height, depth, mask_bits, get_manifold) end

---Query the possible overlaps using AABB ID.
---@param group_id integer Group ID
---@param aabb_id integer AABB ID.
---@param mask_bits? integer Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABB IDs.
---@return integer Count of `result` table.
function daabbcc3d.query_id(group_id, aabb_id, mask_bits, get_manifold) end

---Query possible overlaps using a raw AABB.
---@param group_id integer Group ID
---@param position vector3  position of AABB.
---@param width integer Width of AABB.
---@param height integer Height of AABB.
---@param depth integer depth of AABB.
---@param mask_bits? integer Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABBs. The `result` table contains aabb_ids and distances.
---@return integer Count of `result` table.
function daabbcc3d.query_aabb_sort(group_id, position, width, height, depth, mask_bits, get_manifold) end

---Query the possible overlaps using AABB ID. Returns a Table with IDs and distances, ordered from closest to farthest.
---@param group_id integer Group ID
---@param aabb_id integer AABB ID.
---@param mask_bits? integer Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABBs. The `result` table contains aabb_ids and distances.
---@return integer Count of `result` table.
function daabbcc3d.query_id_sort(group_id, aabb_id, mask_bits, get_manifold) end

---Perform ray casts against the group.
---@param group_id integer Group ID
---@param start_position vector3 Ray start position.
---@param end_position vector3  Ray end position.
---@param mask_bits? integer Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABB IDs.
---@return integer Count of `result` table.
function daabbcc3d.raycast(group_id, start_position, end_position, mask_bits, get_manifold) end

---Perform ray casts against the group. Returns a Table with AABB IDs and distances, ordered from closest to farthest.
---@param group_id integer Group ID
---@param start_position vector3  Ray start position.
---@param end_position vector3  Ray end position.
---@param mask_bits? integer  Default is **all**
---@param get_manifold? boolean  Get collision manifold. Default is **false**
---@return table Table of possible overlapping AABBs. The `result` table contains aabb_ids and distances.
---@return integer Count of `result` table.
function daabbcc3d.raycast_sort(group_id, start_position, end_position, mask_bits, get_manifold) end

---Pause or resume the internal game object position update iteration. This is enabled by default but will not iterate if no game objects are registered. Pausing the iteration can free up compute power (e.g., when the game is paused).
---@param state boolean Pause or resume
function daabbcc3d.run(state) end

---It is possible to set an independent update frequency for the game object position update iteration. The default value is taken from the [display.frequency](https://defold.com/manuals/project-settings/#update-frequency) setting in the game.project file. The update loop follows the same structure as in the [Defold source](https://github.com/defold/defold/blob/cdaa870389ca00062bfc03bcda8f4fb34e93124a/engine/engine/src/engine.cpp#L1860).  This can be very useful if you're running a headless build on a server.
---@param frequency integer Update frequency
function daabbcc3d.update_frequency(frequency) end

---Paritially or full rebuild a group.
---@param group_id integer Group ID
---@param full_build boolean Full or paritial build
function daabbcc3d.rebuild(group_id, full_build) end

---Paritially or full rebuild all groups.
---@param full_build boolean Full or paritial build
function daabbcc3d.rebuild_all(full_build) end

---Removes all AABBs, groups, and game objects, resetting to the initial state. It is recommended to reset the DAABBC when you're done with it (e.g., when your game or level is over).
function daabbcc3d.reset() end
