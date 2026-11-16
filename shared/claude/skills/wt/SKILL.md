---
name: wt
description: Draft and create an issue (GitHub with gh, Gitea with tea), start a task for it with `wt new -i`, list tasks and their Claude's state, and, only when the user asks, read a task's screen or send its Claude a message. Use when the user, in a repo's main checkout, wants an issue made, a task started, or to check on or talk to a task.
---

# wt: issues and tasks from the main checkout

A task is a git worktree on its own branch, opened by `wt` in its own Rex session with two
tabs: `claude` (a Claude Code started on the task's issue) and `shell`. You run in the
repo's main checkout and hand work out as tasks. You don't work on tasks yourself.

## Which tracker

`git remote get-url origin` names the host. SSH host aliases need resolving:
`ssh -G <alias> | awk '/^hostname /{print $2}'`.

- `github.com`: use `gh`, with `-R OWNER/REPO`.
- A host that `tea login list` knows: use `tea`, with `--repo OWNER/REPO --login HOST`
  (tea can't always tell the repo from the folder).

## Create an issue

1. Draft a title and body. The body is the brief the task's Claude starts from, so write
   it for someone with no context: the goal, why, what's in and out of scope, where in
   the code to start, and how to tell it's done. Keep it short.
2. Show the user the draft and wait for their OK or changes. Never create an issue
   without it.
3. Create it, passing the body on stdin:
   - `gh issue create -R OWNER/REPO --title "…" --body-file -`
   - `tea issues create --repo OWNER/REPO --login HOST --title "…" --description-file -`
4. Note the issue number from the output.

## Start a task

`wt new -i <number>` in the main checkout. It names the branch after the issue, creates
the worktree, and opens the Rex session, where Claude reads the issue and documents its
work on it. Tell the user the session's name; they switch to it in Rex's sidebar.

Start several tasks by running it once per issue. Don't pass a title unless the user
wants one.

## Check on tasks

`wt ls` lists the tasks: name, branch, issue, the state of the task's Claude (`working`,
`waiting on you`, `done`, `idle`, `error`) and `*` for uncommitted changes. The user sees
the same in Rex's Activity sidebar (`cmd+.`).

## Read a task's screen or message its Claude (only when the user asks)

Find the task's session ID in the main checkout:
`git config branch.<branch>.wtRexSession`.

- Read: `rex capture -s <id> -w claude --trim | tail -60`
- Message: `rex send -s <id> -w claude "<text>"`, then `rex send-key -s <id> -w claude enter`.

Only send what the user asked to send, and say what you sent.

## Don't

- Remove tasks (`wt rm`, `wt gc`), unless the user asks.
- Commit, push or edit files in a task's worktree.
