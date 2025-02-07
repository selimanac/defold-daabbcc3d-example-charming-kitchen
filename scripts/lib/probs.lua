local data = require("scripts.lib.data")

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
	--pprint(data.probs)
end

return probs
