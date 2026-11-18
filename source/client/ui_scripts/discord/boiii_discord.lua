
-- ================================================
-- BOIII DISCORD
-- Universal Discord Button
-- ================================================

print("[BOIII DISCORD] Script loaded")

local function getDvar(name)
    local ok, value = pcall(function()
        return Engine.DvarString(nil, name)
    end)

    if not ok or value == nil then
        return ""
    end

    return tostring(value)
end


local function getDiscordConfig()
    local enabled = getDvar("boiii_discord_client_enabled")

    if enabled ~= "1" then
        return nil
    end

    local label = getDvar("boiii_discord_client_label")
    local url = getDvar("boiii_discord_client_url")

    -- ================================================
    -- LABEL VALIDATION
    -- ================================================

    if label == "" or label:find("[%c]") then
        return nil
    end

    local visibleText = label

    -- Allow an optional color code (^0 to ^9).
    if label:sub(1, 1) == "^" then
        local color, text = label:match("^%^(%d)(.+)$")

        if not color or not text then
            return nil
        end

        visibleText = text
    end

    -- Validate visible text.
    if visibleText == ""
        or #visibleText > 48
        or visibleText:find("%^") then
        return nil
    end

    -- ================================================
    -- DISCORD URL VALIDATION
    -- ================================================

    local invite = url:match(
        "^https://discord%.gg/([%w_%-]+)$"
    )

    if not invite or #invite > 64 then
        return nil
    end

    -- ================================================
    -- RETURN CONFIGURATION
    -- ================================================

    return {
        label = label,
        url = url
    }
end

-- ================================================
-- DISCORD BUTTON
-- ================================================

local function addDiscordButton(dataSource)
    if not dataSource or
       type(dataSource.prepare) ~= "function" then
        print("[BOIII DISCORD] Data source unavailable")
        return
    end

    if dataSource.boiiiDiscordPatched then
        return
    end

    local originalPrepare = dataSource.prepare

    dataSource.prepare = function(controller, list, filter)
        originalPrepare(controller, list, filter)

        local helper = list and list.customDataSourceHelper
        local items = helper and list[helper]

        if type(items) ~= "table" then
            return
        end

        BoiiiStartMenuOptionCount = #items

        -- Read current server configuration.
        local config = getDiscordConfig()

        if not config then
            return
        end

        -- Prevent duplicate buttons.
        for _, item in ipairs(items) do
            if item.model then
                local textModel = Engine.GetModel(
                    item.model,
                    "displayText"
                )

                if textModel and
                   Engine.GetModelValue(textModel) == config.label then
                    return
                end
            end
        end

        local root = Engine.CreateModel(
            Engine.GetModelForController(controller),
            helper
        )

        local index = #items + 1
        local existing = Engine.GetModel(root, index)

        if existing then
            Engine.UnsubscribeAndFreeModel(existing)
        end

        local model = Engine.CreateModel(root, index)

        Engine.SetModelValue(
            Engine.CreateModel(model, "displayText"),
            config.label
        )

        Engine.SetModelValue(
            Engine.CreateModel(model, "action"),
            function(self, element, controller)

                -- Always read the current server URL.
                local current = getDiscordConfig()

                if not current then
                    print("[BOIII DISCORD] Configuration unavailable")
                    return
                end

                print(
                    "[BOIII DISCORD] Button pressed: "
                    .. current.url
                )

                Engine.OpenURL(current.url)
            end
        )

        table.insert(items, { model = model })

        BoiiiStartMenuOptionCount = #items

        print(
            "[BOIII DISCORD] Button inserted: "
            .. config.label
        )
    end

    dataSource.boiiiDiscordPatched = true
end

-- ================================================
-- REGISTER MENU HOOKS
-- ================================================

addDiscordButton(DataSources and DataSources.StartMenuGameOptions)
addDiscordButton(BoiiiStartMenuGameOptions)
