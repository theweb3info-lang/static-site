#!/usr/bin/env python3
"""TODO manager - JSON storage, rich display."""

import json
import sys
import uuid
from pathlib import Path
from datetime import datetime

TODO_FILE = Path(__file__).resolve().parent.parent / "todo.json"

def load():
    if not TODO_FILE.exists():
        return {"tasks": [], "groups": []}
    return json.loads(TODO_FILE.read_text())

def save(data):
    TODO_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2))

def add(text, group=None, priority="medium"):
    data = load()
    task = {
        "id": str(uuid.uuid4())[:8],
        "text": text,
        "group": group or "inbox",
        "priority": priority,
        "done": False,
        "created": datetime.now().isoformat(),
        "completed": None,
    }
    data["tasks"].append(task)
    if task["group"] not in data["groups"]:
        data["groups"].append(task["group"])
    save(data)
    return task

def done(task_id):
    data = load()
    for t in data["tasks"]:
        if t["id"] == task_id or str(data["tasks"].index(t) + 1) == str(task_id):
            t["done"] = True
            t["completed"] = datetime.now().isoformat()
            save(data)
            return t
    return None

def undone(task_id):
    data = load()
    for t in data["tasks"]:
        if t["id"] == task_id or str(data["tasks"].index(t) + 1) == str(task_id):
            t["done"] = False
            t["completed"] = None
            save(data)
            return t
    return None

def remove(task_id):
    data = load()
    for i, t in enumerate(data["tasks"]):
        if t["id"] == task_id or str(i + 1) == str(task_id):
            removed = data["tasks"].pop(i)
            save(data)
            return removed
    return None

def get_all():
    return load()["tasks"]

def get_pending(group=None):
    tasks = [t for t in get_all() if not t["done"]]
    if group:
        tasks = [t for t in tasks if t["group"] == group]
    return tasks

def get_done(group=None):
    tasks = [t for t in get_all() if t["done"]]
    if group:
        tasks = [t for t in tasks if t["group"] == group]
    return tasks

def summary():
    tasks = get_all()
    total = len(tasks)
    done_count = sum(1 for t in tasks if t["done"])
    pending = total - done_count
    groups = {}
    for t in tasks:
        g = t["group"]
        groups.setdefault(g, {"done": 0, "pending": 0})
        groups[g]["done" if t["done"] else "pending"] += 1
    high_pending = [t for t in tasks if t["priority"] == "high" and not t["done"]]
    return {
        "total": total, "done": done_count, "pending": pending,
        "groups": groups, "high_pending": high_pending
    }

def display_board():
    """Render a display board string."""
    data = load()
    tasks = data["tasks"]
    if not tasks:
        return "📋 **TODO Board**\n\n_No tasks yet._"

    s = summary()
    lines = [f"📋 **TODO Board** — {s['pending']} pending / {s['done']} done\n"]

    # Group by group
    by_group = {}
    for i, t in enumerate(tasks):
        by_group.setdefault(t["group"], []).append((i + 1, t))

    for group, items in by_group.items():
        pending = [x for x in items if not x[1]["done"]]
        completed = [x for x in items if x[1]["done"]]

        if pending or completed:
            lines.append(f"**#{group}**")

        for idx, t in pending:
            pri = {"high": "🔴", "low": "🔵"}.get(t["priority"], "")
            lines.append(f"  {idx}. ⬜{pri} {t['text']}")

        for idx, t in completed:
            lines.append(f"  {idx}. ✅ ~~{t['text']}~~")

        lines.append("")

    if s["high_pending"]:
        lines.append(f"⚠️ {len(s['high_pending'])} high-priority task(s) pending")

    return "\n".join(lines)

if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser(prog='todo')
    sub = p.add_subparsers(dest='cmd')

    a = sub.add_parser('add')
    a.add_argument('text', nargs='+')
    a.add_argument('-g', '--group', default='inbox')
    a.add_argument('-p', '--priority', choices=['high', 'medium', 'low'], default='medium')

    sub.add_parser('board')
    sub.add_parser('summary')

    d = sub.add_parser('done')
    d.add_argument('id')

    u = sub.add_parser('undone')
    u.add_argument('id')

    r = sub.add_parser('rm')
    r.add_argument('id')

    args = p.parse_args()
    if args.cmd == 'add':
        t = add(' '.join(args.text), args.group, args.priority)
        print(f"✅ Added: {t['text']} (#{t['group']})")
    elif args.cmd == 'done':
        t = done(args.id)
        print(f"✅ Done: {t['text']}" if t else "❌ Not found")
    elif args.cmd == 'undone':
        t = undone(args.id)
        print(f"↩️ Reopened: {t['text']}" if t else "❌ Not found")
    elif args.cmd == 'rm':
        t = remove(args.id)
        print(f"🗑️ Removed: {t['text']}" if t else "❌ Not found")
    elif args.cmd == 'board':
        print(display_board())
    elif args.cmd == 'summary':
        s = summary()
        print(f"📊 Total: {s['total']} | ✅ Done: {s['done']} | ⬜ Pending: {s['pending']}")
        for g, c in s['groups'].items():
            print(f"  #{g}: {c['pending']} pending, {c['done']} done")
    else:
        p.print_help()
