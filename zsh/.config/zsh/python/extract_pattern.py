#! /usr/bin/env python3
import sys
import os
import json

def extract_pattern(filename_asset, version_bare, known_arch_strings_json):
    """
    Extracts a download pattern from a filename, version, and known architectures.

    Args:
        filename_asset (str): The actual filename from the download URL.
        version_bare (str): The version string (e.g., "1.2.3") extracted from the URL tag.
                               Pass an empty string if no version is applicable or found.
        known_arch_strings_json (str): A JSON string representing a list of known architecture strings,
                                     expected to be sorted by length descending for prioritization.

    Returns:
        str: The generated pattern string (e.g., "tool-{VERSION}-{ARCH}.tar.gz")
             or the original filename if processing fails or results in a suspicious pattern.
    """
    try:
        known_arch_strings = json.loads(known_arch_strings_json)
        if not isinstance(known_arch_strings, list):
            # print(f"Debug Python: known_arch_strings_json did not decode to a list.", file=sys.stderr)
            return filename_asset
    except json.JSONDecodeError as e:
        # print(f"Debug Python: Error decoding known_arch_strings_json: {e}", file=sys.stderr)
        return filename_asset

    pattern_after_arch_replacement = filename_asset
    arch_found = False
    processed_arch_specifier = ""

    # print(f"Debug Python: Filename: '{filename_asset}', Version: '{version_bare}'", file=sys.stderr)

    # Step 1: Replace architecture string
    for arch_specifier in known_arch_strings:
        if arch_specifier and arch_specifier in pattern_after_arch_replacement:
            pattern_after_arch_replacement = pattern_after_arch_replacement.replace(arch_specifier, "{ARCH}", 1)
            arch_found = True
            processed_arch_specifier = arch_specifier
            # print(f"Debug Python: Replaced '{arch_specifier}' with {{ARCH}}. Pattern: {pattern_after_arch_replacement}", file=sys.stderr)
            break
    
    current_pattern = pattern_after_arch_replacement

    # Step 2: Replace version string
    # Only proceed if version_bare is not empty and is present in the current_pattern
    if version_bare and version_bare in current_pattern:
        # Protect {ARCH} before version replacement, if it exists and is distinct from version_bare
        temp_arch_placeholder = "___TEMP_ARCH_PY_PROTECTOR___"
        arch_was_protected = False

        if "{ARCH}" in current_pattern and (not processed_arch_specifier or version_bare not in processed_arch_specifier):
            current_pattern = current_pattern.replace("{ARCH}", temp_arch_placeholder, 1)
            arch_was_protected = True
            # print(f"Debug Python: Protected {{ARCH}}. Pattern: '{current_pattern}'", file=sys.stderr)

        # Replace the first occurrence of version_bare
        current_pattern = current_pattern.replace(version_bare, "{VERSION}", 1)
        # print(f"Debug Python: Replaced '{version_bare}' with {{VERSION}}. Pattern: '{current_pattern}'", file=sys.stderr)

        # Restore {ARCH} if it was protected
        if arch_was_protected and temp_arch_placeholder in current_pattern:
            current_pattern = current_pattern.replace(temp_arch_placeholder, "{ARCH}", 1)
            # print(f"Debug Python: Restored {{ARCH}}. Pattern: '{current_pattern}'", file=sys.stderr)
    
    final_pattern = current_pattern

    # Sanity checks for the final_pattern
    # 1. Check for suspicious nested/malformed placeholders like {VERSION-{ARCH... or {ARCH.tar.gz}
    if ("{VERSION}" in final_pattern and final_pattern.count("{VERSION}") * len("{VERSION}") != len("{VERSION}") * final_pattern.count("{")) or \
       ("{ARCH}" in final_pattern and final_pattern.count("{ARCH}") * len("{ARCH}") != len("{ARCH}") * final_pattern.count("{")) :
        if "." in final_pattern[final_pattern.find("{") : final_pattern.rfind("}")+1] and \
            (final_pattern.count("{") > (final_pattern.count("{VERSION}") if "{VERSION}" in final_pattern else 0) + (final_pattern.count("{ARCH}") if "{ARCH}" in final_pattern else 0) ) :
            # print(f"Debug Python: Sanity check failed (dot/extra braces in placeholder region). Pattern: '{final_pattern}'", file=sys.stderr)
            # Fallback: if arch was found and its part seems okay, use that, otherwise original
            if arch_found and "{ARCH}" in pattern_after_arch_replacement: return pattern_after_arch_replacement
            return filename_asset

    # 2. If arch was found in step 1, it should be present in the final pattern.
    if arch_found and "{ARCH}" not in final_pattern:
        # print(f"Debug Python: Sanity check failed (ARCH found but missing in final). Pattern: '{final_pattern}'", file=sys.stderr)
        # Fallback to pattern with only ARCH if version replacement caused ARCH to disappear
        if "{ARCH}" in pattern_after_arch_replacement: return pattern_after_arch_replacement
        return filename_asset

    # 3. If version was supposed to be replaced, it should be {VERSION} in the final pattern.
    if version_bare and version_bare in filename_asset and "{VERSION}" not in final_pattern and version_bare not in final_pattern:
        # This means version_bare was present, was replaced by something other than {VERSION} or removed entirely.
        # print(f"Debug Python: Sanity check failed (VERSION should be present or original version_bare). Pattern: '{final_pattern}'", file=sys.stderr)
        # Fallback to original if version processing is problematic.
        return filename_asset
        
    # 4. Ensure that we don't have more placeholders than intended.
    expected_placeholders = 0
    if arch_found: expected_placeholders += 1
    if version_bare and version_bare in filename_asset: expected_placeholders +=1
    
    actual_brace_pairs = final_pattern.count("{")
    if final_pattern.count("}") != actual_brace_pairs: # Unbalanced
        # print(f"Debug Python: Sanity check failed (unbalanced braces). Pattern: '{final_pattern}'", file=sys.stderr)
        return filename_asset

    # This check is a bit simplistic, assumes {VERSION} and {ARCH} are the only possible placeholders
    # A more robust check would count specific placeholders.
    # Count occurrences of {VERSION} and {ARCH}
    num_version_placeholders = final_pattern.count("{VERSION}")
    num_arch_placeholders = final_pattern.count("{ARCH}")

    if (num_version_placeholders > 1) or (num_arch_placeholders > 1) or (num_version_placeholders + num_arch_placeholders > expected_placeholders) :
        # print(f"Debug Python: Sanity check failed (too many or unexpected placeholders). Pattern: '{final_pattern}'", file=sys.stderr)
        if arch_found and "{ARCH}" in pattern_after_arch_replacement and num_arch_placeholders <=1 and num_version_placeholders == 0:
             return pattern_after_arch_replacement # Likely version replacement failed, but arch is good
        return filename_asset

    return final_pattern

if __name__ == "__main__":
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print("Usage: python extract_pattern.py <filename_asset> <known_arch_strings_json> [version_bare]", file=sys.stderr)
        print("Example: python extract_pattern.py ripgrep-1.2.3-x86_64.tar.gz '[\"x86_64\", \"amd64\"]' 1.2.3", file=sys.stderr)
        sys.exit(1)

    filename_arg = sys.argv[1]
    arch_json_arg = sys.argv[2]
    version_arg = sys.argv[3] if len(sys.argv) == 4 else "" # version_bare is optional
    
    # Handle if Zsh passes an empty string for an optional arg that wasn't given, vs. explicitly empty
    if version_arg == "None" or version_arg == '' :
        effective_version = ""
    else:
        effective_version = version_arg

    result = extract_pattern(filename_arg, effective_version, arch_json_arg)
    print(result) 