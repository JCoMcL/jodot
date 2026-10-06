extends FXID
class_name SFXID

func play(n: Node) -> Variant:
	return SFX.get_sfx_player(n).play_sfx(id)
