# Skills Marketplace

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Documentation-based skills** for Claude Code, Claude Desktop, and any AI tool supporting skills. Specialized workflows for SEO audits, AI search optimization, music creation, smart contract security, LinkedIn personal branding, and developer tools.

---

## Quick Install

### Claude Code
```bash
/plugin marketplace add schwepps/skills
```

### Claude Desktop / Other Tools
```bash
git clone https://github.com/schwepps/skills.git
cd skills && ./scripts/build-skills.sh
```
Find packaged skills in `dist/`, then add to your tool's skills directory.

---

## What's Included

| Skill | What It Does |
|-------|--------------|
| **[seo-technical-audit](seo-technical-audit/)** | Crawlability, Core Web Vitals 2025, AI crawler optimization |
| **[seo-content-audit](seo-content-audit/)** | On-page SEO scoring with E-E-A-T analysis |
| **[geo-aeo-optimization](geo-aeo-optimization/)** | Optimize for ChatGPT, Perplexity, Google AI Overviews |
| **[suno-music-creator](suno-music-creator/)** | Professional music creation with Suno AI V5 |
| **[solidity-auditor](solidity-auditor/)** | Smart contract security audits with OWASP Top 10 coverage |
| **[install-skill](install-skill/)** | Automate skill package installation and marketplace registration |
| **[linkedin-personal-branding](linkedin-personal-branding/)** | LinkedIn profile analysis, personal branding audit, and visibility optimization |

## Usage Examples

### SEO
```
"Perform a technical SEO audit on https://example.com"
"Score this content for E-E-A-T signals"
"Optimize my site for AI answer engines"
```

### Music
```
"Create an upbeat pop track for a product video"
"Compose ambient music for a meditation app"
```

### Security
```
"Audit this Solidity contract for vulnerabilities"
"Review my smart contract's gas usage"
"Check this DeFi protocol for reentrancy issues"
```

### Marketing
```
"Audit my LinkedIn profile for personal branding"
"Optimize my LinkedIn headline and About section"
"Analyze my LinkedIn engagement and content strategy"
```

### Tooling
```
"Install the skill from dist/my-skill.skill"
"Add a new skill to the marketplace"
"Unpack and register this skill package"
```

## How Skills Work

Skills are **pure markdown** - no code, no dependencies. Each skill contains:
- `SKILL.md` - Main skill definition with triggers and workflow
- `references/` - Supporting documentation and checklists

Skills auto-activate based on your natural language requests.

## Manual Installation

Each skill includes a `references/` folder. You need the **entire skill folder**, not just SKILL.md.

**Option 1: Build Script**
```bash
./scripts/build-skills.sh           # All skills
./scripts/build-skills.sh seo-technical-audit  # Single skill
```

**Option 2: Direct Copy**
```bash
cp -r skills/seo-technical-audit ./my-project/
```
Then reference in your project's `CLAUDE.md`:
```markdown
@seo-technical-audit/SKILL.md
```

### Browser Download (No Git Required)

Download individual skills directly as ZIP files - no git or command line needed:

| Skill | Direct Download |
|-------|-----------------|
| SEO Technical Audit | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/seo-technical-audit) |
| SEO Content Audit | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/seo-content-audit) |
| GEO/AEO Optimization | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/geo-aeo-optimization) |
| Suno Music Creator | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/suno-music-creator) |
| Solidity Auditor | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/solidity-auditor) |
| Install Skill | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/install-skill) |
| LinkedIn Personal Branding | [Download ZIP](https://download-directory.github.io/?url=https://github.com/schwepps/skills/tree/main/linkedin-personal-branding) |

*Powered by [download-directory.github.io](https://download-directory.github.io)*

## Project Structure

```
skills/
├── .claude-plugin/
│   └── marketplace.json     # Skill registry
├── scripts/
│   └── build-skills.sh      # Packaging script
├── seo-technical-audit/
├── seo-content-audit/
├── geo-aeo-optimization/
├── suno-music-creator/
├── solidity-auditor/
├── install-skill/
├── linkedin-personal-branding/
└── CLAUDE.md                # Contributor guide
```

## Contributing

See [CLAUDE.md](CLAUDE.md) for creating new skills.

```bash
mkdir -p skill-name/references
# Add SKILL.md with frontmatter
# Register in .claude-plugin/marketplace.json
```

## FAQ

**Do I need all skills?** No. Each skill only activates on relevant requests.

**Which tools are supported?** Any tool that accepts markdown-based skills: Claude Code, Claude Desktop, and compatible AI assistants.

**Are skills free?** Yes, MIT licensed. Some reference paid services (e.g., Suno).

## License

MIT
