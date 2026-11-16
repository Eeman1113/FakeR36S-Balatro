-- FakeR36S: handheld shortcuts for Balatro, added after PortMaster's patches by balatro-port.sh.
--   Select+R1  save state: a snapshot of the current run (Balatro's own save_run), one slot
--   Select+L1  load state: restart the run from that snapshot, from anywhere (menu included)
--   Select+B   show / hide an FPS counter
-- The state lives next to Balatro's own save, in <profile>/fakers36s_state.jkr, so it survives a restart.

local STATE_FILE = 'fakers36s_state.jkr'
local SAVE_OK = {}            -- calm moments where a snapshot restores cleanly
for _, k in ipairs({'SELECTING_HAND', 'SHOP', 'BLIND_SELECT'}) do
    if G.STATES[k] then SAVE_OK[G.STATES[k]] = true end
end

local msg, msg_until = nil, 0
local fps_on = false
local select_held = false
local swallowed = {}          -- combo buttons whose release must not reach the game either

local function note(text)
    msg, msg_until = text, love.timer.getTime() + 2
end

local function state_path()
    return (G.SETTINGS and G.SETTINGS.profile or 1) .. '/' .. STATE_FILE
end

local function save_state()
    if G.STAGE ~= G.STAGES.RUN or not G.GAME or not SAVE_OK[G.STATE] or G.F_NO_SAVING then
        note('Save state: only while choosing a hand, a blind or in the shop')
        return
    end
    local ok, err = pcall(function()
        save_run()                                   -- fills G.ARGS.save_run with the whole run
        compress_and_save(state_path(), G.ARGS.save_run)
    end)
    note(ok and 'State saved' or ('Save state failed: ' .. tostring(err)))
    print('[FakeR36S] save state ' .. (ok and 'ok' or tostring(err)))
end

local function load_state()
    local packed = get_compressed(state_path())
    if not packed then note('No saved state yet (Select+R1 saves one)') return end
    local ok, data = pcall(STR_UNPACK, packed)
    if not ok or type(data) ~= 'table' then note('Saved state is damaged') return end
    G:delete_run()
    G:start_run({savetext = data})
    note('State loaded')
    print('[FakeR36S] load state')
end

local game_pressed, game_released = love.gamepadpressed, love.gamepadreleased

function love.gamepadpressed(joystick, button)
    if button == 'back' then select_held = true end
    if select_held and button ~= 'back' then
        local action = ({rightshoulder = save_state, leftshoulder = load_state,
                         b = function() fps_on = not fps_on end})[button]
        if action then
            swallowed[button] = true
            action()
            return
        end
    end
    return game_pressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    if button == 'back' then select_held = false end
    if swallowed[button] then swallowed[button] = nil return end
    return game_released(joystick, button)
end

local font
local game_draw = Game.draw
function Game:draw(...)
    local result = game_draw(self, ...)
    local now = love.timer.getTime()
    if not fps_on and not (msg and now < msg_until) then return result end
    font = font or love.graphics.newFont(16)
    love.graphics.push('all')
    love.graphics.origin()
    love.graphics.setShader()
    love.graphics.setCanvas()
    love.graphics.setFont(font)
    local function label(text, x, y)
        local w, h = font:getWidth(text) + 12, font:getHeight() + 6
        if x < 0 then x = (love.graphics.getWidth() - w) / 2 end
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle('fill', x, y, w, h, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(text, x + 6, y + 3)
    end
    if fps_on then label(string.format('%d FPS', love.timer.getFPS()), 6, 6) end
    if msg and now < msg_until then label(msg, -1, 6) end
    love.graphics.pop()
    return result
end
