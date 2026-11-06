import os
import unittest

os.environ["ACTIVE_PEOPLE"] = "author,merger,shazia-k,hassan,old,newer"

from unittest.mock import patch
from qa_internal_mover import parse_closing_refs, pick_reviewer, handle_issue

ORG, REPO = "OpenResilienceInitiative", "ORISO-Frontend"


def user(login):
    return {"__typename": "User", "login": login}


def bot(login):
    return {"__typename": "Bot", "login": login}


def pr(**kw):
    base = {"number": 1, "url": "https://example.invalid/pr/1", "headRefOid": "head-sha", "author": user("author"), "mergedBy": user("merger"), "assignees": {"nodes": []},
            "reviews": {"nodes": [], "pageInfo": {"hasPreviousPage": False}}, "reviewRequests": {"nodes": []},
            "comments": {"nodes": []}, "timelineItems": {"nodes": []}}
    base.update(kw)
    return base


def issue(**kw):
    base = {"id": "issue", "number": 2, "url": "https://example.invalid/issues/2", "title": "Synthetic issue", "assignees": {"nodes": []}, "comments": {"nodes": [], "pageInfo": {"hasPreviousPage": False}}, "timelineItems": {"nodes": []}}
    base.update(kw)
    return base


class ParseClosingRefs(unittest.TestCase):
    def test_closing_keywords_in_all_forms(self):
        body = ("Closes OpenResilienceInitiative/ORISO-Helm#428 · Refs OpenResilienceInitiative/ORISO-Helm#282\n"
                "Fixes #12, #13 and ORISO-Admin#7.\n"
                "resolves https://github.com/OpenResilienceInitiative/ORISO-Docs/issues/122")
        self.assertEqual(parse_closing_refs(body, ORG, REPO), [
            (ORG, "ORISO-Helm", 428), (ORG, REPO, 12), (ORG, REPO, 13),
            (ORG, "ORISO-Admin", 7), (ORG, "ORISO-Docs", 122)])

    def test_refs_and_part_of_do_not_move(self):
        body = "Refs #1188. Part of #1219 (one ticket). This PR closes both on `dev`."
        self.assertEqual(parse_closing_refs(body, ORG, REPO), [])


    def test_other_orgs_are_ignored(self):
        body = "Closes evil/repo#1, https://github.com/evil/repo/issues/2 and #3"
        self.assertEqual(parse_closing_refs(body, ORG, REPO), [(ORG, REPO, 3)])


class PickPeople(unittest.TestCase):
    def test_human_review_counts_and_bots_do_not(self):
        p = pr(reviews={"nodes": [{"author": bot("coderabbitai"), "state": "APPROVED", "commit": {"oid": "head-sha"}}, {"author": user("shazia-k"), "state": "APPROVED", "commit": {"oid": "head-sha"}}], "pageInfo": {"hasPreviousPage": False}})
        self.assertEqual(pick_reviewer(p), ("shazia-k", "reviewed the PR", True))

    def test_only_bot_review_does_not_count(self):
        p = pr(reviews={"nodes": [{"author": bot("coderabbitai")}, {"author": user("author")}]})
        self.assertEqual(pick_reviewer(p), (None, None, False))

    def test_review_request_does_not_count(self):
        p = pr(timelineItems={"nodes": [{"requestedReviewer": user("hassan")}]})
        self.assertIsNone(pick_reviewer(p)[0])

    def test_self_merge_without_history_has_no_reviewer(self):
        p = pr(mergedBy=user("author"))
        self.assertEqual(pick_reviewer(p), (None, None, False))

    def test_inactive_person_is_not_used_as_reviewer(self):
        p = pr(timelineItems={"nodes": [{"requestedReviewer": user("joro4b")}]})
        self.assertIsNone(pick_reviewer(p)[0])



class FailClosedMoves(unittest.TestCase):
    def test_missing_real_review_never_writes(self):
        record = issue(assignees={'nodes': [user('old')]}, projectItems={'nodes': [], 'pageInfo': {'hasNextPage': False}}, linkedPullRequests={'nodes': [], 'pageInfo': {'hasNextPage': False}})
        with patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest:
            gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
            rest.return_value = {'id': 1}
            handle_issue(pr(), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), (None, None, False), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
            gql.assert_not_called()
            rest.assert_not_called()

    def test_missing_assignee_never_writes(self):
        record = issue(projectItems={'nodes': [], 'pageInfo': {'hasNextPage': False}}, linkedPullRequests={'nodes': [], 'pageInfo': {'hasNextPage': False}})
        with patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest:
            gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
            rest.return_value = {'id': 1}
            handle_issue(pr(author=None, assignees={'nodes': []}), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), ('shazia-k', 'reviewed', True), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
            gql.assert_not_called()
            rest.assert_not_called()

    def test_open_closing_pull_request_or_incomplete_results_never_write(self):
        for refs in ({'nodes': [{'source': {'__typename': 'PullRequest', 'state': 'OPEN'}}], 'pageInfo': {'hasNextPage': False}}, {'nodes': [], 'pageInfo': {'hasNextPage': True}}):
            record = issue(assignees={'nodes': [user('old')]}, projectItems={'nodes': [], 'pageInfo': {'hasNextPage': False}}, linkedPullRequests=refs)
            with self.subTest(refs=refs), patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest:
                gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
                rest.return_value = {'id': 1}
                handle_issue(pr(), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), ('shazia-k', 'reviewed', True), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
                gql.assert_not_called()
                rest.assert_not_called()

    def test_unavailable_reference_and_paginated_project_inventory_never_write(self):
        for refs, projects in [({'nodes': [{'source': None}], 'pageInfo': {'hasNextPage': False}}, {'nodes': [], 'pageInfo': {'hasNextPage': False}}),
                               ({'nodes': [], 'pageInfo': {'hasNextPage': False}}, {'nodes': [], 'pageInfo': {'hasNextPage': True}})]:
            record = issue(assignees={'nodes': [user('old')]}, projectItems=projects, linkedPullRequests=refs)
            with self.subTest(refs=refs, projects=projects), patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest:
                gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
                rest.return_value = {'id': 1}
                handle_issue(pr(), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), ('shazia-k', 'reviewed', True), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
                gql.assert_not_called()
                rest.assert_not_called()

    def test_reviewed_assigned_single_pr_can_move(self):
        record = issue(id='issue', number=2, assignees={'nodes': [user('old')]}, projectItems={'nodes': [{'id': 'item', 'project': {'id': 'p'}, 'fieldValueByName': {'name': 'In review'}}], 'pageInfo': {'hasNextPage': False}}, linkedPullRequests={'nodes': [{'source': {'__typename': 'PullRequest', 'state': 'MERGED'}}], 'pageInfo': {'hasNextPage': False}})
        with patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest, patch('qa_internal_mover.DRY_RUN', False):
            gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
            rest.return_value = {'id': 1}
            handle_issue(pr(url='https://example.invalid/pr/1'), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), ('shazia-k', 'reviewed', True), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
            gql.assert_called_once()
            rest.assert_called_once()

    def test_comment_does_not_clear_previous_change_request(self):
        reviews = [{'author': user('shazia-k'), 'state': 'CHANGES_REQUESTED'},
                   {'author': user('shazia-k'), 'state': 'COMMENTED'},
                   {'author': user('hassan'), 'state': 'APPROVED', 'commit': {'oid': 'head-sha'}}]
        p = pr(reviews={'nodes': reviews, 'pageInfo': {'hasPreviousPage': False}})
        self.assertFalse(pick_reviewer(p)[2])

    def test_inactive_reviewer_change_request_still_blocks(self):
        reviews = [{'author': user('former-member'), 'state': 'CHANGES_REQUESTED'},
                   {'author': user('shazia-k'), 'state': 'APPROVED', 'commit': {'oid': 'head-sha'}}]
        p = pr(reviews={'nodes': reviews, 'pageInfo': {'hasPreviousPage': False}})
        self.assertFalse(pick_reviewer(p)[2])

    def test_dismissal_and_truncated_review_history_fail_closed(self):
        for reviews in ({'nodes': [{'author': user('shazia-k'), 'state': 'APPROVED'}, {'author': user('shazia-k'), 'state': 'DISMISSED'}], 'pageInfo': {'hasPreviousPage': False}},
                        {'nodes': [{'author': user('shazia-k'), 'state': 'APPROVED'}], 'pageInfo': {'hasPreviousPage': True}}):
            self.assertFalse(pick_reviewer(pr(reviews=reviews))[2])

    def test_truncated_comment_history_never_replays_a_move(self):
        record = issue(comments={'nodes': [], 'pageInfo': {'hasPreviousPage': True}}, assignees={'nodes': [user('old')]}, projectItems={'nodes': [], 'pageInfo': {'hasNextPage': False}}, linkedPullRequests={'nodes': [], 'pageInfo': {'hasNextPage': False}})
        with patch('qa_internal_mover.gql') as gql, patch('qa_internal_mover.rest') as rest:
            gql.return_value = {'addProjectV2ItemById': {'item': {'id': 'project-item'}}, 'updateProjectV2ItemFieldValue': {'projectV2Item': {'id': 'project-item'}}}
            rest.return_value = {'id': 1}
            handle_issue(pr(), 'ORISO-Frontend#1', record, 'ORISO-Frontend#2', (ORG, REPO), ('shazia-k', 'reviewed', True), {'id': 'p', 'field_id': 'f', 'option_id': 'o'}, lambda _: None)
            gql.assert_not_called()
            rest.assert_not_called()

    def test_comment_or_stale_approval_never_count(self):
        for review in ({'author': user('shazia-k'), 'state': 'COMMENTED', 'commit': {'oid': 'head-sha'}},
                       {'author': user('shazia-k'), 'state': 'APPROVED', 'commit': {'oid': 'old-sha'}},
                       {'author': user('shazia-k'), 'state': 'APPROVED', 'commit': None}):
            self.assertFalse(pick_reviewer(pr(reviews={'nodes': [review], 'pageInfo': {'hasPreviousPage': False}}))[2])

    def test_dismissed_review_is_not_human_review_evidence(self):
        p = pr(reviews={'nodes': [{'author': user('shazia-k'), 'state': 'DISMISSED'}], 'pageInfo': {'hasPreviousPage': False}})
        self.assertFalse(pick_reviewer(p)[2])


if __name__ == "__main__":
    unittest.main()
