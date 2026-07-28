# Defend the Garden 项目交接

更新时间：2026-07-28
写给：完全没有前文上下文的新 Codex 会话

## 1. 我们在做什么

用户正在制作一款固定斜俯视角的 3D 动作肉鸽花园防守游戏。

核心设想是：

- 玩家操控一名花园守卫者，在小型立体花园场地中移动、瞄准、射击和冲刺。
- 守卫者使用不同的“植物武器”抵御僵尸，同时保护花园核心。
- 场景构图、镜头和即时操作节奏参考用户提供的视频。
- 先验证玩法是否好玩，再细化角色、场景、特效、动画和音频。
- 后续目标是加入随机强化、植物武器组合和可重复游玩的完整肉鸽循环。

用户最初用《植物大战僵尸》的戴夫、植物和僵尸描述故事，但这只能作为内部原型语义。若项目要公开或商业化，必须改成原创角色名、世界观、美术、音频、UI 和敌我设计，不能复制或直接使用《植物大战僵尸》的受保护资产与辨识度过高的表达。

## 2. 当前工作区与资料

- 项目根目录：`/Users/joe/Apps/肉鸽游戏`
- GitHub：`git@github.com:ZZYMMHY/defend_the_garden.git`
- 仓库页面：`https://github.com/ZZYMMHY/defend_the_garden`
- 当前分支：`main`
- 已推送提交：`8c72a1ab7fa00cdccc54856cb2b7b81c8061dc7b`
- 提交标题：`Build first playable garden defense prototype`
- 参考视频：`/Users/joe/Downloads/FireShot/videoplayback.mp4`
- Godot 版本：`4.7.1.stable.official.a13da4feb`
- 本次会话使用的 Godot 可执行文件：
  `/private/tmp/rogue_godot_4.7.1/Godot.app/Contents/MacOS/Godot`

注意：Godot 当前位于 `/private/tmp`，重启或系统清理后可能消失。新会话必须先检查路径是否存在，不要假定它永久可用。需要长期开发时，应让用户安装 Godot 4.7.1 或兼容的 Godot 4 稳定版到正常应用目录。

参考视频没有提交到 Git；不要把视频、临时截图、导出包或 Godot 缓存加入仓库。

## 3. 已经完成了什么

已经做出第一版可玩的 3D 灰盒原型，并完成以下闭环：

- 固定斜俯视 3D 镜头和小型浮岛花园场地。
- 玩家角色移动、鼠标瞄准、持续射击、受伤、死亡和冲刺。
- 第一种植物武器：豌豆发射器。
- 一个需要保护的花园核心。
- 三种僵尸：
  - Walker：主要向花园核心推进。
  - Runner：速度快，优先追击玩家。
  - Bruiser：移动慢、生命高、攻击高。
- 三波进攻，共配置 26 个敌人。
- 击败敌人获得阳光。
- HUD 显示玩家生命、核心生命、波次、阳光和操作提示。
- 胜利、失败、停止控制和重新开始流程。
- 主要画面由 Godot 基础几何体和代码生成，适合继续快速调玩法。
- README、自动烟雾测试和截图脚本。
- 仓库已初始化，并把首个 `main` 提交推送到 GitHub。

当前操作：

- `WASD` 或方向键：移动
- 鼠标：瞄准
- 鼠标左键：连续射击
- `Space` 或 `Shift`：冲刺
- `R`：重新开始

## 4. 代码结构

- `project.godot`
  - 项目配置、主场景和输入动作。
- `scenes/game/main.tscn`
  - 很轻的入口场景，主体内容由游戏脚本在运行时装配。
- `scripts/game/game.gd`
  - 总流程和场景装配、胜负闭环。
- `scripts/game/wave_director.gd`
  - 三波敌人配置、生成和波次状态。
- `scripts/game/camera_follow.gd`
  - 固定斜俯视跟随镜头。
- `scripts/player/player.gd`
  - 移动、瞄准、射击、冲刺、生命和输入。
- `scripts/entities/projectile.gd`
  - 豌豆投射物和伤害处理。
- `scripts/entities/zombie.gd`
  - 三种僵尸的参数和行为。
- `scripts/entities/garden_core.gd`
  - 花园核心生命、受击和表现。
- `scripts/core/visual_factory.gd`
  - 灰盒模型、材质等可视对象的辅助创建。
- `scripts/ui/hud.gd`
  - HUD、提示和胜负界面。
- `tests/smoke_test.gd`
  - 结构、关键数值和核心流程烟雾测试。
- `tests/capture_frame.gd`
  - 运行画面截图脚本。
- `README.md`
  - 玩法、运行方法和代码概览。

## 5. 已验证的状态

最近一次自动验证结果：

```text
SMOKE TEST RESULT: 27 checks passed
```

验证覆盖：

- 主场景及核心节点成功创建。
- 玩家与花园初始生命。
- 三波和 26 个敌人的配置。
- 移动、冲刺、重新开始输入。
- 玩家和花园受伤、恢复。
- 三类僵尸生成及强弱关系。
- 投射物生成和伤害。
- 僵尸死亡与阳光奖励。
- 清空波次后的胜利。
- 胜利后停止玩家控制。

提交前还通过了：

- `git diff --cached --check`
- 远端 `main` 引用校验
- 本地 `main` 与 `origin/main` 一致

这不等同于完整的人类试玩验证。自动测试只能说明主要结构和规则仍能运行，移动手感、射击反馈、难度、镜头舒适度和波次节奏仍需用户试玩反馈。

## 6. 如何运行与验证

如果临时 Godot 路径仍存在，可直接运行游戏：

```bash
/private/tmp/rogue_godot_4.7.1/Godot.app/Contents/MacOS/Godot \
  --path "/Users/joe/Apps/肉鸽游戏"
```

运行 GUI 需要允许启动本地应用。新会话不要仅凭命令进程存在就宣称窗口已经正常显示，应确认 Godot 没有立即退出。

推荐的无界面测试命令：

```bash
/private/tmp/rogue_godot_4.7.1/Godot.app/Contents/MacOS/Godot \
  --display-driver headless \
  --rendering-driver dummy \
  --log-file /private/tmp/defend_the_garden_smoke.log \
  --path "/Users/joe/Apps/肉鸽游戏" \
  --script res://tests/smoke_test.gd
```

成功标准是进程退出码为 `0`，并明确输出：

```text
SMOKE TEST RESULT: 27 checks passed
```

CoreAudio、系统 CA 证书和 dummy audio 相关消息属于当前 macOS 沙箱环境警告；只要测试真正执行、27 项通过且退出码为 0，就不要把这些环境警告误判成玩法失败。

## 7. 当前卡在哪里

目前没有代码或远端阻塞。

真正的项目状态是“第一版灰盒已经可玩，等待用户实际试玩反馈”。尚未确认：

- 玩家移动速度和加速度是否舒服。
- 鼠标瞄准和射击是否准确。
- 冲刺距离、冷却和无敌需求。
- 僵尸追击与核心防守压力是否合理。
- 三波节奏是否过快、过慢或重复。
- 花园核心在画面和战斗中的存在感是否足够。
- 用户最想优先加入哪类植物武器与肉鸽强化。

还没有实现的关键产品能力：

- 每轮或升级时的随机“三选一”强化。
- 多种植物武器、升级分支和组合联动。
- 经验值或升级进度。
- 更长的 8–10 分钟单局曲线。
- 精英、Boss、事件和更丰富的波次。
- 局外成长、解锁、存档和设置。
- 正式角色、场景、动画、粒子、音效和音乐。
- 主菜单、暂停菜单、手柄适配和正式导出流程。

## 8. 建议的下一步

不要立刻进入正式美术制作。先让用户完成一轮试玩并记录最明显的三个问题，然后做玩法版本 `0.2`。

建议按以下顺序推进：

1. 处理试玩反馈
   - 优先修移动、瞄准、镜头、射击反馈和波次节奏。
   - 保持改动小而可比较，每次修改后重跑 27 项测试并再次试玩。

2. 建立最小肉鸽循环
   - 击败僵尸获得经验。
   - 升级时暂停战斗并展示随机三选一。
   - 先做约 8–12 个数值或机制强化。
   - 强化至少覆盖伤害、射速、弹道、移动、生存和花园防守。

3. 增加两种差异明显的植物武器
   - 例如抛物线范围伤害、近身环绕防御或穿透直线攻击。
   - 每种武器先验证操作和定位，不要一口气堆大量内容。

4. 把单局扩展到 8–10 分钟
   - 增加渐进难度、精英敌人和一个临时 Boss。
   - 用数据配置波次和强化，避免继续把大量内容硬编码进单个脚本。

5. 玩法得到用户确认后再做视觉垂直切片
   - 先选一个角色、一块花园、三种敌人和三种武器做正式风格。
   - 同步确立原创 IP，替换“戴夫”和《植物大战僵尸》式占位表达。

玩法 `0.2` 的建议验收标准：

- 一局可稳定玩 8 分钟左右。
- 至少 3 种植物武器。
- 至少 8 个随机强化。
- 一局内能形成两种以上明显不同的构筑。
- 有一个精英或 Boss 作为阶段终点。
- 自动测试覆盖升级选择、强化生效、暂停恢复和胜负重开。

## 9. 绝对不要再踩的坑

### 不要混淆两个不同项目

记忆中还有一个旧项目：`/Users/joe/Sites/aigame`。它是 2D 行列塔防原型，曾有 35 项测试。

当前项目是：

```text
/Users/joe/Apps/肉鸽游戏
```

它是 3D 斜俯视动作肉鸽灰盒，当前是 27 项测试。不要把旧项目的代码结构、测试数量、玩法或验证结论写到当前项目。

### Headless Godot 必须使用可靠参数

只加 `--display-driver headless --rendering-driver dummy` 仍曾因为无法写 `user://logs` 而崩溃并退出 `134`。必须把日志明确写到可写目录，例如：

```text
--log-file /private/tmp/defend_the_garden_smoke.log
```

看到 Godot 崩溃后不要声称测试已通过；必须重跑并拿到退出码 0 和明确的 27 项通过结果。

### 不要依赖临时引擎路径

`/private/tmp/rogue_godot_4.7.1` 可能消失。先检查，再运行；不存在就使用已安装的 Godot 或重新获取官方稳定版。

### 不要用 `pgrep` 判断窗口状态

当前沙箱内 `pgrep` 曾因 `sysmond service not found` 无法读取进程列表。不要围绕它反复尝试。启动 GUI 后应读取启动输出，必要时使用合适的本地应用控制方式检查窗口。

### Git 写操作可能需要权限

当前环境曾禁止写 `.git`，导致 `git init`、`git remote add` 和 `git add` 出现 `Operation not permitted`。不要绕过权限或破坏仓库；需要时按正常流程请求受控授权。

### GitHub CLI 登录目前不可用

本次检查时：

```text
gh auth status
```

显示账号 `aidai524` 的 token 无效。不过 SSH 密钥访问正常，已经成功将 `main` 推送到 `ZZYMMHY/defend_the_garden`。普通 `git fetch/push` 优先继续使用 SSH；只有创建 PR 或必须使用 GitHub CLI 时，才让用户重新执行 `gh auth login -h github.com`。

### 不要覆盖远端历史

远端在首次推送前为空，但现在 `main` 已存在。后续开始修改前先执行：

```bash
git status -sb
git fetch origin
git log --oneline --decorate -5
```

如果出现用户未提交改动或远端新提交，先确认归属和同步策略。不要使用 `git reset --hard`、强制推送或静默覆盖用户修改。

### 不要提交无关或生成文件

`.gitignore` 已排除：

- `.godot/`
- `.DS_Store`
- `captures/`
- `builds/`

继续保持参考视频、临时截图、下载的 Godot、日志和导出包不进入源码提交。

### 不要先堆美术和内容

用户明确要先做玩法。当前最有价值的信息来自试玩，不是增加大量植物、敌人或正式素材。先证明移动、战斗、防守压力和随机构筑循环，再扩大内容。

### 不要直接商业化《植物大战僵尸》表达

“戴夫、植物武器、僵尸守花园”是原型沟通用语，不是可直接发布的原创 IP。正式对外前必须做原创命名与视觉方向，并避免复刻角色造型、UI、音频、地图布局和高度辨识的具体设计。

## 10. 新会话开始时的最短检查清单

```bash
cd "/Users/joe/Apps/肉鸽游戏"
git status -sb
git log -1 --oneline --decorate
git remote -v
test -x /private/tmp/rogue_godot_4.7.1/Godot.app/Contents/MacOS/Godot
test -f /Users/joe/Downloads/FireShot/videoplayback.mp4
```

然后：

1. 阅读本文件和 `README.md`。
2. 查看用户是否给出了试玩反馈。
3. 如果只是要求修改，不要重新规划整个项目；围绕反馈做最小闭环。
4. 修改后运行带 `--log-file` 的 27 项烟雾测试。
5. 需要推送时，先检查工作区和远端状态，只提交本轮相关文件。
