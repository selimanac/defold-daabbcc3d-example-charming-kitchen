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

	local probs_data = json.decode(json_data)
	pprint(probs_data)
end

return probs
