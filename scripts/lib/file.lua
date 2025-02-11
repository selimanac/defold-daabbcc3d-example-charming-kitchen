local data = require("scripts.lib.data")
local const = require("scripts.lib.const")
local room = require("scripts.lib.room")

local file = {}

function file.save()
	local room_file_path = sys.get_save_file("defold-daabbcc3d-charming-kitchen", "room_" .. data.room_number)
	pprint(room_file_path)
	if not sys.save(room_file_path, data.room_props) then
		msg.post(const.URLS.GUI, const.MSG.SAVE_LOAD_ROOM_COMPLETE, { status = "Room could not be saved!" })
	else
		print("SAVED")
		pprint(data.room_props)
		msg.post(const.URLS.GUI, const.MSG.SAVE_LOAD_ROOM_COMPLETE, { status = "Room saved!" })
	end
end

function file.load()
	local room_file_path = sys.get_save_file("defold-daabbcc3d-charming-kitchen", "room_" .. data.room_number)
	local room_props = sys.load(room_file_path)
	if not next(room_props) then
		-- empty table
		print("EMPTY")
		msg.post(const.URLS.GUI, const.MSG.SAVE_LOAD_ROOM_COMPLETE, { status = "The room file is not available!" })
	else
		print("LOADED")

		for key, value in pairs(room_props) do
			pprint(value)
		end
		room.reset()
		--data.room_props = room_props
		room.generate(room_props)
		--data.room_props = room_props

		msg.post(const.URLS.GUI, const.MSG.SAVE_LOAD_ROOM_COMPLETE, { status = "The room loaded!" })
	end
end

function file.message(message_id, message, sender)
	if message_id == const.MSG.LOAD_ROOM then
		file.load()
	elseif message_id == const.MSG.SAVE_ROOM then
		file.save()
	elseif message_id == const.MSG.RESET_ROOM then
		room.reset()
	end
end

return file
