local data = {}

data.probs = {}
data.cursor = {
	origin = vmath.vector3(),
	dir = vmath.vector3(),
	position = vmath.vector3()
}

data.selected_prob = {
	position = vmath.vector3()
}

data.game_manager = ""

return data
