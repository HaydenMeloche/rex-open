---
name: setup
description: Set up rex-open in Rex. Installs the Rex module and adds its key bindings to ~/.config/rex/init.lua.
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/../../scripts/setup.sh)
---

The rex-open setup script ran. Its output:

```!
${CLAUDE_SKILL_DIR}/../../scripts/setup.sh
```

Tell the user in one or two sentences what happened, based only on the output
above. If it finished, mention the keys it lists and that they can change them
in the rex-open block in ~/.config/rex/init.lua. If it stopped, say why
and what to do. Don't run any other commands.
