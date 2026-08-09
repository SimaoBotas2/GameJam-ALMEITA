# Bug: o quadro fechava e voltava a abrir sozinho

## Sintoma

Às vezes, ao carregar em E para fechar o popup de um quadro, ele fechava e reabria logo a seguir.

## Causa

O E que fecha o popup (painting_inspector.gd) é o mesmo E que a personagem lê em handle_interaction() para reabrir o quadro. O código antigo esperava só 1 frame (await get_tree().process_frame) antes de destrancar a interação, mas física e render não correm sempre ao mesmo ritmo — às vezes esse frame não chegava para o clique "expirar", e a personagem interpretava-o como um clique novo. Ver image.png.

## Correção

Em vez de esperar um frame fixo, esperar a tecla ser mesmo largada:

```gdscript
# painting_inspector.gd
while Input.is_action_pressed("interact"):
	await get_tree().process_frame
```

## Padrão a vigiar

Uma ação usada para fechar/destrancar algo, se for lida também noutro sítio, pode ser "reaproveitada". Solução: esperar pela condição real (tecla largada), nunca por um número fixo de frames.
