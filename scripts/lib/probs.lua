local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")

local probs = {}


function probs.init()
	local json_data, error = sys.load_resource("/assets/models/output.json")

	if error then
		print(error)
		return
	end

	if json_data == nil then
		print("No data")
		return
	end

	data.probs = json.decode(json_data)
end

function probs.create(probe_name)
	local prob = data.probs[probe_name]
	prob.id = factory.create(prob.factory)
	go.set_parent(prob.id, const.CURSOR, false)

	-- MOVE THOSE TO INIT
	prob.size = vmath.vector3(prob.size[1], prob.size[2], prob.size[3])
	prob.offset = vmath.vector3(prob.offset[1], prob.offset[2], prob.offset[3])

	--prob.aabb_id = collision.insert_gameobject(prob.id, prob.size.x, prob.size.y, prob.size.z, collision.bits.PROBS)
	pprint(prob)
	return prob
end

return probs
