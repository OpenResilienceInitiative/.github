import os
import unittest

os.environ["ACTIVE_PEOPLE"] = "author,merger,shazia-k,hassan,old,newer"

from qa_internal_mover import parse_closing_refs, pick_assignee, pick_reviewer

ORG, REPO = "OpenResilienceInitiative", "ORISO-Frontend"


def user(login):
    return {"__typename": "User", "login": login}


def bot(login):
    return {"__typename": "Bot", "login": login}


def pr(**kw):
    base = {"author": user("author"), "mergedBy": user("merger"), "assignees": {"nodes": []},
            "reviews": {"nodes": []}, "reviewRequests": {"nodes": []},
            "comments": {"nodes": []}, "timelineItems": {"nodes": []}}
    base.update(kw)
    return base


def issue(**kw):
    base = {"assignees": {"nodes": []}, "comments": {"nodes": []}, "timelineItems": {"nodes": []}}
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


class PickPeople(unittest.TestCase):
    def test_human_review_counts_and_bots_do_not(self):
        p = pr(reviews={"nodes": [{"author": bot("coderabbitai")}, {"author": user("shazia-k")}]})
        self.assertEqual(pick_reviewer(p), ("shazia-k", "reviewed the PR", True))

    def test_only_bot_review_falls_back_to_merger(self):
        p = pr(reviews={"nodes": [{"author": bot("coderabbitai")}, {"author": user("author")}]})
        self.assertEqual(pick_reviewer(p), ("merger", "merged the PR", False))

    def test_earlier_review_request_beats_merger(self):
        p = pr(timelineItems={"nodes": [{"requestedReviewer": user("hassan")}]})
        self.assertEqual(pick_reviewer(p)[0], "hassan")

    def test_self_merge_without_history_has_no_reviewer(self):
        p = pr(mergedBy=user("author"))
        self.assertEqual(pick_reviewer(p), (None, None, False))

    def test_people_who_left_are_never_derived(self):
        p = pr(timelineItems={"nodes": [{"requestedReviewer": user("joro4b")}]})
        self.assertEqual(pick_reviewer(p)[0], "merger")

    def test_assignee_prefers_earlier_assignee_then_pr_author(self):
        i = issue(timelineItems={"nodes": [{"assignee": user("old")}, {"assignee": user("newer")}]})
        self.assertEqual(pick_assignee(i, pr())[0], "newer")
        self.assertEqual(pick_assignee(issue(), pr()), ("author", "author of the PR"))


if __name__ == "__main__":
    unittest.main()
