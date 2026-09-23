---
description: >-
  An agent reviews the inline comments in a YAML file by its own ideas. The
  agent keeps each comment that reads well. A comment that explains what its
  line does or why reads well and stays, and so does one that names a private
  host, address or credential. The kept explanations bury the few comments
  that name a condition or an option, and the kept private info reaches anyone
  who reads the repository. This skill asks the agent to review a YAML file's
  inline comments by the steps below, not by its own ideas.
---

Review a YAML file's inline comments:
1. Cut private info from each comment.
2. Cut each comment that explains what its line does or why, unless it names a condition or an option.
3. Report the outcome with the `reporting-outcomes` skill.
