# Jogo de Reciclagem — Documentação Completa

**Plataforma:** Godot 4.6 · **Resolução:** 1280×720 · **Gênero:** Roguelike Side-scroller 2D  
**Contexto:** Projeto acadêmico educativo sobre reciclagem

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Loop de Jogo](#loop-de-jogo)
3. [Estrutura de Arquivos](#estrutura-de-arquivos)
4. [Arquitetura](#arquitetura)
5. [Scripts — Referência Completa](#scripts--referência-completa)
6. [Mecânicas](#mecânicas)
7. [Sistemas de Progressão](#sistemas-de-progressão)
8. [Interface (HUD e Telas)](#interface-hud-e-telas)
9. [Configuração do Projeto](#configuração-do-projeto)
10. [Como Executar e Exportar](#como-executar-e-exportar)

---

## Visão Geral

Side-scroller 2D onde o personagem avança automaticamente pela fase enquanto o jogador controla ataques e desvios. O tema é reciclagem: os inimigos representam tipos de lixo (papel, plástico, metal, orgânico) e os materiais coletados financiam upgrades entre fases.

O jogo segue um loop roguelike infinito — ao completar as 4 fases, o ciclo recomeça com dificuldade crescente. Não há save de progresso; todo o estado vive em memória durante a sessão.

---

## Loop de Jogo

```
[TelaInicio]
    ↓ Jogar
[Fase 1 → 4]  ←──────────────────────────┐
    ↓ Todas ondas derrotadas              │
[Boss da Fase]                            │
    ↓ Boss derrotado                      │
[Poder aleatório concedido]               │
    ↓                                     │
[TelaUpgrade]  ─── Continuar ────────────┘
                                          ↑ (num_loops++)
    ↓ Vida = 0
[TelaGameOver] ─── Reiniciar → resetar_estado()
```

**Ciclos (loops):** Ao completar a Fase 4, `num_loops` incrementa. A partir do próximo ciclo, todos os multiplicadores de vida, dano e quantidade de inimigos aumentam — dificuldade infinita e progressiva.

---

## Estrutura de Arquivos

```
res://
├── project.godot
├── icon.svg
├── scenes/
│   ├── Main.tscn               # Cena raiz
│   ├── Player.tscn
│   ├── Projetil.tscn
│   ├── EfeitoMorte.tscn
│   ├── enemies/
│   │   ├── Lixo.tscn           # Inimigo base
│   │   ├── LixoEspecial.tscn   # Inimigo elite
│   │   └── Boss.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   ├── TelaInicio.tscn
│   │   ├── TelaGameOver.tscn
│   │   └── TelaUpgrade.tscn
│   └── world/
│       ├── Fase1.tscn          # Tema: Papel
│       ├── Fase2.tscn          # Tema: Plástico
│       ├── Fase3.tscn          # Tema: Metal
│       └── Fase4.tscn          # Tema: Orgânico
├── scripts/
│   ├── GameManager.gd          # Autoload (singleton)
│   ├── Main.gd
│   ├── Player.gd
│   ├── Inimigo.gd
│   ├── Boss.gd
│   ├── EnemySpawner.gd
│   ├── Projetil.gd
│   ├── EfeitoMorte.gd
│   ├── HUD.gd
│   ├── TelaInicio.gd
│   ├── TelaGameOver.gd
│   └── TelaUpgrade.gd
└── assets/
    ├── sprites/
    │   ├── Individual Sprites Male/    # Spritesheet do personagem (128×128/frame)
    │   └── Individual Sprites Slime/  # Sprites do inimigo slime (32×25/frame)
    ├── backgrounds/
    ├── effects/
    ├── HUD/                            # UI Essential Pack (assets de interface)
    ├── sounds/
    └── fonts/
```

---

## Arquitetura

### Máquina de estados (GameManager)

```gdscript
enum Estado { INICIO, JOGANDO, BOSS, UPGRADE, GAME_OVER }
```

| Estado | O que está ativo |
|---|---|
| `INICIO` | TelaInicio; mundo limpo |
| `JOGANDO` | Fase carregada; Player em movimento; EnemySpawner ativo |
| `BOSS` | Fase pausada; Boss instanciado |
| `UPGRADE` | TelaUpgrade visível; Player parado |
| `GAME_OVER` | TelaGameOver visível |

### Fluxo de sinais

| Sinal | Emitido por | Recebido por | Efeito |
|---|---|---|---|
| `estado_mudou(estado)` | GameManager | Main, HUD, todas as telas | Atualiza visibilidade e lógica |
| `player_morreu` | Player | GameManager | `mudar_estado(GAME_OVER)` |
| `inimigo_morreu(material_drop)` | Inimigo | GameManager | Acumula materiais; cura se poder ativo |
| `fase_completa` | EnemySpawner | GameManager | `mudar_estado(BOSS)` |
| `boss_derrotado` | Boss | GameManager | Concede poder; avança fase; `mudar_estado(UPGRADE)` |
| `material_coletado(qtd)` | GameManager | HUD | Atualiza label de materiais |
| `vida_atualizada(atual, max)` | GameManager | HUD | Atualiza barra de vida |
| `poder_concedido(nome)` | GameManager | HUD, Player | Atualiza slots HUD; ativa lógica de poder |

### Camadas de física 2D

| Camada | Nome | Uso |
|---|---|---|
| 1 | `mundo` | Chão, paredes estáticas |
| 2 | `player` | CharacterBody2D do Player |
| 3 | `inimigos` | CharacterBody2D dos inimigos |
| 4 | `hitboxes` | Area2D de HitBox e HurtBox |

### Autoload

`GameManager` é registrado como autoload em `project.godot`. Todos os scripts acessam estado global via `GameManager.<variavel>` diretamente — sem dependência circular ou passagem de referência.

---

## Scripts — Referência Completa

### GameManager.gd

**Tipo:** Autoload (Node) — singleton global  
**Arquivo:** `scripts/GameManager.gd`

#### Enums

```gdscript
enum Estado { INICIO, JOGANDO, BOSS, UPGRADE, GAME_OVER }
enum Poder  { ESCUDO=0, ATAQUE_AREA=1, PROJETIL=2, VELOCIDADE=3, CURA_AO_MATAR=4, RICOCHETE=5 }
```

#### Constantes

| Constante | Valor | Descrição |
|---|---|---|
| `VIDA_INICIAL` | `150` | Vida do jogador ao iniciar/resetar |
| `NUM_PODERES` | `6` | Total de poderes no jogo |
| `TOTAL_FASES` | `4` | Fases antes de incrementar loop |
| `CUSTO_BASE_VIDA` | `5` | Materiais para 1º upgrade de vida |
| `CUSTO_BASE_DANO` | `8` | Materiais para 1º upgrade de dano |
| `CUSTO_BASE_RECARGA` | `6` | Materiais para 1º upgrade de recarga |
| `CUSTO_BASE_VELOCIDADE` | `7` | Materiais para 1º upgrade de velocidade |

#### Variáveis de estado

| Variável | Tipo | Descrição |
|---|---|---|
| `estado_atual` | `Estado` | Estado ativo do jogo |
| `vida_atual` | `int` | Vida corrente do jogador |
| `vida_maxima` | `int` | Teto de vida (aumenta com upgrades) |
| `materiais` | `int` | Moeda do jogo (coletada ao matar inimigos) |
| `poderes_ativos` | `Array` | Índices dos poderes obtidos |
| `fase_atual` | `int` | Fase atual (1–4) |
| `num_loops` | `int` | Quantas vezes o ciclo completo foi concluído |
| `nivel_upgrade_*` | `int` | Contador de cada upgrade (0 = não comprado) |

#### Funções públicas

| Função | Descrição |
|---|---|
| `resetar_estado()` | Zera tudo e vai para INICIO |
| `mudar_estado(novo)` | Transição de estado + emite `estado_mudou` |
| `registrar_player(player)` | Conecta sinal `player_morreu` |
| `custo_upgrade(base, nivel)` | Retorna `int(base * 1.5^nivel)` |
| `conceder_poder_aleatorio()` | Escolhe poder não coletado (ou aleatório se todos obtidos) |

#### Fórmula de custo de upgrade

```
custo = custo_base × 1.5^nivel_atual
```

Exemplo para Vida (base=5): nível 0→5 mat, nível 1→7 mat, nível 2→11 mat, nível 3→16 mat...

---

### Player.gd

**Tipo:** `class_name Player extends CharacterBody2D`  
**Arquivo:** `scripts/Player.gd`  
**Grupo:** `"player"`

#### Constantes

| Constante | Valor |
|---|---|
| `VELOCIDADE_BASE` | `150.0` px/s |
| `IMPULSO_DESVIO` | `-400.0` px/s (pulo) |
| `GRAVIDADE` | `980.0` px/s² |

#### Propriedades exportadas

| Propriedade | Padrão | Descrição |
|---|---|---|
| `velocidade` | `150.0` | Velocidade horizontal (modificável por upgrade) |
| `dano_ataque` | `10` | Dano base por golpe (modificável por upgrade) |

#### Controles (Input Map)

| Ação | Efeito |
|---|---|
| `ui_up` | Pulo (apenas no chão) |
| `atacar` | Ativa HitBox por 1 ciclo de timer (botão esquerdo do mouse) |

#### Lógica de movimentação

O Player avança automaticamente em `velocity.x = velocidade`. Se `em_combate = true` (inimigo em range), para no lugar. O poder `VELOCIDADE` aplica multiplicador `×1.5` sobre a velocidade atual.

#### Sistema de ataque

1. Input `atacar` → `_ativar_hitbox()`
2. `_sprite.play("attack")` inicia animação
3. `_hitbox.monitoring = true` detecta colisões
4. `_timer_ataque` dispara → `monitoring = false`, reset de escala
5. Se `RICOCHETE` ativo: escala da HitBox aumentada para `(1.8, 1.8)`
6. Se `ATAQUE_AREA` ativo: aplica dano a todos inimigos em raio de 150px
7. Se `PROJETIL` ativo: instancia `Projetil.tscn` à frente

#### Sistema de escudo (poder ESCUDO)

- `_escudo_carregado = true` ao obter o poder
- Primeiro dano recebido com escudo: negado; inicia timer de 5s para recarga
- Após 5s: escudo recarrega

#### Recebimento de dano

```
receber_dano(valor):
    se ESCUDO carregado → bloqueia; inicia recarga
    senão → GameManager.vida_atual -= valor
             emite vida_atualizada
             se vida <= 0 → animação "morte" → player_morreu
             senão → _flash_hit() (flash vermelho 0.2s)
```

---

### Inimigo.gd

**Tipo:** `class_name Inimigo extends CharacterBody2D`  
**Arquivo:** `scripts/Inimigo.gd`  
**Grupo:** `"inimigos"`

#### Constantes

| Constante | Valor |
|---|---|
| `DANO_BASE` | `7` (escala: `+7 × num_loops` por ataque) |
| `GRAVIDADE` | `980.0` |

#### Propriedades exportadas

| Propriedade | Padrão | Descrição |
|---|---|---|
| `velocidade` | `80.0` | Velocidade de perseguição |
| `vida_base` | `30` | Vida inicial (sobrescrita pelo spawner) |
| `material_drop` | `1` | Materiais ao morrer (multiplicado por `1 + num_loops`) |
| `slot_offset` | `100.0` | Espaçamento para não empilhar inimigos |
| `margem_ataque` | `70.0` | Distância em px para parar e atacar |

#### IA

O inimigo persegue o Player pelo eixo X:
- Fora do range (`dist > margem_ataque`): move em direção ao Player, animação `"move"`
- Dentro do range: para, define `player.em_combate = true`, inicia timer de ataque, animação `"idle"`
- Timer de ataque: `max(0.4, 1.5 - num_loops × 0.25)` segundos — acelerado com loops

#### Separação de corpos

`_separar_de_outros_inimigos()` aplica força de repulsão quando dois inimigos se sobrepõem horizontalmente dentro de 100px e estão fora do range de ataque do Player. Evita empilhamento visual.

#### Morte

```
_morrer():
    para timer de ataque
    instancia EfeitoMorte na posição atual
    emite inimigo_morreu(material_drop)
    call_deferred("queue_free")
```

---

### Boss.gd

**Tipo:** `class_name Boss extends CharacterBody2D`  
**Arquivo:** `scripts/Boss.gd`  
**Grupo:** `"inimigos"`

#### Constantes

| Constante | Valor |
|---|---|
| `VIDA_BASE` | `220` |
| `DANO_CONTATO` | `12` (`+6 × num_loops`) |
| `DANO_AREA` | `18` (`+9 × num_loops`) |
| `MARGEM_ATAQUE` | `200.0` px |

#### Fases do Boss

| Fase | Condição | Velocidade | Timer ataque |
|---|---|---|---|
| Normal | Início | `70.0` px/s | Definido no editor |
| Agressiva | `vida <= 50%` da vida máxima | `140.0` px/s | `1.5s` fixo |

#### Cálculo de vida

```
vida_atual = VIDA_BASE × multiplicador_vida × (1.0 + num_loops × 0.35)
```

`multiplicador_vida` é definido por `Main.gd` com base na fase atual:

| Fase | Multiplicador |
|---|---|
| 1 | `1.0 × (1.0 + num_loops × 0.4)` |
| 2 | `1.3 × ...` |
| 3 | `1.8 × ...` |
| 4 | `2.5 × ...` |

#### Padrão de ataque

No timer (`_on_timer_ataque_timeout`):
1. Se em range: dano de contato no Player
2. Se fase agressiva: dispara `_atacar_area()` — HitBox de área ativa por 0.3s

Ao morrer: emite `boss_derrotado` (sem drop de materiais — recompensa é o poder).

---

### EnemySpawner.gd

**Tipo:** `class_name EnemySpawner extends Node2D`  
**Arquivo:** `scripts/EnemySpawner.gd`

#### Funcionamento

Spawn baseado em posição X do Player, não em timer. A cada frame, verifica se `player.global_position.x >= onda["posicao_x"]` e lança a onda correspondente.

#### Ondas por fase

| Fase | Tema | Ondas | Posições X |
|---|---|---|---|
| 1 | Papel | 4 ondas | 500, 1500, 2500, 3500 |
| 2 | Plástico | 5 ondas | 500, 1500, 2500, 3500, 4500 |
| 3 | Metal | 5 ondas | 500, 1500, 2500, 3500, 4500 |
| 4 | Orgânico | 6 ondas | 500, 1500, 2500, 3500, 4500, 5500 |

A 3ª coluna de ondas de cada fase (e demais) inclui `LixoEspecial` — inimigos com stats superiores.

#### Escalonamento de vida por fase e loop

```
mult_final = MULT_VIDA_POR_FASE[fase-1] × (1.0 + num_loops × 0.55)
```

`MULT_VIDA_POR_FASE = [1.0, 1.2, 1.5, 2.0]`

#### Conclusão de fase

A fase é marcada como completa quando:
1. Todas as ondas foram lançadas (`_ondas_lancadas >= _ondas.size()`)
2. Todos os inimigos daquela fase morreram (`_inimigos_vivos <= 0`)

Emite `fase_completa` → `GameManager._on_fase_completa()` → `mudar_estado(BOSS)`.

---

### Main.gd

**Tipo:** `extends Node2D`  
**Arquivo:** `scripts/Main.gd`  
**Cena:** `scenes/Main.tscn` (cena raiz)

Responsável por orquestrar carregamento e limpeza de fases e Boss. Responde às mudanças de estado do GameManager:

| Estado | Ação |
|---|---|
| `INICIO` | `_limpar_mundo()`: remove fase e Boss; reposiciona Player |
| `JOGANDO` | `_carregar_fase()`: instancia a fase atual; conecta `fase_completa` |
| `BOSS` | `_spawnar_boss()`: instancia Boss com multiplicador de vida calculado |

---

### Projetil.gd

**Tipo:** `extends Area2D`  
**Arquivo:** `scripts/Projetil.gd`  
**Cena:** `scenes/Projetil.tscn`

Move-se horizontalmente a `400.0` px/s. Dano fixo de `10`. Destroi-se ao colidir com `Inimigo`, `Boss` ou `StaticBody2D`, ou após `2.5s`. Instanciado pelo Player quando o poder `PROJETIL` está ativo.

---

### EfeitoMorte.gd

**Tipo:** `extends AnimatedSprite2D`  
**Arquivo:** `scripts/EfeitoMorte.gd`

Toca a animação `"explode"` ao ser adicionado à cena e chama `queue_free()` ao terminar. Instanciado por `Inimigo._morrer()`.

---

### HUD.gd

**Tipo:** `class_name HUD extends CanvasLayer`  
**Arquivo:** `scripts/HUD.gd`  
**Visível em:** `JOGANDO`, `BOSS`, `UPGRADE`

#### Componentes

| Nó | Tipo | Função |
|---|---|---|
| `PainelVida/BarraVida` | `TextureProgressBar` | Barra visual de vida |
| `PainelVida/LabelVida` | `Label` | Texto `"atual/max"` |
| `PainelMateriais/LabelMateriais` | `Label` | Contagem de materiais |
| `PainelPoderes/SlotPoder0..5` | `NinePatchRect` | 6 slots de poder |
| `NotifPoder` | `Label` | Notificação ao receber poder |
| `TimerNotif` | `Timer` | Controla duração da notificação |

#### Abreviações dos poderes (exibidas nos slots)

| Poder | Abreviação |
|---|---|
| Escudo | `ESC` |
| Ataque em Área | `AÁR` |
| Projétil | `PRJ` |
| Velocidade+ | `VEL` |
| Cura ao Matar | `CUR` |
| Ricochete | `RIC` |

---

### TelaInicio.gd / TelaGameOver.gd

Ambas seguem o mesmo padrão:
- Visíveis apenas no estado correspondente (`INICIO` / `GAME_OVER`)
- Conectam `estado_mudou` em `_ready()`
- Botão de ação: "Jogar" muda para `JOGANDO`; "Reiniciar" chama `resetar_estado()` + recarrega `Main.tscn`

---

### TelaUpgrade.gd

**Arquivo:** `scripts/TelaUpgrade.gd`  
**Visível em:** `UPGRADE`

#### Upgrades disponíveis

| Upgrade | Custo base | Efeito por compra |
|---|---|---|
| Vida | 5 mat | `+25 + num_loops×15` vida máxima; restaura vida completa |
| Dano | 8 mat | `+5 + num_loops×3` no `dano_ataque` do Player |
| Recarga | 6 mat | `-0.02 - num_loops×0.01s` no timer de ataque (mín. 0.3s) |
| Velocidade | 7 mat | `+20 + num_loops×10` px/s na velocidade do Player |

O custo aumenta a cada compra: `custo_base × 1.5^nivel`. Botões são desabilitados automaticamente se materiais insuficientes.

---

## Mecânicas

### Movimento automático

```gdscript
# _physics_process():
velocity.x = velocidade  # sempre positivo → sempre avança para a direita
if Poder.VELOCIDADE in poderes_ativos:
    velocity.x *= 1.5
```

O Player só para quando `em_combate = true` (definido pelo Inimigo ao entrar em range).

### Combate

```
Ataque (input "atacar")
    ↓
HitBox.monitoring = true
    ↓
HitBox.area_entered(area)
    ↓
area.get_parent() is Inimigo → inimigo.receber_dano(dano_ataque)
area.get_parent() is Boss    → boss.receber_dano(dano_ataque)
    ↓
_timer_ataque.timeout → HitBox.monitoring = false
```

### Poderes (obtidos ao derrotar Boss)

| Poder | Efeito em jogo |
|---|---|
| **Escudo** | Bloqueia o próximo dano recebido; recarga em 5s |
| **Ataque em Área** | Cada ataque dana todos inimigos em raio de 150px |
| **Projétil** | Cada ataque dispara um projétil horizontal |
| **Velocidade+** | Multiplicador ×1.5 na velocidade de movimento |
| **Cura ao Matar** | Recupera `max(1, 5 - num_loops×2)` de vida ao matar inimigo |
| **Ricochete** | Escala da HitBox ×1.8 durante o ataque |

Poderes são acumulativos e persistem pelo resto da sessão (sem save). Ao completar todos os 6, novos drops são aleatórios entre os já obtidos.

---

## Sistemas de Progressão

### Escalamento de dificuldade (por loop)

| Elemento | Fórmula |
|---|---|
| Vida dos inimigos comuns | `vida_base × mult_fase × (1 + num_loops × 0.55)` |
| Quantidade por onda | `qtd_base + num_loops` |
| Dano do inimigo | `DANO_BASE + num_loops × 7` |
| Timer de ataque do inimigo | `max(0.4, 1.5 - num_loops × 0.25)` |
| Vida do Boss | `VIDA_BASE × mult_fase × (1 + num_loops × 0.35)` |
| Dano de contato do Boss | `12 + num_loops × 6` |
| Dano de área do Boss | `18 + num_loops × 9` |
| Drop de materiais | `material_drop × (1 + num_loops)` |

### Multiplicadores de fase (inimigos)

| Fase | Tema | Mult. vida base |
|---|---|---|
| 1 | Papel | 1.0× |
| 2 | Plástico | 1.2× |
| 3 | Metal | 1.5× |
| 4 | Orgânico | 2.0× |

### Multiplicadores de fase (Boss em Main.gd)

| Fase | Mult. vida Boss |
|---|---|
| 1 | 1.0× |
| 2 | 1.3× |
| 3 | 1.8× |
| 4 | 2.5× |

---

## Interface (HUD e Telas)

### Visibilidade por estado

| Elemento | INICIO | JOGANDO | BOSS | UPGRADE | GAME_OVER |
|---|---|---|---|---|---|
| TelaInicio | ✓ | — | — | — | — |
| HUD | — | ✓ | ✓ | ✓ | — |
| TelaUpgrade | — | — | — | ✓ | — |
| TelaGameOver | — | — | — | — | ✓ |

### Barra de vida

`TextureProgressBar` com `max_value = vida_maxima` e `value = vida_atual`. Atualizada via sinal `vida_atualizada`.

### Slots de poder (HUD)

6 slots fixos (`SlotPoder0` a `SlotPoder5`). Ao receber um poder via sinal `poder_concedido`:
1. Slot correspondente ao índice do poder recebido troca para textura ativa
2. Label interno exibe a abreviação
3. `NotifPoder` exibe o nome completo por alguns segundos (controlado por `TimerNotif`)

---

## Configuração do Projeto

**Arquivo:** `project.godot`

```ini
[application]
config/name="Jogo de Reciclagem"
run/main_scene="uid://main"
config/features=PackedStringArray("4.6", "Forward Plus")

[autoload]
GameManager="*res://scripts/GameManager.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/resizable=false
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[input]
atacar={ "events": [InputEventMouseButton (botão esquerdo)] }

[rendering]
renderer/rendering_method="gl_compatibility"
environment/defaults/default_clear_color=Color(0.05, 0.04, 0.03, 1)
```

**Camadas de física:**
- Layer 1: `mundo`
- Layer 2: `player`
- Layer 3: `inimigos`
- Layer 4: `hitboxes`

---

## Como Executar e Exportar

### Abrir no editor

```bash
godot --path . project.godot
```

### Rodar cena diretamente (testes isolados)

```bash
godot --path . scenes/Main.tscn
```

### Exportar para Web (HTML5) — recomendado para apresentação

```bash
godot --export-release "Web" exports/web/index.html
```

Testar localmente (obrigatório usar servidor HTTP — não abre direto no browser):

```bash
python -m http.server 8080
# abrir http://localhost:8080 no browser
```

### Exportar para Windows

```bash
godot --export-release "Windows Desktop" exports/windows/jogo.exe
```

> Nunca edite arquivos dentro de `exports/` diretamente — são gerados pelo Godot.

---

## Convenções de Código

| Contexto | Convenção | Exemplo |
|---|---|---|
| Variáveis e funções | `snake_case` | `vida_atual`, `receber_dano()` |
| Classes e cenas | `PascalCase` | `Player`, `Inimigo` |
| Constantes | `UPPER_CASE` | `VELOCIDADE_BASE = 150.0` |
| Funções privadas | prefixo `_` | `_calcular_dano()` |
| Tipagem | estática sempre que possível | `var vida: int = 100` |
| Nomes temáticos | reciclagem nos nomes | `material_reciclavel`, `lixo_organico` |

### Armadilhas conhecidas

| Situação | Solução |
|---|---|
| `queue_free()` durante colisão | Usar `call_deferred("queue_free")` |
| Câmera travando | Confirmar `Camera2D.limit_*` definidos |
| Spawn fora da tela | SpawnPoints devem ficar à direita do viewport |
| HitBox ativada permanentemente | Desativar `monitoring` após ataque via Timer |
| Sinal conectado duas vezes | Conectar apenas em `_ready()`, nunca em `_process()` |
