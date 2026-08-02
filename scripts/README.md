# Evidence rollout

`publish-evidence.mjs` is the single publisher for the whole organisation. The
reusable workflow fetches it at run time, so a repository opting in carries only
the small caller file and never a copy of this logic.

It talks to the evidence gateway over HTTP and uses `gh` for the pull request
comment, so a runner needs no cross-repository install step and holds no token
beyond the workflow's own `GITHUB_TOKEN`.

## Opting a repository in

```bash
# See what would happen first.
DRY_RUN=1 ./deploy-workflows.sh ORISO-E2E ORISO-Frontend ORISO-Admin

# Then open the pull requests.
./deploy-workflows.sh ORISO-E2E ORISO-Frontend ORISO-Admin
```

It opens a pull request per repository rather than pushing to a branch: a
workflow that appears in someone's repository without review is a workflow
nobody trusts. Repositories that already have the caller are skipped, and ORISO
repositories are targeted at `pre-dev` rather than their default branch.

## What a repository needs

- The caller workflow, which `deploy-workflows.sh` adds.
- An `ORISO_EVIDENCE_TOKEN` secret: a project-scoped evidence identity.
  **Never a MinIO key** — the gateway is the only thing that holds those.

Until that secret exists the workflow does nothing and does not fail, so
merging the caller cannot break a repository's CI.

## What it deliberately does not do

- It does not replace a repository's tests. It runs after them and reports what
  they produced.
- It does not depend on CodeRabbit or any other review automation.
- It publishes at most one comment per run. A scheduled run with no pull
  request stays a private draft with no public address.
- A repository with no artefacts is skipped with a notice, not a failure —
  unless it passes `require-evidence: true`, which turns missing evidence into
  a visible error.
