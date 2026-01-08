# Skills Marketplace

Documentation-based skills extending Claude Code and Claude Desktop with specialized workflows for SEO, AI search optimization, and music creation.

## Installation

### Claude Code

```bash
# Full marketplace (all skills)
/plugin marketplace add schwepps/skills

# By category (if supported)
/plugin marketplace add schwepps/skills/seo
/plugin marketplace add schwepps/skills/music
```

### Claude Desktop

Each skill includes a `references/` folder with supporting documentation. You need the **entire skill folder**, not just SKILL.md.

**Option 1: Use Pre-built Combined Files (Easiest)**

1. Run the build script to generate combined files:
   ```bash
   git clone https://github.com/schwepps/skills.git
   cd skills

   # Build all skills
   ./scripts/build-skills.sh

   # Or build a single skill
   ./scripts/build-skills.sh suno-music-creator
   ```

2. Find your skill in `dist/`:
   - `skill-name.zip` - Full skill folder (preserves organized structure)

3. Extract and add to your project, then reference in your `CLAUDE.md`

**Option 2: Project Integration**

1. Clone and copy the skill folder into your project:
   ```bash
   git clone https://github.com/schwepps/skills.git
   cp -r skills/suno-music-creator ./my-project/
   ```

2. Reference in your project's `CLAUDE.md`:
   ```markdown
   @suno-music-creator/SKILL.md
   ```

> **Note**: Category-based installation requires platform support. If commands don't work, install the full marketplace or use manual installation.

## Available Skills

| Skill | Category | Description | Tags |
|-------|----------|-------------|------|
| [seo-technical-audit](seo-technical-audit/) | SEO | Technical SEO audits: crawlability, Core Web Vitals 2025, AI crawlers | `seo`, `technical-seo`, `audit` |
| [seo-content-audit](seo-content-audit/) | SEO | On-page SEO and content quality scoring with E-E-A-T analysis | `seo`, `content-audit`, `e-e-a-t` |
| [geo-aeo-optimization](geo-aeo-optimization/) | SEO | AI search optimization for ChatGPT, Perplexity, Google AI | `geo`, `aeo`, `ai-search` |
| [suno-music-creator](suno-music-creator/) | Music | Professional music creation with Suno AI V5 and Suno Studio | `music`, `suno`, `ai-music` |

## Usage Examples

### SEO Skills

```
"Perform a technical SEO audit on https://example.com"
"Audit crawlability and indexation for my website"
"Optimize this article for AI search engines like ChatGPT and Perplexity"
"Score this content on SEO quality and E-E-A-T signals"
"Check if my site is optimized for AI answer engines"
```

### Music Creation

```
"Create an upbeat pop track for a product video"
"Generate a 3-minute corporate anthem for our company launch"
"Make a workout playlist with high-energy EDM tracks"
"Compose ambient music for a meditation app"
"Create a jingle for a podcast intro"
```

## Project Structure

```
skills/
├── .claude-plugin/
│   ├── marketplace.json        # Full marketplace (all skills)
│   ├── marketplace-seo.json    # SEO skills only
│   └── marketplace-music.json  # Music skills only
├── scripts/
│   └── build-skills.sh         # Build script for Claude Desktop packages
├── dist/                       # Generated packages (after running build)
│   └── *.zip                   # Skill folders zipped
├── seo-technical-audit/
│   ├── SKILL.md                # Skill definition
│   └── references/             # Supporting documentation
├── seo-content-audit/
│   ├── SKILL.md
│   └── references/
├── geo-aeo-optimization/
│   ├── SKILL.md
│   └── references/
├── suno-music-creator/
│   ├── SKILL.md
│   └── references/
├── CLAUDE.md                   # Contributor guide
└── README.md
```

## Contributing

See [CLAUDE.md](CLAUDE.md) for detailed instructions on creating new skills.

### Quick Start

1. Create a skill directory: `mkdir -p skill-name/references`
2. Add `SKILL.md` with required frontmatter (name, description, license, metadata)
3. Register in `.claude-plugin/marketplace.json`

## FAQ

**Q: Do I need all skills installed?**
A: No, but currently the plugin system installs all skills together. Each skill only activates when you use relevant trigger phrases.

**Q: How do I know which skill is active?**
A: Claude automatically activates the appropriate skill based on your request. Check each skill's SKILL.md for trigger phrases.

**Q: Can I request a new skill?**
A: Yes! Open an issue on the repository with your skill idea.

**Q: Are the skills free to use?**
A: Yes, all skills are MIT licensed. Some skills (like suno-music-creator) reference paid external services.

## License

MIT
