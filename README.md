# WIBX SKILLs

<p align="center">
  <pre>
  _____________  __.___.____    .____       _________
 /   _____/    |/ _|   |    |   |    |     /   _____/
 \_____  \|      < |   |    |   |    |     \_____  \ 
 /        \    |  \|   |    |___|    |___  /        \
/_______  /____|__ \___|_______ \_______ \/_______  /
        \/        \/           \/       \/        \/ 
  </pre>
  <strong>The Central Hub for Wibx AI Skills</strong>
</p>

> A comprehensive collection of specialized AI skills designed to enhance productivity, automate workflows, and standardize AI capabilities across all departments at Wiboo.

---

## 🚀 Overview

This repository serves as the official, company-wide source of truth for AI skills. Whether it's for legal, marketing, engineering, or product, every skill here is built to be modular, reusable, and easily integrated into our agent ecosystems (Forge/Bifrost).

## 📦 Core Skills

Every skill in this repository is organized into its own folder containing the `.skill` package and a `MANUAL.md`.

| Skill Name | Folder | Description | Status |
| :--- | :--- | :--- | :--- |
| **Wibx Presentations** | [`/presentations`](./presentations) | Specialized skill for generating and refining corporate presentations. | `Active` |

## 🛠 How to Use

### 🧩 Installation in Claude

To install and use these skills in Claude Desktop:

1. **Download the Skill**: Locate the `.skill` file in the desired skill folder.
2. **Open Claude Settings**: In Claude Desktop, navigate to **Settings > Skills**.
3. **Import**: Click on **"Add Skill"** and upload the `.skill` file.
4. **Verify**: The skill should now be active and ready to use in your conversations.

> [!NOTE]
> If you are using Claude.ai (Web), you can extract the `.skill` file (it's a ZIP) and copy the contents of `SKILL.md` into your **Project Custom Instructions**.

### 💻 General Usage

1. **Clone the Repo**:
   ```bash
   git clone https://github.com/Wibx-LABS/wibx-skills.git
   ```
2. **Import Skill**: Import the desired `.skill` file into your agent environment (Forge, Bifrost, or Claude).
3. **Manuals**: Check the `MANUAL.md` inside each skill folder for specific usage instructions and features.

## 🤝 Contributing

We are constantly expanding our skill library! If you've created a skill that could benefit other teams:

1. Create a new branch for your skill.
2. Add the `.skill` file to the root (or appropriate subdirectory).
3. Update this `README.md` with the new skill's details.
4. Submit a Pull Request for review by the Wibx Labs team.

---

<p align="center">
  <strong>Built and maintained by the Wibx Labs team. Internal use only.</strong>
</p>

