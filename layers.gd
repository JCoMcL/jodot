@tool
class_name Layers

static var layers: Dictionary[String, int]:
	get:
		if ! layers:
			for i in range(32):
				var layer_name = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i)
				if layer_name:
					layers[layer_name] = 2 ** (i-1)
			print("Generated layer map:", layers)
		return layers

static func combined_layers(layer_names: Array[String]) -> int:
	var out = 0
	for s in layer_names:
		out |= layers[s]
	return out

static func seperate_layers(i: int) -> Array[String]:
	var out: Array[String]
	for k in layers.keys():
		if i & layers[k]:
			out.append(k)
	return out