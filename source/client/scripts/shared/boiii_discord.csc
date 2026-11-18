#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#namespace discord;

REGISTER_SYSTEM("boiii_discord", &__init__, undefined)

function __init__()
{
    SetDvar("boiii_discord_client_enabled", "0");
    SetDvar("boiii_discord_client_url", "");
    SetDvar("boiii_discord_client_label", "");
    
    // Register client-side communication handlers.
    util::register_system("discordEnabled", &on_enabled);
    util::register_system("discordUrl", &on_url);
    util::register_system("discordLabel", &on_label);

    // Load existing Lua button.
    LuiLoad("ui_scripts.discord.boiii_discord");
}

function on_enabled(clientNum, state, oldState)
{
    if (state != "1")
    {
        SetDvar("boiii_discord_client_enabled", "0");
        SetDvar("boiii_discord_client_url", "");
        SetDvar("boiii_discord_client_label", "");

        println("[BOIII DISCORD CSC] Disabled");
        return;
    }

    SetDvar("boiii_discord_client_enabled", "1");

    println("[BOIII DISCORD CSC] Enabled: 1");
}

function on_url(clientNum, state, oldState)
{
    url = "https:" + "/" + "/discord.gg/" + state;

    SetDvar("boiii_discord_client_url", url);

    println("[BOIII DISCORD CSC] URL: " + url);
}

function on_label(clientNum, state, oldState)
{
    SetDvar("boiii_discord_client_label", state);

    println("[BOIII DISCORD CSC] Label: " + state);
}