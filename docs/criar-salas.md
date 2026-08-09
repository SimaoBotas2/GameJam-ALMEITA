# Como criar uma sala nova

## 1. Estrutura base

Cria uma scene nova em virus/scenes/levels/, root Node2D. Dentro:

- Background: um Sprite2D com z_index -50 e a imagem da sala.
- Paredes/limites: StaticBody2D + CollisionShape2D filho, um por parede. Não há uma scene de parede genérica pronta a usar — cada sala faz os seus.
- SigmaCharacter: ver secção 2.
- Objetos/portas: ver secções 3 e 4.

Todas as salas usam o mesmo tamanho de mundo: 1150 x 642. Isto está fixo na câmara da personagem (ver secção 2), por isso mantém as salas dentro destas dimensões, ou vais ter de ajustar a câmara nessa instância.

## 2. Instanciar a personagem

Usa uma destas duas scenes de virus/scenes/character/:

| Scene | has_chain | Quando usar |
|---|---|---|
| sigma_character1.tscn | true | Salas onde a personagem ainda tem a corrente (level_1, level_2) |
| sigma_character_level3.tscn | false | Salas sem corrente |

Ambas usam o mesmo script, sigma_character.gd — a diferença é só a flag has_chain e os sprites. Não criem um script novo para uma sala nova; se precisares de uma variante visual nova, duplica uma destas scenes e troca só as texturas/animações.

Passos:
1. Arrasta a scene certa para a tua sala.
2. Posiciona-a onde a personagem deve nascer.
3. Se a sala não tiver corrente, confirma que has_chain fica a false no Inspector.

## 3. Colocar uma porta

1. Instancia virus/scenes/objects/door.tscn.
2. Posiciona-a e ajusta o CollisionShape2D ao vão da porta.
3. No Inspector, define Next Scene Path para a scene de destino.

Cuidado com o caminho: tem de ser o caminho completo a partir de res://scenes/levels/... Já houve um bug em que faltava o "levels/" (res://scenes/level_2.tscn em vez de res://scenes/levels/level_2.tscn) e a porta não levava a lado nenhum. Confirma sempre o caminho no FileSystem antes de gravar.

## 4. Colocar um objeto interativo

Objetos disponíveis em virus/scenes/objects/: caixa_vidros.tscn, botao_interativo.tscn, painting.tscn, etc. Todos seguem a mesma regra:

- collision_layer a 2 e collision_mask a 0 — é isto que faz o detetor de interação da personagem (que tem collision_mask a 2) encontrar o objeto. Não mudes estes valores sem saber porquê.
- Têm um InteractionLabel filho, com o texto do prompt (ex: "Press E to interact"). Não é criado por código nenhum, tem de estar na scene — a forma mais segura de garantir isto é duplicar uma scene de objeto já existente em vez de começar do zero.

Para criar um objeto novo, primeiro decide se é de uso único ou repetível:

- Uso único (porta, botão, caixa de vidros): estende single_use_interactable.gd. Depois do primeiro interact(), o objeto desliga-se sozinho e nunca mais reage.
- Repetível (o quadro, algo que se possa voltar a usar): estende repeatable_interactable.gd. Bloqueia novas interações só enquanto a atual está a decorrer.

Em ambos os casos só precisas de implementar o _on_interact():

```gdscript
extends "res://scripts/objects/single_use_interactable.gd"

func _on_interact() -> void:
	# o que acontece ao interagir
```

Se for repetível e a interação demorar (ex: abrir um popup), avisa a base quando terminar chamando finish_interaction() — vê painting.gd como exemplo.

## Checklist antes de dar como pronta

- [ ] Sala tem Node2D root, background com z_index -50, paredes com colisão.
- [ ] Personagem instanciada com has_chain correto para esta sala.
- [ ] Portas com Next Scene Path a apontar para uma scene que existe mesmo (confirma no FileSystem).
- [ ] Objetos interativos com collision_layer a 2 e collision_mask a 0.
- [ ] Testar a sala sozinha (F6) antes de a ligar ao resto do jogo.
