#!/usr/bin/env python3
"""Reset dotfiles: remove config symlinks and uninstall packages.

Tools are defined in reset.conf.yaml; symlinks come from install.conf.yaml.
Only symlinks that point into this repo are removed, never real files.

Usage:
  ./reset.py --list                         list tools
  ./reset.py [--dry-run] [--yes] TOOL...    reset specific tools
  ./reset.py [--dry-run] [--yes] --all      reset everything

On Windows: python reset.py ...
"""

import argparse
import os
import shutil
import subprocess
import sys

try:
    import yaml
except ImportError:
    sys.exit("error: PyYAML is required (dotbot needs it too): python3 -m pip install pyyaml")

REPO = os.path.dirname(os.path.realpath(__file__))
OS = {"darwin": "macos", "linux": "linux", "win32": "windows"}.get(sys.platform)

if sys.stdout.isatty():
    RED, GREEN, YELLOW, BLUE, NC = "\033[0;31m", "\033[0;32m", "\033[1;33m", "\033[0;34m", "\033[0m"
else:
    RED = GREEN = YELLOW = BLUE = NC = ""


def load_yaml(name):
    with open(os.path.join(REPO, name)) as f:
        return yaml.safe_load(f)


def install_links():
    """(destination, repo source) pairs for every link in install.conf.yaml."""
    links = []
    for directive in load_yaml("install.conf.yaml"):
        for dest, spec in (directive.get("link") or {}).items():
            source = spec["path"] if isinstance(spec, dict) else spec
            links.append((os.path.expanduser(dest), source))
    return list(dict.fromkeys(links))  # same link can be listed per OS


def owned(dest, source):
    """True if dest is a symlink that points at source in this repo."""
    return os.path.islink(dest) and os.path.realpath(dest) == os.path.realpath(os.path.join(REPO, source))


def under(source, prefixes):
    return any(source == p or source.startswith(p.rstrip("/") + "/") for p in prefixes)


def scoop():
    return shutil.which("scoop") or "scoop"


def installed(pkg):
    cmd = {
        "macos": ["brew", "list", pkg],
        "linux": ["pacman", "-Q", pkg],
        "windows": [scoop(), "prefix", pkg],
    }[OS]
    return subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0


def uninstall_cmd(pkgs):
    return {
        "macos": ["brew", "uninstall"] + pkgs,
        "linux": ["paru", "-Rns", "--noconfirm"] + pkgs,
        "windows": [scoop(), "uninstall"] + pkgs,
    }[OS]


def unlink(path):
    try:
        os.unlink(path)
    except (IsADirectoryError, PermissionError):
        os.rmdir(path)  # directory symlinks on Windows


def build_plan(names, tools, links, include_unclaimed):
    """Per tool: symlinks to remove, commands to run, installed packages to uninstall."""
    plan = []
    for name in names:
        tool = tools[name] or {}
        plan.append({
            "name": name,
            "links": [d for d, s in links if under(s, tool.get("links", [])) and owned(d, s)],
            "run": (tool.get("run") or {}).get(OS, []),
            "packages": [p for p in tool.get(OS, []) if installed(p)],
        })

    if include_unclaimed:
        claimed = [p for t in tools.values() for p in (t or {}).get("links", [])]
        rest = [d for d, s in links if not under(s, claimed) and owned(d, s)]
        if rest:
            plan.append({"name": "other links", "links": rest, "run": [], "packages": []})

    return [step for step in plan if step["links"] or step["run"] or step["packages"]]


def print_plan(plan):
    for step in plan:
        print(f"{BLUE}{step['name']}{NC}")
        for dest in step["links"]:
            print(f"  unlink     {dest}")
        for cmd in step["run"]:
            print(f"  run        {cmd}")
        if step["packages"]:
            print(f"  uninstall  {' '.join(step['packages'])}")


def execute(plan):
    failed = []
    for step in plan:
        print(f"{YELLOW}→{NC} Resetting {step['name']}...")
        try:
            for dest in step["links"]:
                unlink(dest)
            for cmd in step["run"]:
                subprocess.run(cmd, shell=True, check=True)
            if step["packages"]:
                subprocess.run(uninstall_cmd(step["packages"]), check=True)
        except (OSError, subprocess.CalledProcessError) as e:
            print(f"{RED}✗{NC} {step['name']}: {e}")
            failed.append(step["name"])
        else:
            print(f"{GREEN}✓{NC} {step['name']}")
    return failed


def main():
    parser = argparse.ArgumentParser(description="Remove dotfiles symlinks and uninstall packages.")
    parser.add_argument("tools", nargs="*", metavar="TOOL", help="tools to reset (see --list)")
    parser.add_argument("--all", action="store_true", help="reset every tool and remove all dotfiles symlinks")
    parser.add_argument("--list", action="store_true", help="list available tools")
    parser.add_argument("-n", "--dry-run", action="store_true", help="show what would be removed, change nothing")
    parser.add_argument("-y", "--yes", action="store_true", help="don't ask for confirmation")
    args = parser.parse_args()

    if OS is None:
        sys.exit(f"error: unsupported platform: {sys.platform}")

    tools = load_yaml("reset.conf.yaml")

    if args.list:
        print("\n".join(tools))
        return 0
    if args.all == bool(args.tools):
        parser.error("pass one or more tools, or --all")

    unknown = [t for t in args.tools if t not in tools]
    if unknown:
        parser.error(f"unknown tool(s): {', '.join(unknown)} (see --list)")

    names = list(tools) if args.all else list(dict.fromkeys(args.tools))
    plan = build_plan(names, tools, install_links(), include_unclaimed=args.all)

    if not plan:
        print(f"{GREEN}✓{NC} Nothing to reset")
        return 0

    print_plan(plan)
    if args.dry_run:
        return 0

    if not args.yes:
        try:
            answer = input("\nProceed? [y/N] ")
        except EOFError:
            answer = ""
        if answer.strip().lower() not in ("y", "yes"):
            print("Aborted")
            return 1

    print()
    failed = execute(plan)
    if failed:
        print(f"\n{RED}✗ Failed: {', '.join(failed)}{NC}")
        return 1
    print(f"\n{GREEN}✓ Reset complete{NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
