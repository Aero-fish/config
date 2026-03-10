return {
    generator = function(search, cb)
        -- Pass a list of templates to the callback
        -- See the built-in providers for make or npm for an example
        -- cb({ ... })
    end,
    -- Optional. Same as template.condition
    condition = function(search)
        return true
    end,
    -- Optional. Overrides the default cache key of `opts.dir`
    -- Additionally, if the returned value is an absolute file path,
    -- whenever that file is written overseer will automatically clear the cache
    cache_key = function(opts)
        return vim.fs.find('Makefile', { upward = true, type = "file", path = opts.dir })
        [1]
    end,
}

