# PRD: Jogo de Reciclagem — Side-Scroller Educativo

**Status**: Rascunho  
**Data**: 2026-05-12  
**Autor**: Desenvolvedor  

---

## 1. Contexto e Problema

Projeto acadêmico com tema obrigatório de reciclagem. O objetivo é criar um jogo 2D educativo e jogável que reforce o tema de reciclagem de forma lúdica, com entrega até o final de julho de 2026. O jogo precisa ser executável no browser (Web/HTML5) sem instalação, para facilitar a apresentação acadêmica.

---

## 2. Objetivos

- **Objetivo principal**: Entregar um jogo side-scroller funcional e completo com tema de reciclagem até 31/07/2026
- **Métricas de sucesso**:
  - Loop completo jogável (horda → boss → upgrade → nova área) sem crashes
  - Exportação Web funcionando no browser
  - 4 áreas temáticas visualmente distintas
  - 6 poderes especiais implementados
- **Fora de escopo**:
  - Save de progresso entre sessões
  - Multiplayer
  - Loja externa ou monetização
  - Mobile/touch controls
  - Mais de 1 personagem jogável

---

## 3. Usuários e Personas

| Persona | Necessidade | Como o jogo atende |
|---------|-------------|-------------------|
| Jogador casual (avaliador acadêmico) | Entender o tema de reciclagem de forma divertida | Nomes, cenários e inimigos com identidade visual de resíduos recicláveis |
| Desenvolvedor (você) | Código legível para defesa oral | Arquitetura modular com sinais, GameManager central, sem gambiarras |

---

## 4. Requisitos Funcionais

### RF-01: Movimento automático do personagem
**Como** jogador, **quero** que o personagem ande automaticamente, **para que** eu foque nas decisões de combate e não na navegação.

**Critérios de aceite:**
- [ ] `velocity.x` sempre positivo no `_physics_process()`
- [ ] Câmera segue o Player via `Camera2D` sem intervenção manual
- [ ] Jogador controla apenas: ataque (`ui_accept`), habilidade (`ui_select`), desvio (`ui_up`)

---

### RF-02: Sistema de combate (HitBox / HurtBox)
**Como** jogador, **quero** atacar inimigos e receber dano ao tocá-los, **para que** haja tensão e estratégia no combate.

**Critérios de aceite:**
- [ ] Ataque ativa `HitBox` (Area2D) por 3–5 frames via Timer
- [ ] `HitBox` desativada automaticamente após o Timer — nunca permanentemente ativa
- [ ] Inimigos causam dano ao tocar o `HurtBox` do Player
- [ ] Player tem vida representada na HUD

---

### RF-03: Inimigos — Normal, Elite e Boss
**Como** jogador, **quero** enfrentar inimigos de diferentes níveis de dificuldade, **para que** o jogo tenha progressão de desafio.

**Critérios de aceite:**
- [ ] Inimigo normal: vida baixa, drop de material reciclável ao morrer
- [ ] Inimigo elite: mais vida que o normal, mesmo comportamento base
- [ ] Boss único: padrões de ataque definidos, aparece ao final de cada área
- [ ] Boss emite sinal ao morrer para acionar drop de poder especial

---

### RF-04: Loop de horda por área
**Como** jogador, **quero** enfrentar ondas de inimigos antes de chegar ao boss, **para que** a progressão seja gradual e tensa.

**Critérios de aceite:**
- [ ] `EnemySpawner` instancia inimigos por posição X no cenário (não por timer global)
- [ ] Horda completa (todos inimigos mortos) libera transição para o boss
- [ ] Após derrotar o boss, jogador avança para a próxima área
- [ ] Ciclo: Área 1 → Boss → Área 2 → Boss → Área 3 → Boss → Área 4 → Boss → repete

---

### RF-05: Poderes especiais (drop do boss)
**Como** jogador, **quero** ganhar um poder especial ao derrotar cada boss, **para que** meu personagem fique progressivamente mais forte.

**Critérios de aceite:**
- [ ] 6 poderes especiais implementados, cada um com mecânica distinta
- [ ] Ao derrotar um boss, 1 poder aleatório dos 6 é concedido ao jogador
- [ ] Jogador não pode escolher o poder — é sempre aleatório
- [ ] Poder ativo é exibido na HUD
- [ ] Poderes são mais fortes que os upgrades compráveis

---

### RF-06: Sistema de upgrades compráveis
**Como** jogador, **quero** gastar materiais recicláveis para melhorar meu personagem entre fases, **para que** eu tenha agência sobre meu build.

**Critérios de aceite:**
- [ ] `TelaUpgrade` exibe upgrades disponíveis após cada boss
- [ ] Upgrades possíveis: mais vida, mais dano, recarga de habilidade, velocidade
- [ ] Custo em materiais recicláveis coletados na fase
- [ ] GameManager aplica os upgrades diretamente nas variáveis do Player
- [ ] Upgrades sempre disponíveis para compra (não são consumidos do catálogo)

---

### RF-07: 4 áreas temáticas de reciclagem
**Como** jogador, **quero** percorrer áreas visualmente distintas com identidade de resíduos recicláveis, **para que** o tema educativo seja reforçado.

**Critérios de aceite:**
- [ ] 4 áreas com backgrounds/tilesets distintos (ex: papel, plástico, metal, orgânico)
- [ ] Inimigos de cada área têm identidade visual relacionada ao tipo de resíduo
- [ ] Nomes de variáveis e cenas refletem o tema (ex: `lixo_organico`, `material_reciclavel`)

---

### RF-08: HUD e telas de fluxo
**Como** jogador, **quero** ver minha vida, materiais e poder ativo na tela, **para que** eu tome decisões informadas.

**Critérios de aceite:**
- [ ] HUD exibe: vida atual/máxima, materiais coletados, poder especial ativo
- [ ] Tela de Início funcional
- [ ] Tela de Game Over com opção de reiniciar (sem save — estado reseta)
- [ ] Tela de Upgrade entre fases
- [ ] Ao reiniciar, GameManager reseta todas as variáveis sem carregar arquivo

---

## 5. Requisitos Não-Funcionais

| Categoria | Requisito |
|-----------|-----------|
| Performance | 60 FPS estável no browser (HTML5 export) |
| Portabilidade | Roda em browser moderno sem plugins — exportação Web/HTML5 |
| Legibilidade | Código em GDScript com snake_case, tipagem estática, sem otimizações prematuras |
| Persistência | **Zero** — nenhum `FileAccess`, `ResourceSaver` ou escrita em disco |
| Segurança | N/A — jogo offline, sem rede, sem autenticação |
| Manutenibilidade | Um script por cena, sinais para comunicação entre módulos, GameManager como único singleton |

---

## 6. Design Técnico (alto nível)

### Arquitetura de cenas

```
Main.tscn
├── GameManager (Autoload/Singleton)
├── Fase1.tscn (world)
│   └── EnemySpawner
├── Player.tscn
│   ├── HitBox (Area2D)
│   └── HurtBox (Area2D)
├── enemies/
│   ├── Lixo.tscn        # inimigo normal
│   ├── LixoEspecial.tscn # inimigo elite
│   └── Boss.tscn
└── ui/
    ├── HUD.tscn
    ├── TelaInicio.tscn
    ├── TelaGameOver.tscn
    ├── TelaUpgrade.tscn
    └── TelaVitoria.tscn
```

### Sinais principais

| Sinal | De | Para |
|-------|----|------|
| `player_morreu` | Player.gd | GameManager.gd |
| `inimigo_morreu(material)` | Inimigo.gd | GameManager.gd |
| `boss_derrotado` | Boss.gd | GameManager.gd |
| `material_coletado(qtd)` | GameManager.gd | HUD.gd |
| `vida_atualizada(atual, max)` | GameManager.gd | HUD.gd |
| `poder_concedido(poder)` | GameManager.gd | HUD.gd |
| `fase_completa` | EnemySpawner.gd | GameManager.gd |

### Estados do GameManager

```gdscript
enum Estado { INICIO, JOGANDO, BOSS, UPGRADE, GAME_OVER }
```

### Sem banco de dados / migrations
Projeto local em Godot — não há banco de dados, endpoints HTTP ou migrations. Todo estado é em memória (variáveis do GameManager).

### Impacto entre módulos
- Upgrades modificam variáveis diretamente no Player via GameManager — cuidado com ordem de inicialização no `_ready()`
- `queue_free()` em inimigos durante colisão deve usar `call_deferred("queue_free")` para evitar crash

---

## 7. Riscos e Dependências

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Arte indefinida (IA vs. Aseprite) atrasa o projeto | Alta | Alto | Decidir na semana 1 e não mudar; preferir assets simples de IA para não bloquear código |
| 6 poderes especiais únicos consomem mais tempo que o estimado | Média | Alto | Implementar 2-3 poderes primeiro; garantir que o sistema funciona antes de escalar para 6 |
| 4 áreas visuais distintas demandam muito de arte | Alta | Médio | Usar variações de paleta de cores sobre o mesmo tileset base ao invés de assets totalmente novos |
| Bug de `queue_free()` durante colisão causa crash | Média | Alto | Usar `call_deferred` em todos os `queue_free()` de inimigos — sem exceção |
| Exportação Web falhar perto da entrega | Baixa | Alto | Testar exportação ao fim da semana 3, não deixar para o final |

---

## 8. Plano de Testes

- [ ] **Teste manual — combate**: atacar inimigo, receber dano, morrer, reiniciar
- [ ] **Teste manual — loop completo**: percorrer área 1 → boss → upgrade → área 2 sem crash
- [ ] **Teste manual — poderes**: derrotar 4 bosses, verificar que poderes aleatórios são concedidos
- [ ] **Teste manual — upgrades**: gastar materiais, verificar que stats do Player mudam
- [ ] **Teste manual — Game Over**: morrer e reiniciar, verificar que estado reseta completamente
- [ ] **Teste de exportação Web**: abrir `index.html` via servidor HTTP local e jogar no browser
- [ ] **Teste de performance**: verificar 60 FPS no browser com horda completa na tela

> Godot 4 não tem framework de testes unitários integrado robusto — todos os testes são manuais ou via GUT (Godot Unit Testing), que é opcional neste projeto acadêmico.

---

## 9. Critérios de Done (DoD)

- [ ] Loop completo jogável: Início → 4 áreas com bosses → Game Over → Reinício
- [ ] 6 poderes especiais implementados e funcionando
- [ ] Sistema de upgrades compráveis funcionando
- [ ] HUD exibindo vida, materiais e poder ativo
- [ ] Todas as telas implementadas (Início, Game Over, Upgrade)
- [ ] 4 áreas com identidade visual distinta e tema de reciclagem
- [ ] Exportação Web testada e funcionando no browser
- [ ] Nenhum `FileAccess` ou escrita em disco no código
- [ ] Código revisado para apresentação oral: nomes legíveis, sem código morto
