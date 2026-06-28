---
name: token审计
description: 运转层上下文占用审计。扫描宪法链+Skill描述的token开销，找冗余直接修。触发：「token审计」「上下文优化」「运转层审计」「上下文太重」；周复盘后顺带提议。
---

# Token 审计

> v1.3 · 2026-06-16

目标：让运转层尽可能轻。读完即跑，跑完即修。

## 流程

### 1. 算常驻成本

```bash
# 根宪法
wc -c CLAUDE.md soul.md ~/.claude/CLAUDE.md
# 工具索引段
sed -n '/^## 工具索引/,/^## 最近变更/p' CLAUDE.md | wc -c
# Skill 描述合计（-L 跟随软链接，grep 不用 ^ 锚点因为 YAML 缩进）
find -L .claude/skills -name "SKILL.md" -exec grep "description:" {} \; | wc -c
# Hook 消息 + Cron 提示词
grep 'MESSAGES+=' AI协作工具/hooks/session-start.sh | wc -c
jq -r '.tasks[].prompt' .claude/scheduled_tasks.json 2>/dev/null | wc -c
# Memory
wc -c ~/.claude/projects/*/memory/MEMORY.md 2>/dev/null
```

输出一张表，token 估算 = 字符数 / 2.5。

### 2. 找浪费并修

三刀：

| 切哪 | 怎么切 | 方法 |
|------|--------|------|
| 工具索引 | 每条从「能力+触发词堆砌」压到「能力一句+触发一个」。手写精简版效果好于脚本，脚本绕三圈不如直接改 | 手写新索引替换 |
| Skill 描述 | >100 字符的 description 精简：去实现细节、去触发词堆砌、去方法论描述。自建 Skill 激进（40-60 字符），外部 Skill 保守（60-120 字符） | Python 批量替换 |
| 多头 description | 部分 SKILL.md frontmatter 有重复 description 行 → 只保留第一条 | Python 去重 |

**外部 Skill 保守原则**：baoyu-*、gstack-*、perspective-* 等第三方 Skill 的 description 是原作者写的，砍太狠可能影响触发准确度。只砍明显冗余（>300 字符且含方法论描述），<150 字符的不管。

### 3. 修后验证

```bash
# 重跑步骤 1 全部命令，对比优化前后的差值
```

### 4. 写报告

`00-运转日志/框架审计/YYYY-MM-DD-token审计.md`：

```markdown
# Token 审计 · YYYY-MM-DD

常驻上下文：~XX,XXX tokens（同比 ±X%）

## 发现与修复
| 组件 | 优化前 | 优化后 | 节省 |
|------|--------|--------|------|
| 宪法链·根宪法 | ... | ... | ... |
| 工具箱·描述 | ... | ... | ... |

## 修复记录
[每次修改的时间/操作/结果]
```

## 铁律

- **审计自身要轻**：四条 bash 并行跑，2 秒出数据。不翻 Skill 全文，不扫规则质量
- **跑完即修**：不堆报告。🔴 直接修不确认，涉及宪法原则的标 🟡
- **手写优于脚本**：工具索引这类结构化但语义敏感的文本，手写精简版效果远超正则。脚本绕三圈不如直接改
- **外部保守内部激进**：自建 Skill description 可以砍到 40 字符，外部 Skill 留 60-120 字符兜底
- **find 要带 -L**：`.claude/skills/` 下全是软链接，不带 `-L` 会跳过所有文件
- **grep description 别加 ^**：YAML frontmatter 里 description 有缩进，`^description:` 永远匹配不到
