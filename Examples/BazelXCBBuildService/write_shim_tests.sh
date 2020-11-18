#!/bin/bash

set -euo pipefail

# --- begin runfiles.bash initialization ---
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    if [[ -f "$0.runfiles_manifest" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
    elif [[ -f "$0.runfiles/MANIFEST" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
    elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
      export RUNFILES_DIR="$0.runfiles"
    fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

readonly stub="$TEST_UNDECLARED_OUTPUTS_DIR/stub"
readonly output="$TEST_UNDECLARED_OUTPUTS_DIR/output"
readonly log_base="$TEST_UNDECLARED_OUTPUTS_DIR/log/stub"

readonly stdout="$TEST_UNDECLARED_OUTPUTS_DIR/stdout"
readonly stderr="$TEST_UNDECLARED_OUTPUTS_DIR/stderr"
readonly err_log="$log_base.err.log"
readonly traced_in="$log_base.in"
readonly traced_out="$log_base.out"

# Create stub executable
cat <<-END > "$stub"
#!/bin/bash

echo "Hello, stdout!"
echo >&2 "Hello, stderr!"
END

chmod +x "$stub"

# Execute
"$(rlocation $TEST_WORKSPACE/BazelXCBBuildService/write_shim.sh)" "$stub" "$output" "11.6" "$log_base"

# Ensure that the shim runs
echo "Hello, stdin!" | "$output" > "$stdout" 2> "$stderr"

echo "Hello, stdout!" | cmp "$stdout" -
echo "Hello, stderr!" | cmp "$err_log" -
[ ! -s "$stderr" ]
[ ! -s "$traced_in" ]
[ ! -s "$traced_out" ]

# Ensure that tracing works
echo "Hello, stdin!" | env BAZELXCBBUILDSERVICE_CAPTURE_IO=true "$output" > "$stdout" 2> "$stderr"

echo "Hello, stdout!" | cmp "$stdout" -
echo "Hello, stderr!" | cmp "$err_log" -
[ ! -s "$stderr" ]
echo "Hello, stdin!" | cmp "$traced_in" -
echo "Hello, stdout!" | cmp "$traced_out" -
