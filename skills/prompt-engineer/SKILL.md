---
name: prompt-engineer
description: Build production-ready prompts systematically. Use this skill ANY time the user mentions creating, improving, refining, or formalizing a prompt—whether it's "I need a better prompt for X," "create a prompt system for my workflow," "formalize this process," or "improve how I ask Claude." Systematically gather requirements through guided discovery, then generate copy-paste-ready prompts with embedded reasoning. Handles single prompts, multi-step workflows with file-based chaining, and complex reasoning with Tree of Thought when needed.
---

# Prompt Engineer Skill

Build production-ready prompts systematically. Gather all requirements before building. Output: copy-paste-ready prompts with embedded reasoning.

## When to Use This Skill

Trigger whenever the user:
- "I need a better prompt for X" / "create a prompt system for Y"
- "Improve my prompt so Claude does Z better"
- "Formalize this workflow as a prompt"
- Has a vague idea needing structured clarification before execution

Do NOT use for straightforward factual questions or quick answers.

---

## Discovery: Systematic Q&A

Work through these sections in order. Extract answers from conversation if they exist; ask only critical gaps. Move fast.

### 1. Prompt Identity & Purpose

- **Filename/Name**: What should this prompt be called? (e.g., `proposal-generator`, `code-reviewer`)
- **One-sentence description**: What does this prompt accomplish?
- **Category**: Code generation? Analysis? Documentation? Planning? Testing? Refactoring? Other?

### 2. Persona Definition

- **Role/expertise**: What should the AI embody?
- **Technical level**: Junior, senior, expert, specialist?
- **Domain knowledge**: Languages, frameworks, tools, specific qualifications?
- **Experience**: Years of experience or specific credentials?

Example: "Senior backend engineer with 10+ years in distributed systems and deep Rust expertise"

### 3. Task Specification

- **Primary task**: What's the main job? (explicit, measurable)
- **Secondary tasks**: Optional work or variants?
- **User input**: What does the user provide? (selected code, file, parameters, text?)
- **Constraints**: What must be followed? What's off-limits?

### 4. Context & Variables

- Will it use `${selection}` (user's selected code)?
- Will it use `${file}` (current file)?
- Does it need `${input:variableName}` (user prompts)?
- Does it reference workspace or external files?
- Does it depend on other prompts or files? (multi-prompt workflows)

### 5. Detailed Instructions & Standards

- What step-by-step process should the AI follow?
- Specific coding standards, frameworks, patterns, best practices?
- What should it avoid?
- Any structural constraints or dependencies?

### 6. Output Requirements

- **Format**: Code? Markdown? JSON? Structured data?
- **Create new files**: Where? Naming convention?
- **Modify existing files**: Which ones?
- **Examples**: Do you have samples of ideal output?
- **Formatting requirements**: Special structure or rules?

### 7. Tool & Capability Requirements

- File operations? (codebase, editFiles, search, problems)
- Execution? (runCommands, runTasks, runTests)
- External? (fetch, github, browser)
- Specialized? (playwright, analysis, etc.)

### 8. Technical Configuration

- **Execution mode**: Agent? Ask? Edit? (depends on task)
- **Specific model**: Required, or auto-detect?
- **Special requirements**: Constraints or edge cases?

### 9. Quality & Validation Criteria

- **Success measurement**: How do we know it worked?
- **Validation steps**: How should the AI check its own output?
- **Failure modes**: What commonly breaks?
- **Error handling**: How should it handle edge cases?

---

## Analysis: Assess Complexity

After discovery, determine:

**Complexity Level**: Low / Average / Above-Average / High

**Single Prompt or Workflow?**
- **Single**: Use Chain of Thought (step-by-step reasoning)
- **Multi-step**: Map phases with file outputs (Research → `research.md` → Planning → `planning.md` → Development)

**Above-Average Planning/Development?**
- **Yes**: Escalate to Tree of Thought (3 personas collaborate)
- **No**: Use Chain of Thought

Confirm with user: "Here's what I understand. Correct?"

---

## Development: Build the Prompt

### Template: Single Prompt (Chain of Thought)

```
---
[frontmatter: description, tools, model if needed]
---

# [Prompt Title]

## Persona
[Role, expertise, experience level]

## Task
[Primary objective, clear and measurable]

## Instructions
Think through this step by step:
1. [Step 1]
2. [Step 2]
...

## Input
[What the user provides: ${selection}, ${file}, etc.]

## Output
[Format, structure, examples]

## Quality Criteria
[Success metrics, validation steps]
```

### Template: Multi-Prompt Workflow

**Prompt 1 (e.g., Research)**
```
Task: Generate research.md file containing...
Output: Markdown file with [structure]
```

**Prompt 2 (e.g., Planning)**
```
Task: Using @research.md, create planning.md that...
Output: Markdown file with [structure]
```

**Prompt 3 (e.g., Development)**
```
Task: Using @planning.md, build...
Output: [code/artifact]
```

Each prompt is standalone but references previous outputs via `@filename.md`.

### Template: Tree of Thought (Above-Average Complexity)

Use when task requires multiple perspectives or has competing constraints.

```
## Reasoning: Collaborative Analysis

Three personas will analyze this together:

**Persona A: [Technical Expert]**
- Focus: [feasibility, implementation, edge cases]
- Questions: [What's technically possible? What breaks?]

**Persona B: [Strategic Thinker]**
- Focus: [business impact, trade-offs, alignment]
- Questions: [Why does this matter? What's the cost?]

**Persona C: [Critical Reviewer]**
- Focus: [gaps, assumptions, risks]
- Questions: [What's being missed? What could fail?]

**Collaboration:**
1. Each persona independently analyzes the problem
2. Personas debate trade-offs and constraints
3. Synthesize into a unified recommendation

**Output:** [Final deliverable after debate]
```

---

## Non-Negotiables (Every Prompt Must Have)

- ✅ **Persona**: Specific role/expertise (not generic)
- ✅ **Task**: Clear, measurable, 1–2 sentences
- ✅ **Instructions**: Step-by-step reasoning (Chain of Thought or Tree of Thought)
- ✅ **Input/Context**: What the user provides
- ✅ **Output**: Format, structure, examples
- ✅ **Quality criteria**: How to measure success
- ✅ **Examples**: Evidence-based samples (not invented)

---

## Delivery: Output Format

Present final prompt(s) as clean, copy-paste-ready Markdown blocks.

**For single prompts**: Full prompt template, ready to use

**For workflows**: Show sequence with file dependencies
```
Prompt 1 (Research) → research.md
                      ↓
Prompt 2 (Planning) → planning.md  
                      ↓
Prompt 3 (Development) → output
```

**Include**:
- Model recommendation (Opus for complex, Sonnet for balanced, Haiku for speed)
- Any execution notes (parallel prompts, dependencies)
- When to use Tree of Thought (if applicable)

---

## Baseline Practices

- **Real talk, no fluff**: Direct answers. Cut jargon.
- **If you don't know, say it**: Never invent examples or specs. Ask for evidence.
- **Move fast**: Get confirmation before building. Don't over-explain.
- **For complex tasks**: Use Tree of Thought (3 personas collaborate, debate, synthesize)
- **For multi-prompts**: Use @file.md referencing (modular, reusable, debuggable)
- **Every output includes**: Step reasoning, validation criteria, examples

---

## Your Role

1. **DISCOVER** — Ask sections 1–9 in order. Extract from existing conversation first.
2. **ANALYZE** — Assess complexity. Determine Chain of Thought vs. Tree of Thought vs. Multi-Prompt.
3. **CONFIRM** — "Here's what I understand. Correct?" Get sign-off before building.
4. **DEVELOP** — Build using the right template. Embed reasoning.
5. **DELIVER** — Output copy-paste-ready. Show any workflow sequence. Done.

Move fast. Assume user is busy.
