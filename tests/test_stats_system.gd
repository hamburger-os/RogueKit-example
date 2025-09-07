extends Node

# 引用我们刚刚修改的组件和数据对象
const StatsComponent = preload("res://lib/roguekit/entity/components/stats_component.gd")
const StatModifier = preload("res://lib/roguekit/entity/stat_modifier.gd")

func _ready():
	# 创建一个 StatsComponent 实例
	var stats_comp = StatsComponent.new()
	add_child(stats_comp)

	print("--- Running Stats System Tests ---")

	# 1. 初始化
	print("\n[1] Initializing StatsComponent...")
	var initial_stats = {
		"strength": 10,
		"agility": 8
	}
	stats_comp.setup(initial_stats)
	assert_equals(stats_comp.get_stat_value("strength"), 10, "Initial strength should be 10")
	assert_equals(stats_comp.get_stat_value("agility"), 8, "Initial agility should be 8")
	print(" -> SUCCESS")

	# 2. 测试加法修改器
	print("\n[2] Testing ADDITIVE modifier...")
	var sword_bonus = StatModifier.new(5.0, StatModifier.ModifierType.ADDITIVE)
	stats_comp.add_modifier("strength", sword_bonus)
	assert_equals(stats_comp.get_stat_value("strength"), 15, "Strength with sword bonus should be 15")
	print(" -> SUCCESS")

	# 3. 测试乘法修改器
	print("\n[3] Testing MULTIPLICATIVE modifier...")
	var rage_bonus = StatModifier.new(0.5, StatModifier.ModifierType.MULTIPLICATIVE) # +50%
	stats_comp.add_modifier("strength", rage_bonus)
	# (10 base + 5 sword) * (1.0 + 0.5 rage) = 15 * 1.5 = 22.5 -> 23
	assert_equals(stats_comp.get_stat_value("strength"), 23, "Strength with rage bonus should be 23")
	print(" -> SUCCESS")
	
	# 4. 测试移除修改器
	print("\n[4] Testing modifier removal...")
	stats_comp.remove_modifier("strength", sword_bonus)
	# (10 base) * (1.0 + 0.5 rage) = 10 * 1.5 = 15
	assert_equals(stats_comp.get_stat_value("strength"), 15, "Strength after removing sword bonus should be 15")
	stats_comp.remove_modifier("strength", rage_bonus)
	assert_equals(stats_comp.get_stat_value("strength"), 10, "Strength after removing all modifiers should be 10")
	print(" -> SUCCESS")

	# 5. 测试临时修改器
	print("\n[5] Testing temporary (duration) modifier...")
	var haste_potion = StatModifier.new(1.0, StatModifier.ModifierType.ADDITIVE, 2.0) # +1 agility for 2 seconds
	stats_comp.add_modifier("agility", haste_potion)
	assert_equals(stats_comp.get_stat_value("agility"), 9, "Agility after drinking haste potion should be 9")
	print(" -> Agility is 9. Waiting for 2.5 seconds for modifier to expire...")
	
	# 等待2.5秒，让修改器过期
	await get_tree().create_timer(2.5).timeout
	
	assert_equals(stats_comp.get_stat_value("agility"), 8, "Agility after haste potion expires should be 8")
	print(" -> Agility is back to 8. SUCCESS")
	
	print("\n--- All Stats System Tests Passed! ---")
	get_tree().quit() # 自动退出游戏


# 自定义断言函数，方便测试
func assert_equals(actual, expected, message):
	if actual == expected:
		print("    - PASSED: %s" % message)
	else:
		print("    - FAILED: %s" % message)
		print("      Expected: %s, but got: %s" % [expected, actual])
		get_tree().quit()
