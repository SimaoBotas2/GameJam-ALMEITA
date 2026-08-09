# Como criar uma skin nova para a personagem

# Autor : Botas
# Co-Autor : Claude

## O que é uma "skin" aqui

Uma skin é um par AnimationPlayer + AnimationTree dentro de virus/scenes/character/sigma_character.tscn. Todas as skins mexem no mesmo Sprite2D (o da personagem) — só uma está ativa de cada vez, e é o script (sigma_character.gd/base_character.gd) que decide qual.

Não se cria uma scene de personagem nova por skin. É sempre a mesma scene, só se acrescenta mais um par de animação lá dentro.

## Formato esperado de uma animação

Cada skin precisa de uma AnimationLibrary com estas três animações, com estes nomes exatos:

- RESET
- idle_animation
- walk_right

Cada animação tem duas tracks, ambas a mexer no mesmo Sprite2D (CollisionShape2D/Sprite2D): uma track para frame (percorre os frames da spritesheet) e outra para texture (a imagem usada). Os nomes têm de ser exatos porque a state machine referencia isto por nome.

## Passos para criar uma skin nova

1. Abre sigma_character.tscn.
2. Seleciona um par já existente (ex: AnimationPlayer_Default + AnimationTree_Default), copia os dois (Ctrl+C) e cola dentro do nó raiz (Ctrl+V).
3. Renomeia os dois nós colados para AnimationPlayer_NomeDaSkin e AnimationTree_NomeDaSkin.
4. No AnimationPlayer novo, edita a AnimationLibrary (painel Animation, em baixo) e troca as texturas das tracks para as imagens da skin nova.
5. No AnimationTree novo, confirma no Inspector que o campo Anim Player aponta para o AnimationPlayer certo (../AnimationPlayer_NomeDaSkin) — às vezes fica desatualizado depois de copiar/colar.
6. Seleciona o nó raiz (SigmaCharacter) e no dicionário Skin Animation Trees acrescenta uma entrada nova: o nome da skin (o mesmo que vais usar no código) a apontar para o AnimationTree novo.

## Como aplicar a skin

De qualquer objeto ou evento, chama:

```gdscript
var player = get_tree().get_first_node_in_group("player")
if player != null and player.has_method("set_skin"):
	player.set_skin("nome_da_skin")
```

Já existe um exemplo disto em caixa_vidros.gd, com o campo skin_on_use exportado no Inspector — a caixa muda a skin da personagem para "after_glass" ao ser usada.

## Checklist antes de dar como pronta

- [ ] AnimationLibrary da skin nova tem RESET, idle_animation e walk_right.
- [ ] AnimationTree novo tem o Anim Player a apontar para o par certo.
- [ ] Entrada nova no dicionário Skin Animation Trees do nó raiz.
- [ ] Testar a skin sozinha, mudando Current Skin no Inspector antes de correr, e depois testar a troca em runtime com set_skin().
