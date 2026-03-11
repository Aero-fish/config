return {
    {
        "olimorris/codecompanion.nvim",
        opts = {
            opts = {
                log_level = "ERROR",
            },
            adapters = {
                http = {
                    ["local"] = function()
                        return require("codecompanion.adapters").extend(
                            "openai_compatible", {
                                env = {
                                    url = "http://localhost:8000",
                                    api_key = "TERM",
                                    chat_url = "/v1/chat/completions",
                                },
                                handlers = {
                                    parse_message_meta = function(self, data)
                                        local extra = data.extra
                                        if extra and extra.reasoning_content then
                                            data.output.reasoning = {
                                                content = extra
                                                    .reasoning_content
                                            }
                                            if data.output.content == "" then
                                                data.output.content = nil
                                            end
                                        end
                                        return data
                                    end,
                                },
                            })
                    end,
                },
            },
            interactions = {
                chat = {
                    -- adapter = "local",
                    adapter = {
                        name = "opencode",
                        -- model = "local_model"
                    },
                },
                inline = {
                    adapter = "local",
                },
                cmd = {
                    adapter = "local",
                },
                shared = {
                    keymaps = {
                        always_accept = {
                            callback = "keymaps.always_accept",
                            modes = { n = "gA" },
                        },
                        accept_change = {
                            callback = "keymaps.accept_change",
                            modes = { n = "ga" },
                        },
                        reject_change = {
                            callback = "keymaps.reject_change",
                            modes = { n = "gr" },
                        },
                        next_hunk = {
                            callback = "keymaps.next_hunk",
                            modes = { n = "}" },
                        },
                        previous_hunk = {
                            callback = "keymaps.previous_hunk",
                            modes = { n = "{" },
                        },
                    },
                },
            },
        },
        keys = {
            {
                "<leader>z",
                ":CodeCompanion ",
                desc = "AI prompt",
                mode = { "n", "x" }
            },
            {
                "<leader><leader>z",
                "<Cmd> CodeCompanionChat <Cr>",
                desc = "AI chat",
                mode = { "n", "x" }
            },
            {
                "<leader>Za",
                "<Cmd> CodeCompanionAction <Cr>",
                desc = "AI action",
                mode = { "n", "x" }
            },
            {
                "<leader>Zc",
                ":CodeCompanionCmd ",
                desc = "AI nvim ex",
                mode = { "n", "x" }
            },
        },
    },
}
