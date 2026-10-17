extends RefCounted
## Vocabulário visual compartilhado pelas telas de entrada e oficina.

const VERDE := Color("a5e6a1")
const CREME := Color("fff1d2")
const SUAVE := Color("a5b5b2")
const OURO := Color("efbe78")

static func caixa(cor: Color, borda: Color, largura: int = 2) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor
	estilo.border_color = borda
	estilo.set_border_width_all(largura)
	estilo.corner_radius_top_left = 3
	estilo.corner_radius_bottom_right = 3
	estilo.content_margin_left = 20
	estilo.content_margin_right = 20
	estilo.content_margin_top = 14
	estilo.content_margin_bottom = 14
	estilo.shadow_color = Color(0.015, 0.025, 0.035, 0.5)
	estilo.shadow_size = 5
	estilo.shadow_offset = Vector2(0, 5)
	return estilo

static func texto(pai: Node, conteudo: String, tamanho: int = 18, cor: Color = CREME) -> Label:
	var label := Label.new()
	label.text = conteudo
	label.add_theme_font_size_override("font_size", tamanho)
	label.add_theme_color_override("font_color", cor)
	label.add_theme_color_override("font_shadow_color", Color(0.02, 0.035, 0.055, 0.7))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(label)
	return label

static func icone(pai: Node, textura: Texture2D, tamanho: Vector2 = Vector2(48, 48)) -> TextureRect:
	var imagem := TextureRect.new()
	imagem.texture = textura
	imagem.custom_minimum_size = tamanho
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(imagem)
	return imagem

static func botao(pai: Node, conteudo: String, principal: bool = false, cor: Color = VERDE) -> Button:
	var button := Button.new()
	button.text = conteudo
	button.custom_minimum_size.y = 54
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 18)
	var fundo := cor if principal else Color("1c3035")
	button.add_theme_stylebox_override("normal", caixa(fundo, cor if principal else Color("527069")))
	button.add_theme_stylebox_override("hover", caixa(cor.lightened(0.14) if principal else Color("2c4845"), cor))
	button.add_theme_stylebox_override("pressed", caixa(cor.darkened(0.18) if principal else Color("14272d"), cor))
	button.add_theme_stylebox_override("disabled", caixa(Color("18242c"), Color("34444a")))
	var foco := caixa(Color.TRANSPARENT, CREME, 2)
	foco.expand_margin_left = 4
	foco.expand_margin_top = 4
	foco.expand_margin_right = 4
	foco.expand_margin_bottom = 4
	foco.shadow_size = 0
	button.add_theme_stylebox_override("focus", foco)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(estado, Color("14252b") if principal else CREME)
	button.add_theme_color_override("font_disabled_color", Color("849390"))
	pai.add_child(button)
	return button

static func conteudo(pai: Control) -> Control:
	var area := Control.new()
	area.name = "Conteudo"
	area.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	area.offset_left = -560
	area.offset_right = 560
	area.offset_top = -290
	area.offset_bottom = 290
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(area)
	return area

static func coluna(pai: Node, posicao: Vector2, tamanho: Vector2, separacao: int = 12) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.position = posicao
	box.size = tamanho
	box.add_theme_constant_override("separation", separacao)
	pai.add_child(box)
	return box

static func linha(pai: Node, cor: Color = Color("527069")) -> ColorRect:
	var separador := ColorRect.new()
	separador.color = cor
	separador.custom_minimum_size.y = 2
	separador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(separador)
	return separador

static func aparecer(node: Control) -> Tween:
	node.modulate.a = 0.0
	var tween := node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	return tween
