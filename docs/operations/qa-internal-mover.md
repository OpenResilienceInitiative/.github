# Moving merged issues to QA internal

The scheduled mover considers issues explicitly closed by a PR merged into `dev`. A `Refs` link alone is not a completion signal. The move means the issue is ready for internal QA; it is not proof of deployment or a passed product acceptance test.

The mover leaves an issue untouched when it has no assignee, the PR has no non-dismissed human approval on the exact merged head, any human reviewer still requests changes, a referenced PR remains open, or review, cross-reference or project data is missing or paginated. It does not infer an assignee, request a review on a merged PR, or treat a comment from a merger as a review. This is deliberately conservative: an unrelated referenced PR may hold an issue for manual triage, while unlinked dependencies cannot be proven absent. It never replaces a human's product-scope decision.

The schedule retains its three-hour lookback. An outage longer than that needs a separate explicitly reviewed recovery plan; do not silently expand the write window. The workflow continues to fail if `ORISO_PROJECT_AUTOMATION_TOKEN` is missing. Its credential owner and visibility must be verified separately; an unrelated workflow-deployment PAT is not a substitute. Before any activation or recovery, inspect the workflow, credential scope and owner, and a dry-run summary. Do not treat an empty dry run or a green unit test as proof that the secret, access, historical backlog or live project changes work.

## Credential and activation gate

First identify the owner of the existing automation credential and check whether the expected secret already exists and is shared to this repository. A missing repository-visible secret does not establish that no organization secret exists. Do not create a new token, change visibility or grant access until that check and the approved credential scope have been reviewed. The existing `ORG_GITHUB_TOKEN` is documented for workflow deployment, not established as the project-writing credential.

After the source change is human-reviewed and merged through the approved branch procedure, the credential owner can verify the dedicated secret and its least-privilege scope, run a bounded read-only dry run and inspect its proposed changes. A live run or outage recovery needs its own reviewed authorization and window. The operator's CLI read access does not prove that the workflow credential exists or can write.
