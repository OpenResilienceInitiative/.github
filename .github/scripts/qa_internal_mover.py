#!/usr/bin/env python3
"""Move tickets closed by PRs merged into `dev` to "QA internal" on the ORISO Roadmap.

A ticket counts as delivered when a merged PR into `dev` names it with a closing
keyword (Closes/Fixes/Resolves). "Refs" and "Part of" mean partial work and are
ignored. Before the move the ticket must have an assignee and the PR a human
reviewer; when either is missing it is taken from the interaction history.

Environment:
  GH_TOKEN        token with org Projects read/write and Issues + Pull requests write
  ORG             default OpenResilienceInitiative
  PROJECT_NUMBER  default 1
  STATUS_NAME     default "QA internal"
  BASE_BRANCH     default dev
  LOOKBACK_HOURS  default 3
  DRY_RUN         "true" prints the plan and writes nothing
  ACTIVE_PEOPLE   comma list; only these are ever derived from the history
"""
import json
import os
import re
import sys
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone

API = "https://api.github.com"
ORG = os.environ.get("ORG", "OpenResilienceInitiative")
PROJECT_NUMBER = int(os.environ.get("PROJECT_NUMBER", "1"))
STATUS_NAME = os.environ.get("STATUS_NAME", "QA internal")
BASE_BRANCH = os.environ.get("BASE_BRANCH", "dev")
LOOKBACK_HOURS = float(os.environ.get("LOOKBACK_HOURS", "3"))
DRY_RUN = os.environ.get("DRY_RUN", "false").lower() in ("1", "true", "yes")

# Statuses a merge may advance from. On hold, QA and Done are left alone.
MOVABLE = {None, "Backlog", "Ready", "In progress", "In review"}
BOT_LOGINS = {"coderabbitai", "chatgpt-codex-connector", "copilot-pull-request-reviewer",
              "copilot", "github-actions", "dependabot"}
# Active roster (oriso-delivery reviewer routing). People who left stay in the
# history but must never be assigned or asked to review.
ACTIVE_PEOPLE = {p.strip().lower() for p in os.environ.get(
    "ACTIVE_PEOPLE", "shazia-k,Shirloin,Hassan9215,shanzaeimran,nikunjdecyb,Storypapst").split(",") if p.strip()}
MARKER = "<!-- oriso-qa-auto-move:{pr} -->"

CLOSING_RE = re.compile(
    r"\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\b:?\s+"
    r"((?:(?:https://github\.com/[\w.-]+/[\w.-]+/issues/\d+|(?:[\w.-]+/)?[\w.-]+#\d+|#\d+)"
    r"(?:\s*(?:,|and)\s*)?)+)",
    re.IGNORECASE)
REF_RE = re.compile(r"https://github\.com/([\w.-]+)/([\w.-]+)/issues/(\d+)|(?:([\w.-]+)/)?([\w.-]+)?#(\d+)")


def parse_closing_refs(body, org, repo):
    """Return [(owner, repo, number)] named with a closing keyword in a PR body."""
    refs = []
    for match in CLOSING_RE.finditer(body or ""):
        for r in REF_RE.finditer(match.group(1)):
            if r.group(3):
                ref = (r.group(1), r.group(2), int(r.group(3)))
            else:
                owner = r.group(4) or org
                name = r.group(5) or repo
                ref = (owner, name, int(r.group(6)))
            # Only tickets in our own org; a body may name anything.
            if ref[0].lower() == org.lower() and ref not in refs:
                refs.append(ref)
    return refs


def is_human(actor):
    if not actor or actor.get("__typename", "User") != "User":
        return False
    login = actor.get("login", "").lower()
    return not login.endswith("[bot]") and login not in BOT_LOGINS and login in ACTIVE_PEOPLE


def first_human(candidates, exclude=()):
    """First (login, reason) whose login is a human and not excluded."""
    for actor, reason in candidates:
        if is_human(actor) and actor["login"] not in exclude:
            return actor["login"], reason
    return None, None


# ---------------------------------------------------------------- GitHub I/O

def _request(method, url, payload=None):
    req = urllib.request.Request(url, method=method, data=json.dumps(payload).encode() if payload is not None else None)
    req.add_header("Authorization", f"Bearer {os.environ['GH_TOKEN']}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        body = resp.read()
        return json.loads(body) if body else None


def gql(query, **variables):
    data = _request("POST", f"{API}/graphql", {"query": query, "variables": variables})
    if data.get("errors"):
        raise RuntimeError(json.dumps(data["errors"]))
    return data["data"]


def rest(method, path, payload=None):
    return _request(method, f"{API}{path}", payload)


ACTOR = "__typename login"

SEARCH_Q = """
query($q: String!, $after: String) {
  search(query: $q, type: ISSUE, first: 50, after: $after) {
    pageInfo { hasNextPage endCursor }
    nodes { ... on PullRequest {
      number url body mergedAt lastEditedAt
      repository { name owner { login } }
      author { %(a)s } mergedBy { %(a)s }
      assignees(first: 10) { nodes { %(a)s } }
      reviews(first: 50) { nodes { author { %(a)s } } }
      reviewRequests(first: 10) { nodes { requestedReviewer { ... on User { %(a)s } } } }
      comments(last: 50) { nodes { author { %(a)s } } }
      timelineItems(last: 50, itemTypes: [REVIEW_REQUESTED_EVENT]) {
        nodes { ... on ReviewRequestedEvent { requestedReviewer { ... on User { %(a)s } } } } }
    } }
  }
}""" % {"a": ACTOR}

ISSUE_Q = """
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) { issue(number: $number) {
    id number url title
    assignees(first: 10) { nodes { %(a)s } }
    comments(last: 100) { nodes { body author { %(a)s } } }
    timelineItems(last: 50, itemTypes: [ASSIGNED_EVENT, UNASSIGNED_EVENT]) { nodes {
      ... on AssignedEvent { assignee { ... on User { %(a)s } } }
      ... on UnassignedEvent { assignee { ... on User { %(a)s } } } } }
    projectItems(first: 20) { nodes {
      id project { id }
      fieldValueByName(name: "Status") { ... on ProjectV2ItemFieldSingleSelectValue { name } } } }
  } }
}""" % {"a": ACTOR}

PROJECT_Q = """
query($org: String!, $number: Int!) {
  organization(login: $org) { projectV2(number: $number) {
    id field(name: "Status") { ... on ProjectV2SingleSelectField { id options { id name } } } } }
}"""


def merged_prs(since):
    q = f"org:{ORG} is:pr is:merged base:{BASE_BRANCH} merged:>={since.strftime('%Y-%m-%dT%H:%M:%SZ')}"
    after, prs = None, []
    while True:
        page = gql(SEARCH_Q, q=q, after=after)["search"]
        prs += [n for n in page["nodes"] if n]
        if not page["pageInfo"]["hasNextPage"]:
            return sorted(prs, key=lambda p: p["mergedAt"])
        after = page["pageInfo"]["endCursor"]


# ------------------------------------------------------------------- logic

def pick_assignee(issue, pr):
    """Who should own the ticket, from the interaction history, newest first."""
    history = []
    for ev in reversed(issue["timelineItems"]["nodes"]):
        history.append((ev.get("assignee"), "earlier assignee of the ticket"))
    history += [(a, "assignee of the PR") for a in pr["assignees"]["nodes"]]
    history.append((pr["author"], "author of the PR"))
    history += [(c["author"], "commented on the ticket") for c in reversed(issue["comments"]["nodes"])]
    return first_human(history)


def pick_reviewer(pr):
    """(login, reason, already_reviewed) for the PR's reviewer."""
    author = (pr["author"] or {}).get("login")
    reviewed, _ = first_human([(r["author"], "") for r in pr["reviews"]["nodes"]], exclude={author})
    if reviewed:
        return reviewed, "reviewed the PR", True
    history = [(r["requestedReviewer"], "review was requested") for r in pr["reviewRequests"]["nodes"]]
    history += [(e["requestedReviewer"], "review was requested earlier")
                for e in reversed(pr["timelineItems"]["nodes"])]
    history += [(c["author"], "commented on the PR") for c in reversed(pr["comments"]["nodes"])]
    history.append((pr["mergedBy"], "merged the PR"))
    login, reason = first_human(history, exclude={author})
    return login, reason, False


def process(pr, project, log):
    owner, repo = pr["repository"]["owner"]["login"], pr["repository"]["name"]
    pr_ref = f"{repo}#{pr['number']}"
    # The body is editable after the merge; only trust what was there when it merged.
    if pr.get("lastEditedAt") and pr["lastEditedAt"] > pr["mergedAt"]:
        log(f"- {pr_ref}: description edited after the merge, skipped (move the ticket by hand)")
        return
    refs = parse_closing_refs(pr["body"], ORG, repo) if owner.lower() == ORG.lower() else []
    if not refs:
        log(f"- {pr_ref}: no `Closes` reference, nothing to move")
        return
    reviewer, rev_reason, reviewed = pick_reviewer(pr)
    if reviewer and not reviewed:
        log(f"- {pr_ref}: no human review on record, reviewer `{reviewer}` ({rev_reason})")
        if not DRY_RUN:
            try:
                rest("POST", f"/repos/{owner}/{repo}/pulls/{pr['number']}/requested_reviewers",
                     {"reviewers": [reviewer]})
            except urllib.error.HTTPError as err:
                log(f"  - could not request review on merged PR ({err.code}); named in the ticket comment instead")
    for i_owner, i_repo, number in refs:
        try:
            issue = gql(ISSUE_Q, owner=i_owner, name=i_repo, number=number)["repository"]["issue"]
        except RuntimeError as err:
            log(f"- {pr_ref} -> {i_repo}#{number}: not an issue or not readable ({err})")
            continue
        handle_issue(pr, pr_ref, issue, f"{i_repo}#{number}", (i_owner, i_repo),
                     (reviewer, rev_reason, reviewed), project, log)


def handle_issue(pr, pr_ref, issue, ticket, issue_repo, review, project, log):
    marker = MARKER.format(pr=pr_ref)
    if any(marker in (c["body"] or "") for c in issue["comments"]["nodes"]):
        log(f"- {pr_ref} -> {ticket}: already handled earlier")
        return
    item = next((i for i in issue["projectItems"]["nodes"] if i["project"]["id"] == project["id"]), None)
    status = item and (item["fieldValueByName"] or {}).get("name")
    if status not in MOVABLE:
        log(f"- {pr_ref} -> {ticket}: status `{status}`, left alone")
        return

    lines = []
    assignees = [a["login"] for a in issue["assignees"]["nodes"]]
    if assignees:
        lines.append(f"- Assignee: {', '.join(f'`{a}`' for a in assignees)}")
    else:
        assignee, reason = pick_assignee(issue, pr)
        if assignee:
            lines.append(f"- Assignee: `{assignee}` (added by this automation: {reason})")
            if not DRY_RUN:
                rest("POST", f"/repos/{issue_repo[0]}/{issue_repo[1]}/issues/{issue['number']}/assignees",
                     {"assignees": [assignee]})
        else:
            lines.append("- Assignee: none found in the history, please set one")
    reviewer, rev_reason, reviewed = review
    if reviewer:
        note = "" if reviewed else f" (added by this automation: {rev_reason})"
        lines.append(f"- Reviewer: `{reviewer}`{note}")
    else:
        lines.append("- Reviewer: none found in the history, please name one")

    log(f"- {pr_ref} -> {ticket}: `{status}` -> `{STATUS_NAME}`")
    for line in lines:
        log(f"  {line}")
    if DRY_RUN:
        return
    item_id = item["id"] if item else gql(
        "mutation($p: ID!, $c: ID!) { addProjectV2ItemById(input: {projectId: $p, contentId: $c}) { item { id } } }",
        p=project["id"], c=issue["id"])["addProjectV2ItemById"]["item"]["id"]
    gql("""mutation($p: ID!, $i: ID!, $f: ID!, $o: String!) {
      updateProjectV2ItemFieldValue(input: {projectId: $p, itemId: $i, fieldId: $f,
        value: {singleSelectOptionId: $o}}) { projectV2Item { id } } }""",
        p=project["id"], i=item_id, f=project["field_id"], o=project["option_id"])
    merged_by = (pr["mergedBy"] or {}).get("login", "unknown")
    body = "\n".join([
        f"Moved to **{STATUS_NAME}**: {pr['url']} was merged into `{BASE_BRANCH}` by `{merged_by}`.",
        "", *lines, "",
        f"Test on Dev once the next `{BASE_BRANCH}` image is deployed.", marker])
    rest("POST", f"/repos/{issue_repo[0]}/{issue_repo[1]}/issues/{issue['number']}/comments", {"body": body})


def main():
    if not os.environ.get("GH_TOKEN"):
        sys.exit("GH_TOKEN is empty: set the ORISO_PROJECT_AUTOMATION_TOKEN secret")
    proj = gql(PROJECT_Q, org=ORG, number=PROJECT_NUMBER)["organization"]["projectV2"]
    option = next((o for o in proj["field"]["options"] if o["name"] == STATUS_NAME), None)
    if not option:
        sys.exit(f"Status option {STATUS_NAME!r} not found on project {PROJECT_NUMBER}")
    project = {"id": proj["id"], "field_id": proj["field"]["id"], "option_id": option["id"]}

    since = datetime.now(timezone.utc) - timedelta(hours=LOOKBACK_HOURS)
    out = [f"## Merged into `{BASE_BRANCH}` since {since:%Y-%m-%d %H:%M} UTC" + (" (dry run)" if DRY_RUN else "")]
    log = out.append
    failed = 0
    for pr in merged_prs(since):
        try:
            process(pr, project, log)
        except Exception as err:  # one bad PR must not stop the rest
            failed += 1
            log(f"- {pr['repository']['name']}#{pr['number']}: FAILED {err}")
    report = "\n".join(out)
    print(report)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as fh:
            fh.write(report + "\n")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
