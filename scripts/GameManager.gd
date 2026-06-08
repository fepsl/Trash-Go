extends Node

enum Estado { INICIO, JOGANDO, BOSS, UPGRADE, GAME_OVER }
enum Poder { ESCUDO = 0, ATAQUE_AREA = 1, PROJETIL = 2, VELOCIDADE = 3, CURA_AO_MATAR = 4, RICOCHETE = 5 }

const VIDA_INICIAL: int = 150
const NUM_PODERES: int = 6
const TOTAL_FASES: int = 4
const CUSTO_BASE_VIDA: int = 5
const CUSTO_BASE_DANO: int = 8
const CUSTO_BASE_RECARGA: int = 6
const CUSTO_BASE_VELOCIDADE: int = 7
const MULTIPLICADOR_CUSTO_UPGRADE: float = 2.0

var estado_atual: Estado = Estado.INICIO
var vida_atual: int = VIDA_INICIAL
var vida_maxima: int = VIDA_INICIAL
var materiais: int = 0
var poderes_ativos: Array = []
var fase_atual: int = 1
var num_loops: int = 0
var nivel_upgrade_vida: int = 0
var nivel_upgrade_dano: int = 0
var nivel_upgrade_recarga: int = 0
var nivel_upgrade_velocidade: int = 0

signal material_coletado(qtd: int)
signal vida_atualizada(atual: int, max: int)
signal poder_concedido(poder: String)
signal estado_mudou(novo_estado: Estado)

func _ready() -> void:
	resetar_estado()

func resetar_estado() -> void:
	vida_maxima = VIDA_INICIAL
	vida_atual = VIDA_INICIAL
	materiais = 0
	poderes_ativos.clear()
	fase_atual = 1
	num_loops = 0
	nivel_upgrade_vida = 0
	nivel_upgrade_dano = 0
	nivel_upgrade_recarga = 0
	nivel_upgrade_velocidade = 0
	vida_atualizada.emit(vida_atual, vida_maxima)
	mudar_estado(Estado.INICIO)

func custo_upgrade(custo_base: int, nivel: int) -> int:
	return int(custo_base * pow(1.5, nivel))

func mudar_estado(novo: Estado) -> void:
	estado_atual = novo
	estado_mudou.emit(novo)

func registrar_player(player: Player) -> void:
	player.player_morreu.connect(_on_player_morreu)

func _on_player_morreu() -> void:
	mudar_estado(Estado.GAME_OVER)

func _on_inimigo_morreu(material_drop: int) -> void:
	var drop_total := material_drop * (1 + num_loops)
	materiais += drop_total
	material_coletado.emit(drop_total)
	if Poder.CURA_AO_MATAR in poderes_ativos:
		vida_atual = min(vida_atual + max(1, 5 - num_loops * 2), vida_maxima)
		vida_atualizada.emit(vida_atual, vida_maxima)

func _on_fase_completa() -> void:
	mudar_estado(Estado.BOSS)

func _on_boss_derrotado() -> void:
	conceder_poder_aleatorio()
	if fase_atual == TOTAL_FASES:
		num_loops += 1
	fase_atual = (fase_atual % TOTAL_FASES) + 1
	mudar_estado(Estado.UPGRADE)

func conceder_poder_aleatorio() -> void:
	var nao_coletados: Array[int] = []
	for i in range(NUM_PODERES):
		if i not in poderes_ativos:
			nao_coletados.append(i)
	var poder: int
	if nao_coletados.is_empty():
		poder = randi() % NUM_PODERES
	else:
		poder = nao_coletados[randi() % nao_coletados.size()]
	if poder not in poderes_ativos:
		poderes_ativos.append(poder)
	poder_concedido.emit(_nome_poder(poder))

func _nome_poder(poder: int) -> String:
	match poder:
		Poder.ESCUDO: return "Escudo"
		Poder.ATAQUE_AREA: return "Ataque em Área"
		Poder.PROJETIL: return "Projétil"
		Poder.VELOCIDADE: return "Velocidade+"
		Poder.CURA_AO_MATAR: return "Cura ao Matar"
		Poder.RICOCHETE: return "Ricochete"
		_: return "Poder"
