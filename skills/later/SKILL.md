# Later — Deferred Task Scheduler

user-invocable: true
command-name: later
description: Schedule a task to run during idle hours (23:00–07:00 SGT)

## Usage

`/later <task description>`

## Behavior

When triggered, schedule the task as a cron job:
- **Idle hours:** 23:00 – 07:00 SGT
- If already in idle hours, schedule to run in ~10 minutes
- If outside idle hours, schedule for 23:00 tonight
- Use `cron add` with `sessionTarget: "isolated"`, `payload.kind: "agentTurn"`
- Model: `anthropic/claude-opus-4-6`
- Delivery: `announce` (reports result back to chat)
- **No concurrency:** Check existing cron jobs first; stagger at least 10 minutes apart from other `/later` tasks
- Confirm the scheduled time to the user
