# PRD: Configuração do Fluxo Completo — Menu → Fase 1

**Status**: Rascunho  
**Data**: 2026-05-18  
**Autor**: Desenvolvedor

---

## 1. Contexto e Problema

O projeto "Jogo de Reciclagem" é um side-scroller 2D educativo desenvolvido em Godot 4.
Os arquivos de cena e scripts existem no repositório, mas o projeto ainda não está configurado
para rodar de ponta a ponta quando aberto no Godot — o editor exibe `[vazio]` e não há
uma cena principal sendo carregada automaticamente.

O objetivo desta fase é estabelecer o fluxo mínimo jogável:
**Menu de início → Fase 1 (floresta) com player e inimigos funcionando**.

---

## 2. Objetivos

- **Objetivo principal**: Abrir o projeto no Godot, apertar F5 e o jogo rodar sem erros —
  exibindo o menu, iniciando a Fase 1 ao clicar "Jogar", com o player se movendo
  automaticamente e inimigos sendo spawnados.
- **Métricas de sucesso**:
  - F5 roda sem erros no Output
  - Menu aparece na tela
  - Botão "Jogar" transiciona para a Fase 1
  - Background floresta com parallax aparece corretamente
  - Player se move da esquerda para direita automaticamente
  - Inimigos (slimes) aparecem nas posições corretas de acordo com as ondas
  - Player pode atacar e matar inimigos
  - HUD exibe vida e materiais coletados
  - Ao morrer, tela de Game Over aparece
- **Fora de escopo**:
  - Fases 2, 3 e 4 (serão tratadas em PRDs futuros)
  - Boss da Fase 1
  - Tela de Upgrade entre fases
  - Tela de Vitória
  - Exportação para Web/Windows

---

## 3. Usuários e Personas

| Persona | Necessidade | Como essa feature ajuda |
|---------|-------------|------------------------|
| Jogador (aluno) | Iniciar o jogo e jogar a Fase 1 sem instruções extras | Menu claro com botão "Jogar" e fase carregando automaticamente |
| Desenvolvedor (apresentação) | Demonstrar o jogo funcionando ao abrir o Godot | F5 roda direto, sem precisar abrir cenas manualmente |
| Professor avaliador | Ver o jogo rodando na apresentação | Fluxo estável, sem crashes nem erros visíveis |

---

## 4. Requisitos Funcionais

### RF-01: Projeto abre corretamente no Godot
**Como** desenvolvedor, **quero** dar duplo clique no `project.godot` e o Godot abrir o projeto,
**para que** eu não precise configurar nada manualmente toda vez.

**Critérios de aceite:**
- [ ] `project.godot` tem `config/main_scene = "res://scenes/Main.tscn"` definido
- [ ] `GameManager` está registrado como autoload em `project.godot`
- [ ] Ao abrir o projeto, o Godot não exibe erros de recursos faltando

---

### RF-02: Tela de Menu (TelaInicio)
**Como** jogador, **quero** ver uma tela de início ao abrir o jogo,
**para que** eu saiba que o jogo carregou e possa escolher quando começar.

**Critérios de aceite:**
- [ ] `TelaInicio.tscn` é exibida automaticamente quando o estado do GameManager é `INICIO`
- [ ] O botão "Jogar" está visível e clicável
- [ ] Ao clicar "Jogar", o estado muda para `JOGANDO` e a tela some
- [ ] O título "Jogo de Reciclagem" aparece na tela

---

### RF-03: Carregamento da Fase 1
**Como** jogador, **quero** que a Fase 1 carregue ao clicar "Jogar",
**para que** eu possa começar a jogar imediatamente.

**Critérios de aceite:**
- [ ] `Main.gd` instancia `Fase1.tscn` quando o estado muda para `JOGANDO`
- [ ] `Fase1.tscn` é adicionada como filho de `Main` na posição 0 (atrás do player)
- [ ] O background floresta com parallax aparece na tela
- [ ] O chão (`StaticBody2D`) está posicionado corretamente para o player pousar

---

### RF-04: Player se move automaticamente
**Como** jogador, **quero** que o personagem se mova para a direita automaticamente,
**para que** eu possa focar nas ações de combate.

**Critérios de aceite:**
- [ ] `velocity.x = velocidade` aplicado em todo `_physics_process` quando estado é `JOGANDO`
- [ ] Player não atravessa o chão (gravidade e colisão funcionando)
- [ ] Player pode pular com `ui_up`
- [ ] `Camera2D` segue o player com limites corretos (`limit_right = 10000`)
- [ ] Animação `run` toca enquanto o player está em movimento

---

### RF-05: Sistema de combate básico
**Como** jogador, **quero** poder atacar os inimigos com `ui_accept`,
**para que** eu possa limpar as ondas e progredir na fase.

**Critérios de aceite:**
- [ ] Pressionar `ui_accept` ativa a `HitBox` do player por ~0.08s via `TimerAtaque`
- [ ] Inimigos (slimes) recebem dano ao contato com a `HitBox`
- [ ] Inimigos morrem quando `vida_atual <= 0` e são removidos da cena
- [ ] Ao matar um inimigo, `material_coletado` é emitido e o HUD atualiza

---

### RF-06: Spawn de inimigos por ondas
**Como** jogador, **quero** que inimigos apareçam enquanto avanço na fase,
**para que** o jogo seja desafiador e progressivo.

**Critérios de aceite:**
- [ ] `EnemySpawner` monitora a posição X do player
- [ ] Onda 1 (3 slimes) spawna quando player chega em X=400
- [ ] Onda 2 (4 slimes) spawna quando player chega em X=800
- [ ] Onda 3 (2 LixoEspecial) spawna quando player chega em X=1200
- [ ] Onda 4 (5 slimes) spawna quando player chega em X=1600
- [ ] Inimigos spawnados à direita da câmera, nunca em cima do player

---

### RF-07: HUD funcional
**Como** jogador, **quero** ver minha vida e materiais coletados na tela,
**para que** eu saiba meu estado durante o jogo.

**Critérios de aceite:**
- [ ] `BarraVida` atualiza ao receber sinal `vida_atualizada`
- [ ] `LabelMateriais` atualiza ao receber sinal `material_coletado`
- [ ] HUD visível durante estado `JOGANDO`, oculto no estado `INICIO`

---

### RF-08: Tela de Game Over
**Como** jogador, **quero** ver uma tela de Game Over ao morrer,
**para que** eu saiba que a partida terminou e possa reiniciar.

**Critérios de aceite:**
- [ ] Quando `vida_atual <= 0`, `player_morreu` é emitido
- [ ] GameManager muda estado para `GAME_OVER`
- [ ] `TelaGameOver.tscn` aparece automaticamente
- [ ] Existe opção para reiniciar (volta ao estado `INICIO` ou recarrega a cena)

---

## 5. Requisitos Não-Funcionais

| Categoria     | Requisito                                                        |
|---------------|------------------------------------------------------------------|
| Performance   | Jogo roda a 60 FPS estável com até 15 inimigos simultâneos       |
| Estabilidade  | Nenhum crash durante o fluxo menu → fase 1 → game over → menu   |
| Legibilidade  | Código segue convenções do CLAUDE.md (snake_case, tipagem estática) |
| Compatibilidade | Roda no Godot 4.x em modo Compatibilidade (GL Compatibility)   |

---

## 6. Design Técnico (alto nível)

### Fluxo de estados (GameManager)

```
INICIO → (botão "Jogar") → JOGANDO → (player morre) → GAME_OVER → (reiniciar) → INICIO
                                    → (fase completa) → BOSS → (boss derrotado) → UPGRADE
```

### Cenas envolvidas

| Cena | Papel |
|------|-------|
| `Main.tscn` | Raiz — contém Player, HUD, todas as telas de UI |
| `Fase1.tscn` | Carregada dinamicamente — background, chão, EnemySpawner |
| `Player.tscn` | CharacterBody2D com animações, HitBox, HurtBox, Camera2D |
| `Lixo.tscn` | Inimigo básico — CharacterBody2D com HurtBox |
| `TelaInicio.tscn` | CanvasLayer com botão "Jogar" |
| `TelaGameOver.tscn` | CanvasLayer exibido ao morrer |
| `HUD.tscn` | CanvasLayer com barra de vida e contador de materiais |

### Scripts e responsabilidades

| Script | Responsabilidade |
|--------|-----------------|
| `GameManager.gd` | Autoload — estado global, vida, materiais, sinais |
| `Main.gd` | Instancia e destrói fases dinamicamente |
| `Player.gd` | Movimento, ataque, receber dano, animações |
| `Inimigo.gd` | IA simples, receber dano, emitir drop ao morrer |
| `EnemySpawner.gd` | Monitora posição do player, lança ondas de inimigos |
| `HUD.gd` | Escuta sinais do GameManager, atualiza UI |
| `TelaInicio.gd` | Exibe/oculta baseado no estado; botão chama GameManager |
| `TelaGameOver.gd` | Exibe/oculta baseado no estado; botão reinicia |

### Mudanças no banco de dados
Não aplicável — sem persistência por definição do projeto.

### Impacto em outros módulos
- Fases 2, 3 e 4 seguirão a mesma estrutura de `Fase1.tscn` (backgrounds diferentes)
- O sistema de Boss usa o mesmo `Main.gd` com `_spawnar_boss()`
- A `TelaUpgrade.tscn` já está em `Main.tscn` mas será ativada em PRD futuro

---

## 7. Riscos e Dependências

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| `HurtBox` do player configurada como Area2D mas recebendo `body_entered` — pode não detectar inimigos que são CharacterBody2D | Média | Alto | Verificar se `monitoring = true` e se os collision layers batem entre player e inimigos |
| Assets de sprite com caminho errado (case-sensitive no Linux/Web) | Média | Médio | Confirmar nomes de arquivo no Windows vs. o que está nas cenas |
| `queue_free()` durante colisão causando crash | Média | Alto | Usar `call_deferred("queue_free")` em `Inimigo.gd._morrer()` |
| `EnemySpawner` não encontra o player no grupo `"player"` | Baixa | Alto | Confirmar que `Player.gd._ready()` chama `add_to_group("player")` antes do spawner |
| Limite da câmera (`limit_right = 10000`) menor que o chão (`size = 20000`) | Baixa | Médio | Alinhar os valores entre `Player.tscn` e `Fase1.tscn` |

---

## 8. Plano de Testes

- [ ] **Teste manual — fluxo completo**: Abrir projeto → F5 → menu aparece → clicar "Jogar" → Fase 1 carrega com background floresta → player corre → inimigos spawnando → atacar e matar inimigos → HUD atualiza → player morre → Game Over aparece
- [ ] **Teste de colisão**: Player não atravessa o chão; inimigos causam dano ao contato
- [ ] **Teste de spawn**: Cada onda spawna na posição X correta e na quantidade certa
- [ ] **Teste de câmera**: Câmera segue o player sem ultrapassar os limites definidos
- [ ] **Teste de reinício**: Após Game Over, reiniciar reseta vida, materiais e posição do player

---

## 9. Critérios de Done (DoD)

- [ ] F5 roda sem nenhum erro vermelho no Output do Godot
- [ ] Fluxo menu → Fase 1 → Game Over → reinício funciona sem crash
- [ ] Background floresta com parallax visível e rolando
- [ ] Player, combate e spawn de inimigos funcionando conforme RF-04 a RF-06
- [ ] HUD exibe informações corretas em tempo real
- [ ] Código segue convenções do CLAUDE.md (snake_case, tipagem, sem FileAccess)
