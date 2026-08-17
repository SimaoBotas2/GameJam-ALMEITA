extends Node2D

# Valor de cada painting, usado depois para gerar o código do baú a partir
# dos paintings que saírem sorteados nos quadros.
const PAINTING_VALUES := {
	"vermelho": 1,
	"laranja": 2,
	"amarelo": 3,
	"verde": 4,
	"azul": 5,
	"roxo": 6,
	"violeta": 7,
}

@export var painting_pool: Dictionary[String,Texture2D] = {} # Nome -> Texture2D, editável no Inspector
@onready var painting_nodes: Array[Node] = [$Painting1, $Painting2, $Painting3, $Painting4]
@onready var chest: Node = $Chest

func _ready() -> void:
	if painting_pool.is_empty():
		return

	# Só sorteia da primeira vez — se já saíste e voltaste a entrar na sala,
	# reusa o que já estava guardado no GameState em vez de sortear outra vez.
	if GameState.room_1_painting_ids.is_empty():
		var pool_keys: Array = painting_pool.keys()
		pool_keys.shuffle()
		GameState.room_1_painting_ids = pool_keys.slice(0, painting_nodes.size())

	var painting_ids: Array = GameState.room_1_painting_ids
	var code: Array = []

	for i in painting_nodes.size():
		if i >= painting_ids.size():
			break
		var painting_key: String = painting_ids[i]
		painting_nodes[i].apply_pool_texture(painting_pool[painting_key])
		code.append(_painting_value_from_key(painting_key))

	chest.expected_code = code

func _painting_value_from_key(key: String) -> int:
	var painting_name := key.trim_prefix("placeholder_")
	return PAINTING_VALUES.get(painting_name, 0)
