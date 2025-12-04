## 0. 文档目的

* 定义项目的 **整体架构 / 目录结构 / 约束规则**。
* 任何 AI 编程工具在生成代码、场景、资源时都必须遵守本说明。
* 核心目标：

  1. 同一套游戏逻辑，运行在 **Windows / Linux / macOS / Web** 上。
  2. 根据设备与屏幕特性，自动选择 **大屏 UI** 或 **手持 UI**。

---

## 1. 整体架构概览

### 1.1 技术栈

* 引擎：Godot 4.x（稳定版）
* 语言：GDScript（强类型）
* 渲染：

  * 桌面优先 Vulkan（必要时可切 GLES3 兼容）
  * Web 使用 WebGL2（Godot 导出模板自动处理）
* 目标平台：

  * 桌面：Windows / Linux / macOS
  * Web：HTML5 + WebAssembly（PC 浏览器 + 手机浏览器）

### 1.2 模块划分

1. **Core 核心层**

   * `Config`：配置加载与访问
   * `Logger`：日志与调试
   * `SceneManager`：场景切换、Root 节点管理
2. **Platform 平台与设备层**

   * `Platform`：平台检测（桌面 / Web / OS 名称）
   * `DeviceProfile`：设备 UI 配置（大屏 / 手持）
3. **Systems 系统层**

   * `InputSystem`：输入封装（键鼠 / 手柄 / 触摸）
   * `AudioSystem`：背景音乐、音效
   * `SaveSystem`：存档读写（`user://`）
   * `UISystem` / `UIManager`：UI 加载、切换、弹窗管理
4. **Gameplay 游戏逻辑层**

   * 游戏状态管理、关卡、角色、战斗/模拟逻辑等
5. **UI 层**

   * 公共 UI 组件（按钮、弹窗、HUD 基类）
   * **大屏 UI 变体**
   * **手持 UI 变体**

---

## 2. 目录结构规范（包含双 UI 方案）

### 2.1 顶层目录

```text
res://
  assets/           # 美术、音频、字体、图标等
  scenes/           # 非 UI 场景（世界、关卡、入口）
  scripts/          # 脚本（核心、系统、玩法）
  ui/               # 所有 UI 相关场景和脚本
  config/           # 配置文件（json / cfg）
  autoload/         # 单例脚本
  shaders/          # 着色器（如有）
  tests/            # 调试场景或测试脚本
  tools/            # 工具脚本（导出、调试用）
```

### 2.2 scripts 结构

```text
scripts/
  core/
    config.gd
    logger.gd
    scene_manager.gd
    platform.gd
    device_profile.gd

  systems/
    input_system.gd
    audio_system.gd
    save_system.gd
    ui_manager.gd      # 管理 UI 加载和切换

  gameplay/
    game_state.gd
    level_manager.gd
    player_controller.gd
    ...（具体玩法）
```

### 2.3 scenes 结构

```text
scenes/
  main.tscn           # 游戏入口场景（根 Node）
  gameplay/
    world.tscn
    level_*.tscn
  debug/
    test_*.tscn
```

> 入口场景主要负责挂载 Root、初始化系统，不做复杂逻辑。

### 2.4 ui 结构：两套 UI + 公共组件

```text
ui/
  common/                      # 可复用通用 UI 组件
    button_primary.tscn
    dialog_base.tscn
    hud_base.tscn
    loading_spinner.tscn

  big_screen/                  # 大屏设备 UI（桌面 + 大屏 Web）
    screens/
      ui_main_menu_big.tscn
      ui_settings_big.tscn
      ui_hud_big.tscn
    components/
      top_bar_big.tscn
      side_menu_big.tscn

  handheld/                    # 手持设备 UI（手机浏览器 / 将来移动端）
    screens/
      ui_main_menu_handheld.tscn
      ui_settings_handheld.tscn
      ui_hud_handheld.tscn
    components/
      bottom_nav_handheld.tscn
      drawer_menu_handheld.tscn
```

约定：

* 相同功能页面命名遵循：`ui_<name>_big.tscn` / `ui_<name>_handheld.tscn`
* 公共组件放在 `ui/common`，两套 UI 尽量复用。

---

## 3. 单例（Autoload）与根节点架构

### 3.1 Autoload 脚本

在 `Project → Autoload` 中添加（示例）：

```text
autoload/
  Global.gd          # 全局常量、轻量状态
  Config.gd          # 配置加载与访问
  Platform.gd        # 平台信息（桌面/Web 等）
  DeviceProfile.gd   # 当前 UI Profile（大屏/手持）
  SceneManager.gd    # 场景切换和 Root 管理
  InputSystem.gd     # 输入封装
  AudioSystem.gd     # 声音系统
  SaveSystem.gd      # 存档系统
  UIManager.gd       # 负责加载具体 UI 变体
```

AI 工具在生成代码时，应通过这些单例访问系统能力，例如：

```gdscript
SceneManager.change_scene("res://scenes/gameplay/world.tscn")
if DeviceProfile.is_big_screen():
    ...
UIManager.show_screen("main_menu")
SaveSystem.save_game(0, state)
Platform.is_web_platform()
```

### 3.2 入口场景结构

`scenes/main.tscn`：

```text
Main (Node)
  └── Root (Node)
        ├── WorldRoot (Node2D / Node3D)
        └── UIRoot (CanvasLayer / Control)
```

职责：

* `Main`：调用 `DeviceProfile.detect_profile()`，初始化 `UIManager`，加载主菜单 UI。
* `WorldRoot`：挂载游戏世界、关卡。
* `UIRoot`：挂载当前 UI（大屏或手持）。

UI 加载示例（伪代码逻辑在 `UIManager.gd` 中实现）：

```gdscript
# autoload/ui_manager.gd
class_name UIManager
extends Node

var ui_root: Node
var current_screen: Node

func _ready() -> void:
    ui_root = get_tree().get_root().get_node("Main/Root/UIRoot")

func show_screen(screen_name: String) -> void:
    # screen_name 逻辑名，如 "main_menu" / "settings" / "hud"
    var scene_path := _resolve_scene_path(screen_name)
    if current_screen:
        current_screen.queue_free()
    current_screen = load(scene_path).instantiate()
    ui_root.add_child(current_screen)

func _resolve_scene_path(screen_name: String) -> String:
    var suffix := DeviceProfile.get_ui_suffix()  # "_big" 或 "_handheld"
    match screen_name:
        "main_menu":
            return "res://ui/%s/screens/ui_main_menu%s.tscn" % [
                DeviceProfile.get_ui_folder(), suffix
            ]
        "settings":
            return "res://ui/%s/screens/ui_settings%s.tscn" % [
                DeviceProfile.get_ui_folder(), suffix
            ]
        "hud":
            return "res://ui/%s/screens/ui_hud%s.tscn" % [
                DeviceProfile.get_ui_folder(), suffix
            ]
        _:
            push_error("Unknown screen_name: %s" % screen_name)
            return ""
```

---

## 4. 平台与设备 Profile（两套 UI 关键）

### 4.1 Platform：平台检测

`autoload/platform.gd`：

```gdscript
class_name Platform
extends Node

var _name := ""
var _is_web := false
var _is_desktop := false

func _ready() -> void:
    _name = OS.get_name()           # "Windows" / "Linux" / "macOS" / "Web" ...
    _is_web = (_name == "Web")
    _is_desktop = _name in ["Windows", "Linux", "macOS"]

func is_web_platform() -> bool:
    return _is_web

func is_desktop_platform() -> bool:
    return _is_desktop

func get_os_name() -> String:
    return _name
```

### 4.2 DeviceProfile：大屏 / 手持 UI 选择逻辑

核心：运行时根据 **触摸能力 + 分辨率 + 宽高比 + 平台** 自动决定 UI 使用哪一套。

`autoload/device_profile.gd`：

```gdscript
class_name DeviceProfile
extends Node

enum UIProfile { BIG_SCREEN, HANDHELD }

var current_profile: UIProfile = UIProfile.BIG_SCREEN

func _ready() -> void:
    current_profile = detect_profile()

func detect_profile() -> UIProfile:
    var size: Vector2i = DisplayServer.window_get_size()
    var w: float = float(size.x)
    var h: float = float(size.y)
    var ratio: float = (h > 0.0) ? w / h : 1.0
    var is_touch: bool = OS.has_touchscreen_ui_hint()
    var is_web: bool = Platform.is_web_platform()

    # 规则示例（可以后续迭代）：
    # - 小屏 + 触摸 → 手持
    # - Web 且宽度 < 1280 → 手持
    # - 其余 → 大屏

    if is_touch and min(w, h) < 900.0:
        return UIProfile.HANDHELD

    if is_web and w < 1280.0:
        return UIProfile.HANDHELD

    return UIProfile.BIG_SCREEN

func is_big_screen() -> bool:
    return current_profile == UIProfile.BIG_SCREEN

func is_handheld() -> bool:
    return current_profile == UIProfile.HANDHELD

func get_ui_folder() -> String:
    # 返回 "big_screen" 或 "handheld"，用于拼接路径
    return "big_screen" if is_big_screen() else "handheld"

func get_ui_suffix() -> String:
    # 返回 "_big" 或 "_handheld"，用于拼接文件名
    return "_big" if is_big_screen() else "_handheld"
```

AI 工具在编写 UI 相关逻辑时，**不要自行判断屏幕大小**，而是通过 `DeviceProfile` 查询：

```gdscript
if DeviceProfile.is_handheld():
    # 做手持专有逻辑
```

Web 平台既可能运行在 PC 浏览器（大屏），也可能在手机浏览器（手持），这个逻辑会统一处理。

---

## 5. 输入与 UI 体系（两套 UI 共用同一逻辑）

### 5.1 InputSystem：统一输入映射

`scripts/systems/input_system.gd`：

* 所有输入均使用 `InputMap` 动作名，不直接硬编码按键。
* 支持键盘、鼠标、触摸（Web 浏览器也包含触摸）。

示例：

```gdscript
class_name InputSystem
extends Node

func is_move_left() -> bool:
    return Input.is_action_pressed("move_left")

func is_move_right() -> bool:
    return Input.is_action_pressed("move_right")

func is_jump_pressed() -> bool:
    return Input.is_action_just_pressed("jump")

func is_pause_pressed() -> bool:
    return Input.is_action_just_pressed("ui_cancel")
```

UI 差异只体现在 **控件布局/控件形态** 而不是输入逻辑；
例如：

* 大屏 UI 用 ESC 键 / 菜单按钮
* 手持 UI 用屏幕上的暂停按钮
  但最终都触发相同的游戏逻辑（比如发送 `pause_requested` 信号）。

### 5.2 UI 架构约束

AI 工具在生成 UI 时遵守：

1. UI 场景全部使用 `Control` + `Container` 布局（HBox/VBox/Grid/Margin/Scroll）。
2. 禁止在 UI 脚本里直接 `get_tree().change_scene_to_file(...)`，改用 `SceneManager` 或发射信号，由上层处理。
3. 对于同一功能页面：

   * 大屏：`ui/big_screen/screens/ui_main_menu_big.tscn`
   * 手持：`ui/handheld/screens/ui_main_menu_handheld.tscn`
   * 共享逻辑尽量放在公共脚本或基类中。

例如 UI 基类：

```gdscript
# scripts/systems/ui_screen_base.gd
class_name UIScreenBase
extends Control

signal request_start_game
signal request_open_settings
signal request_quit

func _ready() -> void:
    # 子类负责连接按钮到这些信号
    pass
```

每个大屏/手持版本的 UI 脚本只负责：

* 获取按钮节点
* 连接到基类信号
* 调 UIManager / SceneManager 处理

---

## 6. 配置与存档（与两套 UI 无强耦合）

保持之前约定即可，重点是 **Web 兼容**：

* 配置（`config/`）使用 `res://` 只读加载。
* 存档统一使用 `user://saves/` 路径，在 Web 中也可持久化。

AI 工具在使用存档时必须通过 `SaveSystem`：

```gdscript
SaveSystem.save_game(0, state)
var state := SaveSystem.load_game(0)
```

不要在 UI 或 Gameplay 里自己直接读写文件。

---

## 7. 导出与 Web 特殊注意

### 7.1 导出预设（Export Presets）

配置以下 preset：

* `Windows Desktop`
* `Linux/X11`
* `macOS`
* `Web`

约束：

* 构建模式：Release
* Web 基于 WebAssembly + WebGL2
* 不使用依赖本地文件系统的功能

### 7.2 Web 下的限制（AI 需要注意）

1. 不能调用 `OS.shell()` / `OS.execute()`。
2. 窗口大小不能直接控制，只能响应 `DisplayServer.window_get_size()` 做自适配。
3. 避免复杂多线程，偏向协程/异步。
4. UI 必须适配浏览器大小变化：

   * 使用 Container 布局
   * 不硬编码像素尺寸

`DeviceProfile.detect_profile()` 会利用当前 `window_get_size()` + 触摸信息区分 Web 大屏 / Web 手持，UI 不需要额外判断。

---

## 8. 编码规范（对 AI 的要求）

1. 使用强类型 GDScript：

```gdscript
var hp: int = 100
func apply_damage(amount: int) -> void:
    hp -= amount
```

2. 统一通过单例访问系统：

   * `SceneManager` 做场景切换
   * `UIManager` 负责界面切换
   * `DeviceProfile` 决定 UI 版本

3. 公共逻辑优先抽到基类或 `scripts/core` / `scripts/systems`，避免在大屏/手持两个版本之间复制粘贴。

4. UI 脚本只做两件事：

   * 控件绑定（连接信号）
   * 调用上层系统（发送信号或调用 `UIManager/SceneManager`）

5. 禁止：

   * 直接在 UI 里写大量游戏逻辑
   * 在随机脚本中随意调用 `get_tree().root` 去跨层操作
