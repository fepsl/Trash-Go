# CLAUDE.md — Jogo de Reciclagem (Godot 2D)

## Visão geral do projeto

Side-scroller 2D educativo sobre reciclagem, desenvolvido em Godot 4.
O personagem anda automaticamente e o jogador controla ações de combate.
**Sem save de progresso** — todo estado vive em memória durante a sessão.
Projeto acadêmico: priorizar código legível e funcional acima de otimizações.

---

## Comandos essenciais

```bash
# Abrir o projeto
godot --path . project.godot

# Exportar para Web (HTML5) — rode no editor ou via CLI
godot --export-release "Web" exports/web/index.html

# Exportar para Windows
godot --export-release "Windows Desktop" exports/windows/jogo.exe

# Rodar cena diretamente (útil para testes isolados)
godot --path . scenes/Main.tscn
```

---

## Estrutura de pastas

```
res://
├── scenes/
│   ├── Main.tscn           # Cena raiz — carrega tudo
│   ├── Player.tscn
│   ├── Projetil.tscn
│   ├── enemies/
│   │   ├── Lixo.tscn       # Inimigo base
│   │   ├── LixoEspecial.tscn
│   │   └── Boss.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   ├── TelaInicio.tscn
│   │   ├── TelaGameOver.tscn
│   │   ├── TelaUpgrade.tscn
│   │   └── TelaVitoria.tscn
│   └── world/
│       ├── Fase1.tscn
│       ├── Fase2.tscn
│       ├── Fase3.tscn
│       └── Fase4.tscn
├── scripts/
│   ├── GameManager.gd
│   ├── Main.gd
│   ├── Player.gd
│   ├── Inimigo.gd
│   ├── Boss.gd
│   ├── EnemySpawner.gd
│   ├── Projetil.gd
│   ├── HUD.gd
│   ├── TelaInicio.gd
│   ├── TelaGameOver.gd
│   └── TelaUpgrade.gd
├── assets/
│   ├── sprites/
│   │   ├── Individual Sprites Male/   # Spritesheet do personagem (128x128 por frame)
│   │   └── Individual Sprites Slime/  # Sprites individuais do inimigo slime (32x25 por frame)
│   ├── backgrounds/                   # Imagens de fundo de cada fase
│   ├── effects/                       # Partículas e efeitos visuais
│   ├── sounds/
│   └── fonts/
└── exports/
    ├── web/
    └── windows/
```

**Nunca edite** arquivos dentro de `exports/` diretamente — são gerados pelo Godot.

---

## Arquitetura e padrões

### Estados do jogo (GameManager.gd)

```gdscript
enum Estado { INICIO, JOGANDO, GAME_OVER, VITORIA }
```

O `GameManager` é um autoload (singleton). Toda mudança de estado passa por ele.
Não acesse estados do jogo diretamente de outros scripts — use sinais.

### Sinais importantes

| Sinal | Emitido por | Recebido por |
|---|---|---|
| `player_morreu` | Player.gd | GameManager.gd |
| `inimigo_morreu(material)` | Inimigo.gd | GameManager.gd |
| `material_coletado(qtd)` | GameManager.gd | HUD.gd |
| `vida_atualizada(atual, max)` | GameManager.gd | HUD.gd |
| `fase_completa` | EnemySpawner.gd | GameManager.gd |

### Sem persistência

Não use `FileAccess`, `ResourceSaver`, ou qualquer escrita em disco.
Todo progresso (vida, materiais, upgrades) fica em variáveis do GameManager.
Ao reiniciar a fase, o GameManager reseta as variáveis — sem carregar arquivo algum.

---

## Convenções de código (GDScript)

- **snake_case** para variáveis e funções: `vida_atual`, `receber_dano()`
- **PascalCase** para classes e nomes de cena: `Player`, `Inimigo`
- **UPPER_CASE** para constantes: `VELOCIDADE_BASE = 150.0`
- Tipagem estática sempre que possível: `var vida: int = 100`
- Funções públicas antes de privadas no arquivo
- Funções privadas com prefixo `_`: `_calcular_dano()`
- Um `class_name` por script quando o script for reutilizado como tipo

### Exemplo de estrutura de script

```gdscript
class_name Inimigo
extends CharacterBody2D

const VIDA_BASE: int = 30

@export var velocidade: float = 80.0
var vida_atual: int

signal inimigo_morreu(material_drop: int)

func _ready() -> void:
    vida_atual = VIDA_BASE

func receber_dano(valor: int) -> void:
    vida_atual -= valor
    if vida_atual <= 0:
        _morrer()

func _morrer() -> void:
    inimigo_morreu.emit(1)
    queue_free()
```

---

## Mecânicas principais

### Movimento do personagem
- Automático: `velocity.x = VELOCIDADE_BASE` sempre no `_physics_process()`
- Jogador controla apenas: ataque (`ui_accept`), habilidade (`ui_select`), desvio (`ui_up`)
- Câmera segue o Player com `Camera2D` — não mova a câmera manualmente

### Sistema de combate
- Ataque ativa `HitBox` (Area2D filho do Player) por 3–5 frames via `Timer`
- `HitBox` detecta `HurtBox` dos inimigos via `area_entered`
- Dano padrão do jogador: variável, modificável por upgrade
- Inimigos causam dano ao tocar o `HurtBox` do Player

### Spawn de inimigos
- `EnemySpawner` verifica a posição X da câmera
- Instancia inimigos quando câmera passa por pontos marcados no mundo
- Não use timers globais para spawn — use posições no cenário

### Upgrades (sem save)
- Aparecem na `TelaUpgrade` entre fases
- Custo em materiais recicláveis (coletados na fase anterior)
- Modificam diretamente variáveis do Player via GameManager
- Lista de upgrades disponíveis: mais vida, mais dano, recarga de habilidade, velocidade

---

## Armadilhas conhecidas

- **`queue_free()` durante colisão**: sempre defira com `call_deferred("queue_free")`
- **Câmera travando**: confirme que os limites (`Camera2D.limit_*`) estão definidos
- **Spawn fora da tela**: SpawnPoints devem ficar à direita do viewport, não no centro
- **HitBox ativada permanentemente**: sempre desative `monitoring` após o ataque via Timer
- **Sinal conectado duas vezes**: verifique se `connect()` não está em `_process()` — conecte só em `_ready()`

---

## Exportação para apresentação

O destino preferido é **Web (HTML5)** — roda no browser sem instalar nada.

1. Em Godot: `Project → Export → Add → Web`
2. Marque "Export PCK/Zip" se quiser distribuir separado
3. Para testar localmente: use um servidor HTTP (ex: `python -m http.server 8080` na pasta `exports/web/`)
4. Não abra o `index.html` direto no browser — precisa de servidor HTTP

---

## Contexto acadêmico

- Código deve ser legível para apresentação e defesa
- Prefira clareza a performance: loops simples > otimizações prematuras
- Comente decisões de design não óbvias, não código óbvio
- O tema de reciclagem deve aparecer nos nomes de variáveis e cenas quando fizer sentido (ex: `material_reciclavel`, `lixo_organico`)
