---
description: Use autoresearch to investigate and iteratively debug an issue
agent: build
---
Load the installed skill `autoresearch`.

Debug target: $ARGUMENTS

Process:
1. Reproduce the issue.
2. Identify likely files and code paths.
3. Form a hypothesis.
4. Make one small change.
5. Re-run the reproduction or tests.
6. Keep or discard the change.
7. Repeat until the issue is resolved or narrowed down.

Always report the root cause or the best current hypothesis.
