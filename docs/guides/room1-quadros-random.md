# Plano: quadros random em room_1 (pool pré-definida)

# Autor : Claude (plano, por implementar)

## Contexto

`room_1` tem 4 instâncias de `painting.tscn` (`Painting1`-`Painting4`), cada uma só com `painting_title` fixo. Como nenhuma define `closeup_texture`, todas caem no fallback de `painting.gd` (`canvas_sprite.texture`), que é sempre `painting1.jpg` — hoje os 4 quadros mostram a mesma imagem. Ver [virus/TODO.md](../../virus/TODO.md) para o levantamento completo.

Este documento é só o plano. Não implementar sem confirmação explícita.

## Decisões confirmadas (2026-08-13)

1. **Pool via Resource `.tres` custom** — editável no Inspector, sem tocar em código para ajustar entradas.
2. **Pool específica de `room_1`** — não é partilhada globalmente com outras salas.
3. **Sorteio sem repetição** — dois quadros da mesma sala nunca mostram a mesma imagem ao mesmo tempo.
4. **Sorteio centralizado** — corre num script da própria `room_1`, que distribui a pool pelos 4 nós `Painting`. Cada `Painting` não se sorteia a si próprio.
5. **Assets:** só existe `painting1.jpg` no projeto. Para já usamos **placeholders** (texturas geradas, ex. `GradientTexture2D` com cores diferentes) em vez de esperar por arte final — trocam-se depois sem mexer na lógica.
6. **Título independente da imagem** — o título de cada quadro continua fixo por posição na sala (`Painting1.painting_title`, `Painting2.painting_title`, ...), tal como já está hoje. Só a **imagem** é sorteada a partir da pool; o título não faz parte da pool.

## Passo 1 — Adaptar `painting.gd` para aceitar uma textura dinâmica

Hoje a imagem é só a `@export` do `CanvasSprite` fixa na cena. Precisa de um método público para trocar só a textura depois de instanciado (o título fica como está, não mexe). Importante: `_ready()` de `painting.gd` já corre `_fit_sprite_to_box` com a textura por omissão, por isso este método tem de repetir o fit (ver Nota sobre ordem de `_ready` abaixo).

Adicionar a `painting.gd`:

```gdscript
func apply_pool_texture(entry_texture: Texture2D) -> void:
    if canvas_sprite != null and entry_texture != null:
        canvas_sprite.texture = entry_texture
        _fit_sprite_to_box(canvas_sprite, canvas_display_size)
```

Dica: não mexer em `painting_title` aqui (decisão 6) nem em `closeup_texture` — este último continua a servir de override manual pontual para o popup de close-up, independente da imagem mostrada na parede.

## Passo 2 — Criar o Resource da pool

**2a. Script do tipo de entrada** — `res://scripts/resources/painting_pool_entry.gd`:

```gdscript
extends Resource
class_name PaintingPoolEntry

@export var texture: Texture2D
```

(Só tem `texture` — decisão 6 tirou o `title` daqui.)

**2b. Script da pool em si** — `res://scripts/resources/painting_pool.gd`:

```gdscript
extends Resource
class_name PaintingPool

@export var entries: Array[PaintingPoolEntry] = []
```

**2c. Recurso `.tres` da pool de `room_1`** — `res://resources/painting_pools/room_1_paintings.tres`:
- Criar no FileSystem do editor: botão direito → New Resource → `PaintingPool`.
- Dentro, adicionar `PaintingPoolEntry` novos (um por imagem da pool) e, em cada um, atribuir a `texture`.

**Placeholders (decisão 5):** já que não há imagens finais, cada `PaintingPoolEntry.texture` pode apontar para um `GradientTexture2D` com uma cor sólida diferente (o mesmo padrão que `painting.tscn` já usa para a `FrameSprite`) — dá para distinguir visualmente os quadros sorteados sem esperar por arte. Sugestão: criar 4-6 entradas com cores distintas (ex. vermelho, azul, verde, amarelo, roxo) para já dar variedade visível ao sorteio. Quando houver arte final, troca-se só a `texture` de cada `PaintingPoolEntry` no Inspector — nada de código muda.

## Passo 3 — Script na própria `room_1` que distribui a pool

`room_1.tscn` não tem script próprio hoje (root `Node2D` sem `script=`). Precisa de um:

```gdscript
# res://scripts/levels/room_1.gd
extends Node2D

@export var painting_pool: PaintingPool
@onready var painting_nodes: Array[Node] = [$Painting1, $Painting2, $Painting3, $Painting4]

func _ready() -> void:
    if painting_pool == null or painting_pool.entries.is_empty():
        return

    var pool_entries := painting_pool.entries.duplicate()
    pool_entries.shuffle()

    for i in painting_nodes.size():
        if i >= pool_entries.size():
            break # pool mais pequena que o nº de quadros — ver "Casos de borda"
        painting_nodes[i].apply_pool_texture(pool_entries[i].texture)
```

Depois:
- Liga este script ao nó raiz `room_1` no editor (ou define `script = ExtResource(...)` na `.tscn`).
- No Inspector do nó `room_1`, atribui `painting_pool` = o `.tres` criado no Passo 2c.

### Nota sobre ordem de `_ready()`

Em Godot, os `_ready()` dos filhos correm **antes** do `_ready()` do pai. Quando `room_1.gd::_ready()` chamar `apply_pool_texture`, cada `Painting` já correu o seu próprio `_ready()` (fit da textura por omissão). Não há problema — `apply_pool_texture` troca a textura e volta a chamar `_fit_sprite_to_box`, por isso o resultado final fica correto.

## Passo 4 — Casos de borda a decidir

- **Pool mais pequena que o nº de quadros da sala:** o pseudocódigo acima simplesmente para de atribuir (quadros a mais ficam com a imagem por omissão da cena). Com 4-6 placeholders sugeridos no Passo 2c isto não deve acontecer em `room_1`, mas vale a pena ter isto em mente se a pool ficar mais pequena no futuro.
- **Quadro fixo que não deve entrar no sorteio:** dá para excluir um nó da lista `painting_nodes`, ou marcar uma flag `@export var use_random_pool := true` em `painting.gd` e o script da sala saltar os que tiverem `false`.
- **Reutilizar isto noutras salas:** como `PaintingPool`/`PaintingPoolEntry` já são Resources genéricos (não específicos de `room_1`), outras salas podem ter o mesmo `room_1.gd`-style script com o seu próprio `.tres` sem duplicar os scripts de recurso — só a lógica de distribuição no `_ready()` de cada sala se repetiria. Se isso incomodar, extrair para uma função utilitária (ex. `res://scripts/utils/painting_pool_util.gd`).

## Passo 5 — Teste

Seguindo o checklist do [guia de salas](criar-salas-ou-objects.md):
- Testar `room_1` sozinha (F6) várias vezes seguidas — confirmar que a combinação de placeholders muda a cada run e que não há duas cores iguais ao mesmo tempo.
- Confirmar que o título mostrado no `painting_inspector` (popup de close-up) continua correto por posição (Painting1 = "Painting 1", etc.), independente de qual placeholder saiu.
- Confirmar que, se a pool tiver menos entradas que quadros, nada rebenta com erro.

## Resumo de ficheiros a tocar (quando formos implementar)

| Ficheiro | Mudança |
|---|---|
| `virus/scripts/objects/painting.gd` | novo método `apply_pool_texture()` |
| `virus/scripts/resources/painting_pool_entry.gd` (novo) | Resource com `texture` |
| `virus/scripts/resources/painting_pool.gd` (novo) | Resource com `entries: Array[PaintingPoolEntry]` |
| `virus/resources/painting_pools/room_1_paintings.tres` (novo) | pool de placeholders para `room_1` |
| `virus/scripts/levels/room_1.gd` (novo) | sorteio sem repetição + distribuição no `_ready()` |
| `virus/scenes/levels/room_1.tscn` | associar `room_1.gd` ao nó raiz + atribuir `painting_pool` no Inspector |

Segue-se, depois desta mecânica estar a funcionar com placeholders: substituir as texturas placeholder por arte final nos `PaintingPoolEntry` (sem mexer em código).

Não implementar nenhum destes pontos até confirmação de "100% de certeza".
