import json
import sys
import re
from urllib.parse import urlparse

# Pre-compiled patterns for performance
_COMMON_SUFFIX_RE = [
    re.compile(p + '$') for p in [
        r"-x86_64-unknown-linux-gnu\.tar\.gz",
        r"-aarch64-unknown-linux-gnu\.tar\.gz",
        r"-x86_64-unknown-linux-musl\.tar\.gz",
        r"-aarch64-unknown-linux-musl\.tar\.gz",
        r"-x86_64-apple-darwin\.tar\.gz",
        r"-aarch64-apple-darwin\.tar\.gz",
        r"_linux_amd64\.tar\.gz",
        r"_Linux_x86_64\.tar\.gz",
        r"_linux_arm64\.tar\.gz",
        r"_windows_amd64\.zip",
        r"-win-x64\.zip",
        r"\.tar\.gz",
        r"\.tgz",
        r"\.tar\.bz2",
        r"\.tbz2",
        r"\.tar\.xz",
        r"\.txz",
        r"\.zip",
        r"\.gz",
        r"\.bz2",
        r"\.xz",
        r"\.deb",
        r"\.rpm",
        r"-x86_64-unknown-linux-gnu",
        r"-aarch64-unknown-linux-gnu",
        r"-x86_64-unknown-linux-musl",
        r"-aarch64-unknown-linux-musl",
        r"-x86_64-apple-darwin",
        r"-aarch64-apple-darwin",
        r"_linux_amd64",
        r"_Linux_x86_64",
        r"_linux_arm64",
        r"-amd64",
        r"-arm64",
        r"-x86_64",
        r"-i686",
        r"-x64",
        r"-x86",
        r"-linux",
        r"-windows",
        r"-darwin",
    ]
]

def extract_meta(url):
    parsed = urlparse(url)
    path_parts = [p for p in parsed.path.split('/') if p]
    
    repo = ""
    example_tag = ""
    asset_filename = ""
    tool_name_guess = ""

    # Try to match GitHub release download URL structure
    # e.g., https://github.com/owner/repo/releases/download/v1.2.3/asset-v1.2.3-arch.tar.gz
    if "github.com" in parsed.netloc and len(path_parts) >= 5 and \
       path_parts[2] == "releases" and path_parts[3] == "download":
        repo = f"{path_parts[0]}/{path_parts[1]}"
        example_tag = path_parts[4]
        asset_filename = path_parts[-1]
        
        # Initial tool_name_guess from repo name
        if repo:
            tool_name_guess = repo.split('/')[-1]

        # Attempt to refine tool_name_guess from asset_filename
        # This is a heuristic process and might need further tuning
        temp_name = asset_filename
        
        # 1. Remove version (bare and with 'v') if present in filename, using example_tag
        #    This helps isolate the tool name from version strings.
        if example_tag:
            # Remove tag with 'v' (e.g., "v0.25.0")
            temp_name = temp_name.replace(example_tag, "")
            # Remove tag without 'v' (e.g., "0.25.0")
            temp_name = temp_name.replace(example_tag.lstrip('v'), "")

        # 2. Remove common architecture/platform indicators and extensions
        #    Order can be important here. Regex might be more robust but complex.
        for pat in _COMMON_SUFFIX_RE:
            temp_name = pat.sub('', temp_name)

        # 3. Clean up common separators and "v" prefixes that might remain
        #    e.g., if tool is "name-v" and version was "1.0", we might have "name-v"
        #    or if original was "tool_name_v1.0", after removing version it's "tool_name_"
        temp_name = temp_name.strip('-_v.')
        
        # 4. If after stripping, temp_name is not empty, use it. Otherwise, stick to repo name.
        if temp_name:
            # If the name still contains delimiters like '-' or '_', it might be compound.
            # Often the first part is the actual tool name (e.g. "gh_2.4.0" -> "gh")
            # This is a simple heuristic, could be more sophisticated.
            parts = re.split(r'[-_]', temp_name)
            if parts and parts[0]: # Ensure the first part is not empty
                 tool_name_guess = parts[0]
            elif temp_name: # if no delimiters, but temp_name is valid
                 tool_name_guess = temp_name
        # else: tool_name_guess remains the repo's name part.

    return {
        "repo": repo,
        "example_tag": example_tag,
        "asset_filename": asset_filename,
        "tool_name_guess": tool_name_guess
    }

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Ensure the output is always a JSON, even if some fields are empty
        result = extract_meta(sys.argv[1])
        print(json.dumps(result))
    else:
        print("Usage: python url_meta_extractor.py <url>", file=sys.stderr)
        # Output empty JSON on usage error to prevent Zsh script from breaking on empty input
        print(json.dumps({
            "repo": "", "example_tag": "", "asset_filename": "", "tool_name_guess": ""
        }))
        sys.exit(1) 
