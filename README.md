# 🌠 Stella-Regis Archetype

Welcome to the official repository for the **Stella-Regis** archetype. This is a custom Yu-Gi-Oh! archetype designed for use in the **EDOPro** simulator. The archetype focuses on Xyz mechanics that specialized field control.

---

## 🛠️ How to Add to EDOPro

To use these cards in your EDOPro client, follow these steps to link this repository:

1. **Locate your EDOPro folder**: Open the main directory where your EDOPro executable is located.
2. **Open the Config folder**: Navigate to `config`.
3. **Edit user_configs.json**: Open the `user_configs.json` file with a text editor (like Notepad++ or VS Code).
4. **Update the Repos Array**: Find the `"repos": [` section and paste the following block inside the square brackets:

```json
{
  "url": "https://github.com/Danang-Bahtiar/YGO-StellaRegis",
  "repo_name": "Custom Updates",
  "repo_path": "./repositories/custom",
  "has_core": false,
  "data_path": "",
  "script_path": "stella-script",
  "should_update": true,
  "should_read": true
}