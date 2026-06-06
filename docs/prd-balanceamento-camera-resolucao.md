# PRD: Balanceamento de Gameplay, Câmera e Resolução

**Status**: Rascunho  
**Data**: 2026-06-05  
**Autor**: Felipe

---

## 1. Contexto e Problema

O jogo apresenta uma curva de dificuldade quebrada: o início é desafiador, mas após o jogador adquirir upgrades o desafio desaparece e o combate perde o dinamismo. Os upgrades têm custo fixo, o que permite acúmulo de recursos sem pressão crescente.

Além disso, a câmera está muito afastada — o personagem ocupa menos de 5% da tela — tornando o combate visualmente desengajante. A resolução atual (1920x750) também não preenche telas padrão, gerando barras pretas na interface.

---

## 2. Objetivos

- **Objetivo principal**: Tornar o jogo mais dinâmico e manter o desafio ao longo de todas as fases, mesmo após upgrades
- **Métricas de sucesso**:
  - O jogador não consegue eliminar inimigos sem sofrer dano em fases avançadas sem upgrades
  - O custo acumulado de upgrades exige escolhas estratégicas entre fases
  - Personagem e inimigos ocupam visualmente uma porção significativa da tela durante o combate
  - O jogo preenche a tela sem barras pretas em monitores 16:9
- **Fora de escopo**:
  - Novos tipos de inimigos ou novas mecânicas de combate
  - Retrabalho dos assets de background ou sprites
  - Sistema de save/persistência

---

## 3. Usuários e Personas

| Persona | Necessidade | Como essa feature ajuda |
|---------|------------|------------------------|
| Jogador casual | Sentir progressão real e desafio constante | Inimigos mais fortes por fase + upgrades caros exigem estratégia |
| Jogador que quer platinar | Ter motivo para usar todos os upgrades disponíveis | Custo exponencial torna cada upgrade uma decisão importante |
| Avaliador acadêmico | Ver um jogo equilibrado e com boa apresentação visual | Câmera próxima e tela cheia tornam a experiência mais polida |

---

## 4. Requisitos Funcionais

### RF-01: Escalada de HP e quantidade de inimigos por fase
**Como** jogador, **quero** encontrar inimigos progressivamente mais resistentes e numerosos, **para que** o desafio aumente junto com meu poder.

**Critérios de aceite:**
- [ ] Cada fase subsequente tem ao menos 25% mais inimigos que a anterior
- [ ] O HP dos inimigos escala por fase (ex: Fase 1 = base, Fase 2 = 1.5x, Fase 3 = 2.5x, Fase 4 = 4x)
- [ ] O Boss de cada fase também tem HP escalado proporcionalmente

---

### RF-02: Custo exponencial de upgrades
**Como** jogador, **quero** que os upgrades fiquem progressivamente mais caros, **para que** minha escolha de quais upgrades priorizar seja estratégica.

**Critérios de aceite:**
- [ ] Custo de cada nível de upgrade segue a fórmula: `custo(n) = custo_base * multiplicador ^ (n - 1)`
- [ ] Multiplicador sugerido: 2.0 (dobra a cada nível)
- [ ] O custo é exibido corretamente na TelaUpgrade para todos os níveis
- [ ] Upgrades de nível mais alto (3+) custam visivelmente mais materiais do que o jogador coletou na fase

---

### RF-03: Zoom de câmera aproximado
**Como** jogador, **quero** ver o personagem e os inimigos maiores na tela, **para que** o combate seja visualmente dinâmico e legível.

**Critérios de aceite:**
- [ ] O personagem ocupa aproximadamente 8–12% da altura da tela
- [ ] É possível ver ao menos 2–3 inimigos na tela simultaneamente durante o combate
- [ ] A HUD (vida, materiais, fase) permanece completamente visível após o zoom
- [ ] Os spawn points de inimigos continuam fora do viewport (inimigos não aparecem "do nada" na tela)

---

### RF-04: Resolução responsiva sem barras pretas
**Como** jogador, **quero** que o jogo preencha minha tela inteira, **para que** a experiência visual seja imersiva.

**Critérios de aceite:**
- [ ] O jogo preenche telas 16:9 sem barras pretas horizontais ou verticais
- [ ] O background continua cobrindo toda a área visível em todas as resoluções testadas
- [ ] Funciona corretamente tanto no editor (1920px largura) quanto exportado para Web

---

## 5. Requisitos Não-Funcionais

| Categoria | Requisito |
|-----------|-----------|
| Performance | Aumento de inimigos não deve causar queda de FPS abaixo de 30fps em hardware básico |
| Compatibilidade | Resolução deve funcionar em telas 16:9 (1920x1080, 1366x768, 1280x720) |
| Legibilidade | Após zoom, nenhum elemento de UI deve ficar fora da tela ou sobreposto |
| Manutenção | Valores de balanceamento devem estar em constantes nomeadas, não em magic numbers |

---

## 6. Design Técnico (alto nível)

### Arquivos afetados

| Arquivo | Mudança |
|---------|---------|
| `scripts/Inimigo.gd` | Aumentar `VIDA_BASE`; aceitar modificador de fase |
| `scripts/EnemySpawner.gd` | Aumentar quantidade de inimigos por fase; aplicar multiplicador de HP via fase |
| `scripts/TelaUpgrade.gd` | Implementar fórmula exponencial de custo |
| `scripts/GameManager.gd` | Passar `numero_fase` ao spawner; armazenar nível atual de cada upgrade |
| `scenes/Player.tscn` | Ajustar `Camera2D.zoom` (ex: Vector2(2.0, 2.0)) |
| `project.godot` | Alterar `display/window/stretch/mode` e `aspect` |

### Fórmula de custo de upgrades

```gdscript
const MULTIPLICADOR_CUSTO: float = 2.0

func calcular_custo(custo_base: int, nivel_atual: int) -> int:
    return int(custo_base * pow(MULTIPLICADOR_CUSTO, nivel_atual))
```

### Configuração de resolução (Project Settings)

```
display/window/size/viewport_width = 1920
display/window/size/viewport_height = 750
display/window/stretch/mode = canvas_items
display/window/stretch/aspect = expand
```

### Impacto em outros módulos

- **HUD.tscn**: Verificar ancoragem (`anchor_right = 1`, `anchor_bottom = 1`) para que se adapte ao zoom e ao stretch
- **TelaGameOver / TelaVitoria / TelaUpgrade**: Confirmar que telas de UI usam `CanvasLayer` para não serem afetadas pelo zoom da câmera
- **SpawnPoints no cenário**: Após zoom, verificar se os pontos de spawn ainda estão fora do viewport

---

## 7. Riscos e Dependências

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Zoom corta a HUD ou elementos de UI | Alta | Alto | Confirmar que HUD está em CanvasLayer; testar zoom antes de ajustar balanceamento |
| Exponencial muito agressiva torna upgrades inacessíveis | Média | Alto | Começar com multiplicador 2.0 e ajustar via playtest |
| Mais inimigos quebra posicionamento dos spawn points | Média | Médio | Auditar EnemySpawner antes de aumentar quantidade |
| Background não cobre tela após mudança de stretch mode | Alta | Médio | Testar stretch mode em janela redimensionada antes de finalizar |

---

## 8. Plano de Testes

- [ ] **Teste de câmera**: Abrir Fase 1 e verificar que personagem ocupa ~10% da altura da tela
- [ ] **Teste de HUD**: Confirmar que vida, materiais e nome da fase estão visíveis após zoom
- [ ] **Teste de resolução**: Redimensionar janela e confirmar que background cobre a tela
- [ ] **Teste de balanceamento Fase 1**: Completar sem upgrades — deve ser desafiador mas possível
- [ ] **Teste de balanceamento Fase 4**: Com todos upgrades máximos — ainda deve haver risco de morte
- [ ] **Teste de custo exponencial**: Verificar custo de cada nível na TelaUpgrade (nível 1, 2, 3, 4)
- [ ] **Teste de spawn**: Confirmar que inimigos não aparecem visíveis no frame ao serem instanciados

---

## 9. Critérios de Done (DoD)

- [ ] RF-01: HP e quantidade de inimigos escalados por fase, sem regressão no spawner
- [ ] RF-02: Custo exponencial implementado e exibido corretamente na TelaUpgrade
- [ ] RF-03: Camera2D com zoom ajustado, HUD visível, spawns fora do viewport
- [ ] RF-04: Stretch mode configurado, background cobrindo tela em 16:9
- [ ] Nenhum magic number — todos os valores de balanceamento em constantes nomeadas
- [ ] Testado manualmente jogando as 4 fases do início ao fim
