extends CanvasLayer

# Base para popups de ecrã cheio que trancam a personagem enquanto estão
# abertos (ex: inspecionar um quadro, o código de um baú). Só trata do que é
# comum a todos: trancar/destrancar a personagem, e fechar com E/Esc sem
# reabrir por engano. Quem estender isto acrescenta o seu próprio conteúdo
# (imagem, discos, etc.) e pode ler mais input enquanto está aberto.

signal closed

var target_player: Node = null

func open(player: Node) -> void:
	target_player = player
	if target_player != null:
		if target_player.has_method("lock_movement"):
			target_player.lock_movement()
		if target_player.has_method("lock_interaction"):
			target_player.lock_interaction()

# E ou Esc fecham o popup. set_input_as_handled() evita que o mesmo clique
# também seja lido por outra coisa por trás (ex: um menu).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func close() -> void:
	if target_player != null and target_player.has_method("unlock_movement"):
		target_player.unlock_movement()

	# Esperamos a tecla ser mesmo largada antes de destrancar a interação.
	# Só esperar um frame não chega sempre — is_action_just_pressed() é lido
	# no _physics_process(), que corre a um ritmo diferente do process_frame,
	# e às vezes ainda via a tecla como "acabada de premir" e reabria o popup.
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	if target_player != null and target_player.has_method("unlock_interaction"):
		target_player.unlock_interaction()

	# Avisa quem criou o popup que já pode aceitar um interact() novo.
	closed.emit()
	queue_free()
