# Contributing

Contributions should improve a repeatable engineering decision, not expand pattern usage.

## Choose the correct surface

- Edit `SKILL.md` when the agent's reusable decision workflow is wrong or incomplete.
- Edit `README.md` when human installation, navigation, or explanation needs improvement.
- Edit handcrafted references when a conditional workflow needs deeper guidance.
- Do not edit generated references. Change `Design-Patterns-in-Swift` or `scripts/sync_from_catalogue.rb`, then synchronize.

## Add or change a skill

1. Keep the name action-oriented and the description discriminating.
2. State the trigger boundary and adjacent work the skill must refuse.
3. Preserve direct Swift and no-pattern outcomes where applicable.
4. Add references or scripts only when they remove repeated, error-prone work.
5. Keep external and destructive actions behind explicit authorization.
6. Update the human README with real inputs, outputs, examples, and limitations.

## Validate

```sh
ruby scripts/validate_skills.rb
ruby scripts/sync_from_catalogue.rb --source /path/to/Design-Patterns-in-Swift --check
```

For packaging or installation changes:

```sh
DISABLE_TELEMETRY=1 npx skills@1.7.2 add . --list
```

Use a temporary project and explicit agent IDs for installation smoke tests. Inspect the installed directories; a success message alone is not enough.

## Test behavior

Exercise at least one normal request and one request that should stop safely. Do not validate a skill only by matching wording or headings.

## Pull requests

Explain the observed failure, the smallest skill correction, validation evidence, and whether generated upstream references changed. Separate format validation, installation validation, and real host behavior.

## Commit messages

Use English subjects:

```text
New: Add evidence-led implementation skill
Fix: Stop catalogue audits from editing by default
Update: Sync pattern catalogue evidence
```

## License

Contributions are accepted under the repository's MIT License.
