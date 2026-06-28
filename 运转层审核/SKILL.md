---
name: 运转层审核
description: 运转层全量审计：宪法+自动化链+Skill+配置+MCP+Memory+Git。触发：「运转层审核」「框架审核」；结构性改动后自动触发。
followed_by: [知识库体检]
---

# 运转层审核

> 版本：v3.1 · 2026-06-20
> v3.0→v3.1：**Skill 层同步更新**。① 知识编译版本引用 v3.6→v3.7（两阶段 typed link）；② Skill 层检查新增「typed link审计」Skill（v1.3，分类模式 + 全量审计）；③ 过时表述新增「剪存文档」→「剪存」命名约定。

> 每次结构性改动后必须执行。审核范围：工作空间运转所需的全部机制文件——不只是宪法和 Skill，还包括让它自动跑起来的 hook、cron、settings、MCP、memory 等。

## 为什么需要这个 Skill

这个工作空间不是一堆 Markdown 文件的集合。它是一套运转中的协作系统，由 11 层组件咬合而成。任何一层的修改都可能在其他层留下过时引用、断链或配置漂移。

v2.x 只审了宪法+Skill+MOC——这是房子的「设计图」和「家具」，但没审它的「水电管线」（hook/cron）、「配电箱」（settings）、「门禁系统」（MCP）、「地基」（目录结构/Git）。v3.0 补上这些。

## 触发场景

- **结构性改动后强制触发**：目录重命名/新建、机制重写、路径变更、Skill/Hook/Cron 新增或删除、Settings/MCP 修改
- **青城手动触发**："框架审核""审核协作机制""检查框架""框架有没有问题"
- **知识库体检后联动触发**：体检发现框架问题时

## 框架全貌：11 层组件

审核前先理解这 11 层是什么、互相怎么咬合：

```
🎯 宪法层（设计图）：CLAUDE.md ×11 + soul.md + ~/.claude/CLAUDE.md
⚡ 自动化层（引擎）：SessionStart hook → session-start.sh + Cron 任务
🔧 Skill 层（工具箱）：100+ SKILL.md + 79 软链接
⚙️ 配置层（开关）：settings.json ×3 + .mcp.json
🧠 Memory 层（记忆）：~/.claude/projects/.../memory/ + MEMORY.md
📁 目录层（骨架）：顶层 11 目录 + 子目录结构
🔒 Git 层（版本）：.gitignore
📋 运转日志层（记录）：对话/日报/周复盘/体检/框架审核
🔌 外部集成层（管线）：MCP 6 个 + CLI 工具 + API 配置
📚 知识库设施层（数据）：index/log/MOC/卡片格式
🏠 Obsidian 层（容器）：.obsidian/ 配置
```

## 审核流程（12 步 · 4 阶段）

---

### 阶段一：骨架完整性

#### 1. 全文件清单确认

确认以下全部文件存在且可读：

**宪法**：
- 根目录：`CLAUDE.md`、`soul.md`
- 子宪法：扫描项目根目录下所有含 `CLAUDE.md` 的子目录，动态发现，不硬编码数量
- 全局宪法：`~/.claude/CLAUDE.md`

**自动化**：
- Hook 配置：`.claude/settings.json`（hooks 节）
- Hook 脚本：`AI协作工具/hooks/session-start.sh`
- Hook 文档：`AI协作工具/hooks/CLAUDE.md`
- Cron 任务：`.claude/scheduled_tasks.json`

**Skill 本体**：
- 项目 Skill：`AI协作工具/skills/` 下全部 `SKILL.md`
- 领域 Skill：`03-认知工坊/skills/`、`04-内容生产/skills/`、`06-对外分享/skills/`、`07-AI产品开发/skills/` 下全部 `SKILL.md`（排除 node_modules）

**配置**：
- 项目设置：`.claude/settings.json`、`.claude/settings.local.json`
- 全局设置：`~/.claude/settings.json`
- MCP 配置：`~/.claude/.mcp.json`

**Memory**：
- Memory 目录：`~/.claude/projects/` 下当前项目的 `memory/` 目录及其全部 `.md` 文件
- Memory 索引：`MEMORY.md`

**Git**：
- `.gitignore`

**知识库管理**：
- `02-知识库/index.md`、`02-知识库/log.md`
- MOC：`02-知识库/MOC/` 下全部 `.md` 文件
- 调用记录：`00-运转日志/知识卡片调用记录.md`

**运转日志**：
- 目录：`00-运转日志/对话记录/`、`00-运转日志/日报/`、`00-运转日志/周复盘/`、`00-运转日志/体检报告/`、`00-运转日志/框架审核/`

#### 2. 目录结构一致性

逐份子宪法读取「目录结构」节，与磁盘实际目录比对：
- 文档声称的目录 → 磁盘上存在
- 磁盘上存在的一级子目录 → 至少在一份子宪法中有说明
- 路径格式统一（中文目录名、无尾部斜杠）

#### 3. Git 配置审计

- `.gitignore` 存在且不排斥框架关键文件（`.claude/settings.json`、`.claude/scheduled_tasks.json`、`AI协作工具/hooks/` 等应被跟踪）
- `.gitignore` 覆盖敏感文件：`.mcp.json`、`cookies.json`、API 密钥文件

---

### 阶段二：自动化链审计

#### 4. Hook 体系

- `.claude/settings.json` 中 `hooks.SessionStart` 配置完整（含 `type: command`、`command`、`timeout`）
- Hook 脚本路径可解析，文件存在且可执行（`test -x`）
- Hook 脚本语法有效（`bash -n` 无错误）
- `AI协作工具/hooks/CLAUDE.md` 描述的脚本列表与实际文件一致
- Hook 脚本中引用的路径（PROJECT 变量、Skill 名称、目录路径）全部存在

#### 5. Cron 任务

- `.claude/scheduled_tasks.json` 合法 JSON
- 每个任务含必要字段：`cron`、`prompt`、`recurring`
- Cron 表达式语法正确（5 字段）
- 任务未超过 7 天过期上限（`createdAt` 距今 < 7 天），接近 5 天标 🟡
- 任务 prompt 中引用的 Skill 名称存在
- Cron 任务数量与根宪法文档描述一致

#### 6. 自动化链端到端

验证整条自动化链的引用无断点：
- SessionStart hook → `session-start.sh` → 6 个任务各自引用的 Skill/路径/MCP
- Cron 任务 → 引用的 Skill（对话存档）→ Skill 内部引用
- Hook 输出注入 AI 上下文后，AI 按指令调用的 Skill 全部存在

---

### 阶段三：配置与集成审计

#### 7. Settings 配置

三份 settings JSON 逐一检查：
- **`.claude/settings.json`**（项目）：hooks 配置完整，无语法错误
- **`.claude/settings.local.json`**（项目本地）：permissions.allow 中无过期命令（引用已删除/重命名的路径），enabledMcpjsonServers 与实际 MCP 配置一致
- **`~/.claude/settings.json`**（全局）：`env` 节关键字段存在（`ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_BASE_URL`、模型映射），`permissions.defaultMode` 配置正确，`enabledPlugins` 与 `~/.claude/plugins/` 一致

过期权限检测重点：
- 命令中引用的路径是否仍存在
- mv/rm/ln 类一次性迁移命令是否已完成（目标已存在则权限可清理）

#### 8. MCP 配置

- `~/.claude/.mcp.json` 合法 JSON
- 每个 MCP server 的 `command` + `args` 可解析，启动脚本/二进制存在
- 每个 SSE 类 server 的 URL 格式正确
- MCP server 数量与根宪法「工具索引」中 MCP 工具条目数一致
- MCP server 名称与 `AI协作工具/MCP工具/` 下文档对应

#### 9. 外部集成

- **CLI 工具**：`AI协作工具/CLI工具/` 下每个工具的使用说明与实际二进制/脚本路径一致（weflow、xhs-cli、wx-cli、飞书CLI）
- **API 配置**：`AI协作工具/api配置/` 下每个配置文件引用完整
- **MCP 工具文档**：`AI协作工具/MCP工具/` 下文档数量与实际启用的 MCP server 一致，每份文档描述的工具数与实际可用工具匹配

---

### 阶段四：质量与一致性

#### 10. Skill 全量审计（扩展）

**软链接完整性**（两组全扫）：
- `~/.claude/skills/` 下所有软链接 → 目标存在且可读（0 断链）
- `.claude/skills/` 下所有软链接 → 目标存在且可读（0 断链）
- 检测重复映射（多个软链接指向同一目标）

**Skill 本体完整性**（全部 SKILL.md，不仅 AI协作工具/skills/）：
- 每个 Skill 有标准版本号行（`> 版本：vX.X · YYYY-MM-DD`）
- 每个 Skill 的 frontmatter 含 `name` 和 `description`
- 无空 SKILL.md（0 字节或仅 frontmatter）

**Skill 内部引用**（抽样重点 Skill）：
- 路径引用指向存在的文件/目录
- 引用的 MOC 名称与 `02-知识库/MOC/` 下实际文件名一致
- 调用的其他 Skill 名称正确（未被合并或删除）

#### 11. Memory 体系

- Memory 目录存在且含 `MEMORY.md` 索引
- `MEMORY.md` 中列出的每条 memory 文件实际存在
- Memory 目录下的 `.md` 文件（除 MEMORY.md 外）都在 MEMORY.md 中有对应条目
- 每条 memory 文件含合法 frontmatter（`name`、`description`、`metadata.type`）
- 无孤儿文件（磁盘有但索引无）和无着落条目（索引有但磁盘无）

#### 12. 版本号与术语一致性（原有步骤 2-4 合并）

**版本号**：
- 根 `CLAUDE.md` 版本号与全部子宪法引用的根宪法版本号一致
- 全局 `~/.claude/CLAUDE.md` 版本号存在
- Skill 版本号全部存在（已在步骤 10 检查，此处汇总）

**路径引用**：
- 逐文件扫描路径引用，验证目标存在（重点：目录重命名后旧路径残留）
- 路径格式统一（中文标点、无混合分隔符）

**术语统一**：

| 检查项 | 正确用语 | 废弃用语 |
|--------|---------|---------|
| 知识库定位 | 地基和数据基建 | AI 工作记忆、外脑 |
| 卡片格式 | 四区（Frontmatter→标题+正文→相关链接→来源） | 旧格式缺相关链接区 |
| 调用记录 | `00-运转日志/知识卡片调用记录.md`，累计计数，无日期列 | 旧格式含日期列 |
| MOC 格式 | `## 节标题` → `- [[卡片名]]`，无引导语无描述 | 含引导语、含 `— 描述` |
| MOC 命名 | `MOC-主题` | `主题-MOC` |
| typed link | 四标准类型：支撑/应用于/张力/互见 | 取代/互补/同源/相关等非标变体 |
| source_type | 10 种取值 | 越界值 |
| status | 四阶段 seed→growing→evergreen→dormant | active 等非标值 |
| 知识编译 | v3.7 三阶段框架 + 两阶段 typed link（编译裸链接→分类器标注） | v3.5 直接写 typed link |

**index.md 与 MOC**：
- 卡片数、MOC 数与实际一致
- 全部 MOC frontmatter 完整（`created` + `source_type: MOC`）
- 全部 MOC 节标题格式 `## xxx`，无双前缀（如 `MOC-MOC-xxx`）

---

### 12+1. Token 审计（独立 Skill）

Token 审计已拆分回独立 Skill「token审计」。框架审核完成 12 步后，**自动提议调用 token审计 Skill** 做深度上下文和规则质量审计。不再在此处做简化的行数计数。

> Token 审计 Skill 覆盖：全量上下文清单、宪法体积审计、规则质量扫描、AI 判断边界分析、Skill 描述精准度审计、综合优化建议。详见 `token审计` Skill。

---

## 输出审核报告

写入 `00-运转日志/框架审核/YYYY-MM-DD-框架审核报告.md`（目录不存在则先创建）。

```markdown
---
created: YYYY-MM-DD
source_type: 框架审核报告
---

# 运转层审核报告·YYYY-MM-DD

## 总体状态
[✅ 通过 / 🔴 N 项待修复]

## 审核明细

### 阶段一：骨架完整性
### 阶段二：自动化链
### 阶段三：配置与集成
### 阶段四：质量与一致性

## 待修复清单
### 🔴 必须修复
### 🟡 建议修复
### ℹ️ 发现但未修复（需青城确认）

## 修复记录
| 时间 | 阶段 | 问题 | 操作 | 结果 |
|------|------|------|------|------|
```

## 修复联动

🔴 项默认进入修复。原则：逐项修复 → 重跑受影响步骤 → 追加 `00-运转日志/知识卡片调用记录.md` 系统变更记录。

以下场景需先确认不自动修复（写入 `ℹ️ 发现但未修复`）：
- `settings.local.json` 过期权限：涉及安全配置，标注后等青城确认
- Memory 文件内容修改：标注不一致，等青城确认
- `.gitignore` 修改：可能影响版本控制策略

## 异常处理

| 场景 | 触发条件 | 处理动作 |
|------|---------|---------|
| 子宪法缺失 | 路径下找不到 `CLAUDE.md` | 标注「缺失」，继续扫描 |
| 版本号不一致 | 子宪法引用版本 ≠ 根宪法当前 | 标注差异，默认同步 |
| 软链接断链 | `readlink` 目标不存在 | 标注断链路径，提议修复或删除 |
| Hook 脚本语法错误 | `bash -n` 非零退出 | 标注行号和错误信息 |
| Cron JSON 非法 | `jq` 解析失败 | 标注具体字段 |
| Settings JSON 非法 | 解析失败 | 标注文件路径和行号 |
| Settings 过期权限 | allow 列表含已删除路径 | 标注具体命令，记入「需确认」 |
| MCP 启动命令不可达 | `command -v` 或路径检查失败 | 标注路径 |
| Memory 索引不一致 | 磁盘文件 vs MEMORY.md 条目不匹配 | 列出孤儿文件和缺失条目 |
| Token 审计超基线 | 根宪法行数增长 >30% | 标注 🔴 |
| MOC 格式异常 | 缺 frontmatter / 标题格式不符 | 标注具体问题，不自动改 MOC 正文 |
| 审核期间文件被修改 | `git status` 显示改动 | 重新扫描受影响步骤 |

## 反例清单

| # | 反模式 | 为什么不要做 | 替代做法 |
|---|--------|-------------|---------|
| 1 | **只扫宪法不扫自动化链** | Hook/Cron 断了不会报错，系统悄悄停摆 | 12 步全量，Hook/Cron/Settings 必查 |
| 2 | **发现问题只报告不修复** | 报告堆积 → 问题积累 → 框架腐化 | 🔴 项默认修复，逐项→重跑→追加日志 |
| 3 | **修复一处漏掉引用点** | 版本号更新只改根宪法，子宪法引用旧版 | 修一处，grep 全局搜引用，全量同步 |
| 4 | **跳过 MOC 格式检查** | MOC 引导语残留/节标题缺失是历史高频 bug | MOC 结构检查是固定步骤 |
| 5 | **不审 settings.local.json** | 过期权限堆积，污染权限列表 | 逐条检查 allow 命令中的路径是否仍存在 |
| 6 | **只扫 AI协作工具/skills/ 的 SKILL.md** | 领域 Skill 断链、版本缺失不会被发现 | 全量 SKILL.md 扫描 |

## 铁律

- **改动即审核**：结构性改动后立即触发，不等青城说
- **全量不抽样**：11 层框架组件全部检查，一层不落
- **联动不孤立**：修一处，查全部引用点（宪法、Skill、Hook、Cron 都可能引用同一路径）
- **修复必回写**：报告 → 修复 → 重跑 → 追加日志，形成闭环
- **权限变更需确认**：settings.local.json 的过期权限清理涉及安全，不自动删，标 ℹ️ 等青城确认
