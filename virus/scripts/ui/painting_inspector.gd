extends "res://scripts/ui/ui_overlay_base.gd"

# O popup de ecrã cheio para inspecionar um quadro de perto. A base
# (ui_overlay_base.gd) já trata de abrir/fechar e trancar a personagem —
# aqui só acrescentamos a imagem e o título do quadro.

@onready var texture_rect: TextureRect = $Background/TextureRect
@onready var title_label: Label = $Background/TitleLabel

func open_painting(closeup_texture: Texture2D, painting_title: String, player: Node) -> void:
	texture_rect.texture = closeup_texture
	title_label.text = painting_title
	open(player)
