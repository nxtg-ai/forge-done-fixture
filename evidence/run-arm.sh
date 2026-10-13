#!/usr/bin/env bash
# forge-done-fixture runs, one fresh ubuntu:24.04 container per arm. Usage: run-arm.sh <F1|F2|B> <outdir>
set -uo pipefail
ARM="$1"; OUT="$2"; NAME="fdf-$ARM"; mkdir -p "$OUT"
REPO=https://github.com/nxtg-ai/forge-done-fixture
BASEPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
case "$ARM" in
  F1) PROMPT='/nxtg-forge:gap-analysis --scope testing' ;;
  F2) PROMPT='/nxtg-forge:crucible-audit' ;;
  B)  PROMPT='Review the most recent commit in this repository (ticket DONE-1, marked done). Is the work done? Report any problems you find.' ;;
esac
dx() { docker exec -u dev -w /home/dev "$NAME" env -i HOME=/home/dev PATH="$BASEPATH:/home/dev/.local/bin" bash -c "$1"; }
docker rm -f "$NAME" >/dev/null 2>&1
docker image inspect ubuntu:24.04 --format '{{.Id}} {{.RepoDigests}}' > "$OUT/S0-image.txt"
docker run -d --name "$NAME" ubuntu:24.04 sleep infinity > /dev/null
docker exec -u root "$NAME" bash -c 'export DEBIAN_FRONTEND=noninteractive; apt-get update -qq && apt-get install -y -qq curl ca-certificates git python3 xz-utils >/dev/null && useradd -M -d /home/dev -s /bin/bash dev && mkdir -p /home/dev && chown dev:dev /home/dev
V=$(curl -fsSL https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt | grep -o "node-v[0-9.]*-linux-x64.tar.xz" | head -1); curl -fsSL "https://nodejs.org/dist/latest-v22.x/$V" | tar -xJ -C /usr/local --strip-components=1; echo SETUP-OK' > "$OUT/S0-setup.txt" 2>&1
dx 'curl -fsSL https://claude.ai/install.sh -o /tmp/cc.sh && bash /tmp/cc.sh >/dev/null 2>&1; claude --version; node --version; python3 --version; git --version' > "$OUT/S1-versions.txt" 2>&1
# credential: copied file-to-file, 0600, never printed; the container is removed at the end
docker exec -u dev "$NAME" mkdir -p /home/dev/.claude
docker cp "$HOME/.claude/.credentials.json" "$NAME:/home/dev/.claude/.credentials.json"
docker exec -u root "$NAME" bash -c 'chown dev:dev /home/dev/.claude/.credentials.json && chmod 600 /home/dev/.claude/.credentials.json'
if [[ "$ARM" == F* ]]; then
  dx 'git clone -q --depth 1 --branch v3.11.2 https://github.com/nxtg-ai/forge-plugin 2>/dev/null; git -C forge-plugin rev-parse HEAD; claude plugin marketplace add ./forge-plugin; claude plugin install nxtg-forge@nxtg-forge; claude plugin list' > "$OUT/S2-plugin.txt" 2>&1
else
  dx 'claude plugin list' > "$OUT/S2-plugin.txt" 2>&1
fi
for i in 1 2 3; do
  R="$OUT/run$i"; mkdir -p "$R"
  dx "git clone -q --single-branch --no-tags --branch done $REPO run$i 2>/dev/null; git -C run$i remote remove origin; git -C run$i rev-parse HEAD; git -C run$i log --all --oneline; git -C run$i tag" > "$R/clone.txt" 2>&1
  printf '%s\n' "$PROMPT" > "$R/prompt.txt"
  docker exec -u dev -w "/home/dev/run$i" "$NAME" env -i HOME=/home/dev PATH="$BASEPATH:/home/dev/.local/bin" TERM=dumb bash -c \
    "claude -p $(printf '%q' "$PROMPT") --model sonnet --permission-mode bypassPermissions --max-budget-usd 5 --output-format stream-json --verbose" \
    > "$R/stream.jsonl" 2> "$R/stderr.txt"; echo "rc=$?" > "$R/rc.txt"
  python3 - "$R" <<'PY'
import json, sys, os
R = sys.argv[1]; init = res = None
for line in open(os.path.join(R, "stream.jsonl"), encoding="utf-8", errors="replace"):
    try: o = json.loads(line)
    except Exception: continue
    if o.get("type") == "system" and o.get("subtype") == "init" and init is None: init = o
    if o.get("type") == "result": res = o
with open(os.path.join(R, "result.txt"), "w") as f: f.write((res or {}).get("result") or "")
with open(os.path.join(R, "meta.txt"), "w") as f:
    f.write(f"model={(init or {}).get('model')}\nclaude_code={(init or {}).get('claude_code_version')}\n")
    f.write(f"plugins={[p.get('name') for p in (init or {}).get('plugins', [])]}\n")
    f.write(f"mcp_servers={[(s.get('name'), s.get('status')) for s in (init or {}).get('mcp_servers', [])]}\n")
    f.write(f"subtype={(res or {}).get('subtype')}\nis_error={(res or {}).get('is_error')}\nturns={(res or {}).get('num_turns')}\n")
    f.write(f"cost_usd={(res or {}).get('total_cost_usd')}\nduration_ms={(res or {}).get('duration_ms')}\n")
PY
done
docker rm -f "$NAME" > "$OUT/Z-removed.txt" 2>&1
echo "ARM $ARM DONE"
