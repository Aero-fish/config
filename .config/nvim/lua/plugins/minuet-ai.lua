return {
    {
        "milanglacier/minuet-ai.nvim",
        opts = {
            provider = "openai_compatible",

            --  Length of context after cursor used to filter completion text.
            n_completions = 3, -- recommend for local model for resource saving

            -- I recommend beginning with a small context window size and incrementally
            -- expanding it, depending on your local computing power. A context window
            -- of 512, serves as an good starting point to estimate your computing
            -- power. Once you have a reliable estimate of your local computing power,
            -- you should adjust the context window to a larger value.
            context_window = 2048,
            provider_options = {
                openai_compatible = {
                    model = "local",
                    stream = false,
                    end_point = "http://localhost:8000/v1/chat/completions",
                    api_key = "TERM",
                    name = "local",
                    optional = {
                        stop = nil,
                        max_tokens = nil,
                    },
                    -- a list of functions to transform the endpoint, header, and request body
                    transform = {},
                }
            },
            virtualtext = {
                auto_trigger_ft = {},
                keymap = {
                    -- accept whole completion
                    accept = nil,
                    -- accept one line
                    accept_line = "<Tab>",
                    -- accept n lines (prompts for number)
                    -- e.g. "A-z 2 CR" will accept 2 lines
                    accept_n_lines = nil,
                    -- Cycle to prev completion item, or manually invoke completion
                    prev = "<C-k>",
                    -- Cycle to next completion item, or manually invoke completion
                    next = "<C-j>",
                    dismiss = "<C-c>",
                },
            },
        },
        keys = {
            {
                "<leader>ta",
                "<Cmd> Minuet virtualtext toggle <Cr>",
                desc = "AI virtual text",
                mode = { "n", "x" }
            }
        }
    },
}
