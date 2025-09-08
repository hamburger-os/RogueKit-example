class_name ChainReactionEffect
extends EffectData

@export var max_targets: int = 2
@export var radius: float = 150.0
@export var damage_falloff: float = 0.5

func execute(context: EffectContext):
	if not context.target or not context.target.global_position:
		push_warning("ChainReactionEffect: Invalid context target.")
		return

	var original_target_pos = context.target.global_position
	var current_damage = context.damage_dealt # 假设 EffectContext 包含 damage_dealt

	var nearby_enemies = []
	# 遍历所有实体来查找附近的敌人
	# 这里需要一个全局的实体管理系统，或者通过 GameManager 来获取所有实体
	# 假设 GameManager 有一个方法来获取所有实体
	if game_manager and game_manager.has_method("get_all_entities"):
		for entity in game_manager.get_all_entities():
			if entity != context.target and entity.has_method("get_health_component") and entity.get_health_component() and entity.global_position.distance_to(original_target_pos) <= radius:
				# 简单的敌人检测，可以根据需要添加更多条件（如标签、阵营等）
				nearby_enemies.append(entity)

	# 根据距离排序并选取最近的 max_targets 个敌人
	nearby_enemies.sort_custom(func(a, b): return original_target_pos.distance_to(a.global_position) < original_target_pos.distance_to(b.global_position))

	var targets_to_chain = min(max_targets, nearby_enemies.size())
	for i in range(targets_to_chain):
		var chained_target = nearby_enemies[i]
		var chained_damage = current_damage * (1.0 - damage_falloff) # 伤害衰减

		# 对链式目标应用新的伤害效果
		var damage_effect = preload("res://lib/roguekit/entity/effects/damage_effect.gd").new()
		var chained_context = EffectContext.new(context.attacker, chained_target, context.ability_core)
		chained_context.damage_dealt = chained_damage # 传递衰减后的伤害
		damage_effect.execute(chained_context)