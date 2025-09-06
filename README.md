# 项目：RogueKit 高级演示模板 (RogueKit Advanced Showcase)

## 1. 项目定位与设计哲学

欢迎使用 `RogueKit` 高级演示项目。本项目的首要目标是展示如何在一个接近真实开发环境的项目中，利用 `RogueKit` 库的全部潜力来构建一个复杂的 Roguelike 游戏。

本项目严格遵循 `RogueKit` 的核心设计哲学：

  * **组合优于继承**：游戏实体（如玩家和敌人）是通过“组装”功能组件（如 `HealthComponent`、`InventoryComponent`）来构建的，而不是通过创建复杂的继承树。这提供了极高的灵活性。
  * **数据驱动设计**：游戏的大部分内容——包括角色属性、物品效果、敌人配置和关卡布局——都是通过 Godot 的 `Resource`（资源文件，`.tres`）来定义的，而非硬编码在脚本中。这使得游戏设计师可以不接触代码就能调整游戏平衡和添加新内容。
  * **清晰的扩展边界**：`RogueKit` 提供了一套稳固的基础类。当需要实现独特的游戏机制时，您应该通过继承这些基础类来扩展功能，而不是修改库的源代码。

## 2. 核心特性一览

本示例项目演示了以下关键功能的集成与应用：

  * **模块化实体系统**：展示如何配置 `EntityData` 资源，并将其应用于包含标准 `RogueKit` 组件（如 `StatsComponent` 和 `HealthComponent`）的实体场景上。
  * **多层级物品系统**：演示如何定义消耗品（`ConsumableData`）和装备（`EquipmentData`），并通过 `StatModifier` 资源实现属性变更。
  * **链式地图生成**：通过 `MapGenerationProfile` 配置一个多阶段的生成流程，例如，先运行 `BSPTreePass` 创建房间结构，再运行 `CellularAutomataPass` 生成自然的洞穴连接。
  * **数据驱动的 AI**：使用 `AIBehaviorProfile` 资源，在 Godot 编辑器中可视化地组合行为树节点，为不同类型的敌人配置截然不同的战斗逻辑。
  * **战利品管理**：配置 `LootTable` 资源来定义敌人的掉落物及其概率，并通过 `LootDropComponent` 将其与实体关联。
  * **扩展性演示**：包含自定义脚本示例，展示如何通过继承 `GenerationPass` 或 `EffectData` 来实现项目中特有的游戏逻辑。

## 3. 安装与环境设置

**依赖项**：Godot Engine (版本与 `RogueKit` 库兼容)

### Git Submodule 安装

本项目使用 Git Submodule 来管理 `RogueKit` 库的依赖。

1.  **克隆仓库（推荐方式）**：
    使用 `--recurse-submodules` 标志来确保在克隆主项目的同时自动初始化并拉取 `RogueKit` 子模块。

    ```bash
    git clone --recurse-submodules [repository_url]
    ```

2.  **针对已克隆的项目**：
    如果项目已经克隆，但 `RogueKit` 目录为空，请运行以下命令来初始化并拉取子模块：

    ```bash
    git submodule update --init --recursive
    ```

### Godot 引擎设置

1.  **导入项目**：打开 Godot 引擎，使用项目管理器的“导入”功能，选择本项目的 `project.godot` 文件。
2.  **检查 Autoloads**：为确保 `RogueKit` 的核心系统（如 `TurnManager`、`GameManager`）能够正常工作，请检查 `项目 -> 项目设置 -> Autoload`。本示例应已预先配置好所有必需的全局单例。

## 4. 核心工作流：数据驱动的内容创作

本节将详细介绍使用 `RogueKit` 创建游戏内容的核心流程。重点在于理解数据资源、组件和场景之间的关系。

### 4.1. 实体蓝图：创建模块化角色

**目标**：创建一个新的敌人类型，例如“哥布林斥候”。

1.  **数据层（定义属性）**：

      * 在文件系统中创建 `EntityData` 类型的资源文件（例如 `goblin_scout_data.tres`）。
      * 在 Godot 检查器中配置此资源：设置基础生命值、属性字典（如力量、敏捷、速度） 以及其他元数据。这是实体的“灵魂”。

2.  **组件层（组装场景）**：

      * 创建一个新的 Godot 场景（例如 `goblin_scout.tscn`）。
      * 将 `RogueKit` 提供的标准组件场景作为子节点添加到此场景中。对于一个可战斗的 AI，通常需要：
          * `HealthComponent`：处理伤害和死亡。
          * `StatsComponent`：管理所有可变的数值属性。
          * `AIComponent` 或更高级的行为树执行组件：驱动决策。
          * `LootDropComponent`：管理死亡后的掉落物。

3.  **链接（数据与场景结合）**：

      * 选中 `goblin_scout.tscn` 的根节点。
      * 将第一步创建的 `goblin_scout_data.tres` 资源拖拽到根节点脚本暴露的 `entity_data` 导出变量上。
      * 在游戏运行时，根实体脚本会自动将数据分发给各个子组件进行初始化。

### 4.2. 物品与掉落：定义数据并配置概率

**目标**：创建一个治疗药水，并让敌人有概率掉落它。

1.  **定义物品效果**：创建 `EffectData` 类型的资源，用于封装具体的效果逻辑（例如“恢复生命值”）。对于简单属性修改，可使用 `StatModifier` 资源。

2.  **定义物品本身**：

      * 创建 `ConsumableData` 类型的资源文件（例如 `potion_health.tres`）。
      * 配置其基础属性（名称、图标、堆叠上限）。
      * 将其 `effects` 数组指向第一步中创建的效果资源。

3.  **配置掉落表**：

      * 创建 `LootTable` 类型的资源文件（例如 `dungeon_common_loot.tres`）。
      * 在掉落表条目中添加 `potion_health.tres`，并设置其生成权重和数量范围。

4.  **关联敌人**：在“哥布林斥候”的场景中，找到 `LootDropComponent` 组件，并将其 `loot_table` 属性设置为 `dungeon_common_loot.tres`。

### 4.3. 关卡生成：算法的组合与配置

**目标**：创建一个由“房间和走廊”构成，但部分区域为“自然洞穴”的复杂地牢。

1.  **理解策略模式**：`RogueKit` 使用策略模式进行地图生成。每个生成算法都被封装在一个继承自 `GenerationPass` 的资源中。

2.  **创建生成配置文件**：创建 `MapGenerationProfile` 类型的资源文件（例如 `mixed_dungeon_profile.tres`）。

3.  **配置生成通道（链式执行）**：在 `MapGenerationProfile` 的 `generation_passes` 数组中按顺序添加算法资源：

      * **通道 1 (BSP Tree)**：添加一个 `BSPTreePass` 实例。配置其参数（如最小房间尺寸）来生成地牢的基础房间布局。`MapData` 现在包含了这些房间信息。
      * **通道 2 (Corridor Connector)**：添加一个用于连接房间的通道实例（可能是自定义通道）。它会读取通道 1 生成的房间数据，并在它们之间挖掘走廊。
      * **通道 3 (Cellular Automata)**：添加一个 `CellularAutomataPass` 实例。配置它在地图的特定区域（或全局）运行，以平滑墙壁或创造自然的洞穴外观，从而修改前两个通道的结果。

4.  **执行生成**：在游戏启动时，调用 `MapGenerator` 并传入 `mixed_dungeon_profile.tres`。生成器将严格按照数组顺序执行所有通道。

### 4.4. AI 配置：构建可复用的行为逻辑

**目标**：配置一个“胆怯”的敌人 AI，它会在低生命值时逃跑，否则会接近并攻击玩家。

1.  **理解行为树**：AI 逻辑通过行为树（Behavior Tree）定义。`AIBehaviorProfile` 资源是行为树的根。
2.  **配置行为蓝图**：在 Godot 编辑器中打开 `AIBehaviorProfile` 资源。
3.  **可视化组装**：通过组合 `RogueKit` 提供的标准行为树节点（如 `Sequence`, `Selector`, `Inverter`）来构建逻辑流程。例如：
      * **根节点 (Selector)**：尝试按顺序执行子节点，直到一个成功。
          * **子节点 1 (Sequence - 逃跑)**：
              * **条件**：检查“自身生命值是否低于 30%”（可能需要自定义条件节点，见下文）。
              * **动作**：执行“朝远离玩家的方向移动”动作。
          * **子节点 2 (Sequence - 攻击)**：
              * **条件**：检查“玩家是否在视野内”。
              * **动作**：执行“朝向玩家移动”或“攻击玩家”动作。

## 5. 高级扩展模式：超越基础配置

当标准组件无法满足特定需求时，您可以通过继承 `RogueKit` 的基类来创建自定义逻辑。这是推荐的扩展方式，因为它不会破坏库的封装性。

### 5.1. 模式一：创建自定义游戏效果

**场景**：您需要一个“吸血”效果，在造成伤害时按比例回复攻击者的生命值。内置的 `StatModifier` 无法处理这种情景交互。

**工作流**：

1.  **创建新脚本**：创建一个新脚本文件（例如 `effect_lifesteal.gd`），使其继承自 `RogueKit` 的 `EffectData` 基类。
2.  **实现逻辑**：重写 `execute(target)` 方法。在此方法中，编写逻辑以获取伤害事件的上下文（可能需要通过信号总线 或行动系统 传递），计算吸血量，并对攻击者应用治疗。
3.  **配置使用**：在 Godot 编辑器中创建该新脚本的资源实例（`.tres` 文件）。现在，您可以像使用任何标准效果一样，将这个“吸血效果”资源添加到武器或技能的 `effects` 数组中。

### 5.2. 模式二：设计自定义地图生成通道

**场景**：您需要一个特殊的生成通道来在地图上放置河流，`RogueKit` 没有提供此算法。

**工作流**：

1.  **创建新脚本**：创建一个新脚本文件（例如 `river_generation_pass.gd`），使其继承自 `GenerationPass` 基类。
2.  **实现逻辑**：重写 `generate(map_data)` 方法。在此方法中，实现您的河流生成算法（例如使用随机游走算法），修改传入的 `MapData` 对象，将对应坐标的瓦片类型设置为 `FLOOR`。
3.  **配置使用**：创建该脚本的资源实例后，将其拖拽到 `MapGenerationProfile` 的通道数组中，与其他生成通道（如 `BSPTreePass`）组合使用。

### 5.3. 模式三：扩展 AI 行为树节点

**场景**：AI 需要一个新的决策条件：“检查 3 格范围内是否有盟友”。

**工作流**：

1.  **创建新脚本**：创建一个新脚本文件（例如 `condition_check_nearby_allies.gd`），使其继承自 `BehaviorNode` 基类。
2.  **实现逻辑**：重写 `tick()` 方法。编写逻辑来扫描周围区域，检查是否存在其他“盟友”标签的实体。根据检查结果返回 `Status.SUCCESS` 或 `Status.FAILURE`。
3.  **配置使用**：在 Godot 编辑器中，这个新创建的条件节点现在可以作为构建块，在 `AIBehaviorProfile` 中与其他节点一起组装，以创建更复杂的 AI 逻辑。

## 6. 推荐的项目结构

为了保持清晰和可维护性，建议采用以下目录结构来分离库代码、项目内容和自定义扩展：

```plaintext
godot-project-root/
│
├── lib/
│   └── roguekit/               # RogueKit 库 (Git Submodule)，不应修改内部文件。
│
├── content/                    # 游戏内容配置层 (主要存放 .tres 资源)
│   ├── entities/               # 角色数据 (EntityData) 和 AI 配置 (AIBehaviorProfile)
│   ├── items/                  # 物品数据 (ConsumableData, EquipmentData)
│   ├── generation/             # 关卡配置 (MapGenerationProfile) 和掉落表 (LootTable)
│   └── ...
│
├── prefabs/                    # 游戏场景预制件 (主要存放 .tscn 文件)
│   ├── entities/               # 玩家和敌人的场景文件
│   ├── items/                  # 物品在地面上显示的场景
│   └── vfx/                    # 视觉效果场景
│
├── extensions/                 # 自定义逻辑层 (主要存放 .gd 脚本)
│   ├── custom_effects/         # 继承自 EffectData 的脚本
│   ├── custom_gen_passes/      # 继承自 GenerationPass 的脚本
│   └── custom_ai_nodes/        # 继承自 BehaviorNode 的脚本
│
├── systems/                    # 项目特定的管理器脚本 (例如游戏主循环、UI管理器)
└── project.godot
```