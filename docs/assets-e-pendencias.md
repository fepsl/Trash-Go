# Assets e Pendências do Projeto

## Sprites necessários

### Personagem (Player)
- Idle — parado ( loop)
- Run — andando (estado padrão, anda automaticamente)
- Attack — atacando
- Hurt — levando dano
- Dead — morrendo

### Inimigos
- **Lixo** (base): idle, walk, hurt, dead
- **LixoEspecial**: mesma coisa com visual diferente (ex: lixo tóxico, eletrônico)
- **Boss**: idle, ataque, fase agressiva (50% de vida)

### Cenário / World
- Background de cada fase (ver seção Cenários)
- Tileset de chão: bloco 32×32px que se repete
- SpawnPoints são nós invisíveis — não precisam de sprite

### UI / HUD
- Ícone de material reciclável (contador)
- Ícones dos 6 poderes (Escudo, Ataque em Área, Projétil, Velocidade+, Cura ao Matar, Ricochete)
- Arte/logo da tela de início (opcional)

### Efeitos (opcional)
- Hit effect ao acertar inimigo
- Drop de material ao matar inimigo

---

## Cenários (4 fases)

### Fase 1 — Rua da Cidade
- Ambiente urbano poluído: lixeiras coloridas, prédios, postes, sacolas voando
- Inimigos temáticos: sacos de lixo animados, garrafas PET

### Fase 2 — Depósito / Aterro Sanitário
- Montanhas de lixo, fumaça no chão, guindaste ao fundo
- Inimigos temáticos: lixo tóxico, latas amassadas

### Fase 3 — Rio Poluído
- Água escura com lixo flutuando, ponte, fábricas ao fundo
- Plataformas: pedras ou barcos
- Inimigos temáticos: lixo eletrônico, óleo derramado

### Fase 4 — Fábrica de Reciclagem
- Esteiras, máquinas, contêineres coloridos, iluminação dramática
- Boss final aqui
- Inimigos temáticos: lixo eletrônico reanimado

### Estrutura de cada cenário no Godot
Cada fase usa 3 camadas:
1. **Fundo** — Sprite2D ou ParallaxBackground, sem colisão
2. **Meio** — decorações mais próximas
3. **Chão** — TileMapLayer com StaticBody2D para colisão

---

## Pendências para finalizar o projeto

### Prioridade alta
- [ ] Criar sprites (usar Piskel para pixel art ou baixar pack no kenney.nl / itch.io)
- [ ] Configurar AnimatedSprite2D no Player.tscn, Lixo.tscn, LixoEspecial.tscn, Boss.tscn
- [ ] Montar as 4 fases no editor (tileset + SpawnPoints + background)
- [ ] Testar loop completo: Fase1 → Boss → Upgrade → Fase2 → ... → Fase4

### Prioridade média
- [ ] Sons: ataque, dano, morte de inimigo, boss, trilha de fundo
- [ ] Revisar TelaUpgrade.gd — verificar conexão com fluxo de materiais
- [ ] Corrigir _on_hurtbox_area_entered vazio em Inimigo.gd (linha 52)

### Prioridade baixa (polimento)
- [ ] Paralaxe no background
- [ ] Partículas de hit
- [ ] Ícones dos poderes na HUD

### Exportação (fazer antes da apresentação)
- [ ] Configurar preset Web (HTML5) no Godot: Project → Export → Add → Web
- [ ] Testar localmente com servidor HTTP: `python -m http.server 8080` na pasta exports/web/
- [ ] Não abrir index.html direto no browser — precisa do servidor HTTP

---

## Ferramentas recomendadas para criar sprites

| Ferramenta | Tipo | Observação |
|---|---|---|
| [Piskel](https://www.piskelapp.com/) | Pixel art (browser) | Gratuito, sem instalar, bom para iniciantes |
| Aseprite | Pixel art (desktop) | Pago ~US$20, padrão da indústria |
| LibreSprite | Pixel art (desktop) | Gratuito, fork do Aseprite |
| [kenney.nl](https://kenney.nl/assets) | Packs prontos | Gratuito, limpo, fácil de adaptar |
| [itch.io/game-assets](https://itch.io/game-assets/free) | Packs prontos | Muitos packs grátis com tema variado |
| [OpenGameArt.org](https://opengamear  t.org/) | Packs prontos | Gratuito e open source |

**Formato:** PNG com fundo transparente para tudo que não é cenário.
**Resolução sugerida:** player ~64×64px, inimigos ~48×48px, tiles ~32×32px.
