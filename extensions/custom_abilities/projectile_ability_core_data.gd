class_name ProjectileAbilityCoreData
extends AbilityCoreData

enum ProjectileType {
    GENERIC,
    FIREBALL,
    ICE_SHARD,
    LIGHTNING_BOLT
}

@export_group("Projectile Specifics")
@export var projectile_type: ProjectileType = ProjectileType.GENERIC
@export var base_damage: float = 10.0
@export var base_speed: float = 300.0
@export var vfx_scene: PackedScene # 投射物视觉效果场景

# 可以添加其他投射物特有的属性，例如：
func get_calculated_damage(stats_component: StatsComponent) -> float:
	return base_damage * stats_component.get_stat_value("damage_multiplier")

func get_calculated_speed(stats_component: StatsComponent) -> float:
	return base_speed * stats_component.get_stat_value("speed_multiplier") # 假设有 speed_multiplier 属性

func get_calculated_projectile_count(stats_component: StatsComponent) -> int:
	return int(stats_component.get_stat_value("projectile_count")) # Cast to int for count