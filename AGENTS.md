# Repository collaboration

- All new development text is English, including documentation, code comments, test descriptions, diagnostics, and commit messages. Preserve upstream licensing and meaningful multilingual test inputs verbatim.
- This is an independent, native Swift port of remend. It must build and test without the AI Markdown workspace, JavaScript, or WebKit at runtime.
- Keep platform-neutral implementation in the Remend target. Follow SwiftPM's Sources/<Target> and Tests/<Target>Tests convention, with mirrored feature directories and dedicated Fixtures resources.
- Pin the upstream source version and exact source/license hashes. Preserve imported upstream evidence; do not silently update upstream while making unrelated changes.
- The ai-markdown branch carries the Swift implementation. Keep the upstream baseline separately auditable and record actual behavioral differences.
- Use Conventional Commits 1.0.0 in English. Run relevant tests before committing. The parent repository pins a concrete published commit and consumes a remote SwiftPM URL; development overrides are explicit.
