extends Node

@onready var turn_manager: TurnManager = $TurnManager
@onready var player: Entity = $Player
@onready var enemy_container: Node = $Enemies
@onready var events_bus: Node = $Events

# 测试持续时间（秒）
const TEST_DURATION: float = 5.0

func _ready():
	# 1. 注入依赖并连接信号
	player.events_bus = events_bus
	player.get_node("PlayerInputComponent").game_manager = $GameManager
	turn_manager.register_actor(player)
	
	for enemy in enemy_container.get_children():
		enemy.events_bus = events_bus
		turn_manager.register_actor(enemy)
		
	events_bus.entity_died.connect(turn_manager._on_entity_died)

	# 2. 启动游戏循环
	print("--- Starting Turn-Based Speed Test ---")
	turn_manager.start_game()
	
	# 3. 设置计时器以在测试结束后验证结果
	await get_tree().create_timer(TEST_DURATION).timeout
	validate_turn_counts()


func validate_turn_counts():
	print("\n--- Validating Turn Counts after %.1f seconds ---" % TEST_DURATION)
	
	var player_turns: int = turn_manager.turn_counts.get(player, 0)
	# 假设只有一个敌人用于测试
	var enemy: Entity = enemy_container.get_children()[0]
	var enemy_turns: int = turn_manager.turn_counts.get(enemy, 0)
	
	print("Player turns: %d" % player_turns)
	print("Enemy turns: %d" % enemy_turns)

	if enemy_turns == 0:
		_assert(false, "Enemy took 0 turns, test is invalid.")
		get_tree().quit()
		return
		
	var player_speed: float = player.stats_component.get_stat_value("speed")
	var enemy_speed: float = enemy.stats_component.get_stat_value("speed")
	
	var expected_ratio: float = player_speed / enemy_speed
	var actual_ratio: float = float(player_turns) / float(enemy_turns)
	
	print("Expected turn ratio (Player/Enemy): %.2f (Speed %d/%d)" % [expected_ratio, player_speed, enemy_speed])
	print("Actual turn ratio (Player/Enemy): %.2f (%d/%d)" % [actual_ratio, player_turns, enemy_turns])
	
	# 允许25%的误差范围，因为回合制和能量阈值会导致离散结果
	var tolerance: float = 0.25 
	var lower_bound: float = expected_ratio * (1.0 - tolerance)
	var upper_bound: float = expected_ratio * (1.0 + tolerance)
	
	var success: bool = actual_ratio >= lower_bound and actual_ratio <= upper_bound
	
	_assert(success, "Turn ratio is within the expected range.")
	
	get_tree().quit()


func _assert(condition: bool, message: String):
	if condition:
		print(" -> PASSED: %s" % message)
	else:
		print(" -> FAILED: %s" % message)
