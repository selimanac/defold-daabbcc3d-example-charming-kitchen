local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")

local props = {}


function props.init()
	local json_data, error = sys.load_resource("/assets/models/output-edit.json")

	if error then
		print(error)
		return
	end

	if json_data == nil then
		print("No data")
		return
	end

	data.props = json.decode(json_data)
	local count = 0
	for title, prop in pairs(data.props) do
		prop.size = vmath.vector3(prop.size[1], prop.size[2], prop.size[3])
		prop.offset = vmath.vector3(prop.offset[1], prop.offset[2], prop.offset[3])
		prop.name = title
		count = count + 1
	end
	print("Prop Count: ", count)


	msg.post(const.URLS.GUI, const.MSG.SETUP_GUI)
end

function props.create(prope_name)
	local prop = data.props[prope_name]
	prop.id = factory.create(prop.factory)
	go.set_parent(prop.id, const.CURSOR, false)
	--prop.aabb_id = collision.insert_gameobject(prop.id, prop.size.x, prop.size.y, prop.size.z, collision.bits.props)

	return prop
end

return props
