#!/bin/sh
# claude-desktop-profiles installer.
#
# Builds the "Claude Profiles" app into ~/Applications (SwiftUI when the
# Swift toolchain is available, AppleScript dialog otherwise) and links the
# cdp CLI onto your PATH when possible. Everything is built locally on your
# machine — nothing is downloaded, nothing needs notarization.

set -e
cd "$(dirname "$0")"

CDP="$PWD/bin/cdp"
chmod +x "$CDP"

if command -v swiftc >/dev/null 2>&1; then
    "$CDP" gui
else
    echo "swiftc not found — installing the dialog-based chooser instead."
    echo "For the full GUI: xcode-select --install, then re-run ./install.sh"
    "$CDP" chooser
fi

# Best-effort CLI symlink into the first writable bin dir already on PATH;
# the GUI is fully usable without it.
linked=""
for dir in /usr/local/bin /opt/homebrew/bin "$HOME/.local/bin"; do
    case ":$PATH:" in *":$dir:"*) ;; *) continue ;; esac
    [ -d "$dir" ] && [ -w "$dir" ] || continue
    ln -sf "$CDP" "$dir/cdp" && linked="$dir" && break
done
if [ -n "$linked" ]; then
    echo "✓ cdp linked into $linked"
else
    echo "ℹ No writable bin dir on PATH. For the CLI, add to PATH:"
    echo "    export PATH=\"$PWD/bin:\$PATH\""
fi

echo ""
echo "Done. Hit ⌘Space and type: Claude Profiles"
