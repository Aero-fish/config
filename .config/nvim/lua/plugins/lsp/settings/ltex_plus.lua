-- settings.ltex.latex.commands
-- "default": Ignore command only, not arguments.
-- "ignore": Ignore command and arguments.
-- "dummy": Replace command and arguments with a singular dummy word.
-- "pluralDummy": Replace command and arguments with a plural dummy word.
-- "vowelDummy": Replace command and arguments with a vowel dummy word (i.e., Ina).


-- settings.ltex.language
-- "auto": Automatic language detection (not recommended)
-- "ar": Arabic
-- "ast-ES": Asturian
-- "be-BY": Belarusian
-- "br-FR": Breton
-- "ca-ES": Catalan
-- "ca-ES-valencia": Catalan (Valencian)
-- "da-DK": Danish
-- "de": German
-- "de-AT": German (Austria)
-- "de-CH": German (Swiss)
-- "de-DE": German (Germany)
-- "de-DE-x-simple-language": Simple German
-- "el-GR": Greek
-- "en": English
-- "en-AU": English (Australian)
-- "en-CA": English (Canadian)
-- "en-GB": English (GB)
-- "en-NZ": English (New Zealand)
-- "en-US": English (US)
-- "en-ZA": English (South African)
-- "eo": Esperanto
-- "es": Spanish
-- "es-AR": Spanish (voseo)
-- "fa": Persian
-- "fr": French
-- "ga-IE": Irish
-- "gl-ES": Galician
-- "it": Italian
-- "ja-JP": Japanese
-- "km-KH": Khmer
-- "nl": Dutch
-- "nl-BE": Dutch (Belgium)
-- "pl-PL": Polish
-- "pt": Portuguese
-- "pt-AO": Portuguese (Angola preAO)
-- "pt-BR": Portuguese (Brazil)
-- "pt-MZ": Portuguese (Moçambique preAO)
-- "pt-PT": Portuguese (Portugal)
-- "ro-RO": Romanian
-- "ru-RU": Russian
-- "sk-SK": Slovak
-- "sl-SI": Slovenian
-- "sv": Swedish
-- "ta-IN": Tamil
-- "tl-PH": Tagalog
-- "uk-UA": Ukrainian
-- "zh-CN": Chinese
return {
    filetypes = {
        "text",
        "bib",
        "gitcommit",
        "markdown",
        "org",
        "plaintex",
        "rst",
        "rnoweb",
        "tex"
    },
    settings = {
        ltex = {
            enabled = true,
            language = "en-GB",
            disabledRules = {
                ["en-GB"] = {
                    "WORD_CONTAINS_UNDERSCORE",
                    "MORFOLOGIK_RULE_EN_GB",   -- Disable spell check, use cspell. It does not check source code.
                    "OXFORD_SPELLING_Z_NOT_S", -- Disable spell check, use cspell. It does not check source code.
                }
            },
            additionalRules = {
                languageModel = os.getenv("HOME") .. "/misc/other_stuffs/ngram"
            },
            ----- This does not work
            -- dictionary = {
            --     ["en-GB"] = ":" ..
            --     os.getenv("HOME") .. "/.config/my-config/cspell_ignore_words.txt",
            -- },
            latex = {
                commands = {
                    ["\\label{}"] = "ignore",
                    ["\\documentclass[]{}"] = "ignore",
                    ["\\cite{}"] = "dummy",
                    ["\\cite[]{}"] = "dummy",
                },
                environments = {
                    ["lstlisting"] = "ignore",
                    ["verbatim"] = "ignore",
                }
            }
        },
    },
}
