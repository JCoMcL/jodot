extends FXID
class_name SFXID

func play(n: Node) -> Variant:
	return SFXPlayer.get_sfx_player(n).play_sfx(id)
