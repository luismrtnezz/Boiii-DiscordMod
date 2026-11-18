# BOIII Discord Mod

Add a server-configured Discord invitation to the in-game pause menu. Each server supplies its own invitation code and button label through its CFG.

The shared client mod folder is `discord_mod`. Administrators can distribute the same compiled files through their own FastDL host while keeping server-specific settings in their server CFG.

## Requirements

- A BOIII client build containing [Ask before opening links from Lua](https://github.com/Ezz-lol/boiii-free/commit/7e5b45de797d8a4aaa9322602d5a10f139caa991), or a later build that retains this feature.
- A BOIII dedicated server with custom GSC loading and FastDL support.
- A publicly reachable FastDL host when players need to download the mod.
- A working Discord invitation.

The source changes must be present in the client executable distributed to players. Check the BOIII update channel you use. Merging a commit does not establish which released executable includes it.

## Install on the dedicated server

Download the prepared release archive and extract it into the dedicated server directory, alongside `boiii.exe`. The installation contains these files.

```text
<server directory>/
├── boiii.exe
├── mods/
│   └── discord_mod/
│       └── zone/
│           ├── mp_mod.ff
│           ├── en_mp_mod.ff
│           ├── zm_mod.ff
│           ├── en_zm_mod.ff
│           └── workshop.json
└── boiii/
    └── custom_scripts/
        ├── mp/
        │   └── boiii_discord.gsc
        └── zm/
            └── boiii_discord.gsc
```

Both server scripts are supplied for the respective MP and ZM modes. BOIII compiles the GSC source when loading it.

If installing from the repository checkout, copy its `mods` and `boiii` directories into the server directory.

## Configure the invitation

Add these settings to the CFG executed by your server. An editable example is available in `config/discord.example.cfg`.

```cfg
set boiii_discord_enabled "1"
set boiii_discord_code "YOUR_INVITE_CODE"
set boiii_discord_label "JOIN OUR DISCORD"
```

| Setting | Value |
| --- | --- |
| `boiii_discord_enabled` | `1` enables the button. `0` disables it. |
| `boiii_discord_code` | The code after `https://discord.gg/`. Replace the example with a real invitation code. |
| `boiii_discord_label` | The text displayed in the pause menu. |

The client constructs `https://discord.gg/<code>` and validates the resulting URL. The current pattern accepts ASCII letters, digits, underscores and hyphens, with a maximum invite code length of 64 characters.

The label accepts up to 48 bytes of visible text and an optional leading color code from `^0` to `^9`. Control characters and additional `^` characters are rejected. For example, `^5COMMUNITY DISCORD` is accepted.

The server sends the configuration once per player, after spawning. Apply settings before players join. After changing them, restart the match or server and reconnect to test with a fresh player session.

## Load the mod

Include the following arguments in your existing server startup command.

```text
+set fs_game "discord_mod"
```

Keep the rest of your normal startup arguments, ports and server CFG. If your launcher uses a variable for the mod folder, set that variable to `discord_mod` instead.

This package is a standalone client mod and includes an override of `scripts/shared/music_shared.csc` to load its CSC system. Combining it with another mod requires checking script and asset conflicts. Installing it over another mod's fastfiles can replace that mod's content. A combined build has different client files and needs its own distribution.

## Configure FastDL

Add the FastDL settings to the CFG executed by the server.

```cfg
set sv_wwwDownload "1"
set sv_wwwBaseURL "https://downloads.example.com/"
```

Replace the example URL with your publicly reachable download root. The release contains a shared `zone/workshop.json` and a `manifest.json` for its exact files. Keep `FolderName` and `PublisherID` set to `discord_mod`; the repository name is `boiii_discord_mod`.

The manifest uses relative file paths, sizes and SHA-1 hashes. The FastDL host URL is configured separately in `sv_wwwBaseURL`, so multiple hosts can serve the same release and manifest.

You can upload the release's mod directory directly. If you change its files, start the server with `discord_mod` loaded, then run this command in the dedicated server console to regenerate the manifest.

```text
fastdl_manifest
```

Upload the entire resulting `mods/discord_mod` directory, including its generated `manifest.json`, so the web server exposes these paths.

```text
https://downloads.example.com/mods/discord_mod/manifest.json
https://downloads.example.com/mods/discord_mod/zone/workshop.json
https://downloads.example.com/mods/discord_mod/zone/mp_mod.ff
https://downloads.example.com/mods/discord_mod/zone/en_mp_mod.ff
https://downloads.example.com/mods/discord_mod/zone/zm_mod.ff
https://downloads.example.com/mods/discord_mod/zone/en_zm_mod.ff
```

Copy the files first, generate the manifest if needed, then upload them together. Regenerate the manifest whenever the distributed files change. Keep the metadata's title and description common across servers; the server CFG supplies the Discord button label. Confirm that the manifest and each file are accessible from another machine without authentication.

BOIII prompts players to download missing content or update mismatched content. Players may need to reconnect after the download. See the project's [FastDL documentation](https://github.com/Ezz-lol/boiii-free/blob/beta/docs/fastdl.md) for the current behavior.

The server GSC scripts stay under `boiii/custom_scripts`. FastDL distributes the files in `mods/discord_mod`.

## Keep the same mod across servers

Use the same official release, the same `discord_mod` folder name and the same compiled fastfiles on every server. Customize the three CFG settings for your community.

An existing matching copy can be reused. Download behavior also depends on BOIII's content checks, the installed mod and the server's manifest. Shared files reduce updates caused by server-specific builds. Switching between different mods still requires loading the appropriate content.

The release includes SHA-256 checksums for the installed payload. They can be checked in PowerShell with `Get-FileHash -Algorithm SHA256`. FastDL generates its own manifest.

## What players see

After spawning, open the pause menu and select the configured Discord button. BOIII presents its in-game confirmation with the URL and host. Accepting opens the default web browser.

In the BOIII implementation linked above, rejecting a URL suppresses further prompts for that exact URL until the client restarts. Accepting allows another prompt on a later click. Other URLs can still be requested. This behavior belongs to the client engine.

The mod calls `Engine.OpenURL(current.url)` from the button callback. Its GSC and CSC exchange the server configuration before Lua builds the menu.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Button missing | Spawn first, reopen the pause menu, check that `fs_game` loads `discord_mod`, and check the enabled, code and label settings. |
| CSC output appears but the Lua does not load | The CSC calls `LuiLoad("ui_scripts.discord.boiii_discord")`. The fastfile must include `rawfile,ui_scripts/discord/boiii_discord.lua`. |
| Button logs a click but no confirmation appears | Check the client build and whether that exact URL was previously rejected in the current client session. Restart the client to clear the rejection. |
| Invite fails in the browser | Open the configured Discord invitation directly and verify that it remains valid. |
| Download fails or repeats | Check the public FastDL paths, regenerate the manifest, and compare the files served by FastDL with the installed server files. |
| Configuration is missing | Look for `[BOIII DISCORD] GSC initialized`, `[BOIII DISCORD] Configuration sent` and the CSC configuration messages. Check the matching mode's custom script directory. |

## Sources and build information

The `source/client` directory contains the Lua, CSC and MP/ZM zone definitions. The server GSC sources are the deployable files under `boiii/custom_scripts`. See `source/BUILD.md` for build guidance.

For normal installation, use the prebuilt release package. Publishing the sources supports review and contributions. Keeping one shared distribution depends on administrators adopting the official release.

## Validation

The button and browser confirmation were tested with left-click and Cross on a PlayStation controller, including switching between both devices. Cancellation and browser opening were verified. The current engine's per-URL rejection behavior was also checked.

This package includes MP and ZM assets. A separate, complete ZM deployment test and additional client languages remain pending.