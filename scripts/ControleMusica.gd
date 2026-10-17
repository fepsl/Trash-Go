extends CanvasLayer
## Controle compacto que permanece acessível acima dos menus.

const Estilo = preload("res://scripts/MenuEstilo.gd")
var _slider: HSlider
var _porcentagem: Label
var _silenciar: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var painel := $Painel as PanelContainer
	painel.add_to_group("bloqueia_ataque")
	var estilo := Estilo.caixa(Color(0.055, 0.095, 0.125, 0.97), Color("527069"))
	estilo.content_margin_left = 12
	estilo.content_margin_right = 12
	estilo.content_margin_top = 10
	estilo.content_margin_bottom = 10
	painel.add_theme_stylebox_override("panel", estilo)
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 12)
	painel.add_child(linha)
	_silenciar = Button.new()
	_silenciar.name = "Silenciar"
	_silenciar.custom_minimum_size = Vector2(32, 32)
	_silenciar.icon = preload("res://assets/ui/menu/musica.svg")
	_silenciar.expand_icon = true
	_silenciar.toggle_mode = true
	_silenciar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_silenciar.add_theme_stylebox_override("normal", Estilo.caixa(Color("203b38"), Color("527069"), 1))
	_silenciar.add_theme_stylebox_override("hover", Estilo.caixa(Color("35564b"), Estilo.VERDE, 1))
	_silenciar.add_theme_stylebox_override("pressed", Estilo.caixa(Color("3f3035"), Estilo.OURO, 1))
	for estado in ["normal", "hover", "pressed"]:
		var caixa := _silenciar.get_theme_stylebox(estado) as StyleBoxFlat
		caixa.content_margin_left = 6
		caixa.content_margin_right = 6
		caixa.content_margin_top = 6
		caixa.content_margin_bottom = 6
		caixa.shadow_size = 0
	linha.add_child(_silenciar)
	_silenciar.pressed.connect(Musica.alternar_silencio)
	Estilo.texto(linha, "MÚSICA", 12, Estilo.SUAVE)
	_slider = HSlider.new()
	_slider.name = "Volume"
	_slider.custom_minimum_size = Vector2(110, 32)
	_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_slider.min_value = 0
	_slider.max_value = 100
	_slider.step = 1
	_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider.tooltip_text = "Volume da música · 0 a 100%"
	var trilho := Estilo.caixa(Color("253d43"), Color("527069"), 1)
	trilho.content_margin_top = 3
	trilho.content_margin_bottom = 3
	trilho.shadow_size = 0
	_slider.add_theme_stylebox_override("slider", trilho)
	var preenchimento := trilho.duplicate() as StyleBoxFlat
	preenchimento.bg_color = Estilo.VERDE
	preenchimento.border_color = Estilo.VERDE
	_slider.add_theme_stylebox_override("grabber_area", preenchimento)
	_slider.add_theme_stylebox_override("grabber_area_highlight", preenchimento)
	_slider.add_theme_icon_override("grabber", preload("res://assets/ui/menu/volume_grabber.svg"))
	_slider.add_theme_icon_override("grabber_highlight", preload("res://assets/ui/menu/volume_grabber.svg"))
	linha.add_child(_slider)
	_slider.value_changed.connect(_on_volume_mudou)
	_slider.drag_ended.connect(_on_arraste_finalizado)
	_slider.focus_exited.connect(Musica.salvar_preferencias)
	_porcentagem = Estilo.texto(linha, "25%", 13, Estilo.VERDE)
	_porcentagem.custom_minimum_size.x = 42
	_porcentagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Musica.volume_mudou.connect(_sincronizar)
	_sincronizar(Musica.volume, Musica.silenciada)

func _sincronizar(valor: float, sem_som: bool) -> void:
	_slider.set_value_no_signal(valor)
	_silenciar.set_pressed_no_signal(sem_som)
	_porcentagem.text = "0%" if sem_som else "%d%%" % roundi(valor)
	_silenciar.tooltip_text = "Ativar música" if sem_som else "Silenciar música"
	_silenciar.icon = preload("res://assets/ui/menu/musica_muda.svg") if sem_som or valor == 0 else preload("res://assets/ui/menu/musica.svg")

func _on_volume_mudou(valor: float) -> void:
	Musica.definir_volume(valor)

func _on_arraste_finalizado(_alterado: bool) -> void:
	Musica.salvar_preferencias()

func _unhandled_key_input(event: InputEvent) -> void:
	if _slider.has_focus() and event.is_released():
		Musica.salvar_preferencias()
