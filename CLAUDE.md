# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code skills marketplace repository** containing documentation-based skills that extend Claude Code with specialized workflows. Skills are pure markdown - no build system, dependencies, or executable code.

## Project Structure

```
skills/
├── .claude-plugin/
│   ├── marketplace.json        # Full marketplace (all skills)
│   ├── marketplace-seo.json    # SEO skills only
│   └── marketplace-music.json  # Music skills only
├── scripts/
│   └── build-skills.sh         # Build script for packaging
├── dist/                       # Generated packages (after build)
├── skill-name/
│   ├── SKILL.md                # Required: Main skill definition
│   └── references/             # Optional: Supporting documentation
│       └── *.md files
└── CLAUDE.md
```

## Creating a New Skill

### 1. Create Skill Directory

```bash
mkdir -p skill-name/references
touch skill-name/SKILL.md
```

### 2. SKILL.md Frontmatter

```yaml
---
name: skill-name
description: This skill should be used when the user asks to "specific phrase 1", "specific phrase 2", or "specific phrase 3". Be concrete about trigger conditions.
license: MIT
metadata:
  author: Schwepps
  version: "1.0.0"
  category: marketing|music|development|etc
  tags: tag1, tag2, tag3
---
```

**Critical**: The `description` field determines when Claude activates the skill:
- Use third-person phrasing: "This skill should be used when..."
- Include exact phrases users would say to trigger it
- Be specific and concrete, not vague

### 3. SKILL.md Content Structure

After frontmatter, include:
- **When to Use**: Clear activation criteria
- **Workflow/Methodology**: Phased approach with specific steps
- **Output Format**: Template showing expected deliverable structure
- **Scoring Guide** (for audits): Quantitative evaluation criteria
- **Quick Version**: Abbreviated workflow for rapid execution

### 4. Reference Files

Place supporting materials in `references/`:
- Checklists with verification steps
- Templates and examples
- Tool commands and configurations
- Domain-specific guides

## Marketplace Registration

Add new skills to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "skill-name",
      "type": "skill",
      "path": "skill-name",
      "description": "One-line description of the skill",
      "category": "seo",
      "tags": ["tag1", "tag2", "tag3"]
    }
  ]
}
```

Also add to the appropriate category marketplace (`marketplace-seo.json` or `marketplace-music.json`).

## Conventions

| Aspect | Standard |
|--------|----------|
| Naming | kebab-case for directories and skill names |
| License | MIT |
| Author | Schwepps |
| Version | Semver, start at 1.0.0 |
| Categories | seo, music (extensible) |
| Tags | Lowercase, comma-separated |

## Content Patterns

Established patterns from existing skills:

- **Phased workflows**: Phase 1, Phase 2, etc. with clear deliverables
- **Scoring rubrics**: 0-100 scale with tiers (90-100 Excellent, 70-89 Good, 50-69 Needs Work, <50 Critical)
- **Status indicators**: [Good], [Needs Work], [Critical]
- **Checklists**: Use □ for unchecked items
- **Priority actions**: Immediate → Short-term → Ongoing
- **Output tables**: Markdown tables for structured data
