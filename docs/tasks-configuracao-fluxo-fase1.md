# Tasks: Configuração do Fluxo Completo — Menu → Fase 1

> Gerado a partir de: [prd-configuracao-fluxo-fase1.md](prd-configuracao-fluxo-fase1.md)
> Data: 2026-05-18
> Atualizado: 2026-05-18 — análise pré-flight completa + 2 bugs corrigidos

---

## Dependências entre tasks

```
TASK-00  (bug crítico — resolvido)
TASK-00A (bug pré-flight — resolvido)
TASK-00B (bug pré-flight — resolvido)
TASK-01 → TASK-02 → TASK-03 → TASK-05
                 → TASK-04 → TASK-05
                            → TASK-06 (resolvido — ver nota)
TASK-05 → TASK-07
TASK-06 → TASK-07
```

---

## Análise pré-flight (2026-05-18)

Inspeção completa de todos os scripts e cenas antes dos testes manuais.

**Verificado sem problemas:**
- `GameManager` autoload configurado em `project.godot` ✓
- Todos os assets referenciados existem em disco (backgrounds, sprites, efeitos) ✓
- Conexões de sinais completas: `player_morreu`, `fase_completa`, `boss_derrotado`, `inimigo_morreu` ✓
- Conexões dos botões nas `.tscn` (BotaoJogar, BotaoReiniciar, upgrades, BotaoContinuar) ✓
- Collision layers corretos em todos os nós (Player, Inimigo, LixoEspecial, Boss) ✓
- `EnemySpawner` encontra o player via grupo após `add_child` da fase ✓
- Fluxo reiniciar: `resetar_estado()` + `reload_current_scene()` correto ✓
- `EfeitoMorte.tscn` tem animação "explode" e auto-destrói via `animation_finished` ✓

**Bugs encontrados e corrigidos:** → ver TASK-00A e TASK-00B abaixo.

**Limitação de design (não é bug):** `body_entered` dispara uma vez por contato, não continuamente. Na prática, com inimigos e player sempre se movendo, o dano por contato funciona adequadamente.

---

## TASK-00 — [CONCLUÍDA] Bug crítico: main scene apontando para Fase1 em vez de Main.tscn

**Tipo**: `fix`
**Status**: ✅ Concluída
**Descoberta durante**: inspeção de código antes de TASK-01

**Contexto:**
`project.godot` tinha `run/main_scene="uid://fase1tscn"` — o jogo abria a Fase1 diretamente,
pulando o menu completamente. A chave `config/main_scene` que apontava para `Main.tscn`
é ignorada pelo Godot 4; a chave ativa é `run/main_scene`.

**O que foi feito:**
- [x] Corrigido `run/main_scene` de `uid://fase1tscn` para `uid://main`
- [x] Removida a chave redundante `config/main_scene`
- [x] Adicionada seção `[layer_names]` com nomes para as 4 camadas de física 2D

**Arquivos alterados:**
- `project.godot`

---

## TASK-00A — [CONCLUÍDA] Bug pré-flight: Projetil não detectava inimigos

**Tipo**: `fix`
**Status**: ✅ Concluída
**Descoberta durante**: análise pré-flight (2026-05-18)

**Contexto:**
`Projetil.tscn` não tinha `collision_mask` definido. O default do Godot é `1` (layer "mundo"),
então o projétil só detectava o chão (`StaticBody2D`) via `body_entered`, mas nunca os inimigos
(`CharacterBody2D`, layer 3 = bitmask `4`). O poder Projétil seria completamente não-funcional.

**O que foi feito:**
- [x] Adicionado `collision_mask = 5` em `Projetil.tscn` (bitmask: mundo `1` + inimigos `4`)

**Arquivos alterados:**
- `scenes/Projetil.tscn`

---

## TASK-00B — [CONCLUÍDA] Bug pré-flight: Boss sem controle de animação

**Tipo**: `fix`
**Status**: ✅ Concluída
**Descoberta durante**: análise pré-flight (2026-05-18)

**Contexto:**
`Boss.gd` não chamava `$AnimatedSprite2D.play()` em nenhum momento. O boss tinha as
animações "idle", "move" e "attack" definidas no `.tscn`, mas ficava perpetuamente no
autoplay "idle" — mesmo enquanto perseguia o player.

**O que foi feito:**
- [x] Adicionado controle de animação em `_physics_process`: `play("move")` quando perseguindo player, `play("idle")` caso contrário
- [x] Adicionado `flip_h` para espelhar o sprite conforme a direção de movimento

**Arquivos alterados:**
- `scripts/Boss.gd`

---

## TASK-01 — Abrir o projeto corretamente no Godot

**Tipo**: `chore`
**Estimativa**: 0.5h
**Bloqueia**: TASK-03, TASK-04
**Bloqueada por**: —

**O que fazer:**
- [ ] No Windows Explorer, navegar até `C:\Users\Usuario\Desktop\Projeto de reciclagem`
- [ ] Dar duplo clique no arquivo `project.godot` (ícone do Godot)
- [ ] Aguardar o Godot importar os assets (barra de progresso na primeira abertura)
- [ ] Confirmar que o painel de arquivos (`res://`) mostra as pastas `scenes/`, `scripts/`, `assets/`
- [ ] Abrir `scenes/Main.tscn` com duplo clique para visualizar no editor
- [ ] Pressionar **F5** e confirmar que o jogo inicia sem erros vermelhos no Output

**Arquivos afetados:**
- Nenhum arquivo editado — só verificação

**Critério de done:**
- [ ] F5 abre o jogo e a tela de menu ("Jogo de Reciclagem" + botão "Jogar") aparece
- [ ] Output não tem nenhuma linha vermelha de erro

---

## TASK-02 — [CONCLUÍDA] Verificar e configurar collision layers (Player ↔ Inimigos)

**Tipo**: `fix`
**Status**: ✅ Concluída
**Estimativa original**: 1h

**Contexto:**
Todos os nós estavam na camada padrão (layer=1, mask=1). Isso funcionaria para colisão
básica, mas misturava chão, player, inimigos e hitboxes na mesma camada, impedindo
filtragem precisa. Os layers foram separados por responsabilidade.

**Mapa de layers implementado:**

| Layer | Nome | Bitmask |
|-------|------|---------|
| Layer 1 | mundo | 1 |
| Layer 2 | player | 2 |
| Layer 3 | inimigos | 4 |
| Layer 4 | hitboxes | 8 |

> **Nota sobre o task spec original:** Os valores `collision_layer = 3` (inimigos) e
> `collision_layer = 4` (hitboxes) no spec original usavam numeração de layer em vez
> de bitmask. Os valores corretos para Godot 4 são bitmask: Layer 3 = `4`, Layer 4 = `8`.

**O que foi feito:**

`scenes/Player.tscn`:
- [x] `Player` (CharacterBody2D): `collision_layer = 2`, `collision_mask = 1`
- [x] `HurtBox` (Area2D): `collision_layer = 8`, `collision_mask = 4`, `monitoring = true`, `monitorable = true`
- [x] `HitBox` (Area2D): `collision_layer = 0`, `collision_mask = 8`

`scenes/enemies/Lixo.tscn`:
- [x] `Lixo` (CharacterBody2D): `collision_layer = 4`, `collision_mask = 1`
- [x] `HurtBox` (Area2D): `collision_layer = 8`, `collision_mask = 0`, `monitoring = false`, `monitorable = true`

`scenes/enemies/LixoEspecial.tscn`:
- [x] Mesmos valores de `Lixo.tscn`

`scenes/enemies/Boss.tscn`:
- [x] `Boss` (CharacterBody2D): `collision_layer = 4`, `collision_mask = 1`
- [x] `HurtBox` (Area2D): `collision_layer = 8`, `collision_mask = 0`, `monitoring = false`, `monitorable = true`
- [x] `HitBoxAtaque` (Area2D): `collision_layer = 0`, `collision_mask = 8`

**Critério de done:**
- [ ] Player recebe dano ao ser tocado por um inimigo (barra de vida diminui no HUD)
- [ ] Player causa dano ao atacar (`ui_accept`) perto de um inimigo (inimigo pisca vermelho)
- [ ] Player não atravessa o chão da Fase 1
- [ ] Inimigos não atravessam o chão da Fase 1

---

## TASK-03 — Validar fluxo Menu → Jogar → Fase 1 carregando

**Tipo**: `test`
**Estimativa**: 0.5h
**Bloqueia**: TASK-05
**Bloqueada por**: TASK-01

**O que fazer:**
- [ ] Pressionar F5 no Godot
- [ ] Confirmar que a tela de menu aparece com o título e o botão "Jogar"
- [ ] Clicar "Jogar" e confirmar que a Fase 1 carrega (background floresta com parallax visível)
- [ ] Confirmar que o HUD aparece (barra de vida + "Materiais: 0")
- [ ] Confirmar que o player começa a se mover para a direita automaticamente
- [ ] Confirmar que a câmera segue o player
- [ ] Se algo falhar, checar o Output por erros e corrigir antes de prosseguir

**Arquivos afetados:**
- Nenhum — só verificação. Se encontrar bug, criar subtask de fix.

**Critério de done:**
- [ ] Menu aparece ao iniciar
- [ ] Clicar "Jogar" carrega a Fase 1 sem erros
- [ ] Background floresta visível com efeito parallax ao mover o player

---

## TASK-04 — Validar sistema de combate — ataque e morte de inimigos

**Tipo**: `test`
**Estimativa**: 1h
**Bloqueia**: TASK-05
**Bloqueada por**: TASK-01

**O que fazer:**
- [ ] Jogar até chegar na primeira onda (player precisa chegar em X≈400)
- [ ] Pressionar `Enter` (`ui_accept`) para atacar
- [ ] Confirmar que o inimigo pisca vermelho ao receber dano
- [ ] Confirmar que o inimigo morre e some com efeito de explosão
- [ ] Confirmar que "Materiais:" no HUD incrementa ao matar inimigo
- [ ] Deixar um inimigo encostar no player e confirmar que a barra de vida diminui
- [ ] Deixar o player morrer (vida chegar a 0) e confirmar que a tela de Game Over aparece
- [ ] Clicar "Reiniciar" e confirmar que o menu volta e o jogo reinicia do zero

**Arquivos afetados:**
- Nenhum esperado — as collision layers já foram configuradas corretamente na TASK-02

**Critério de done:**
- [ ] Ataque do player causa dano e mata inimigos
- [ ] Inimigos causam dano ao player por contato
- [ ] Efeito de explosão aparece ao matar inimigo
- [ ] Fluxo morte → Game Over → Reiniciar funciona sem crash

---

## TASK-05 — Validar spawn de ondas — todas as 4 ondas da Fase 1

**Tipo**: `test`
**Estimativa**: 1h
**Bloqueia**: TASK-07
**Bloqueada por**: TASK-03, TASK-04

**O que fazer:**
- [ ] Jogar a Fase 1 do início e verificar cada onda:
  - [ ] **Onda 1** (X≈400): 3 slimes verdes spawnando à direita da câmera
  - [ ] **Onda 2** (X≈800): 4 slimes verdes spawnando
  - [ ] **Onda 3** (X≈1200): 2 LixoEspecial (slime laranja maior) spawnando
  - [ ] **Onda 4** (X≈1600): 5 slimes verdes spawnando
- [ ] Confirmar que os inimigos aparecem à direita do player, não em cima dele
- [ ] Confirmar que após matar todos os inimigos de todas as ondas, o sinal `fase_completa` dispara
  (verificar no Output: o jogo tentará transitar para estado BOSS)
- [ ] Se alguma onda não spawnar, checar se o player está no grupo `"player"` corretamente

**Arquivos afetados:**
- `scripts/EnemySpawner.gd` — apenas se precisar ajustar posições das ondas
- `scripts/Player.gd` — `add_to_group("player")` já confirmado em `_ready()` na linha 20

**Critério de done:**
- [ ] Todas as 4 ondas spawnando na ordem e posição corretas
- [ ] Inimigos perseguem o player após spawnar
- [ ] Após todas as ondas eliminadas, o Output mostra transição de estado (BOSS ou GAME_OVER)

---

## TASK-06 — [CONCLUÍDA] Bug: sinal boss_derrotado não conectado

**Tipo**: `fix`
**Status**: ✅ Já estava resolvido no código — nenhuma alteração necessária
**Estimativa original**: 0.5h

**Contexto:**
Após inspeção de código, o sinal `boss_derrotado` **já está conectado** em `Boss.gd:24`
dentro de `_ready()`:
```gdscript
boss_derrotado.connect(GameManager._on_boss_derrotado)
```
O bug descrito no task spec (conexão ausente em `Main._spawnar_boss()`) foi corrigido
em algum momento anterior colocando a conexão no próprio `Boss.gd`. A solução é
equivalente e mais limpa — o Boss gerencia seu próprio sinal.

**Verificações confirmadas:**
- [x] `Boss.gd` declara o sinal `boss_derrotado` (linha 18)
- [x] `Boss.gd` conecta ao `GameManager._on_boss_derrotado` em `_ready()` (linha 24)
- [x] `Boss._morrer()` emite `boss_derrotado` antes de `queue_free` (linha 64)
- [x] `GameManager._on_boss_derrotado()` chama `mudar_estado(Estado.UPGRADE)` (linha 53)

**Arquivos afetados:**
- Nenhum

---

## TASK-07 — Teste de integração completo — fluxo Menu → Fase 1 → Boss → Upgrade

**Tipo**: `test`
**Estimativa**: 1.5h
**Bloqueia**: —
**Bloqueada por**: TASK-05

**O que fazer:**
- [ ] Jogar o fluxo completo do início ao fim da Fase 1:
  1. F5 → menu aparece
  2. Clicar "Jogar" → Fase 1 carrega, player move
  3. Passar pelas 4 ondas de inimigos eliminando todos
  4. Boss spawna à direita (com animação de movimento correta)
  5. Derrotar o boss → tela de upgrade aparece
- [ ] Testar o fluxo alternativo (morte):
  1. F5 → menu → Jogar
  2. Deixar player morrer → Game Over aparece
  3. Clicar "Reiniciar" → tudo reseta
- [ ] Verificar que nenhum erro aparece no Output durante qualquer parte do fluxo
- [ ] Verificar que o HUD atualiza corretamente em todos os momentos
- [ ] Verificar que a câmera não trava nem sai dos limites

**Arquivos afetados:**
- Nenhum — validação. Qualquer bug encontrado vira nova task de fix.

**Critério de done:**
- [ ] Fluxo completo (menu → fase → boss → upgrade) sem crashes
- [ ] Fluxo de morte (menu → fase → morte → game over → reinício) sem crashes
- [ ] Zero erros vermelhos no Output do Godot durante qualquer sessão de jogo
- [ ] HUD exibe vida e materiais corretos em tempo real

---

## Resumo de estimativas

| Task | Tipo | Status | Estimativa |
|------|------|--------|-----------|
| TASK-00: Bug main scene (project.godot) | fix | ✅ Concluída | — |
| TASK-00A: Bug Projetil collision_mask | fix | ✅ Concluída | — |
| TASK-00B: Bug Boss sem animação | fix | ✅ Concluída | — |
| TASK-01: Abrir projeto no Godot | chore | ⏳ Pendente | 0.5h |
| TASK-02: Collision layers | fix | ✅ Concluída | — |
| TASK-03: Fluxo menu → Fase 1 | test | ⏳ Pendente | 0.5h |
| TASK-04: Combate e morte de inimigos | test | ⏳ Pendente | 1h |
| TASK-05: Spawn das 4 ondas | test | ⏳ Pendente | 1h |
| TASK-06: Bug sinal boss_derrotado | fix | ✅ Já resolvido | — |
| TASK-07: Integração completa | test | ⏳ Pendente | 1.5h |
| **Restante** | | | **~4h** |

**Por onde continuar**: TASK-01 — abrir o projeto no Godot e pressionar F5.
Todos os bugs conhecidos foram corrigidos por inspeção estática. O código está pronto para testes manuais.
