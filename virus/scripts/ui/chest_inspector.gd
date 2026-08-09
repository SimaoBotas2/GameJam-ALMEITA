extends "res://scripts/ui/ui_overlay_base.gd"

# Emitido só quando o código está certo, antes do close() — para quem abriu
# isto (o chest.gd) saber que foi mesmo resolvido, e não só fechado com Esc.
signal solved

#deixar aqui para depois ter textura os dials, por agor n tem
#@onready var texture_rect: TextureRect = $Background/TextureRect
@onready var title_label: Label = $Background/TitleLabel
@onready var dial_container: HBoxContainer = $Background/HBoxContainer

@export var chest_code = [1, 2, 3, 4]

# Descobertos automaticamente a partir dos filhos do dial_container — dá
# para adicionar/tirar discos na scene sem mexer aqui, o código adapta-se.
var dial_rects: Array = []
var dial_labels: Array = []

var current_dial = 0
var dials: Array = []

# Cor original de cada disco, guardada uma vez, para sabermos a que cor
# voltar quando deixam de estar selecionados (clarear sempre a mesma cor
# base ia acumulando erro se fizesses isto repetidamente).
var dial_base_colors: Array[Color] = []

func _ready() -> void:
	dial_rects = dial_container.get_children()
	for dial in dial_rects:
		dial_labels.append(dial.get_node("Label"))
		dial_base_colors.append(dial.color)

	dials.resize(dial_rects.size())
	dials.fill(0)

	if chest_code.size() != dial_rects.size():
		push_warning("chest_code tem %d dígitos, mas há %d discos na scene." % [chest_code.size(), dial_rects.size()])

	update_dial_selection()

func open_chest(closeup_texture: Texture2D, chest_title: String, player: Node) -> void:
	#texture_rect.texture = closeup_texture
	title_label.text = chest_title
	open(player)


func update_dial_display() -> void:
	for i in dial_rects.size():
		dial_labels[i].text = str(dials[i])

# Deixa o disco selecionado ligeiramente mais claro, para se ver qual é
# que vais mudar com cima/baixo. Os outros voltam à cor original deles.
func update_dial_selection() -> void:
	for i in dial_rects.size():
		if i == current_dial:
			dial_rects[i].color = dial_base_colors[i].lightened(0.35)
		else:
			dial_rects[i].color = dial_base_colors[i]

func increase_dial_value() -> void:
	dials[current_dial] += 1
	if dials[current_dial] > 9:
		dials[current_dial] = 0
	update_dial_display()


func decrease_dial_value() -> void:
	dials[current_dial] -= 1
	if dials[current_dial] < 0:
		dials[current_dial] = 9
	update_dial_display()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		current_dial = (current_dial - 1 + dial_rects.size()) % dial_rects.size()
		update_dial_selection()
	elif event.is_action_pressed("right"):
		current_dial = (current_dial + 1) % dial_rects.size()
		update_dial_selection()

	if event.is_action_pressed("up"):
		increase_dial_value()
	elif event.is_action_pressed("down"):
		decrease_dial_value()

	if event.is_action_pressed("interact"):
		if dials == chest_code:
			title_label.text = "Correct Code!"
			solved.emit()
			await get_tree().create_timer(1.0).timeout
			close()
		else:
			title_label.text = "Wrong Code!"
			await get_tree().create_timer(2.0).timeout
			title_label.text = "Insert Code Below:"

	if event.is_action_pressed("ui_cancel"):
		close()
