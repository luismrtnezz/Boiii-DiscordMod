# Client mod sources

Use Call of Duty Black Ops III Mod Tools to build the client fastfiles. The distributable package already includes compiled MP and ZM files.

1. Create a mod project named `discord_mod` using the standard Mod Tools project structure.
2. Copy the contents of `source/client` into that mod project, preserving the `scripts`, `ui_scripts` and `zone_source` paths.
3. Retain the Mod Tools default resources referenced by the zone files, including `dummy.cfg` and the standard `mp_mod.class` and `zm_mod.class` definitions.
4. Build the MP and ZM zones with the Mod Tools launcher for English, matching the supplied `en_mp_mod.ff` and `en_zm_mod.ff` localization files.
5. Test the resulting `mp_mod.ff`, `zm_mod.ff` and localization fastfiles in the client before distributing them.
6. Regenerate the dedicated server's FastDL manifest after replacing the compiled files.

The CSC entry point uses `LuiLoad("ui_scripts.discord.boiii_discord")`. The MP and ZM zones package the matching Lua rawfile and both CSC scripts.

`music_shared.csc` is the existing script override used to import `boiii_discord.csc`. Inspect its compatibility when working with other client mods.

The runtime server scripts under `boiii/custom_scripts/mp` and `boiii/custom_scripts/zm` are compiled and loaded by BOIII. See the project's [GSC scripting documentation](https://github.com/Ezz-lol/boiii-free/blob/beta/docs/gsc-scripting.md).

The source files and compiled fastfiles were collected from the current installation. The fastfiles matched byte for byte between the tested client and dedicated server. A fresh Mod Tools rebuild has not been performed for this repository preparation, so reproducibility against the supplied binaries remains unverified.

After building the English pair, the distribution copies each English localization fastfile to every additional language prefix listed in the main README. MP copies come from en_mp_mod.ff and ZM copies come from en_zm_mod.ff. Include these copies when regenerating the FastDL manifest and release checksums.
