# test_action_system.gd
extends GutTest

var MockEntity = preload("res://lib/roguekit/entity/entity.gd")
var MoveAction = preload("res://lib/roguekit/turn_based/actions/move_action.gd")
var AttackAction = preload("res://lib/roguekit/turn_based/actions/attack_action.gd")

var entity
var target_entity

func before_each():
	# 创建一个模拟的实体，它需要有一个StatsComponent和HealthComponent
	entity = MockEntity.new()
	entity.name = "TestEntity"
	var stats = StatsComponent.new()
	entity.add_child(stats)
	
	target_entity = MockEntity.new()
	target_entity.name = "TargetEntity"
	var target_stats = StatsComponent.new()
	var target_health = HealthComponent.new()
	target_entity.add_child(target_stats)
	target_entity.add_child(target_health)
	
	# 将它们添加到场景树中，以便get_node等方法可以工作
	add_child(entity)
	add_child(target_entity)

func after_each():
	entity.queue_free()
	target_entity.queue_free()

# 测试MoveAction在没有GameManager时的失败行为
func test_move_action_fails_without_gamemanager():
	var move_action = MoveAction.new(Vector2i(1, 0))
	assert_eq(move_action.direction, Vector2i(1, 0), "MoveAction should store the correct direction.")
	
	# 记录初始位置
	var initial_position = entity.global_position
	
	# 在没有GameManager的情况下执行
	move_action.execute(entity)
	
	# 断言实体位置没有改变
	assert_eq(entity.global_position, initial_position, "Entity should not move when GameManager is not present.")


# 测试AttackAction的构造和执行
func test_attack_action():
	var attack_action = AttackAction.new(target_entity)
	assert_eq(attack_action.target, target_entity, "AttackAction should store the correct target.")
	
	# 设置基础属性
	var attacker_stats = entity.get_node("StatsComponent")
	attacker_stats.stats["strength"] = Stat.new()
	attacker_stats.stats["strength"].base_value = 10
	
	var target_health = target_entity.get_node("HealthComponent")
	target_health.max_health = 50
	target_health.health = 50
	
	# 执行攻击
	attack_action.execute(entity)
	
	# 验证伤害
	assert_eq(target_health.health, 40, "Target should take 10 damage (10 strength - 0 defense).")
