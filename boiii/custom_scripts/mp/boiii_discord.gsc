#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;

#namespace boiii_discord;

REGISTER_SYSTEM("boiii_discord", &__init__, undefined)

function __init__()
{
    println("[BOIII DISCORD] GSC initialized");

    // Register communication systems.
    util::registerClientSys("discordEnabled");
    util::registerClientSys("discordUrl");
    util::registerClientSys("discordLabel");

    callback::on_spawned(&on_player_spawned);
}

function on_player_spawned()
{
    // Ignore bots.
    if (self util::is_bot())
    {
        return;
    }

    // Send configuration only once per player.
    if (isdefined(self.boiii_discord_sent))
    {
        return;
    }

    enabled = GetDvarString("boiii_discord_enabled");
    code = GetDvarString("boiii_discord_code");
    label = GetDvarString("boiii_discord_label");

    if (enabled != "1" || code == "" || label == "")
    {
        self.boiii_discord_sent = true;

        util::setClientSysState(
            "discordEnabled",
            "0",
            self
        );

        println("[BOIII DISCORD] Disabled or missing configuration");
        return;
    }

    self.boiii_discord_sent = true;

    // Send URL and label first.
    util::setClientSysState("discordUrl", code, self);
    util::setClientSysState("discordLabel", label, self);

    // Enable last.
    util::setClientSysState("discordEnabled", "1", self);

    println("[BOIII DISCORD] Configuration sent");
}