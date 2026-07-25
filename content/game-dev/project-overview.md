---
title: "Project_DND 项目总览"
description: "项目定位、技术选型、工程结构、Demo 设计与正式版规划 —— 一站式导航"
date: 2026-07-25T16:00:00+08:00
slug: "project-overview"
weight: -10
draft: false
tags:
  - 架构
  - 总览
  - 置顶
---

## 项目定位

基于 DND5e 规则的 3D 写实风格单人回合制战术游戏。

**目标：** Steam 新品节前推出可试玩 demo，展示核心玩法（战斗、角色、美术风格）。

## 技术栈

| 项目 | 选型 |
|---|---|
| 引擎 | Unreal Engine 5.6 |
| 编程 | C++ |
| 战斗框架 | GAS (Gameplay Ability System) |
| AI | Behavior Tree + AIController |
| 美术风格 | 2.5D 纸片人（Sprite-based） |
| 数据驱动 | DataTable + DataAsset |

---

## 文档导航

本总览是项目文档的**入口枢纽**。各模块详情见对应子文档：

| 文档 | 内容 | 状态 |
|---|---|---|
| [世界观设定：巨兽梦境与 2.5D 的本体论](https://innnnnk.github.io/game-dev/worldbuilding-foundation/) | 世界观内核、冰山叙事、庞加莱回归、NG+ 设计 | 已确定 |
| [真菌森林 · 展示场景设计](https://innnnnk.github.io/game-dev/fungal-forest-showcase/) | 六区珠串结构、Boss 四阶段、同伴系统、叙事滤镜、词汇敏感度矩阵 | 30 分钟版本设计完成 |
| [Demo 深潜版：60 分钟完整体验](https://innnnnk.github.io/game-dev/fungal-forest-demo/) | 回声裂隙 + 孢子平台支线、恢复内容、时间分配、开发顺序、风险应对 | 60 分钟版本设计完成 |
| [剧情设计追踪表](https://innnnnk.github.io/game-dev/narrative-design-tracker/) | CRPG 五模块全景表：地基/结构/人物/具体内容/体验设计 | 活文档，持续更新 |
| [觉醒共鸣系统 v2](https://innnnnk.github.io/game-dev/awakening-resonance-system-v2/) | 正式版核心机制：行为驱动的叙事引擎、含混请求、异常事件、同化度 | 正式版设计完成 |
| [GameDoc 开发资产](https://innnnnk.github.io/game-dev/) | AI 美术 Prompt 集、源脉文设计、版权规避指南 | 持续积累 |

---

## 已实现的系统

底层框架和数据层基本完成。以下系统已实现并可运行。

### ⚔ 网格战斗系统

- 20×20 格地图，支持自定义尺寸（TileSize/GirdWidth/GridHeight）
- A\* 寻路 + 移动消耗（普通 1 格 / 困难 2 格）
- Chebyshev 对角线距离计算（DND 规则）
- 单位格子缓存（O(1) 查询）
- Debug 网格可视化

### 🔄 回合制流程

- 三态状态机：自由探索 → 遭遇定格 → 回合制战斗
- D&D 先攻投掷（1d20 + 敏捷调整值）与排序
- 轮次计数器 + 死亡检测 + 自动结束战斗
- 回合切换事件广播（镜头跟随/UI更新）

### 🧬 GAS 属性与技能

- **完整六属性：** 力量/敏捷/体质/智力/感知/魅力（1–30 Clamp）
- **战斗属性：** HP、MaxHP、AC、AttackBonus、AttackRange
- **资源属性：** MaxMovement、CurrentMovement、MaxActionPoints、CurrentActionPoints
- **调整值计算：** Modifier = floor((值-10)/2)
- 近战攻击 Ability（GAS GameplayAbility）
- 伤害/初始化/行动点消耗 GameplayEffect
- 自定义 GameplayTags

### 🧠 AI 行为树

- `BTTask_AttackTarget` — 寻敌攻击
- `BTTask_MoveToTarget_Grid` — 格子寻路移动
- `BTTask_EndTurn` — 结束回合
- `BTTask_GetRandomLocation` — 随机目标点
- Blackboard 驱动 + 蓝图 BehaviorTree/Blackboard 资产

### 👤 角色系统

- `DND_CharacterBase` — GAS 集成 + 存档初始化 + 视觉组件
- 物理底座（BaseMesh）+ 血条 Widget（HealthWidgetComp）
- 纸片人渲染（VisualPivot + VisualMesh 驱动 4 方向 Sprite）
- `DND_UnitVisualComponent` — 视觉逻辑控制器
- 草地交互 MPC（Interaction + Wind）
- 布娃娃死亡（`EnableRagdoll`）

### 📊 D&D 数据层

**14 张 DataTable：**
`DT_RaceSheet` | `DT_ClassesSheet` | `DT_SubclassSheet` | `DT_SpellSheet` | `DT_SpellSlotSheet` | `DT_WeaponSheet` | `DT_ArmorSheet` | `DT_EquipmentSheet` | `DT_SkillSheet` | `DT_BackgroundSheet` | `DT_AlignmentSheet` | `DT_LevelProgSheet` | `DT_RaceTraitSheet` | `DT_ClassFeatureSheet`

**7 个 DataAsset 缓存：**
`DA_RaceData` | `DA_ClassesData` | `DA_ClassFeatureData` | `DA_BackgroundData` | `DA_AlignmentData` | `DA_SkillData` | `DA_PlayerCharacter_Default`

**3 个预制模板：**
`DA_Template_Elf_Rouge` | `DA_Template_Halforc_Barbarian` | `DA_Template_Human_Fighter`

### 👥 角色创建系统

- MVVM 架构 ViewModel（`DND_CharacterCreationViewModel`）
- 7 步流程：新角色 → 种族 → 背景 → 职业 → 阵营 → 属性（27 点购）→ 命名与技能选择
- 预制模板模式（锁定所有步骤，只读预览）
- 技能选择弹窗系统（`SkillSelector_Popup`）
- 实时预览（HP/AC/熟练加值/速度）
- 存档写入（FinalizeCharacterCreation）

### 🎨 美术资产

- **野蛮人/战士/游荡者** 各 4 状态网格体：Idle / Attack / Hit / Dead
- **场景装饰：** 草地 3 种、蘑菇 5 种
- **材质系统：** 角色材质 M_Chara + 12 个实例、草地/蘑菇材质、UI 材质（血条/阵营/便签）、后处理描边
- **纹理：** 角色 Sprite 贴图、法线贴图、噪声贴图
- **草地交互 Shader：** MPC_Interaction + MF_GrassInteraction
- **人面枯树桩** — 基础模型已完成（AI 建模），原型验证通过（yaw 轴注视跟踪）

### 🎮 操作交互

- 框选 / 点击选择（支持多选友军）
- 自由探索模式 NavMesh 移动
- 战斗模式路径显示
- 专用 CameraPawn（缩放 + 中键旋转）
- 回合切换镜头跟随
- 伤害数字/血条/死亡卡片场景 Widget

### 🌐 本地化

- 中英双语（zh-CN / en）
- 完整的 Localization 配置（Gather/Export/Import/Compile）
- 设置资源表（`ST_Character`、`ST_UIText`）

### 🔧 调试工具

- `DND_ClearCacheEditor` — 缓存清理
- `DND_DebugSaveFile` — 存档调试
- DebugStartCombat — 快速战斗测试

---

## 世界观内核

> 详见：[世界观设定：巨兽梦境与 2.5D 的本体论](https://innnnnk.github.io/game-dev/worldbuilding-foundation/)

**核心设定：** 世界是一头高维巨兽的梦。空间、时间、因果、生死——全是梦的规则。源脉矿石是巨兽凝固的血。

**2.5D 纸片人的本体论：** 不是美术妥协——而是"高维存在在三维空间的投影切面"。人类的认知窗口不足以解析全貌，只能看到"一帧"。

**三幕认知阶梯：**
- Act 1：正常的 DND 奇幻（埋种子）
- Act 2：世界是活体巨兽（体制困境）
- Act 3：万物同源（你就是梦的一部分）

**冰山原则：** 表面是派系斗争与矿石争夺。底层是"认知的代价"——你越靠近真相，你的身体越不像你自己。

---

## Demo：真菌森林展示场景

> 详见：[真菌森林展示场景](https://innnnnk.github.io/game-dev/fungal-forest-showcase/) | [60 分钟深潜版](https://innnnnk.github.io/game-dev/fungal-forest-demo/)

### 六区珠串结构

```
🌿入口 → 🍄走廊 → ⚔小战 → 🌑峡谷 → 👑BOSS → ✨结尾
 好奇     沉浸     紧张     压抑     高潮     释放
```

| 区域 | 功能 | 叙事承载 |
|---|---|---|
| A 入口 | 出生点、移动教学、任务交代 | 倒下的蘑菇：第一个"不对劲" |
| B 幽光走廊 | 营地探索、矿工日记、解救同伴 | 菌丝覆盖的身形、第一块铭牌 |
| C 腐木空地 | 小型遭遇（2 菌丝宿主 + 同伴并肩） | 人面树桩注视、战斗教学 |
| D 深菇峡谷 | 铭牌拾取、纹路异常、源脉矿石初现 | 菌丝嵌入岩壁、阴影消失 |
| E 巨菇王座 | Boss 四阶段战 | 菌丝网络节点、真相的核心 |
| F 孢子之径 | 委托交付、结尾演出 | "十二块铭牌，你明明只捡了十一块" |

### Boss 战四阶段

```
阶段一：并肩 — 玩家 + 矮人同伴 vs 真菌之主 + 2 小怪
阶段二：反水 — 同伴被感染，成为虚弱敌人
阶段三：释放 — 击败同伴触发的净化演出，玩家获得 buff
阶段四：收尾 — 玩家 + buff vs 残余 Boss
```

### 叙事滤镜

三种固定身份（调查员/矿工/精灵学者）共享同一关卡流程，仅在文本/对话上差异。工作量 ≈ ×1.3 而非 ×3。

### 矿工铭牌（13 块）

铭牌不是"收集品"——是"证据链"。11 块拾取 + 1 块 Boss 掉落（名字被刮掉）+ 1 块同伴脖子上（不可拾取）= 13。委托人说派了十二个人——多出来的是谁？

### 词汇敏感度矩阵

三层词汇管控。Demo 绝不出现 L3 词汇（源脉、巨兽、螺旋文明等）。所有代码注释、DataTable 行名、调试日志同样受约束。

---

## 60 分钟版本 vs 30 分钟版本

> 详见：[Demo 深潜版](https://innnnnk.github.io/game-dev/fungal-forest-demo/)

60 分钟版本 = 30 分钟主干 + 两条可选支线 + 恢复被砍内容。

| 差异 | 30 分钟版本 | 60 分钟版本 |
|---|---|---|
| 法师职业 | 暂锁 | 开放（2 戏法 + 1 法术/场战斗） |
| 同伴 AI 性格签名 | 默认台词 | 识别动画 + 条件台词分支 |
| Boss 战斗日志 | 3 条替换 | 5 条完整不可理解化 |
| 孢子云记忆文本 | 纯机制 | 3 段淡金色氛围文本 |
| 铭牌计数器视觉污染 | 去掉 | 抖动/淡紫/呼吸闪烁 |
| 支线1：回声裂隙 | 无 | 地下空间 + 精英战斗 + 矿工画板 |
| 支线2：孢子平台 | 无 | 冥想者 + 多周目元文本 + 可选 buff |

**目标发布策略：** 时间充裕直接做 60 分钟版；时间中等先发 30 分钟版上新品节，60 分钟版作为售前更新。

---

## 正式版规划

### 核心机制：觉醒共鸣系统 v2

> 详见：[觉醒共鸣系统 v2](https://innnnnk.github.io/game-dev/awakening-resonance-system-v2/)

**一句话：背包不是棋盘。你管理的不是最优解，是一群越来越吵的室友。**

核心设计原则：
- **不暴露数值** — 没有饥饿度/共鸣度 UI，玩家只通过行为观察
- **含混请求** — 物品不发布明确的任务，只用行为和暗示沟通
- **异常事件** — 替代数值阈值。玩家感知"越来越近了"但永远不知道"哪一次触发"
- **同化度** — 隐藏数值，暴露身体（底座阴影抖动、视野菌丝纹理、闪回）

Demo 中已埋下 5 颗种子：晶核脉动、铭牌计数器视觉污染、孢子平台感知 buff、同伴反水、不可理解化战斗日志。

### 源脉文字符系统

> 详见：`GameDoc/sanguin-script/sanguin-script-design.md`

原创文字系统，28 字符。设计理念：文字不是被发明出来的，而是从巨兽的梦中沉淀在矿石晶体中的天然刻痕。Demo 中的源脉矿石视觉锚点（岩壁嵌块、节点矿脉、晶核）是最小可行表现。

---

## Demo 开发待办

> 完整清单见 [真菌森林 Demo](https://innnnnk.github.io/game-dev/fungal-forest-demo/#demo-开发待办)，以下为优先级摘要。

### P0 — 没这个跑不起来

| # | 项目 |
|---|---|
| 1 | 真菌森林关卡（`FungalForest_Showcase.umap` 白盒） |
| 2 | 流程管理器（六区状态机） |
| 3 | Demo 快速选职业入口（战士/游荡者/法师） |
| 4 | 同伴系统（BT_CompanionBase + 状态机） |
| 5 | Boss 战四阶段 + 孢子云机制 |
| 6 | 菌丝宿主敌人 |
| 7 | 真菌之主 Boss |
| 8 | A 区异常蘑菇（世界观钩子） |
| 9 | 词汇敏感度矩阵全局替换 |

### P1 — 能跑但体验打折

| # | 项目 |
|---|---|
| 10 | 文本交互弹窗 |
| 11 | 极简背包 UI |
| 12 | 可拾取物系统（铭牌 + 晶核） |
| 13 | 检查点/重生 |
| 14 | B 区营救交互 |
| 15 | 简易演出系统 |
| 16 | 听觉反馈（9 条音频资产） |
| 17 | 同伴 AI 性格签名 |
| 18 | Boss 战斗日志不可理解化 |
| 19 | Boss 击败演出重构 |
| 20 | 铭牌计数器视觉污染 |
| 21 | D 区底座阴影随机抖动 |
| 22 | F 区结尾演出（黑屏 + 手写体文本） |
| 28 | 同伴死亡分支 |
| 30 | 返回已通过区域行为 |
| 33 | 人面树桩注视组件 |

### P2 — 锦上添花

| # | 项目 |
|---|---|
| 23 | 真菌森林环境资产（巨型蘑菇、倒木、岩石等） |
| 24 | 视觉异常效果（影子消失、纹路脉搏光、菌丝脉络） |
| 25 | Quick Start 画面 |
| 26 | Demo 结束画面 |
| 27 | 法师系统（60 分钟版） |
| 31 | 选职业界面说明文本 |
| 32 | 结束画面 Widget |

### 建议实现顺序

```
第0步：词汇敏感度矩阵全局替换
第1步：白盒关卡 + 流程管理器 + 快速选职业入口
第2步：A 区异常蘑菇 + 战斗教学孢子虫
第3步：敌人 + 同伴
第4步：交互系统
第5步：Boss 战机制 + 不可理解化 + 检查点
第6步：演出 + 声音
第7步：铭牌计数器 + D区阴影抖动 + F区结尾
第8步：环境资产 + 视觉异常 + 首尾画面
第9步：回声裂隙支线
第10步：孢子平台支线
```

---

## 完整工程目录结构

```
Project_DND/
│
├── Config/                          # 引擎配置
│   ├── DefaultEditor.ini
│   ├── DefaultEngine.ini
│   ├── DefaultGame.ini
│   ├── DefaultInput.ini
│   ├── Localization/               # 本地化编译配置
│   └── Tags/
│       └── DND_GASData.ini         # GAS 标签定义
│
├── Content/                         # 游戏资产
│   ├── AI/                          # AI 行为资产
│   │   ├── BB_EnemyBase.uasset
│   │   └── BT_EnemyBase.uasset
│   │
│   ├── Blueprints/                  # 蓝图
│   │   ├── BP_DNDCameraPawn.uasset
│   │   ├── BP_DNDGameModeBase.uasset
│   │   ├── BP_DNDHUD.uasset
│   │   ├── BP_DNDPlayerController.uasset
│   │   ├── AI/
│   │   │   └── BP_DND_AIController.uasset
│   │   ├── Character/
│   │   │   ├── BP_DND_CharacterBase.uasset
│   │   │   └── BP_DND_EnemyBase.uasset
│   │   ├── Combat/
│   │   │   ├── BP_CombatManager.uasset
│   │   │   ├── BP_EnconterTrigger.uasset
│   │   │   └── BP_GridManager.uasset
│   │   ├── Environment/
│   │   │   └── BP_GrassInteraction.uasset
│   │   ├── GAS/
│   │   │   ├── BP_GA_MeleeAttack.uasset
│   │   │   ├── BP_GE_ActionCost.uasset
│   │   │   └── BP_GE_Damage.uasset
│   │   ├── UI/
│   │   │   ├── CharacterCreation/   # 角色创建 UI（7 步流程）
│   │   │   ├── CommonComps/         # 通用组件
│   │   │   └── SceneWidgets/        # 场景 Widget（伤害/血条/死亡卡）
│   │   └── Utility/
│   │       └── BP_TexToModelBaker.uasset
│   │
│   ├── Data/                        # 数据驱动资产
│   │   ├── DataAsset/               # 运行时缓存（7 个）
│   │   ├── DataTable/               # 数据表（14 张）
│   │   └── Template/                # 预制角色模板（3 个）
│   │
│   ├── FX/                          # 特效（待完善）
│   │
│   ├── Localization/Game/           # 本地化资源（zh-CN / en）
│   │
│   ├── Maps/                        # 关卡
│   │   ├── Forest_Map.umap
│   │   ├── MainMap.umap
│   │   └── TestUI.umap
│   │
│   ├── Material/                    # 材质系统
│   │   ├── Characters/              #   角色材质 + 12 实例
│   │   ├── Foliage/                 #   植被材质
│   │   ├── Landscape/               #   地形材质
│   │   ├── MPC/                     #   材质参数集（风 + 草地交互）
│   │   ├── MaterialFunction/        #   材质函数
│   │   ├── PostProcess/             #   后处理（描边）
│   │   └── UI/                      #   UI 材质
│   │
│   ├── Mesh/                        # 网格体
│   │   ├── Characters/              #   角色纸片人（3 种 × 4 状态）
│   │   ├── Combat/                  #   伤害标记 + 死亡卡
│   │   ├── Components/              #   物理底座
│   │   └── Foliage/                 #   植被（草地 + 蘑菇）
│   │
│   ├── Settings/Localization/       # 本地化设置表
│   │
│   └── Texture/                     # 贴图
│       ├── Foliage/
│       └── ForTest/
│
├── Source/                          # C++ 源码
│   └── Project_DND/
│       ├── AI/                      # AIController + 4 个 BT Task
│       ├── Character/               # CharacterBase + UnitVisualComponent
│       ├── Combat/                  # GridManager, CombatManager, CombatRules, GridMovement
│       ├── Common/                  # 蓝图函数库
│       ├── Data/                    # 数据定义（13 个 DataAsset 类 + 枚举 + 结构体）
│       ├── Debug/                   # 缓存清理 + 存档调试
│       ├── GAS/                     # AttributeSet, GameplayTags, Ability, Effects
│       ├── Interface/               # CharacterStats + TurnBasedUnit
│       ├── SaveSystem/              # 存档系统
│       ├── Settings/                # 本地化设置
│       ├── UI/                      # ViewModel + DamageVisual + DeathVisual + WorldInfo
│       ├── Utility/                 # 骰子系统
│       ├── DND_CameraPawn.{h,cpp}
│       ├── DND_GameModeBase.{h,cpp}
│       ├── DND_HUD.{h,cpp}
│       └── DND_PlayerController.{h,cpp}
│
├── Project_DND.sln
├── Project_DND.uproject
└── Binaries/ & Intermediate/ & Saved/ & DerivedDataCache/   # 生成文件
```

---

## GameDoc 资产库

项目辅助资产和工具文档，与引擎工程分离管理：

| 路径 | 说明 |
|---|---|
| `comfyui-asset-design-prompts.md` | AI 图生 3D 资产设计 Prompt 集（Krea2 写实风） |
| `comfyui-concept-art-prompts.md` | AI 概念图 Prompt 集（手绘/氛围风） |
| `comfyui-map-prompts.md` | AI 俯视图/地图 Prompt 集 |
| `sanguin-script/` | 源脉文字符系统（28 字符 + SVG 矢量预览 + 字体生成指南） |
| `DND 5E 游戏版权规避指南.md` | 版权清洗清单 |
| `fungal-forest-demo.md` | 本地 Demo 设计缓存 |

---

## 当前阶段

**底层框架和数据层基本完成。** 当前核心任务：

> **搭建真菌森林展示场景** — 把现有系统串成一条完整的可体验流程：
> `角色创建 → 进入关卡 → 自由探索 → 遇敌触发 → 回合制战斗 → 胜利/失败 → 结尾演出`

第一个里程碑：30 分钟 Demo（A→F 主干跑通）→ Steam 新品节发布。

---

*最后更新：2026-07-25*
