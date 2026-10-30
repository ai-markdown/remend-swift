#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$repo_root"
evidence_dir="$repo_root/.build/upstream-input-contract"
mkdir -p "$evidence_dir"
swift build > "$evidence_dir/build.log" 2>&1
binary_dir="$(swift build --show-bin-path)"
cat > "$evidence_dir/valid.swift" <<'SWIFT'
import Remend
let result: String = try remend("text")
SWIFT
swiftc -typecheck -I "$binary_dir" -I "$binary_dir/Modules" "$evidence_dir/valid.swift" > "$evidence_dir/valid.log" 2>&1
cat > "$evidence_dir/null.swift" <<'SWIFT'
import Remend
let result = try remend(nil)
SWIFT
cat > "$evidence_dir/absence.swift" <<'SWIFT'
import Remend
let content: String? = nil
let result = try remend(content)
SWIFT
cat > "$evidence_dir/integer.swift" <<'SWIFT'
import Remend
let result = try remend(123)
SWIFT
for input in null absence integer; do
  if swiftc -typecheck -I "$binary_dir" -I "$binary_dir/Modules" "$evidence_dir/$input.swift" > "$evidence_dir/$input.log" 2>&1; then
    echo "Expected String API to reject $input input" >&2
    exit 1
  fi
  if ! grep -Eq 'not compatible|cannot convert|optional type|must be unwrapped' "$evidence_dir/$input.log"; then
    echo "Unexpected diagnostic for $input; inspect $evidence_dir/$input.log" >&2
    exit 1
  fi
done
printf '%s\n' 'Verified String input contract: valid String accepted; nil, Optional<String>, and integer rejected.'
