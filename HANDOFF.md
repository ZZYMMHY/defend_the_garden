# Defend the Garden 项目交接

更新时间：2026-07-29
写给：完全没有前文上下文的新 Codex 会话

## 1. 项目现状

这是一个固定斜俯视角、3D 玩法与 2.5D 美术混合呈现的动作肉鸽花园防守游戏，项目名仍为 `Garden Nightwatch`。当前已完成：

1. 第一版三波可玩闭环。
2. Lanternroot（灯根花园）原创视觉方向及严格设计稿资源替换。
3. 设计稿同构环境底图、五个透明主体精灵和正式 Seedlight VFX。
4. 玩法与视觉分离的 `PackedScene` 注入接口。
5. 27 项玩法测试、22 项视觉测试和 48 项正式资源契约测试。
6. 1280×720 同机位 GUI 实机截图逐项校准。

Lanternroot 是当前美术方向代号，不等同于最终游戏名。当前世界观是一座漂浮在暮色中的手作花园模型：灯根守望者使用会发光的种子器械保护心灯花，对抗由枯根、裂荚和破陶壳形成的腐化园灵。

项目已经不再使用程序化低模作为默认画面。当前默认是固定镜头 2.5D 混合方案：高精度环境底图和透明主体精灵负责画面，原有 3D 节点继续负责移动、碰撞、伤害和波次。程序化低模仅作为资源缺失时的 fallback。

## 2. 当前工作区

- 项目根目录：`/Users/joezhu/Apps/defend_the_garden`
- Godot：`/opt/homebrew/bin/godot`
- Godot 版本：`4.7.1.stable.official.a13da4feb`
- 主场景：`res://scenes/game/main.tscn`
- 当前分支：`main`
- 远端：`https://github.com/ZZYMMHY/defend_the_garden.git`
- 当前基础提交：`3fbafd28b0ac4548765643a004d0eb42ea77e5df`
- 美术规范：`docs/art_direction/ART_DIRECTION.md`
- 视觉参考：
  - `docs/art_direction/lanternroot-gameplay-keyframe.png`
  - `docs/art_direction/lanternroot-asset-lineup.png`
- 当前严格对照实机图：
  - `docs/art_direction/lanternroot-runtime-strict.png`

Lanternroot 视觉切片当前是工作区改动，本轮没有提交。新会话开始时必须先运行 `git status -sb`，不要假定这些改动已经推送。

`.gitignore` 已排除 `.godot/`、`.DS_Store`、`captures/` 和 `builds/`。不要提交 `/private/tmp` 日志、临时截图、Godot 缓存或本地导出包。

## 3. 原创术语映射

| 旧原型或内部兼容语义 | 当前世界观与 UI 语义 | 视觉识别 |
|---|---|---|
| Dave / 玩家 | 灯根守望者 Lantern Keeper | 靛蓝斗篷与兜帽、陶瓷面具、暖色灯罐背包 |
| 豌豆发射器 | 种铸器 Seed Caster | 苔绿与黄铜短发射器、琥珀种子腔 |
| 花园核心 | 心灯花 Heartbloom | 多层奶油色花瓣、中心琥珀灯心 |
| Walker | 枯根行者 Root Drifter | 低重心木壳、粗短根肢 |
| Runner | 裂荚虫 Pod Skitter | 高腿、窄体、裂荚孔洞与腐化紫 |
| Bruiser | 陶壳巨灵 Clay Bulwark | 宽肩、大陶壳、粗手臂与藤刺 |
| 豌豆弹 | 种光弹 Seedlight Bolt | 琥珀种核、发光材质、无逐弹实时灯 |
| 阳光 | 辉种 Glowseed | 小型生命种子语义，不使用太阳图形 |
| 僵尸群 | 枯潮园灵 / Rootlings | 非人形腐化园灵，不使用传统僵尸造型 |

`DavePlayer`、`walker`、`runner`、`bruiser`、`sunlight` 等仍存在于内部代码和旧玩法测试中。这是为保持接口、存量逻辑和回归测试稳定，不代表玩家可见命名。若将来迁移内部标识，应作为独立重构完成，并同时更新全部测试。

## 4. 已完成的玩法

- 固定斜俯视正交镜头。
- 四入口小型浮岛花园。
- `WASD` / 方向键移动。
- 鼠标瞄准和左键连续射击。
- `Space` / `Shift` 种光冲刺。
- 玩家和心灯花生命、受击、死亡与失败流程。
- 三种敌人行为：
  - Root Drifter：通常优先攻击心灯花。
  - Pod Skitter：速度最快，优先追击守望者。
  - Clay Bulwark：生命与攻击最高，移动最慢。
- 三波共 26 个敌人。
- 击败敌人获得 Glowseed。
- 清空三波、停止战斗、胜利提示和 `R` 重开。
- 开场说明消失后才启动第一波。

现阶段玩法数值与碰撞逻辑仍沿用首个可玩版本；本轮视觉替换没有改变移动速度、射速、伤害、生命、敌人强弱关系或波次数量。

## 5. 已完成的严格设计稿实现

- `garden-clean-plate.png` 保留设计稿的岛屿轮廓、四座基数方向桥梁、瀑布、悬崖、植被、盆栽和冷暖光层次。
- 灯根守望者、Heartbloom、Root Drifter、Pod Skitter 和 Clay Bulwark 已替换为独立透明高精度资源。
- 五个主体全部使用正式 `PackedScene`，并暴露朝向、受击、攻击、开火或生命状态接口。
- Seedlight Bolt 使用琥珀种核、亮芯和短拖尾；命中使用花瓣爆点、扩散环与火花。
- 正交镜头完全固定，不再跟随玩家；底图与世界坐标按 1280×720 机位标定。
- 敌人入口已从四角改为北、东、南、西四个方向，匹配设计稿桥梁。
- 底图已关闭额外运行时雾化，避免二次漂白设计稿颜色。
- 程序化场景、角色和敌人仍存在，但默认路径不会进入它们。
- 正常游戏保留 HUD；严格美术对照截图隐藏 HUD，因为现有设计稿本身没有 HUD 成稿。

`docs/art_direction/lanternroot-runtime-strict.png` 是当前验收基准。它确认了岛屿占屏、主体比例、Heartbloom 焦点、三类敌人落点和 Seedlight 交战构图。截图验收不代替后续手感、难度和长时间性能测试。

## 6. 视觉资源注入架构

`scripts/game/game.gd` 暴露七个可选 `PackedScene`：

```text
player_visual_scene
projectile_visual_scene
garden_core_visual_scene
arena_visual_scene
drifter_visual_scene
skitter_visual_scene
bulwark_visual_scene
```

装配关系：

- `player_visual_scene` 注入灯根守望者视觉。
- `projectile_visual_scene` 经玩家传递给每个 Seedlight Bolt。
- `garden_core_visual_scene` 注入 Heartbloom。
- `arena_visual_scene` 替换程序化场景美术，但仍保留场地碰撞。
- 三个敌人资源按内部 kind 映射到 Drifter、Skitter、Bulwark。

玩家、Heartbloom、三类敌人和 Seedlight Bolt 当前均有默认正式资源。没有指定资源时，逻辑脚本才构建程序化 Lanternroot fallback。替换资源时必须遵守：

- 不修改现有碰撞体和战斗数值。
- Godot 正面朝向为 `-Z`。
- 视觉根节点必须使用 `Node3D`；无效根节点会警告并回退到程序化视觉。
- 注入资源必须是纯视觉资源，不携带 `CollisionObject3D`；逻辑脚本继续拥有唯一碰撞权。
- 场景美术需匹配固定的 `24×18` 可行走碰撞范围和现有坐标 clamp。
- 普通投射物使用 Emission 或粒子，不要恢复逐弹实时灯光。
- 保留测试使用的视觉根节点和关键挂点，或同步更新视觉契约测试。

环境不是通过 `arena_visual_scene` 注入，而是由 `use_design_reference_plate` 默认开启并挂到固定相机后方。场地仍保留独立不可见的 `24×18` 碰撞。该方案只支持当前锁定机位；自由镜头需要新的完整 3D 场景资源。

## 7. 代码结构

- `project.godot`
  - 项目配置、主场景、1280×720 视口和 GL Compatibility 渲染路径。
- `scenes/game/main.tscn`
  - 轻量入口场景，主体由脚本装配。
- `scripts/core/lanternroot_palette.gd`
  - Lanternroot 八色统一色板。
- `scripts/core/visual_factory.gd`
  - 材质、基础几何、锥台和圆角岛体 helper。
- `scripts/game/game.gd`
  - 环境、场景装配、视觉注入、角色连接与胜负闭环。
- `scripts/game/wave_director.gd`
  - 三波敌人配置、倒计时、生成和波次状态。
- `scripts/game/camera_follow.gd`
  - 锁定斜俯视正交镜头和设计稿环境底图。
- `scripts/player/player.gd`
  - 玩家移动、瞄准、射击、冲刺、生命和守望者视觉。
- `scripts/entities/projectile.gd`
  - Seedlight Bolt 移动、碰撞、伤害和视觉。
- `scripts/entities/zombie.gd`
  - 三种敌人的数值、行为、视觉注入和 fallback。
- `scripts/entities/garden_core.gd`
  - Heartbloom 生命、受击、视觉注入和 fallback。
- `scripts/ui/hud.gd`
  - HUD、开场节奏、状态和三种结果界面。
- `tests/smoke_test.gd`
  - 27 项玩法结构与关键数值测试。
- `tests/visual_smoke_test.gd`
  - 22 项 Lanternroot 视觉契约测试。
- `tests/art_scene_contract_test.gd`
  - 48 项正式视觉默认绑定、无碰撞、无逐弹灯和固定相机契约测试。
- `tests/capture_frame.gd`
  - GUI/可渲染环境中的画面截图辅助脚本。
- `docs/art_direction/ART_DIRECTION.md`
  - 世界观、术语、色板、形状、材质、镜头和资源规范。

## 8. 运行

GUI 运行：

```bash
/opt/homebrew/bin/godot \
  --path "/Users/joezhu/Apps/defend_the_garden"
```

新 clone 或 `.godot/` 不存在时，先生成导入和全局类缓存：

```bash
/opt/homebrew/bin/godot \
  --headless \
  --log-file /private/tmp/defend_the_garden_import.log \
  --path "/Users/joezhu/Apps/defend_the_garden" \
  --import
```

不要仅凭 Godot 进程存在就声称 GUI 正常；视觉验收需要实际窗口或可渲染截图。

## 9. 自动验证

### 玩法测试

```bash
/opt/homebrew/bin/godot \
  --display-driver headless \
  --rendering-driver dummy \
  --log-file /private/tmp/defend_the_garden_smoke.log \
  --path "/Users/joezhu/Apps/defend_the_garden" \
  --script res://tests/smoke_test.gd
```

成功标准：

```text
SMOKE TEST RESULT: 27 checks passed
```

覆盖主场景装配、初始生命、三波 26 敌人、输入注册、伤害与恢复、三类敌人数值关系、投射物伤害、击杀奖励和胜利停止控制。

### 视觉测试

```bash
/opt/homebrew/bin/godot \
  --display-driver headless \
  --rendering-driver dummy \
  --log-file /private/tmp/defend_the_garden_visual_smoke.log \
  --path "/Users/joezhu/Apps/defend_the_garden" \
  --script res://tests/visual_smoke_test.gd
```

成功标准：

```text
VISUAL SMOKE TEST RESULT: 22 checks passed
```

覆盖 Lantern Keeper 与 Seed Caster、Heartbloom 灯心及低血量状态、Deep Dusk 环境、三类敌人视觉身份、Seedlight Bolt、逐弹零实时灯、Glowseed / Rootlings HUD 术语、开场位置和两种失败语义。

### 正式美术资源契约测试

```bash
/opt/homebrew/bin/godot \
  --display-driver headless \
  --rendering-driver dummy \
  --log-file /private/tmp/defend_the_garden_art_contract.log \
  --path "/Users/joezhu/Apps/defend_the_garden" \
  --script res://tests/art_scene_contract_test.gd
```

成功标准：

```text
ART SCENE CONTRACT TEST RESULT: 48 checks passed
```

覆盖六个默认正式视觉绑定、运行时注入链路、纯视觉场景无碰撞、Seedlight 无逐弹灯，以及相机不随玩家移动。

当前验证结果：

```text
SMOKE TEST RESULT: 27 checks passed
VISUAL SMOKE TEST RESULT: 22 checks passed
ART SCENE CONTRACT TEST RESULT: 48 checks passed
```

三条命令均以退出码 `0` 完成。macOS 沙箱中的 CoreAudio、dummy audio 和系统 CA 证书消息属于已知环境警告；不能只看警告或部分 PASS，必须同时确认退出码和最终结果。

## 10. 当前下一步：方向动作与命中体积对齐

严格设计稿替换后，UI、镜头和总体构图已经接近目标，但新主体精灵的尺寸、朝向和动作没有同步进入原有灰盒逻辑。当前问题不是单个参数错误，而是“视觉资源、角色状态和物理判定”三套系统仍未完成对齐。

本节是下一阶段实施计划；本次只记录分析和计划，没有修改游戏代码。

### 10.1 已确认的根因

1. **逻辑瞄准是 360°，角色表现仍只有左右翻转。**
   - `player.gd` 已计算完整的世界空间瞄准方向。
   - `lanternroot_sprite_visual.gd` 只接收水平分量并执行 `flip_h`。
   - 守望者的身体、手臂和 Seed Caster 烘焙在同一张图中，因此枪口不能独立跟随瞄准角度，也没有前后方向的正确遮挡关系。
   - 场景中虽有 `Muzzle`，当前子弹仍通过角色中心加固定偏移生成，没有真正从方向对应的枪口发射。

2. **主体只有静态立绘，没有方向动作状态。**
   - 守望者和三类敌人当前均是单张 `Sprite3D` 立绘，没有八方向 idle、move、fire / attack、hit 和 death 帧。
   - 敌人移动使用统一的程序化上下浮动，即使接近静止也会继续摆动，不能表达三类敌人不同的重量和步态。
   - 敌人伤害在攻击逻辑开始时立刻结算，而不是在动作接触帧结算；受击、攻击和死亡效果也缺少统一的状态优先级与取消规则。

3. **美术放大了，伤害判定仍沿用灰盒尺寸。**
   - 当前胶囊适合承担寻路和移动阻挡，但明显小于新精灵的可见轮廓。
   - 投射物碰撞球直径约 `0.40`，也小于约 `0.82` 的发光主体。
   - 攻击距离、敌群分离距离和攻击原点仍按旧模型的中心距离计算，导致“画面已经碰到但逻辑尚未命中”以及大体型敌人互相穿叠。

当前可见宽度与移动碰撞宽度的对比：

| 主体 | 可见宽度（世界单位） | 移动碰撞宽度 | 碰撞占可见宽度 |
|---|---:|---:|---:|
| Lantern Keeper | 3.41 | 0.84 | 24.6% |
| Root Drifter | 5.09 | 0.86 | 16.9% |
| Pod Skitter | 3.10 | 0.86 | 27.7% |
| Clay Bulwark | 5.38 | 1.16 | 21.6% |

这些数值说明移动胶囊不能直接兼任伤害判定。不要简单把移动胶囊放大到整张图，否则角色会在桥梁、敌群和场地边缘频繁卡住。

### 10.2 阶段 A：拆分移动碰撞与伤害 Hurtbox

1. 保留现有 `CharacterBody3D` 胶囊作为移动、寻路和实体阻挡，不先改变已验证的移动手感。
2. 为玩家和三类敌人增加独立 `DamageHurtbox`（`Area3D`），放在专用物理层。
3. Hurtbox 使用一个或多个简单形状贴合主体可受击轮廓；Clay Bulwark 等宽体型优先使用复合形状，不用整张透明画布的矩形。
4. 投射物同时支持 `area_entered` 命中并经过统一命中入口，保证一颗普通 Seedlight Bolt 最多结算一次伤害。
5. 投射物碰撞半径先由 `0.20` 调整到约 `0.30` 作为起点，再用调试轮廓和实机截图校准，不直接按发光边缘做满尺寸碰撞。
6. 玩家、三类敌人的移动胶囊、伤害 Hurtbox 和攻击范围分别可视化，避免今后换图时再次把三种语义混在一起。

### 10.3 阶段 B：建立八方向美术资源合同

第一批先制作守望者与三类敌人的八方向静态帧，共 `4 × 8 = 32` 张：

```text
N / NE / E / SE / S / SW / W / NW
```

资源必须满足：

- 同一角色的画布尺寸、脚底锚点、地面接触点、比例和光源方向一致。
- 八个方向均提供明确资源，不把运行时 `flip_h` 当成最终方案；守望者的枪、背包和面具具有不对称特征，尤其不能只做镜像。
- 透明边距受控，角色换方向时脚底不跳、整体不缩放、阴影不漂移。
- 守望者拆为“身体 / 背包”和“武器 / 手臂”两个表现层，以支持枪口方向、开火后坐和未来武器替换。
- 每组资源先做方向排列表验收，再接入游戏，避免在运行时逐张发现尺寸和锚点问题。

### 10.4 阶段 C：方向控制与真实枪口

1. 将视觉接口由 `set_facing_x(float)` 升级为接收完整方向的 `set_facing(Vector3)`。
2. 使用八方向扇区选择表现帧；逻辑弹道仍保留连续 360° 精度，不把实际射击方向量化成八方向。
3. 方向切换立即响应，不做旋转补间；在扇区边界加入约 `5°` 滞回，防止鼠标停在边界时帧来回闪烁。
4. 为八个方向配置对应的 `Muzzle` 偏移，子弹统一从当前方向的枪口位置生成。
5. 武器层根据当前瞄准方向切换前后遮挡，开火只在武器层播放短促后坐，身体不再整体抖动。

最低视觉验收：

- 鼠标绕守望者一周时，身体、武器和枪口朝向一致。
- 角色位于屏幕中心及四个边缘区域时，子弹起点都贴合枪口。
- 1280×720 基准画面中，枪口闪光与子弹首帧的偏差不超过约 `8 px`。

### 10.5 阶段 D：动作状态与帧事件

先建立可复用的动作状态机，再增加帧数：

| 主体 | 第一版动作规格 |
|---|---|
| Lantern Keeper | idle 2 帧、move 4 帧、fire 2–3 帧、dash 2–3 帧、hit 1–2 帧 |
| 三类敌人 | idle 2 帧、move 4 帧、attack 至少 3 个阶段、death 3–4 帧 |

- 整体保持约 `8–12 FPS` 的手作定格感，不追求过度平滑。
- 动作优先级统一为 `death > hit > attack / fire > dash > move > idle`。
- 切换到更高优先级状态时取消旧 Tween、计时器和一次性回调，避免受击、攻击、死亡同时争夺缩放和颜色。
- 敌人攻击至少包含 windup、contact 和 recovery；伤害只在 contact 帧触发一次。
- `AttackOrigin` 成为实际攻击判定的起点，不再保留为未使用挂点。

三类敌人的移动语言必须不同：

- Root Drifter：低频、拖拽感明显的扎根爬行。
- Pod Skitter：高频、小幅、快速的裂荚疾走。
- Clay Bulwark：低频、重落点、大惯性的陶壳迈步，攻击前摇清晰。

所有上下起伏只作用于视觉层，阴影和逻辑脚底保持贴地；停止移动时回到稳定 idle，不继续播放行走浮动。

### 10.6 阶段 E：大体型敌人的攻击距离与群体间距

1. 为三类敌人配置独立的视觉足迹半径、攻击接触距离和分离半径。
2. 两个敌人的分离阈值使用双方半径之和，不再使用统一的中心距离。
3. 攻击距离以目标 Hurtbox 边缘和 `AttackOrigin` 为基础校准，不按两者中心距离目测。
4. 用完整三波 `26` 个敌人复测四座桥梁、Heartbloom 周围和玩家近身区域。
5. 只有实际出现性能问题时才把邻居搜索改为网格或空间分桶；第一版先保持简单、可验证。

### 10.7 自动与人工验收

新增自动测试至少覆盖：

- 八方向扇区映射、边界滞回和方向资源完整性。
- 八方向枪口偏移与投射物生成位置。
- 三类敌人的中心命中、视觉边缘命中和轮廓外未命中。
- 单颗普通投射物不能因同时触发 body 与 area 而重复伤害。
- 增加 Hurtbox 后，原移动胶囊尺寸和角色通过桥梁的能力不变。
- 敌人伤害只在 attack contact 帧发生一次。
- death 状态不能被 hit 或 attack 覆盖。

人工验收至少包含：

- 守望者八方向转向、移动、连续射击和冲刺录屏。
- 三类敌人八方向排列表与动作表。
- 开启物理调试轮廓后的 Hurtbox 对齐截图。
- 26 敌人完整波次中无明显穿叠、隔空攻击或视觉命中失败。
- 现有 27 项玩法测试、22 项视觉测试和 48 项资源契约测试继续通过。

### 10.8 实施顺序

1. 先实现独立 Hurtbox，解决“打到图却不掉血”的阻断问题。
2. 接入 Lantern Keeper 八方向静态帧、分层武器和真实 `Muzzle`。
3. 接入三类敌人的八方向静态帧。
4. 增加玩家动作状态与开火、冲刺反馈。
5. 增加敌人 move / attack / hit / death 状态和接触帧伤害。
6. 调整大体型敌人的攻击距离、群体间距并完成整局回归。

完成以上视觉—物理对齐后，再进入最小肉鸽三选一：升级进度、暂停三选一、强化生效、恢复战斗和重开清理。不要在角色朝向、攻击反馈和命中可信度尚未建立时继续叠加新系统。

## 11. 不要踩的坑

### 不要回退到受保护或占位表达

不要在玩家可见文本、美术或音频中重新使用戴夫、豌豆射手、人形僵尸、路障、铁桶、草坪格子或其他高度可识别的商业游戏表达。内部旧标识只是兼容层。

### 不要破坏视觉与逻辑分离

正式模型应通过 `PackedScene` 注入，不要为了换美术重写移动、伤害、碰撞、波次或胜负逻辑。程序化 Lanternroot 视觉只能作为开发 fallback，不得重新设为默认画面。

### 不要把每颗投射物做成实时灯

Seedlight Bolt 当前使用发光材质，无 `OmniLight3D`。大量逐弹实时灯会显著增加成本，也违反美术规范和视觉测试。

### Headless 测试先确保类缓存存在

在全新 clone 上直接执行 `--script` 可能因为 `.godot/global_script_class_cache.cfg` 尚未生成而找不到 `class_name`。先运行一次 `--import`，再执行三套测试。

### Dummy renderer 不能作为截图验收

`--rendering-driver dummy` 可运行测试，但不能可靠输出有效画面。截图需要 GUI 或可渲染驱动；目视验收必须真正打开或查看生成图像。

### 不要覆盖他人或远端改动

开始修改前运行：

```bash
cd "/Users/joezhu/Apps/defend_the_garden"
git status -sb
git log -3 --oneline --decorate
git remote -v
```

如果工作区已有修改，先确认归属。不要使用 `git reset --hard`、强制推送或静默覆盖其他任务的文件。

## 12. 新会话最短检查清单

1. 确认当前目录是 `/Users/joezhu/Apps/defend_the_garden`。
2. 阅读 `HANDOFF.md`、`README.md` 和 `docs/art_direction/ART_DIRECTION.md`。
3. 运行 `git status -sb`，保留未提交的 Lanternroot 改动。
4. 确认 `/opt/homebrew/bin/godot --version` 为兼容的 Godot 4.7。
5. 缺少 `.godot/` 时先执行 `--import`。
6. 修改前后分别运行 27 项玩法测试、22 项视觉测试和 48 项正式资源契约测试。
7. 下一项开发先按第 10 节完成方向动作与命中体积对齐，再进入最小肉鸽三选一。
8. 需要提交或推送时，只处理本轮确认范围内的文件。
