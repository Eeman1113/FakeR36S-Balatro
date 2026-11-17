-- FakeR36S: fit Balatro's start-up into 512 MB (added by balatro-port.sh after PortMaster's patches).
-- Measured on the console: loading went 67 -> 226 MB on the 2x card art (PortMaster switches to 1x
-- only after it is loaded), then past 260 MB plus all swap on fonts for every language (Chinese,
-- Japanese, Korean, Russian, several sizes), and the kernel killed it.

-- 1. 1x textures from the very first load
local game_set_render_settings = Game.set_render_settings
function Game:set_render_settings(...)
    self.SETTINGS.GRAPHICS.texture_scaling = 1
    return game_set_render_settings(self, ...)
end

-- 2. only the fonts the current language uses; other languages' slots share the UI font until picked
local LANG_FONT = {
    zh_CN = 'resources/fonts/NotoSansSC-Bold.ttf', zh_TW = 'resources/fonts/NotoSansTC-Bold.ttf',
    ko = 'resources/fonts/NotoSansKR-Bold.ttf', ja = 'resources/fonts/NotoSansJP-Bold.ttf',
    ru = 'resources/fonts/NotoSans-Bold.ttf',
}
local UI_FONT = 'resources/fonts/m6x11plus.ttf'

local game_set_language = Game.set_language
function Game:set_language(...)
    if self.LANGUAGES then return game_set_language(self, ...) end   -- fonts already made
    local wanted = { [UI_FONT] = true }
    local lang_file = LANG_FONT[self.SETTINGS.language or 'en-us']
    if lang_file then wanted[lang_file] = true end
    local made, fallback = {}, nil
    local new_font = love.graphics.newFont
    love.graphics.newFont = function(file, size, ...)
        if type(file) ~= 'string' or wanted[file] then
            local f = new_font(file, size, ...)
            if file == UI_FONT then fallback = fallback or f end
            return f
        end
        made[#made + 1] = file
        return fallback or new_font(UI_FONT, size)
    end
    local ok, err = pcall(game_set_language, self, ...)
    love.graphics.newFont = new_font
    if #made > 0 then print('[FakeR36S] fonts skipped (other languages): ' .. #made) end
    if not ok then error(err, 0) end
end
