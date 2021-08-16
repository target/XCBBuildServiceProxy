#!/bin/bash

set -euo pipefail

readonly service_path="$1"
readonly output_path="$2"
readonly xcode_version="$3"
readonly log_base="${4:-"/tmp/Bazel-trace/XCBBuildService-$xcode_version"}"

cat <<-END > "$output_path"
#!/bin/bash

set -euo pipefail

readonly original_service_path="\${BASH_SOURCE[0]}.original"
readonly replacement_service_path="$service_path"

if [ -s "\$replacement_service_path" ]; then
    # Use the version installed next to it
    readonly default_log_level=debug
    readonly service="\${ACTUAL_XCBBUILDSERVICE_PATH:-"\$replacement_service_path"}"
else
    # Otherwise, call the original
    readonly default_log_level=info
    readonly service="\${ACTUAL_XCBBUILDSERVICE_PATH:-"\$original_service_path"}"
fi

export BAZELXCBBUILDSERVICE_LOGLEVEL=\${BAZELXCBBUILDSERVICE_LOGLEVEL:-\$default_log_level}

if [ -s "$log_base.err.log" ]; then
    /bin/cp -f "$log_base.err.log" "$log_base.err.last.log" || true
fi

/bin/mkdir -p "$(dirname "$log_base")"
if [ "\${BAZELXCBBUILDSERVICE_CAPTURE_IO:-}" != "" ]; then
    if [ -s "$log_base.in" ]; then
        /bin/cp -f "$log_base.in" "$log_base.last.in" || true
    fi
    if [ -s "$log_base.out" ]; then
        /bin/cp -f "$log_base.out" "$log_base.last.out" || true
    fi

    /usr/bin/tee "$log_base.in" | "\$service" 2> "$log_base.err.log" | /usr/bin/tee "$log_base.out"
else
    "\$service" 2> "$log_base.err.log"
fi
END

chmod +x "$output_path"
