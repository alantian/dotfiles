# macOS: Homebrew (Apple Silicon and Intel locations)
path_prepend /usr/local/bin
path_prepend /opt/homebrew/bin   # last prepend wins: Apple Silicon brew first
# Our toolchain (proto shims, ~/.local/bin, npm globals) must shadow any
# Homebrew copies of node/uv/python; re-assert our order in front of Homebrew.
user_path_setup
