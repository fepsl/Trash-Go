# Prompts para gerar sprites com IA

> Cole cada prompt em: **Leonardo.ai**, **Midjourney**, **DALL-E 3**, ou **Adobe Firefly**
> Formato final: PNG fundo transparente
> Estilo: pixel art 16x16 — visual retrô clássico (Game Boy / NES)

---

## Escala no Godot (IMPORTANTE)

Sprites de 16x16 precisam ser ampliados no Godot, senão ficam invisíveis na tela.
Faça isso em **duas etapas**:

**1. Desativar o filtro (anti-aliasing) — sem isso fica borrado ao ampliar:**
> `Project → Project Settings → Rendering → Textures → Default Texture Filter → Nearest`

**2. Ampliar o sprite no Inspector:**
> Selecione o nó `Sprite2D` ou `AnimatedSprite2D` → `Scale: (4, 4)` para 64x64 na tela
> Ou use `(3, 3)` para 48x48 na tela — escolha o que couber melhor no cenário

---

## Dica de uso

Para animações (idle, run, attack...), gere cada frame separado ou peça uma **sprite sheet**.
Sugestão de frase adicional para sprite sheets:
> `sprite sheet with 4 frames on a single row, transparent background, 16x16 each frame`

---

## PERSONAGEM (Player)

> Tamanho: **16x16 px** por frame — amplia para 64x64 no Godot com scale (4,4)

### Idle (parado, respirando)
```
2D pixel art game character, tiny eco-hero wearing green outfit with recycling symbol, idle pose standing upright, side-scrolling platformer style, exactly 16x16 pixels, transparent background, clean pixel outlines, limited color palette, retro NES style
```

### Run (andando/correndo)
```
2D pixel art game character, tiny eco-hero wearing green outfit with recycling symbol, running mid-stride pose, side view, side-scrolling platformer style, exactly 16x16 pixels, transparent background, retro NES style, limited color palette
```

### Attack (atacando)
```
2D pixel art game character, tiny eco-hero wearing green outfit, attacking pose, arm extended forward, side view, side-scrolling platformer style, exactly 16x16 pixels, transparent background, retro NES style
```

### Hurt (levando dano)
```
2D pixel art game character, tiny eco-hero wearing green outfit, hurt/knockback pose, leaning backward, side view, exactly 16x16 pixels, transparent background, retro NES style
```

### Dead (morrendo)
```
2D pixel art game character, tiny eco-hero wearing green outfit, death pose, lying flat or falling, x eyes, side view, exactly 16x16 pixels, transparent background, retro NES style
```

---

## INIMIGOS

> Tamanho: **16x16 px** por frame — amplia para 48x48 no Godot com scale (3,3)

### Lixo Base — Idle (saco de lixo animado)
```
2D pixel art enemy, tiny animated trash bag monster, black garbage bag with evil eyes and small arms, idle breathing pose, side-scrolling game style, exactly 16x16 pixels, transparent background, retro NES style, limited color palette
```

### Lixo Base — Walk (andando)
```
2D pixel art enemy, tiny animated trash bag monster walking forward, black garbage bag with small arms and legs, side view, exactly 16x16 pixels, transparent background, retro NES style
```

### Lixo Base — Hurt
```
2D pixel art enemy, tiny animated trash bag monster hit reaction, recoiling backward, impact stars, exactly 16x16 pixels, transparent background, retro NES style
```

### Lixo Base — Dead
```
2D pixel art enemy, tiny animated trash bag monster death, deflating or exploding into small pieces, exactly 16x16 pixels, transparent background, retro NES style
```

### LixoEspecial — Lixo Tóxico (Fase 2)
```
2D pixel art enemy, tiny toxic waste monster, small green glowing barrel with face and arms, dripping slime, evil expression, exactly 16x16 pixels, transparent background, retro NES style, neon green palette
```

### LixoEspecial — Lixo Eletrônico (Fase 3 e 4)
```
2D pixel art enemy, tiny electronic waste monster, small broken TV with robotic arms, sparking electricity, red eyes, exactly 16x16 pixels, transparent background, retro NES style
```

### Boss — Fase Normal (idle)
```
2D pixel art boss enemy, garbage monster made of mixed trash, humanoid shape with crown of broken bottles, large glowing red eyes, imposing idle pose, side-scrolling game style, exactly 32x32 pixels, transparent background, retro NES style
```

### Boss — Fase Agressiva (menos de 50% de vida)
```
2D pixel art boss enemy, garbage monster in rage mode, cracked body leaking toxic smoke, bright orange glowing eyes, aggressive attack pose, exactly 32x32 pixels, transparent background, retro NES style
```

### Boss — Ataque
```
2D pixel art boss enemy, garbage monster slamming fists or throwing trash projectile, dynamic attack pose, exactly 32x32 pixels, transparent background, retro NES style
```

---

## CENÁRIOS / BACKGROUNDS

> Backgrounds podem ser resolução maior (não são ampliados da mesma forma)

### Fase 1 — Rua da Cidade
```
2D pixel art side-scrolling game background, polluted city street at dusk, colorful overflowing trash cans, dirty buildings, flickering streetlights, plastic bags blowing in wind, 1920x1080 pixels, no characters, parallax layers style, retro pixel art, limited color palette
```

### Fase 1 — Chão (Tileset)
```
2D pixel art tileset tile, dirty city sidewalk, cracked concrete with trash and stains, exactly 16x16 pixels, seamless repeating tile, muted gray and brown tones, retro NES style
```

### Fase 2 — Aterro Sanitário
```
2D pixel art side-scrolling game background, landfill dumping site, massive piles of garbage, toxic smoke from ground, rusty crane in background, gray cloudy sky, 1920x1080 pixels, no characters, retro pixel art, limited color palette
```

### Fase 2 — Chão (Tileset)
```
2D pixel art tileset tile, compressed garbage ground, layers of squashed trash and dirt, exactly 16x16 pixels, seamless repeating tile, brown and dark green tones, retro NES style
```

### Fase 3 — Rio Poluído
```
2D pixel art side-scrolling game background, heavily polluted dark river, trash floating on black water, industrial bridge in midground, smoking factories, foggy atmosphere, 1920x1080 pixels, no characters, retro pixel art, dark blues and grays
```

### Fase 3 — Plataformas (pedras/barcos)
```
2D pixel art platform tile, old wooden boat plank or mossy river rock, exactly 16x16 pixels, seamless tile, dark and weathered look, retro NES style
```

### Fase 4 — Fábrica de Reciclagem
```
2D pixel art side-scrolling game background, recycling factory interior, conveyor belts, colorful sorting containers blue green yellow, industrial machines, dramatic lighting, 1920x1080 pixels, no characters, retro pixel art, limited color palette
```

### Fase 4 — Chão (Tileset)
```
2D pixel art tileset tile, factory metal floor, industrial steel grating with bolts, exactly 16x16 pixels, seamless repeating tile, dark gray metallic tones with rust spots, retro NES style
```

---

## HUD / INTERFACE

### Ícone de Material Reciclável (contador)
```
2D pixel art UI icon, recycling material collectible, tiny glowing green recycling symbol or crushed aluminum can, exactly 16x16 pixels, transparent background, vibrant, retro game HUD style
```

### Ícone — Poder: Escudo
```
2D pixel art UI skill icon, shield power-up, small green shield with recycling symbol, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Ícone — Poder: Ataque em Área
```
2D pixel art UI skill icon, area attack power-up, fist with shockwave rings, green energy, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Ícone — Poder: Projétil
```
2D pixel art UI skill icon, projectile power-up, green energy ball flying forward with motion lines, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Ícone — Poder: Velocidade+
```
2D pixel art UI skill icon, speed boost, lightning bolt or running shoe with green glow, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Ícone — Poder: Cura ao Matar
```
2D pixel art UI skill icon, heal on kill, heart with green recycling arrows around it, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Ícone — Poder: Ricochete
```
2D pixel art UI skill icon, ricochet power-up, projectile bouncing off wall with arrows, exactly 16x16 pixels, transparent background, retro game HUD style
```

### Logo / Arte da Tela de Início
```
2D pixel art game title screen art, recycling hero theme, young hero standing heroically with recycling symbol glowing behind, city background with pollution turning clean, vibrant greens and blues, retro pixel art style, 1280x720 pixels
```

---

## EFEITOS (opcional)

### Hit Effect
```
2D pixel art hit effect, small impact burst, star-shaped yellow and white flash, exactly 16x16 pixels, transparent background, retro NES game impact effect
```

### Drop de Material
```
2D pixel art collectible drop, tiny glowing recycling token, sparkle effect, floating, exactly 16x16 pixels, transparent background, bright and attractive, retro NES style
```

---

## DICAS EXTRAS

**Para consistência de estilo**, adicione ao final de todo prompt:
> `pixel art, limited color palette, clean pixel outlines, retro NES/Game Boy style, no anti-aliasing`

**Para fundo transparente**, adicione:
> `isolated on transparent background, no background, PNG format`

**Para sprite sheets animadas**, adicione:
> `sprite sheet, 4 frames horizontal, same character in sequential poses, 16x16 each frame, uniform spacing`

**Configuração no Godot para tiles de 16x16:**
> `TileMapLayer → Tile Set → Tile Size: 16x16`
> Para o mundo ficar proporcional ao player, use scale (4,4) em tudo ou ajuste o zoom da câmera.
