#!/usr/bin/env python3
# pyright: reportAttributeAccessIssue=false
"""Make the managed Hermes Nerd Font dynamic profile iTerm2's default.

This follows iTerm2's official recommendation for making a Dynamic Profile the
startup default: place a Python API script in Scripts/AutoLaunch so it runs after
dynamic profiles load.
"""

import iterm2

PROFILE_NAME = "Hermes Nerd Font"


async def main(connection):
    profiles = await iterm2.PartialProfile.async_query(connection)
    for profile in profiles:
        if profile.name == PROFILE_NAME:
            await profile.async_make_default()
            return
    print(f"iTerm2 profile not found: {PROFILE_NAME}")


iterm2.run_until_complete(main)
