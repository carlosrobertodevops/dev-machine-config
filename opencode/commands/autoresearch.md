---
description: Run the autoresearch loop on a repository goal
agent: build
---
Load the installed skill `autoresearch` and follow it strictly.

Goal: $ARGUMENTS

Process:
1. Inspect the repository and identify the relevant files.
2. Define a measurable baseline and a verification command.
3. Propose the smallest useful first iteration.
4. Make one change at a time.
5. Run verification after each change.
6. Keep or discard the change based on the result.
7. Repeat until the goal is reached or improvement is no longer justified.

Prefer safe and reversible steps.
Always explain what changed and why.
