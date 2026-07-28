# Garden Nightwatch

第一版灰盒玩法原型：戴夫在固定斜俯视角的 3D 浮岛花园中使用豌豆武器，保护花园核心并抵御三波僵尸。

## 当前玩法

- `WASD` 或方向键：移动
- 鼠标：瞄准
- 鼠标左键：连续发射豌豆
- `Space` 或 `Shift`：闪避冲刺
- `R`：重新开始

三种敌人：

- Walker：主要攻击花园核心
- Runner：快速追击戴夫
- Bruiser：缓慢、高生命、高伤害

消灭僵尸会获得阳光。完成三波进攻即获胜；戴夫或花园核心生命归零则失败。

## 运行

使用 Godot 4.7.1 或兼容的 Godot 4 稳定版打开当前目录，然后运行主场景。

命令行运行：

```bash
/path/to/Godot --path .
```

## 自动化验证

```bash
/path/to/Godot \
  --display-driver headless \
  --rendering-driver dummy \
  --path . \
  --script res://tests/smoke_test.gd
```

## 代码结构

- `scripts/player/player.gd`：移动、瞄准、射击、冲刺、生命
- `scripts/entities/`：僵尸、豌豆投射物、花园核心
- `scripts/game/wave_director.gd`：三波敌人和波次状态
- `scripts/game/game.gd`：场景装配、胜负闭环
- `scripts/ui/hud.gd`：生命、波次、阳光、控制提示
- `tests/smoke_test.gd`：玩法结构和关键数值的烟雾测试

这一版优先验证移动、攻击、防守压力和战斗节奏。随机房间、三选一强化、更多植物武器和正式美术留到下一阶段。
