@tool
class_name TemperatureLight
extends Light3D

## A [Light3D] that takes its colour from a colour temperature in kelvin, so a
## light can be authored as "a 2700K bulb" instead of a hand-picked RGB value.
## [member temperature] is the source of truth: whatever [member Light3D.light_color]
## says in the inspector gets overwritten.

const MIN_TEMPERATURE := 1000.0

## Colour temperature in kelvin: 1900 candle, 2700 warm household bulb,
## 5500 midday sun, 10000 overcast sky.
@export_range(1000, 15000, 1, "or_greater", "suffix:K") var temperature := 5500.0:
	set(value):
		temperature = maxf(value, MIN_TEMPERATURE)
		apply_temperature()

## Multiplies the blackbody colour, for coloured bulbs and gels.
@export var tint := Color.WHITE:
	set(value):
		tint = value
		apply_temperature()

func _ready() -> void:
	apply_temperature()

func apply_temperature() -> void:
	light_color = color_for_temperature(temperature) * tint

## Blackbody colour for [param kelvin], in the linear space light colours are stored in.
static func color_for_temperature(kelvin: float) -> Color:
	var t := maxf(kelvin, MIN_TEMPERATURE) / 100.0
	var red: float
	var green: float
	var blue: float
	if t <= 66.0:
		red = 255.0
		green = 99.4708025861 * log(t) - 161.1195681661
	else:
		red = 329.698727446 * pow(t - 60.0, -0.1332047592)
		green = 288.1221695283 * pow(t - 60.0, -0.0755148492)
	if t >= 66.0:
		blue = 255.0
	elif t <= 19.0:
		blue = 0.0
	else:
		blue = 138.5177312231 * log(t - 10.0) - 305.0447927307

	var srgb := Color(
		clampf(red, 0.0, 255.0) / 255.0,
		clampf(green, 0.0, 255.0) / 255.0,
		clampf(blue, 0.0, 255.0) / 255.0
	)
	return srgb.srgb_to_linear()
