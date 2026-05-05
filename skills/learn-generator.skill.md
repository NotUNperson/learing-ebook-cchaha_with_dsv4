---
name: learn-generator
description: |
  Generate a structured learning framework for any technical topic. Creates a directory tree of
  sequentially numbered markdown tutorials + runnable example files, with content tuned for absolute
  beginners. Use when the user asks to "create a learning framework", "build a tutorial series",
  "generate course content", or "organize knowledge about X into lessons". Also use when the user
  asks to "do it like the frontend trilogy" or "copy the larn/ pattern".
argument-hint: "<topic> [--audience <description>] [--language <zh|en>] [--depth <beginner|intermediate>]"
---

# Learning Framework Generator

Generate a full, structured, self-contained learning project for any technical topic. The output
mirrors the `larn/` frontend-trilogy pattern: numbered markdown tutorials paired with runnable
example files, all tuned for absolute beginners.

## Process Overview

### Phase 1: Design the framework (present to user BEFORE writing code)

1. **Decompose the topic** into 3–7 modules (e.g. Introduction → Core → Advanced → Applied).
2. **Within each module, list chapters.** Each chapter must answer exactly one clear question
   or teach one skill. A chapter is the smallest unit the user can finish in ~30 min (15 reading +
   15 hands-on).
3. **Chapter-splitting rules:**
   - One concept per chapter. If a chapter would naturally explain two unrelated things, split it.
   - A chapter that takes more than ~200 lines of markdown is too large; split it.
   - Leaf-level chapters are fine. Avoid "part 1 / part 2" when the parts are really about
     different sub-topics — split them explicitly.
   - Every module ends with an **integration exercise** (综合练习) that ties together all
     concepts from that module.
4. **Present the full numbered outline** to the user as a table. Ask for adjustments. Do NOT
   write any files until the user approves the framework.

### Phase 2: Set up the directory scaffold

```
<topic-slug>/
├── 00-<intro-module>/
├── 01-<module>/
│   └── examples/
├── 02-<module>/
│   └── examples/
└── ...
```

- Module directories use `NN-` prefix for ordering.
- Every module that needs code examples gets an `examples/` subdirectory.
- All paths use the user's project root.

### Phase 3: Write content (launch parallel agents)

For each module (or module-half if the module is large), launch a background `general-purpose`
agent with a prompt that follows this template:

---

**Agent prompt template:**

```
你是[领域]教学内容的写手。你需要在以下目录下创建 N 个 markdown 文件，
每个都配一个[文件类型]示例文件。

目录：[path]
代码示例放在：[path]/examples/

受众：[audience description]
读者已完成的前置内容：[prerequisites]

每个 markdown 文件必须包含：
- 标题（编号+章节名）
- "本节你会学到什么"（3-5 条要点，动词开头）
- 正文（用生活例子和类比讲清楚概念，像在跟朋友聊天。每个抽象概念至少配一个类比）
- 关键代码示例（嵌入 md，可复制即可运行）
- "动手试试"（一个小练习，能在 5 分钟内完成）
- "本节小结"（一句话）
- "下一节预告"

每个 md 对应一个[示例文件]：
- 完整可运行
- 有详细的中文注释解释每段代码的意图
- [encoding/runtime requirements]

请创建以下 N 个文件：
[numbered list of files with 1-sentence scope for each]

重要要求：
- 每节必须有实质内容，不能只是大纲
- 代码示例要完整且能运行
- 不要用 emoji
- 用最通俗的语言，假设读者是[level]
- [domain-specific quality rules]
```

---

**Agent dispatch rules:**
- ~7 chapters: 1 agent
- ~15 chapters: 1 agent
- ~30 chapters: split into 2 agents (1–15, 16–30)
- ~50+ chapters: split into 3+ agents
- All agents for a given module can run in parallel (they write to different files).
- Set `run_in_background: true` so all agents work simultaneously.

### Phase 4: Spot-check quality

After each agent completes, read 1–2 files at random and verify:
- [ ] Learning objectives are clear and actionable
- [ ] At least one concrete life analogy or metaphor
- [ ] Code example runs without errors
- [ ] "动手试试" section is specific (not "go read the docs")
- [ ] No emoji
- [ ] Language matches the audience level (no unexplained jargon)

If quality checks fail, re-launch that agent with a corrected prompt.

### Phase 5: Final report

When all agents complete:
1. Run `ls -R` or equivalent to get the full file tree.
2. Present a summary table: modules, chapter counts, example counts, total files.
3. Recommend a learning order.
4. Save project context to memory so future sessions resume from here.

## Writing Standards

### Content principles
- **Analogy-first**: Introduce every abstract concept with a concrete metaphor from daily life
  (外卖 for client-server, 快递盒 for box model, 族谱 for prototype chain).
- **Bridge from known**: If the user has prior knowledge (e.g. C language), add explicit
  comparisons: "In C you would X; in this language you Y instead."
- **Capstone every module**: The last chapter of each module is a 综合练习 that pulls together
  every concept from that module into one working project.
- **One breath, one section**: Each section within a chapter should be readable in one sitting
  without scrolling too much.

### Chapter structure template

```markdown
# <number> <title>

## 本节你会学到什么
- <verb> <outcome>
- <verb> <outcome>
- <verb> <outcome>

## 正文
### <section 1 — concept + analogy>
...

### <section 2 — code + explanation>
...

## 动手试试
1. ...
2. ...

## 本节小结
<one sentence>

## 下一节预告
<one sentence>
```

## Audience Configuration

When `--audience` is not specified, ask:
- What is their current level? (absolute beginner / knows another language / has some exposure)
- What is their goal? (job prep / academic / hobby project / exam prep)
- What prior knowledge can you bridge from? (mention specific languages or concepts)

For absolute beginners:
- No unexplained technical terms. Every term gets a first-use definition.
- Metaphors from everyday life, not from other programming domains.
- Code examples are short (< 30 lines) and produce visible output immediately.
- Each chapter is self-contained; don't assume they remember everything from previous chapters.

## Example: Frontend Trilogy

The user says:
> "整理前端三件套知识，包括导论、HTML、CSS、JavaScript（分语言核心和浏览器两部分）"

The framework produced:

| Module | Chapters | Examples |
|--------|----------|----------|
| 00 导论 | 7 | 0 |
| 01 HTML | 17 | 17 .html |
| 02 CSS | 26 | 26 .html |
| 03 JS-A 语言核心 | 30 | 30 .js |
| 03 JS-B 浏览器 | 18 | 18 .html |
| **Total** | **98** | **91** |

This was generated with 6 parallel agents (one per module-half), completing in parallel.
