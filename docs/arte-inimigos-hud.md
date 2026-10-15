# Inimigos em pixel art e HUD

Atualização de 15/10/2026. Sprites criadas com a ferramenta integrada ImageGen; HUD criada com SVGs de formas pixeladas e controles nativos do Godot.

## Arquivos finais

- `assets/sprites/enemies/lixo_pixel_sheet.png`: monstrinho de saco de lixo, 1254 × 1254, PNG RGBA transparente.
- `assets/sprites/enemies/toxico_pixel_sheet.png`: barril tóxico roxo com slime verde, 1254 × 1254, PNG RGBA transparente.
- `assets/sprites/enemies/boss_pixel_sheet.png`: chefão de sucata laranja, 1254 × 1254, PNG RGBA transparente.
- `scenes/enemies/Lixo.tscn`, `LixoEspecial.tscn`, `Boss.tscn`: quatro quadros por ação (idle, movimento, ataque e morte), 48 no total. AtlasTexture com margens mantém o mesmo pivô e a base dos pés.
- `scripts/Inimigo.gd` e `scripts/Boss.gd`: ataques não são interrompidos pela corrida; mortes concluem antes de liberar o nó. Golpes repetidos durante a morte não duplicam materiais/recompensas.
- `scripts/SombraInimigo.gd`: sombras locais alinhadas à base das sprites.
- `assets/HUD/pixel/`: moldura escura com cantos em degraus, moldura de retrato, coração, caixa de materiais e slots de habilidades.
- `scenes/ui/HUD.tscn` e `scripts/HUD.gd`: retrato do personagem, vida numérica, barra animada com rastro de dano e cores de alerta, contador de materiais com destaque na coleta, estilos dos slots atualizados.
- `docs/inimigos-hud.png`: captura da composição final renderizada no Godot.

## Verificação

Executado no Godot 4.6 com renderização OpenGL. Passaram: três inimigos tocando o chão, 48 quadros com dimensão lógica comum, movimento, ataque e retorno ao idle, morte e liberação do nó, recompensa única em dano repetido, fase agressiva do chefe, atualização de materiais, vida máxima após melhoria, alerta de pouca vida, rastro de dano e reinício.

O preset Web existente continua avisando sobre a chave `runnable` ausente. O verificador temporário também gerou aviso de recursos próprios pendentes ao encerrar; o diagnóstico identificou o script de verificação e um SceneTreeTimer. A exportação Web `docs/index.*` não foi regenerada. Execute o projeto no Godot para ver as mudanças.

## Prompts usados no ImageGen

### lixo

```text
Use case: stylized-concept. Asset type: production PIXEL ART animation atlas for a Godot recycling side-scroller. TRUE 16-bit PIXEL ART: square pixel clusters, crisp dark navy outline, flat 2-3-tone shading, limited palette, no blur, no painterly or 3D rendering. Cute but dangerous indie-game enemy readable at 110 pixels tall, matching the supplied pixel-art recycling hero's game style. Exact regular grid: 1024x1024 image, FOUR COLUMNS and FOUR ROWS, each cell 256x256, exactly 16 complete separate poses. Every character has the SAME scale, faces LEFT, center pivot x=128 in its cell, ground baseline y=228. Upright enemy height approximately 170 pixels, leave at least 24px transparent padding at all cell edges. Every pose fully inside its own cell, no overlap. Row 1 four IDLE breathing poses, row 2 four WALK loop poses with alternating feet and body squash, row 3 four ATTACK poses (anticipation, windup, lunge LEFT, recovery), row 4 four DEATH poses (hurt, collapse, break apart, little debris heap on same baseline). Character stays consistent between all poses. Genuine transparent alpha background; absolutely no floor, no cast shadows, no background haze, no gradients in empty space, no grid lines, no labels, no numbers, no text, no checkerboard, no watermark. Subject: an original scrappy trash-bag GREMLIN. A squat charcoal blue garbage sack brought to life with a knotted top, mischievous glowing AMBER eyes and jagged cardboard teeth. Two stubby bootlike scrap feet, thick short arms, crumpled soda can shoulder armor, tiny bottle and paper scraps sticking out. Teal charcoal main body, rusty tan cardboard patches, silver can edges, amber eye accent. Expressive chunky silhouette. Not a brown amorphous slime. No weapon. In attack he swipes with a crumpled-can fist. Death becomes a small loose sack and can heap.
```

### toxico

```text
Use case: stylized-concept. Asset type: production PIXEL ART animation atlas for a Godot recycling side-scroller. TRUE 16-bit PIXEL ART: square pixel clusters, crisp dark navy outline, flat 2-3-tone shading, limited palette, no blur, no painterly or 3D rendering. Cute but dangerous indie-game enemy readable at 110 pixels tall, matching the supplied pixel-art recycling hero's game style. Exact regular grid: 1024x1024 image, FOUR COLUMNS and FOUR ROWS, each cell 256x256, exactly 16 complete separate poses. Every character has the SAME scale, faces LEFT, center pivot x=128 in its cell, ground baseline y=228. Upright enemy height approximately 170 pixels, leave at least 24px transparent padding at all cell edges. Every pose fully inside its own cell, no overlap. Row 1 four IDLE breathing poses, row 2 four WALK loop poses with alternating feet and body squash, row 3 four ATTACK poses (anticipation, windup, lunge LEFT, recovery), row 4 four DEATH poses (hurt, collapse, break apart, little debris heap on same baseline). Character stays consistent between all poses. Genuine transparent alpha background; absolutely no floor, no cast shadows, no background haze, no gradients in empty space, no grid lines, no labels, no numbers, no text, no checkerboard, no watermark. Subject: an original TOXIC BARREL mutant. Squat upright rusty PURPLE industrial drum with dark iron banding and a huge jagged grin and luminous ACID GREEN eyes. Green slime leaks from its cracked lid and forms two stubby legs and oversized goo fists. A simple yellow hazard triangle on its chest, readable at small scale. Palette purple metal, charcoal outline, yellow small hazard accent, vibrant emerald and lime slime. Strong distinct barrel silhouette, intimidating elite enemy. Attack punches LEFT with a large slime fist. Death barrel splits and drains into a green puddle with metal scraps. Keep puddle within its cell.
```

### boss

```text
Use case: stylized-concept. Asset type: production PIXEL ART animation atlas for a Godot recycling side-scroller. TRUE 16-bit PIXEL ART: square pixel clusters, crisp dark navy outline, flat 2-3-tone shading, limited palette, no blur, no painterly or 3D rendering. Cute but dangerous indie-game enemy readable at 110 pixels tall, matching the supplied pixel-art recycling hero's game style. Exact regular grid: 1024x1024 image, FOUR COLUMNS and FOUR ROWS, each cell 256x256, exactly 16 complete separate poses. Every character has the SAME scale, faces LEFT, center pivot x=128 in its cell, ground baseline y=228. Upright enemy height approximately 170 pixels, leave at least 24px transparent padding at all cell edges. Every pose fully inside its own cell, no overlap. Row 1 four IDLE breathing poses, row 2 four WALK loop poses with alternating feet and body squash, row 3 four ATTACK poses (anticipation, windup, lunge LEFT, recovery), row 4 four DEATH poses (hurt, collapse, break apart, little debris heap on same baseline). Character stays consistent between all poses. Genuine transparent alpha background; absolutely no floor, no cast shadows, no background haze, no gradients in empty space, no grid lines, no labels, no numbers, no text, no checkerboard, no watermark. Subject: an original imposing SCRAP GOLEM boss built from a battered orange industrial dumpster torso, asymmetric bulky mechanical arms made of compacted scrap, tanklike scrap feet, a dark mechanical face with TWO bright crimson eyes, a jagged steel jaw, old pipes and small exhaust stacks on shoulders. Rust ORANGE and dark navy metal with yellow hazard stripes and turquoise small mechanical highlights. Broad powerful top-heavy silhouette, approximately 190px tall and 200px wide within each cell, extra clear separation between limbs. The same single boss consistently, no extra creatures. Attack a heavy steel fist slam LEFT. Death slumps into a broken orange dumpster and scattered metal parts. No black smoke clouds outside the character.
```

### Ajuste final de espaçamento aplicado às três folhas

```text
Edit this sprite animation sheet. Preserve exactly the same character design, pixel art, 16 poses, pose order and transparent alpha. Correct ONLY the atlas layout: SHRINK EACH INDIVIDUAL CHARACTER TO 65 PERCENT OF ITS CURRENT SIZE in its own cell, so there is much more empty transparent padding between poses. FOUR columns and FOUR rows on a square canvas. Each of the 16 cells must contain exactly one complete pose including fists, feet, particles and debris. At least 35 pixels of fully transparent padding on EVERY side of each character; absolutely no parts reaching or crossing cell boundaries. Same scale for all poses. Body center horizontally at center of each cell. All boots/debris on the same floor baseline within each row. For example, on a 1280x1280 canvas cells are 320x320, object is about 180x200px, centered x=160, feet y=260. If choosing a different canvas size, scale these ratios proportionally. Reconstruct any hand clipped by the canvas in the source. This is a SPACIOUS practical production atlas, not a tightly packed illustration. Alpha zero throughout all empty space. No glow behind sprites, no grid lines, no text, no watermark.
```
