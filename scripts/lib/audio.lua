local audio = {}

local music = "/sounds#music"
local gate_time = 0.3
local sounds = {}

audio.FX = {
	POP = "/sounds#pop",
	TRASH = "/sounds#trash",
	PICK = "/sounds#pick",
	CLICK = "/sounds#click"
}

function audio.init()
	audio.play(music)
end

function audio.update(dt)
	for k, _ in pairs(sounds) do
		sounds[k] = sounds[k] - dt

		if sounds[k] < 0 then
			sounds[k] = nil
		end
	end
end

function audio.play(fx)
	--	sound.play(fx)

	if sounds[fx] == nil then
		-- Store sound timer in table
		sounds[fx] = gate_time
		-- Play the sound
		sound.play(fx)
	else
		-- An attempt to play a sound was gated
		print("gated " .. fx)
	end
end

return audio
