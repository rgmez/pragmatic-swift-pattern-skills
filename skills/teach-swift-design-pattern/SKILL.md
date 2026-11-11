---
name: teach-swift-design-pattern
description: Turn verified Swift pattern code and tests into a standalone evidence-first teaching guide with a direct baseline, turning point, diagram, trade-offs, alternatives, and when-not-to-use guidance. Use for documentation and learning artifacts; not for choosing architecture or inventing missing implementation evidence.
license: MIT
---

# Teach Swift Design Pattern

Create a guide that helps a reader decide, not memorize. The pattern name is the conclusion of the story, not its opening argument.

## Entry gate

Require verified code, relevant tests, and a current app requirement. If the implementation is incomplete or the pressure exists only in prose, report the missing evidence instead of presenting the pattern as earned.

Do not change production architecture to make the document easier to write. Route implementation work to `implement-swift-design-pattern` and decision work to `choose-swift-design-pattern` when those skills are available.

## Reading experience

Read the synced [pattern README template](references/pattern-readme-template.md) for the complete content contract. Read [README experience](references/readme-experience.md) when the target repository uses long-form GitHub documentation or needs mobile-friendly navigation.

Every guide must let the reader answer quickly:

- What app problem exists now?
- What is the smallest direct Swift solution?
- What changed and why is a local refactor insufficient?
- Which responsibility moves to the pattern boundary?
- What complexity is added?
- Which nearby alternative loses and why?
- When should the pattern be removed or avoided?

## Workflow

1. Verify names, signatures, commands, behavior, and tests against the source.
2. Write an `At a glance` summary covering problem, direct baseline, use signal, and keep-it-simple signal.
3. Explain the app problem and invariants before describing the pattern.
4. Preserve the direct solution and make the turning point concrete and measurable.
5. Describe participants by app responsibility rather than GoF placeholder names.
6. Trace one real input through the Swift implementation to an observable result or error.
7. Add one domain-specific Mermaid diagram and an equivalent accessible description.
8. Document exact run/test commands, trade-offs, closest alternatives, `When not to use it`, and a source map.
9. End the decision with one concrete reversal signal: the requirement that removes the pattern, changes the infrastructure boundary, or makes the direct design preferable again.

## Visuals

Read [visual contract](references/visual-style.md) only when the target repository uses the RG editorial system or requests a compatible header. Otherwise preserve the target's existing visual authority.

The synced pattern template is evidence from the RG catalogue, not a universal asset-path requirement. In another repository, preserve its content sequence but replace or omit the editorial header and RG-specific paths rather than creating nonexistent assets.

An editorial image communicates one thesis; Mermaid explains code relationships, sequence, or state. Neither replaces behavioral evidence. Never let an image generator recreate a supplied logo or final typography.

## Boundaries

- Do not paste generic pattern definitions from a book.
- Do not claim a benchmark, memory saving, concurrency guarantee, or platform behavior that tests or measurements do not establish.
- Do not create a class per participant when Swift values, enums, functions, actors, or native APIs express the responsibility more clearly.
- Do not hide known limitations, invalid alternatives, or renderer/tooling gaps.
- Keep each prose paragraph and list item on one logical Markdown line unless the target repository requires another style.

## Response contract

Return the guide path, evidence used, commands verified, diagram type, visual status, known limits, and any architecture fact that could not be confirmed. Do not mark the guide complete while source, tests, links, or terminology disagree.
