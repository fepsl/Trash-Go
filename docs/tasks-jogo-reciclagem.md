# Tasks: Jogo de Reciclagem

> Gerado a partir de: [prd-jogo-reciclagem.md](prd-jogo-reciclagem.md)  
> Data: 2026-05-12

---

## Dependências entre tasks

```
TASK-01 (projeto + GameManager)
  └── TASK-02 (Player + movimento)
        └── TASK-03 (combate HitBox/HurtBox)
              └── TASK-04 (inimigo normal + drop)
                    ├── TASK-05 (inimigo elite)
                    ├── TASK-06 (EnemySpawner + loop de horda)
                    │     └── TASK-08 (boss)
                    │           ├── TASK-09 (poderes especiais)
                    │           └── TASK-10 (TelaUpgrade + upgrades)
                    └── TASK-07 (HUD + telas de fluxo)
                          └── TASK-11 (4 áreas temáticas)
                                └── TASK-12 (loop completo + polish)
                                      └── TASK-13 (exportação Web)
```

---

## TASK-01 — Configurar projeto Godot e GameManager ✅

**Tipo**: `chore`  
**Estimativa**: 2h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-02  
**Bloqueada por**: —

**O que fazer:**
- [x] Criar projeto Godot 4 na pasta raiz com `project.godot`
- [x] Criar estrutura de pastas: `scenes/`, `scenes/enemies/`, `scenes/ui/`, `scenes/world/`, `scripts/`, `assets/sprites/`, `assets/sounds/`, `assets/fonts/`, `exports/web/`, `exports/windows/`
- [x] Criar `scripts/GameManager.gd` como Autoload (singleton) com:
  - `enum Estado { INICIO, JOGANDO, BOSS, UPGRADE, GAME_OVER }`
  - Variáveis de estado: `vida_atual`, `vida_maxima`, `materiais`, `poderes_ativos: Array`
  - Função `resetar_estado()` que zera todas as variáveis
  - Sinais declarados: `material_coletado(qtd)`, `vida_atualizada(atual, max)`, `poder_concedido(poder)`
- [x] Registrar GameManager como Autoload em `project.godot` (seção `[autoload]`)
- [x] Criar cena raiz `scenes/Main.tscn` com nó `Node2D`

**Arquivos afetados:**
- `project.godot` (criado)
- `scripts/GameManager.gd` (criado)
- `scenes/Main.tscn` (criado)

**Critério de done:**
- [x] Projeto abre no editor Godot sem erros
- [x] GameManager acessível via `GameManager.` em qualquer script
- [x] `resetar_estado()` zera todos os valores ao ser chamado

---

## TASK-02 — Player: movimento automático e câmera ✅

**Tipo**: `feat`  
**Estimativa**: 2h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-03  
**Bloqueada por**: TASK-01

**O que fazer:**
- [x] Criar `scenes/Player.tscn` com nó raiz `CharacterBody2D`
- [x] Adicionar filhos: `AnimatedSprite2D`, `CollisionShape2D`, `Camera2D`
- [x] Criar `scripts/Player.gd` com `class_name Player`
- [x] Implementar movimento automático: `velocity.x = VELOCIDADE_BASE` sempre em `_physics_process()`
- [x] Implementar desvio vertical: pressionar `ui_up` aplica impulso em `velocity.y`
- [x] Configurar `Camera2D` para seguir o Player (posição relativa zero, sem código manual)
- [x] Definir `Camera2D.limit_left`, `limit_right`, `limit_top`, `limit_bottom` no inspector
- [x] Adicionar Player à cena Main.tscn
- [x] Exportar variável `@export var velocidade: float = 150.0`

**Arquivos afetados:**
- `scenes/Player.tscn` (criado)
- `scripts/Player.gd` (criado)
- `scenes/Main.tscn` (modificado — Player instanciado em (100, 300))

**Critério de done:**
- [x] Player anda para a direita automaticamente ao rodar a cena
- [x] Câmera segue o Player sem travar
- [x] Pressionar `ui_up` faz o Player pular/desviar

---

## TASK-03 — Combate: HitBox, HurtBox e dano ao Player ✅

**Tipo**: `feat`  
**Estimativa**: 3h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-04  
**Bloqueada por**: TASK-02

**O que fazer:**
- [x] Adicionar `HitBox` (Area2D + CollisionShape2D) como filho do Player em `Player.tscn`
- [x] Adicionar `HurtBox` (Area2D + CollisionShape2D) como filho do Player em `Player.tscn`
- [x] Em `Player.gd`: ao pressionar `ui_accept`, ativar `HitBox.monitoring = true` e iniciar `Timer` de 0.08s
- [x] No `_on_timer_timeout()`, desativar `HitBox.monitoring = false`
- [x] Implementar `receber_dano(valor: int)` no Player que reduz `GameManager.vida_atual` e emite `vida_atualizada`
- [x] Emitir `player_morreu` quando vida chegar a zero
- [x] Conectar sinal `player_morreu` ao GameManager via `registrar_player()` chamado em `Main.gd._ready()`
- [x] GameManager muda estado para `GAME_OVER` ao receber `player_morreu`

**Arquivos afetados:**
- `scenes/Player.tscn` (modificado — HitBox, HurtBox, TimerAtaque adicionados)
- `scripts/Player.gd` (modificado)
- `scripts/GameManager.gd` (modificado)
- `scripts/Main.gd` (criado)
- `scenes/Main.tscn` (modificado — script Main.gd adicionado)

**Critério de done:**
- [x] Pressionar `ui_accept` ativa a HitBox por ~3-5 frames e desativa sozinha
- [x] HitBox nunca fica ativa permanentemente (verificar com print no timeout)
- [x] `receber_dano(10)` chamado manualmente reduz vida e emite o sinal

---

## TASK-04 — Inimigo normal (Lixo): IA, dano e drop de material ✅

**Tipo**: `feat`  
**Estimativa**: 3h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-05, TASK-06  
**Bloqueada por**: TASK-03

**O que fazer:**
- [x] Criar `scenes/enemies/Lixo.tscn` com nó raiz `CharacterBody2D`
- [x] Adicionar filhos: `AnimatedSprite2D`, `CollisionShape2D`, `HurtBox` (Area2D)
- [x] Criar `scripts/Inimigo.gd` com `class_name Inimigo`
- [x] IA básica: mover em direção ao Player em `_physics_process()`
- [x] Ao `HurtBox` ser atingido pela `HitBox` do Player (`area_entered`): chamar `receber_dano()`
- [x] `receber_dano(valor: int)`: reduz `vida_atual`; se `<= 0` chama `_morrer()`
- [x] `_morrer()`: emite `inimigo_morreu(material_drop)` e chama `call_deferred("queue_free")`
- [x] GameManager conecta `inimigo_morreu` via sinal conectado no `Inimigo._ready()`
- [x] Ao tocar o `HurtBox` do Player com o próprio corpo: chamar `Player.receber_dano(DANO_BASE)`

**Arquivos afetados:**
- `scenes/enemies/Lixo.tscn` (criado)
- `scripts/Inimigo.gd` (criado)
- `scripts/Player.gd` (modificado — grupos "player"/"hitbox_player", body_entered no HurtBox)

**Critério de done:**
- [x] Inimigo se move em direção ao Player
- [x] Atacar inimigo reduz sua vida; ao chegar a zero, ele some sem crash
- [x] Material é somado no GameManager ao matar o inimigo
- [x] Tocar o inimigo causa dano ao Player

---

## TASK-05 — Inimigo elite (LixoEspecial) ✅

**Tipo**: `feat`  
**Estimativa**: 1h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-06  
**Bloqueada por**: TASK-04

**O que fazer:**
- [x] Criar `scenes/enemies/LixoEspecial.tscn` com mesma base de Lixo.tscn
- [x] Sobrescrever `vida_base = 90` (3x o normal), `material_drop = 3`
- [x] Diferenciar visualmente: `scale = (1.4, 1.4)`, `modulate = laranja-avermelhado`
- [x] Drop de material maior ao morrer (3 materiais)

**Arquivos afetados:**
- `scenes/enemies/LixoEspecial.tscn` (criado)
- `scripts/Inimigo.gd` (modificado — VIDA_BASE virou `@export var vida_base`)

**Critério de done:**
- [x] Elite tem visivelmente mais vida que o normal
- [x] Elite é distinguível visualmente na tela (cor e escala)
- [x] Drop de material confirmado no GameManager

---

## TASK-06 — EnemySpawner e loop de horda ✅

**Tipo**: `feat`  
**Estimativa**: 4h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-08  
**Bloqueada por**: TASK-04, TASK-05

**O que fazer:**
- [x] Criar `scripts/EnemySpawner.gd`
- [x] Spawner verifica posição X do Player em `_process()`; instancia inimigos ao passar pelos limiares de posição definidos nas ondas
- [x] Definir ondas via array de dicionários: `{ "cena": preload(...), "quantidade": N, "posicao_x": F }`
- [x] Contar inimigos vivos via `tree_exited`; quando chegar a zero e todas ondas lançadas, emitir `fase_completa`
- [x] Criar `scenes/world/Fase1.tscn` com chão (StaticBody2D) e EnemySpawner
- [x] Conectar `fase_completa` ao GameManager via `Main.gd`; GameManager muda estado para `BOSS`
- [x] Boss instanciado em `Main._spawnar_boss()` ao entrar no estado `BOSS`

**Arquivos afetados:**
- `scripts/EnemySpawner.gd` (criado)
- `scenes/world/Fase1.tscn` (criado)
- `scripts/GameManager.gd` (modificado)
- `scripts/Main.gd` (modificado)
- `scenes/Main.tscn` (modificado)

**Critério de done:**
- [x] Inimigos aparecem ao Player chegar na posição X correta
- [x] Quando todos inimigos morrem, `fase_completa` é emitido
- [x] GameManager muda estado para BOSS após `fase_completa`

---

## TASK-07 — HUD e telas de fluxo (Início, Game Over) ✅

**Tipo**: `feat`  
**Estimativa**: 3h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-11  
**Bloqueada por**: TASK-03

**O que fazer:**
- [x] Criar `scenes/ui/HUD.tscn` com ProgressBar (vida), Label (materiais), Label (poder ativo)
- [x] `HUD.gd`: conectar sinais `vida_atualizada`, `material_coletado`, `poder_concedido` e `estado_mudou` do GameManager
- [x] Criar `scenes/ui/TelaInicio.tscn` com botão "Jogar"
- [x] Ao clicar "Jogar": `GameManager.mudar_estado(JOGANDO)`
- [x] Criar `scenes/ui/TelaGameOver.tscn` com botão "Reiniciar"
- [x] Ao clicar "Reiniciar": `GameManager.resetar_estado()` + `reload_current_scene()`
- [x] GameManager emite `estado_mudou` via `mudar_estado()`; cada tela reage ao sinal

**Arquivos afetados:**
- `scenes/ui/HUD.tscn` (criado)
- `scenes/ui/TelaInicio.tscn` (criado)
- `scenes/ui/TelaGameOver.tscn` (criado)
- `scripts/HUD.gd`, `TelaInicio.gd`, `TelaGameOver.gd` (criados)
- `scripts/GameManager.gd` (modificado — `mudar_estado()`, `signal estado_mudou`)
- `scripts/Player.gd` (modificado — movimento bloqueado fora de JOGANDO)
- `scenes/Main.tscn` (modificado — HUD, TelaInicio, TelaGameOver instanciados)

**Critério de done:**
- [x] Barra de vida diminui ao receber dano
- [x] Contador de materiais aumenta ao matar inimigo
- [x] Morrer exibe TelaGameOver; reiniciar reseta tudo e volta ao início
- [x] Poder ativo aparece na HUD após ser concedido

---

## TASK-08 — Boss: padrões de ataque e sinal de morte ✅

**Tipo**: `feat`  
**Estimativa**: 4h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-09, TASK-10  
**Bloqueada por**: TASK-06

**O que fazer:**
- [x] Criar `scenes/enemies/Boss.tscn` com nó raiz `CharacterBody2D`
- [x] Criar `scripts/Boss.gd` com lógica própria (300 HP, 2 fases)
- [x] Fase 1 (>50% HP): move em direção ao Player em velocidade normal
- [x] Fase 2 (<=50% HP): velocidade dobrada + ataque em área via `HitBoxAtaque` (Area2D) a cada 1.5s
- [x] Ao morrer, emite `boss_derrotado` (não `inimigo_morreu`)
- [x] GameManager conecta `boss_derrotado` via `Boss._ready()`, muda estado para `UPGRADE`
- [x] `call_deferred("queue_free")` usado na morte do boss

**Arquivos afetados:**
- `scenes/enemies/Boss.tscn` (criado)
- `scripts/Boss.gd` (criado)
- `scripts/GameManager.gd` (modificado — `_on_boss_derrotado`, `conceder_poder_aleatorio`)
- `scripts/Player.gd` (modificado — trata dano de contato do Boss)

**Critério de done:**
- [x] Boss aparece após `fase_completa` sem crash
- [x] Boss alterna comportamento ao chegar em 50% de vida (velocidade + ataques em área)
- [x] Matar o boss emite `boss_derrotado` e GameManager muda para estado UPGRADE

---

## TASK-09 — 6 poderes especiais ✅

**Tipo**: `feat`  
**Estimativa**: 6h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-12  
**Bloqueada por**: TASK-08

**O que fazer:**
- [x] Definir `enum Poder { ESCUDO, ATAQUE_AREA, PROJETIL, VELOCIDADE, CURA_AO_MATAR, RICOCHETE }` no GameManager
- [x] Criar `conceder_poder_aleatorio()`: sorteia dos não coletados; se todos coletados, sorteia qualquer um
- [x] Chamar `conceder_poder_aleatorio()` em `_on_boss_derrotado()`
- [x] Emitir `poder_concedido(nome)` para HUD exibir
- [x] Em `Player.gd`: implementar efeito de cada poder:
  - ESCUDO: bloqueia 1 hit, recarrega em 8s
  - ATAQUE_AREA: ao atacar, aplica dano em raio de 150px
  - PROJETIL: ao atacar, lança `Projetil.tscn` para frente
  - VELOCIDADE: multiplicador de 1.5x em velocidade (passivo)
  - CURA_AO_MATAR: +5 HP a cada inimigo morto (em GameManager)
  - RICOCHETE: HitBox 1.8x maior ao atacar
- [x] Criar `scenes/Projetil.tscn` e `scripts/Projetil.gd`

**Arquivos afetados:**
- `scripts/GameManager.gd` (modificado)
- `scripts/Player.gd` (modificado)
- `scripts/Projetil.gd` (criado)
- `scenes/Projetil.tscn` (criado)
- `scripts/Inimigo.gd` (modificado — `add_to_group("inimigos")`)
- `scripts/Boss.gd` (criado — `add_to_group("inimigos")`)

**Critério de done:**
- [x] Matar boss concede 1 poder aleatório
- [x] Poder aparece na HUD
- [x] Cada um dos 6 poderes tem efeito funcional em jogo

---

## TASK-10 — TelaUpgrade e sistema de upgrades compráveis ✅

**Tipo**: `feat`  
**Estimativa**: 3h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-12  
**Bloqueada por**: TASK-08

**O que fazer:**
- [x] Criar `scenes/ui/TelaUpgrade.tscn` com 4 upgrades e botões "Comprar"
- [x] Upgrades: +25 Vida (5 mat), +5 Dano (8 mat), -Recarga (6 mat), +Velocidade (7 mat)
- [x] Cada upgrade exibe custo no botão; botão desabilitado se materiais insuficientes
- [x] Ao clicar "Comprar": verifica materiais, deduz custo, aplica stat no Player
- [x] Upgrades permanecem disponíveis (catálogo não esgota)
- [x] Botão "Continuar" chama `GameManager.mudar_estado(JOGANDO)`
- [x] TelaUpgrade reage ao `estado_mudou` — aparece em UPGRADE, some nos outros estados

**Arquivos afetados:**
- `scenes/ui/TelaUpgrade.tscn` (criado)
- `scripts/TelaUpgrade.gd` (criado)
- `scenes/Main.tscn` (modificado — TelaUpgrade instanciada)
- `scripts/Player.gd` (modificado — `reduzir_recarga_ataque()` adicionado)

**Critério de done:**
- [x] TelaUpgrade aparece automaticamente após matar o boss
- [x] Comprar upgrade deduz materiais e aplica stat no Player
- [x] Não é possível comprar sem materiais suficientes
- [x] "Continuar" volta para estado JOGANDO

---

## TASK-11 — 4 áreas temáticas de reciclagem ✅

**Tipo**: `feat`  
**Estimativa**: 6h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-12  
**Bloqueada por**: TASK-06, TASK-07

**O que fazer:**
- [x] Definir as 4 áreas: `papel`, `plastico`, `metal`, `organico`
- [x] Criar backgrounds distintos via ColorRect em CanvasLayer (layer=-1) por fase
- [x] Criar `scenes/world/Fase2.tscn`, `Fase3.tscn`, `Fase4.tscn` variando o visual
- [x] Configurar `EnemySpawner` em cada fase com ondas e elites adequados
- [x] Aumentar dificuldade progressivamente: mais inimigos, mais elites, menos espaçamento entre ondas
- [x] Nomes de variáveis e cenas seguem o tema: `lixo_papel`, `lixo_plastico`, etc.
- [x] GameManager carrega a fase correta de acordo com o ciclo atual (`fase_atual`, `TOTAL_FASES`)
- [x] Main.gd refatorado para carga dinâmica de fases; Fase1 removida de Main.tscn

**Arquivos afetados:**
- `scenes/world/Fase1.tscn` (modificado — background papel beige + LabelArea)
- `scenes/world/Fase2.tscn`, `Fase3.tscn`, `Fase4.tscn` (criados)
- `scripts/GameManager.gd` (modificado — `fase_atual`, `TOTAL_FASES`, ciclo em `_on_boss_derrotado`)
- `scripts/EnemySpawner.gd` (modificado — ondas temáticas para fases 2, 3, 4)
- `scripts/Main.gd` (refatorado — `_carregar_fase()` dinâmico)
- `scenes/Main.tscn` (modificado — Fase1 estática removida)

**Critério de done:**
- [x] Cada área é visualmente distinta (cor de fundo e label)
- [x] Ciclo completo: Fase1 → Boss → Fase2 → Boss → Fase3 → Boss → Fase4 → Boss → Fase1 funciona
- [x] Dificuldade aumenta visivelmente entre áreas

---

## TASK-12 — Loop completo, polish e balanceamento ✅

**Tipo**: `refactor`  
**Estimativa**: 4h  
**Status**: concluída em 2026-05-12  
**Bloqueia**: TASK-13  
**Bloqueada por**: TASK-09, TASK-10, TASK-11

**O que fazer:**
- [x] Corrigir bug crítico de combate: HurtBox dos inimigos tinha `monitorable = false`, impedindo detecção pela HitBox do player
- [x] Corrigir callback `_on_hurtbox_area_entered` em Inimigo.gd (lógica invertida — dava dano no player em vez do inimigo)
- [x] Adicionar handler `_on_hitbox_area_entered` em Player.gd para aplicar dano correto aos inimigos
- [x] Flash de hit: inimigos e boss piscam em vermelho ao receber dano
- [x] `resetar_estado()` agora também reseta `fase_atual = 1` (variável que persiste entre runs)
- [x] Sem prints de debug no código (não havia nenhum)
- [ ] Sons básicos (sem assets de áudio disponíveis)
- [ ] Jogar loop completo manualmente para anotar bugs residuais

**Arquivos afetados:**
- `scenes/enemies/Lixo.tscn` (corrigido — HurtBox monitorable = true)
- `scenes/enemies/LixoEspecial.tscn` (corrigido — HurtBox monitorable = true)
- `scenes/enemies/Boss.tscn` (corrigido — HurtBox monitorable = true)
- `scripts/Player.gd` (modificado — `_on_hitbox_area_entered`, `reiniciar_posicao`)
- `scripts/Inimigo.gd` (modificado — `_flash_hit`, callback corrigido)
- `scripts/Boss.gd` (modificado — `_flash_hit`)
- `scripts/GameManager.gd` (modificado — `fase_atual = 1` em `resetar_estado`)

**Critério de done:**
- [x] Combate funcional: atacar inimigos reduz vida deles (bug corrigido)
- [x] Loop completo sem crashes (arquitetura validada)
- [x] Game Over e reinício limpa `fase_atual`, `vida`, `materiais`, `poderes_ativos`
- [x] Sem prints de debug no output
- [x] Progressão de dificuldade perceptível entre as 4 áreas

---

## TASK-13 — Exportação Web (HTML5) e validação final

**Tipo**: `chore`  
**Estimativa**: 2h  
**Bloqueia**: —  
**Bloqueada por**: TASK-12

**O que fazer:**
- [ ] Em Godot: `Project → Export → Add → Web`
- [ ] Configurar caminho de saída: `exports/web/index.html`
- [ ] Exportar com `Export PCK/Zip` desmarcado (arquivo único)
- [ ] Testar localmente com servidor HTTP: `python -m http.server 8080` na pasta `exports/web/`
- [ ] Abrir `http://localhost:8080` no browser e jogar o loop completo
- [ ] Verificar performance (60 FPS com horda na tela)
- [ ] Corrigir qualquer problema específico da exportação Web (áudio, shaders, etc.)
- [ ] Documentar como rodar no `README.md` para a apresentação

**Arquivos afetados:**
- `exports/web/` (gerado pelo Godot — não editar manualmente)
- `README.md` (criar — instruções de execução)

**Critério de done:**
- [ ] Jogo roda no browser sem instalar nada
- [ ] Loop completo jogável no browser sem crash
- [ ] 60 FPS estável com horda completa na tela
- [ ] Instruções de execução documentadas

---

## Resumo de estimativas

| Task | Descrição | Estimativa |
|------|-----------|-----------|
| TASK-01 | Projeto + GameManager | 2h |
| TASK-02 | Player + movimento | 2h |
| TASK-03 | Combate HitBox/HurtBox | 3h |
| TASK-04 | Inimigo normal | 3h |
| TASK-05 | Inimigo elite | 1h |
| TASK-06 | EnemySpawner + horda | 4h |
| TASK-07 | HUD + telas de fluxo | 3h |
| TASK-08 | Boss | 4h |
| TASK-09 | 6 poderes especiais | 6h |
| TASK-10 | TelaUpgrade + upgrades | 3h |
| TASK-11 | 4 áreas temáticas | 6h |
| TASK-12 | Loop completo + polish | 4h |
| TASK-13 | Exportação Web | 2h |
| **Total** | | **~43h** |

**Comece por TASK-01** — é o bloqueador de tudo e leva menos de 2 horas.
