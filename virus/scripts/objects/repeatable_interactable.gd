extends "res://scripts/objects/interaction_object.gd"

# Para coisas que se podem usar várias vezes (ex: um quadro para inspecionar).
# Em vez de se desligar depois da primeira vez, só bloqueia novas interações
# enquanto a atual ainda está "a decorrer" (is_busy). Quem estender isto
# implementa o _on_interact() e chama finish_interaction() quando terminar.

var is_busy: bool = false

func show_prompt() -> void:
	if not is_busy:
		super.show_prompt()

func interact() -> void:
	if is_busy:
		return

	is_busy = true
	hide_prompt()

	# implementar isto nas subclasses concretas (definido em interaction_object.gd)
	_on_interact()

func finish_interaction() -> void:
	is_busy = false
	show_prompt()
