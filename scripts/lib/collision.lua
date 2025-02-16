local collision     = {}

local aabb_group_id = daabbcc3d.new_group(daabbcc3d.UPDATE_PARTIALREBUILD)

collision.bits      = {
	CURSOR          = 1,   -- (2^0)
	WALLS           = 2,   -- (2^1)
	GROUND          = 4,   -- (2^2)
	PROPS           = 8,   -- (2^3)
	TRASH           = 16,
	PROPS_CONTAINER = 32,  -- (2^3)

	ALL             = bit.bnot(0) -- -1 for all results
}

--PROP_TARGETS = bit.bor(collision.bits.WALLS, collision.bits.PROPS, collision.bits.TRASH),

collision.targets   = bit.bor(collision.bits.WALLS, collision.bits.GROUND)

function collision.insert_aabb(position, width, height, depth, collision_bit)
	collision_bit = collision_bit and collision_bit or nil
	return daabbcc3d.insert_aabb(aabb_group_id, position, width, height, depth, collision_bit)
end

function collision.insert_gameobject(go_url, width, height, depth, collision_bit)
	collision_bit = collision_bit and collision_bit or nil
	return daabbcc3d.insert_gameobject(aabb_group_id, go_url, width, height, depth, collision_bit)
end

function collision.query_aabb(position, width, height, depth, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.query_aabb(aabb_group_id, position, width, height, depth, collision_bits, get_manifold)
end

function collision.query_id(aabb_id, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.query_id(aabb_group_id, aabb_id, collision_bits, get_manifold)
end

function collision.query_id_sort(aabb_id, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.query_id_sort(aabb_group_id, aabb_id, collision_bits, get_manifold)
end

function collision.query_aabb_sort(position, width, height, depth, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.query_aabb_sort(aabb_group_id, position, width, height, depth, collision_bits, get_manifold)
end

function collision.raycast(ray_start, ray_end, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.raycast(aabb_group_id, ray_start, ray_end, collision_bits, get_manifold)
end

function collision.raycast_sort(ray_start, ray_end, collision_bits, get_manifold)
	collision_bits = collision_bits and collision_bits or nil
	get_manifold   = get_manifold and get_manifold or nil
	return daabbcc3d.raycast_sort(aabb_group_id, ray_start, ray_end, collision_bits, get_manifold)
end

function collision.update_aabb(aabb)
	daabbcc3d.update_aabb(aabb_group_id, aabb.aabb_id, aabb.position, aabb.size.width, aabb.size.height, aabb.size.depth)
end

function collision.remove(aabb_id)
	daabbcc3d.remove(aabb_group_id, aabb_id)
end

function collision.reset()
	daabbcc3d.reset()
end

return collision
