-- Execute fenced code block

return {
    {
        "jubnzv/mdeval.nvim",
        cmd = { "MdEval" },
        opts = {
            -- Don't ask before executing code blocks
            require_confirmation = true,

            -- Not ask for confirmation
            -- allowed_file_types={'python', 'cpp'},

            -- tmp_build_dir="/tmp/mdeval/",

            -- Time out in seconds. -1 is disable timeout.
            -- exec_timeout="-1",


            -- Change code blocks evaluation options.
            eval_options = {
                -- Set custom configuration for C++
                cpp = {
                    command = { "clang++", "-std=c++20", "-O0" },
                    default_header = [[
    #include <iostream>
    #include <vector>
    using namespace std;
]]
                },
                python = {
                    command = { "python" },    -- Command to run interpreter
                    language_code = "python",  -- Markdown language code
                    exec_type = "interpreted", -- compiled or interpreted
                    extension = "py",          -- File extension for temporary files
                },
            },
        },
        keys = {
            {
                "<leader>xc",
                function() require("mdeval").eval_code_block() end,
                desc = "Code block",
                mode = { "n", "x" }
            }
        }
    },
}
