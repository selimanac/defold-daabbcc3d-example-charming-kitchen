local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local audio = require("scripts.lib.audio")

local trash = {}

trash.is_trash_prop = false
local trash_size = vmath.vector3(1.3)

function trash.reset(active_prop)
	trash.is_trash_prop = false

	go.cancel_animations(data.room_trash.model_url, "tint")

	if next(active_prop) then
		go.cancel_animations(active_prop.model_url, "tint")
	end

	go.set(data.room_trash.model_url, "tint", vmath.vector4(1, 1, 1, 1))
	go.set(active_prop.model_url, "tint", vmath.vector4(1, 1, 1, 1))
	go.set_scale(trash_size, data.room_trash.id)
end

function trash.check(ray_collision_response, active_prop)
	if data.room_colliders[ray_collision_response.id] and data.room_colliders[ray_collision_response.id].type == collision.bits.TRASH then
		if trash.is_trash_prop == false then
			go.animate(data.room_trash.id, "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(2.3, 1.2, 1.8), go.EASING_INSINE, 0.3, 0, function()
				go.set_scale(trash_size, data.room_trash.id)
			end)
			go.animate(data.room_trash.model_url, "tint", go.PLAYBACK_LOOP_PINGPONG, vmath.vector4(0.5, 1.0, 0.5, 1), go.EASING_INSINE, 1.0)
			go.animate(active_prop.model_url, "tint", go.PLAYBACK_LOOP_PINGPONG, vmath.vector4(1.0, 0.5, 0.5, 1), go.EASING_INSINE, 1.0)
		end

		trash.is_trash_prop = true

		return true
	else
		trash.reset(active_prop)
	end

	return false
end

function trash.delete()
	audio.play(audio.FX.TRASH)
	go.animate(data.room_trash.id, "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(2.3, 2.2, 0.8), go.EASING_INSINE, 0.3)
	go.animate(data.room_trash.model_url, "tint", go.PLAYBACK_ONCE_PINGPONG, vmath.vector4(1.0, 1.0, 1.0, 2), go.EASING_INSINE, 0.3)
end

return trash
