# Tasks: Balanceamento de Gameplay, Câmera e Resolução

> Gerado a partir de: [[prd-balanceamento-camera-resolucao.md]]  
> Data: 2026-06-05

---

## Dependências entre tasks

```
TASK-01  (independente)
TASK-02  (independente)
TASK-03 → TASK-04
TASK-05  (independente)
```

Ordem recomendada de execução: **TASK-01 → TASK-02 → TASK-03 → TASK-04 → TASK-05**

---

## TASK-01 — Configurar stretch mode para tela cheia responsiva

**Tipo**: `chore`  
**Estimativa**: 30 min  
**Bloqueia**: —  
**Bloqueada por**: —

**Contexto:**  
O `project.godot` usa resolução `1920x750` sem stretch mode configurado, causando barras pretas em monitores 16:9. A altura não pode mudar (backgrounds dimensionados para 750px); só o comportamento de expansão lateral precisa ser corrigido.

**O que fazer:**
- [ ] Abrir `project.godot` e localizar a seção `[display]`
- [ ] Definir `window/stretch/mode = "canvas_items"`
- [ ] Definir `window/stretch/aspect = "expand"`
- [ ] Manter `window/size/viewport_width = 1920` e `window/size/viewport_height = 750`

**Arquivos afetados:**
- `project.godot` (editar)

**Critério de done:**
- [ ] Ao redimensionar a janela do editor, o background cobre toda a área sem barras pretas
- [ ] A proporção do cenário se mantém em 750px de altura

---

## TASK-02 — Aumentar zoom da câmera e verificar UI/spawns

**Tipo**: `feat`  
**Estimativa**: 1.5h  
**Bloqueia**: —  
**Bloqueada por**: —

**Contexto:**  
O personagem ocupa menos de 5% da tela porque a `Camera2D` está com zoom padrão (1, 1). A `TelaUpgrade` já usa `CanvasLayer` (linha 1 de `TelaUpgrade.gd`), então não será afetada pelo zoom. Precisa verificar se a HUD e as telas de estado também estão em `CanvasLayer`.

**O que fazer:**
- [ ] Abrir `scenes/Player.tscn` no editor Godot
- [ ] Selecionar o nó `Camera2D` filho do Player
- [ ] Definir `Camera2D.zoom = Vector2(2.0, 2.0)` (começar com 2x e ajustar)
- [ ] Abrir `scenes/ui/HUD.tscn` e confirmar que o nó raiz é `CanvasLayer`
- [ ] Abrir `scenes/ui/TelaGameOver.tscn`, `TelaVitoria.tscn` e confirmar que são `CanvasLayer`
- [ ] Rodar a Fase 1 e verificar que o personagem ocupa ~10% da altura da tela
- [ ] Verificar que inimigos aparecem fora da tela (spawn a ~300px à frente do player — ver `EnemySpawner.gd:75`)
- [ ] Se inimigos aparecerem na tela ao spawnar, aumentar o offset em `EnemySpawner.gd:75` de `300.0` para `~600.0`

**Arquivos afetados:**
- `scenes/Player.tscn` (editar nó Camera2D)
- `scripts/EnemySpawner.gd` linha 75 (possivelmente ajustar offset de spawn)

**Critério de done:**
- [ ] Personagem visualmente maior, combate mais dinâmico
- [ ] HUD de vida e materiais completamente visível
- [ ] Inimigos não "piscam" na tela ao serem instanciados

---

## TASK-03 — Rastrear nível de cada upgrade no GameManager

**Tipo**: `feat`  
**Estimativa**: 1h  
**Bloqueia**: TASK-04  
**Bloqueada por**: —

**Contexto:**  
Hoje o `GameManager.gd` não tem variáveis de nível por upgrade — apenas aplica os efeitos diretamente no Player (ver `TelaUpgrade.gd` linhas 31–64). Para implementar custo exponencial, o `GameManager` precisa saber em qual nível cada upgrade está.

**O que fazer:**
- [ ] Em `GameManager.gd`, adicionar as variáveis de nível após `var fase_atual`:
  ```gdscript
  var nivel_upgrade_vida: int = 0
  var nivel_upgrade_dano: int = 0
  var nivel_upgrade_recarga: int = 0
  var nivel_upgrade_velocidade: int = 0
  ```
- [ ] Em `resetar_estado()`, zerar os quatro novos campos junto com os demais
- [ ] Definir os custos base como constantes no `GameManager.gd`:
  ```gdscript
  const CUSTO_BASE_VIDA: int = 5
  const CUSTO_BASE_DANO: int = 8
  const CUSTO_BASE_RECARGA: int = 6
  const CUSTO_BASE_VELOCIDADE: int = 7
  const MULTIPLICADOR_CUSTO_UPGRADE: float = 2.0
  ```
- [ ] Adicionar a função de cálculo de custo:
  ```gdscript
  func custo_upgrade(custo_base: int, nivel: int) -> int:
      return int(custo_base * pow(MULTIPLICADOR_CUSTO_UPGRADE, nivel))
  ```

**Arquivos afetados:**
- `scripts/GameManager.gd` (editar)

**Critério de done:**
- [ ] `GameManager.custo_upgrade(5, 0)` retorna `5`
- [ ] `GameManager.custo_upgrade(5, 1)` retorna `10`
- [ ] `GameManager.custo_upgrade(5, 2)` retorna `20`
- [ ] `resetar_estado()` zera todos os níveis

---

## TASK-04 — Custo exponencial de upgrades na TelaUpgrade

**Tipo**: `feat`  
**Estimativa**: 2h  
**Bloqueia**: —  
**Bloqueada por**: TASK-03

**Contexto:**  
Hoje `TelaUpgrade.gd` tem custos fixos como constantes locais (linhas 3–6) e não exibe o custo nos botões. Com a TASK-03, o GameManager já terá os níveis e a função `custo_upgrade()`. Agora é só refatorar a TelaUpgrade para usar isso.

**O que fazer:**
- [ ] Remover as 4 constantes de custo do topo de `TelaUpgrade.gd` (linhas 3–6) — o custo agora vem do `GameManager`
- [ ] Atualizar `_atualizar_botoes()` para calcular o custo de cada upgrade via `GameManager.custo_upgrade()` e exibir no texto do botão:
  ```gdscript
  func _atualizar_botoes() -> void:
      _label_materiais.text = "Materiais: %d" % GameManager.materiais
      var custo_vida := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VIDA, GameManager.nivel_upgrade_vida)
      var custo_dano := GameManager.custo_upgrade(GameManager.CUSTO_BASE_DANO, GameManager.nivel_upgrade_dano)
      var custo_recarga := GameManager.custo_upgrade(GameManager.CUSTO_BASE_RECARGA, GameManager.nivel_upgrade_recarga)
      var custo_velocidade := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VELOCIDADE, GameManager.nivel_upgrade_velocidade)
      _botao_vida.text = "Mais Vida (%d mat)" % custo_vida
      _botao_vida.disabled = GameManager.materiais < custo_vida
      _botao_dano.text = "Mais Dano (%d mat)" % custo_dano
      _botao_dano.disabled = GameManager.materiais < custo_dano
      _botao_recarga.text = "Recarga (%d mat)" % custo_recarga
      _botao_recarga.disabled = GameManager.materiais < custo_recarga
      _botao_velocidade.text = "Velocidade (%d mat)" % custo_velocidade
      _botao_velocidade.disabled = GameManager.materiais < custo_velocidade
  ```
- [ ] Atualizar `_on_vida_pressed()` para usar o custo calculado e incrementar `GameManager.nivel_upgrade_vida`
- [ ] Atualizar `_on_dano_pressed()` para usar o custo calculado e incrementar `GameManager.nivel_upgrade_dano`
- [ ] Atualizar `_on_recarga_pressed()` para usar o custo calculado e incrementar `GameManager.nivel_upgrade_recarga`
- [ ] Atualizar `_on_velocidade_pressed()` para usar o custo calculado e incrementar `GameManager.nivel_upgrade_velocidade`

**Arquivos afetados:**
- `scripts/TelaUpgrade.gd` (refatorar)

**Critério de done:**
- [ ] Botões exibem o custo atual em materiais
- [ ] Após comprar um upgrade, o custo do próximo nível dobra
- [ ] Ao reiniciar o jogo (`resetar_estado()`), custos voltam ao valor base
- [ ] Botão fica desabilitado quando materiais são insuficientes para o nível atual

---

## TASK-05 — Escalar HP e quantidade de inimigos + Boss por fase

**Tipo**: `feat`  
**Estimativa**: 2h  
**Bloqueia**: —  
**Bloqueada por**: —

**Contexto:**  
Hoje todos os inimigos spawnam com `vida_base = 30` (padrão do `@export` em `Inimigo.gd:8`) independente da fase. O `EnemySpawner.gd` já tem `fase_numero` como `@export` e define as ondas com quantidades fixas. O `Boss.gd` tem `VIDA_BASE = 300` fixo sem escalar.

**Multiplicadores de HP sugeridos por fase:**
- Fase 1: `1.0x` → 30 HP (base)
- Fase 2: `1.5x` → 45 HP
- Fase 3: `2.5x` → 75 HP
- Fase 4: `4.0x` → 120 HP

**O que fazer:**

**Em `EnemySpawner.gd`:**
- [ ] Adicionar constante com os multiplicadores de vida por fase:
  ```gdscript
  const MULT_VIDA_POR_FASE: Array[float] = [1.0, 1.5, 2.5, 4.0]
  ```
- [ ] Em `_lancar_onda()`, aplicar o multiplicador ao `vida_base` do inimigo antes de adicionar à cena:
  ```gdscript
  var mult := MULT_VIDA_POR_FASE[fase_numero - 1]
  inimigo.vida_base = int(inimigo.vida_base * mult)
  inimigo.vida_atual = inimigo.vida_base
  ```
  *(deve vir após `get_parent().add_child(inimigo)` e antes de posicionar)*
- [ ] Aumentar a quantidade de inimigos nas ondas existentes seguindo a progressão abaixo:

  **Fase 1** (papel): `3, 4, 2, 5` → `4, 6, 3, 7`  
  **Fase 2** (plástico): `4, 5, 3, 6, 2` → `5, 7, 4, 8, 3`  
  **Fase 3** (metal): `5, 3, 6, 4, 7` → `7, 5, 8, 6, 9`  
  **Fase 4** (orgânico): `6, 4, 7, 5, 8, 3` → `8, 6, 10, 7, 11, 5`

**Em `Boss.gd`:**
- [ ] Adicionar `@export var multiplicador_vida: float = 1.0` após as constantes
- [ ] Substituir `vida_atual = VIDA_BASE` em `_ready()` por:
  ```gdscript
  vida_atual = int(VIDA_BASE * multiplicador_vida)
  ```
- [ ] Corrigir `receber_dano()` para usar `vida_atual <= int(VIDA_BASE * multiplicador_vida) / 2.0` na transição de fase agressiva

**Em `Main.gd` ou na cena de cada fase** (onde o Boss é instanciado):
- [ ] Ao instanciar o Boss, definir `multiplicador_vida` com base em `GameManager.fase_atual`:
  ```gdscript
  const MULT_BOSS_POR_FASE: Array[float] = [1.0, 1.5, 2.5, 4.0]
  boss.multiplicador_vida = MULT_BOSS_POR_FASE[GameManager.fase_atual - 1]
  ```

**Arquivos afetados:**
- `scripts/EnemySpawner.gd` (editar)
- `scripts/Boss.gd` (editar)
- `scripts/Main.gd` (verificar onde Boss é instanciado e passar multiplicador)

**Critério de done:**
- [ ] Inimigos da Fase 4 têm visivelmente mais HP que os da Fase 1 (barra de vida dura mais)
- [ ] Quantidade de inimigos por onda aumentou em todas as fases
- [ ] Boss da Fase 4 aguenta mais golpes que o Boss da Fase 1
- [ ] Nenhum magic number nos multiplicadores — todos em constantes nomeadas

---

## Resumo

| Task | Tipo | Estimativa | Depende de |
|------|------|------------|------------|
| TASK-01 — Stretch mode | chore | 30 min | — |
| TASK-02 — Zoom câmera | feat | 1.5h | — |
| TASK-03 — Nível de upgrades no GameManager | feat | 1h | — |
| TASK-04 — Custo exponencial de upgrades | feat | 2h | TASK-03 |
| TASK-05 — HP e quantidade de inimigos por fase | feat | 2h | — |

**Total estimado: ~7 horas**

**Por onde começar:** TASK-01 (30min, zero risco, resultado imediato) e TASK-03 (base para TASK-04) em paralelo.
