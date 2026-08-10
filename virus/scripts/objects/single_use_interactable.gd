extends "res://scripts/objects/interaction_object.gd"

# Para coisas que só se usam uma vez (porta, botão, caixa de vidros). Depois
# do primeiro interact(), desliga-se sozinho e nunca mais reage a nada.
# Para criar um objeto novo destes, só é preciso implementar o _on_interact().

var was_used: bool = false

func show_prompt() -> void:
	if not was_used:
		super.show_prompt()

func interact() -> void:
	if was_used:
		return

	was_used = true
	hide_prompt()
	interaction_zone.monitoring = false
	interaction_zone.monitorable = false
	interaction_zone.collision_layer = 0

	# implementa isto nas subclasses concretas (definido em interaction_object.gd)
	_on_interact()
