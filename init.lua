local mouseMode = false
local accel = 1
local accelTimer = nil
local baseMove = 5
local fastMove = 25
local accelStep = 1
local accelMax = 6
local currentDirection = nil
local moveTimer = nil
local scrollAccel = 1
local scrollAccelTimer = nil
local currentScrollDirection = nil
local baseScroll = 4
local scrollTimer = nil
local isLeftClickHeld = false

-- Hotkeys for when mouse mode is active
local mouseHotkeys = {}

-- Global hotkeys for cmd+jkl; as arrow keys
hs.hotkey.bind({ "cmd" }, "j", function()
    hs.eventtap.keyStroke({}, "left")
end)

hs.hotkey.bind({ "cmd" }, "k", function()
    hs.eventtap.keyStroke({}, "down")
end)

hs.hotkey.bind({ "cmd" }, "l", function()
    hs.eventtap.keyStroke({}, "up")
end)

hs.hotkey.bind({ "cmd" }, ";", function()
    hs.eventtap.keyStroke({}, "right")
end)

-- Global hotkey for double-click with cmd+option+enter
hs.hotkey.bind({ "cmd", "option" }, "return", function()
    local pos = hs.mouse.absolutePosition()
    -- Perform double-click
    hs.eventtap.leftClick(pos)
    hs.timer.doAfter(0.05, function()
        hs.eventtap.leftClick(pos)
    end)
end)

-- Toggle mouse mode with hyper+A
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "A", function()
    mouseMode = not mouseMode

    if mouseMode then
        -- Enable mouse mode hotkeys
        mouseHotkeys = {
            hs.hotkey.bind({}, "left", function() startMoving(-1, 0) end, function() stopMoving() end,
                function() startMoving(-1, 0) end),
            hs.hotkey.bind({}, "right", function() startMoving(1, 0) end, function() stopMoving() end,
                function() startMoving(1, 0) end),
            hs.hotkey.bind({}, "down", function() startMoving(0, 1) end, function() stopMoving() end,
                function() startMoving(0, 1) end),
            hs.hotkey.bind({}, "up", function() startMoving(0, -1) end, function() stopMoving() end,
                function() startMoving(0, -1) end),
            -- jkl; as alternative arrow keys
            hs.hotkey.bind({}, "j", function() startMoving(-1, 0) end, function() stopMoving() end,
                function() startMoving(-1, 0) end),
            hs.hotkey.bind({}, ";", function() startMoving(1, 0) end, function() stopMoving() end,
                function() startMoving(1, 0) end),
            hs.hotkey.bind({}, "k", function() startMoving(0, 1) end, function() stopMoving() end,
                function() startMoving(0, 1) end),
            hs.hotkey.bind({}, "l", function() startMoving(0, -1) end, function() stopMoving() end,
                function() startMoving(0, -1) end),
            hs.hotkey.bind({ "shift" }, "left", function() startMovingFast(-1, 0) end, function() stopMoving() end,
                function() startMovingFast(-1, 0) end),
            hs.hotkey.bind({ "shift" }, "right", function() startMovingFast(1, 0) end, function() stopMoving() end,
                function() startMovingFast(1, 0) end),
            hs.hotkey.bind({ "shift" }, "down", function() startMovingFast(0, 1) end, function() stopMoving() end,
                function() startMovingFast(0, 1) end),
            hs.hotkey.bind({ "shift" }, "up", function() startMovingFast(0, -1) end, function() stopMoving() end,
                function() startMovingFast(0, -1) end),
            -- jkl; with shift for fast movement
            hs.hotkey.bind({ "shift" }, "j", function() startMovingFast(-1, 0) end, function() stopMoving() end,
                function() startMovingFast(-1, 0) end),
            hs.hotkey.bind({ "shift" }, ";", function() startMovingFast(1, 0) end, function() stopMoving() end,
                function() startMovingFast(1, 0) end),
            hs.hotkey.bind({ "shift" }, "k", function() startMovingFast(0, 1) end, function() stopMoving() end,
                function() startMovingFast(0, 1) end),
            hs.hotkey.bind({ "shift" }, "l", function() startMovingFast(0, -1) end, function() stopMoving() end,
                function() startMovingFast(0, -1) end),
            hs.hotkey.bind({ "cmd" }, "left", function() moveToScreenEdge("left") end),
            hs.hotkey.bind({ "cmd" }, "right", function() moveToScreenEdge("right") end),
            hs.hotkey.bind({ "cmd" }, "down", function() moveToScreenEdge("down") end),
            hs.hotkey.bind({ "cmd" }, "up", function() moveToScreenEdge("up") end),
            -- jkl; with cmd for screen edge movement
            hs.hotkey.bind({ "cmd" }, "j", function() moveToScreenEdge("left") end),
            hs.hotkey.bind({ "cmd" }, ";", function() moveToScreenEdge("right") end),
            hs.hotkey.bind({ "cmd" }, "k", function() moveToScreenEdge("down") end),
            hs.hotkey.bind({ "cmd" }, "l", function() moveToScreenEdge("up") end),
            hs.hotkey.bind({ "alt" }, "left", function() startScrolling(1, 0) end, function() stopScrolling() end,
                function() startScrolling(1, 0) end),
            hs.hotkey.bind({ "alt" }, "right", function() startScrolling(-1, 0) end, function() stopScrolling() end,
                function() startScrolling(-1, 0) end),
            hs.hotkey.bind({ "alt" }, "down", function() startScrolling(0, -1) end, function() stopScrolling() end,
                function() startScrolling(0, -1) end),
            hs.hotkey.bind({ "alt" }, "up", function() startScrolling(0, 1) end, function() stopScrolling() end,
                function() startScrolling(0, 1) end),
            -- jkl; with alt for scrolling
            hs.hotkey.bind({ "alt" }, "j", function() startScrolling(1, 0) end, function() stopScrolling() end,
                function() startScrolling(1, 0) end),
            hs.hotkey.bind({ "alt" }, ";", function() startScrolling(-1, 0) end, function() stopScrolling() end,
                function() startScrolling(-1, 0) end),
            hs.hotkey.bind({ "alt" }, "k", function() startScrolling(0, -1) end, function() stopScrolling() end,
                function() startScrolling(0, -1) end),
            hs.hotkey.bind({ "alt" }, "l", function() startScrolling(0, 1) end, function() stopScrolling() end,
                function() startScrolling(0, 1) end),
            hs.hotkey.bind({}, "return", function()
                if screenshotMode then
                    completeScreenshotSelection()
                elseif isLeftClickHeld then
                    releaseLeftClick()
                else
                    leftClick()
                    mouseMode = false
                    disableMouseMode()
                end
            end),
            hs.hotkey.bind({ "shift" }, "return", function()
                if isLeftClickHeld then
                    releaseLeftClick()
                else
                    startLeftClickHold()
                end
            end),
            hs.hotkey.bind({ "cmd", "shift" }, "return", function()
                startScreenshotSelection()
            end),
            hs.hotkey.bind({ "cmd" }, "return", function() rightClick() end),
            hs.hotkey.bind({}, "escape", function()
                if screenshotMode then
                    screenshotMode = false
                    startPos = nil
                    print("Screenshot selection cancelled")
                else
                    mouseMode = false
                    disableMouseMode()
                end
            end)
        }
    else
        disableMouseMode()
    end
end)

-- Function to disable mouse mode and clean up hotkeys
function disableMouseMode()
    for _, hotkey in ipairs(mouseHotkeys) do
        hotkey:delete()
    end
    mouseHotkeys = {}
    accel = 1
    currentDirection = nil
    scrollAccel = 1
    currentScrollDirection = nil
    if isLeftClickHeld then
        releaseLeftClick()
    end
    if accelTimer then
        accelTimer:stop()
        accelTimer = nil
    end
    if moveTimer then
        moveTimer:stop()
        moveTimer = nil
    end
    if scrollTimer then
        scrollTimer:stop()
        scrollTimer = nil
    end
    if scrollAccelTimer then
        scrollAccelTimer:stop()
        scrollAccelTimer = nil
    end
end

-- Movement control functions
function startMoving(dx, dy)
    -- If direction changed, reset acceleration
    if currentDirection and (currentDirection.dx ~= dx or currentDirection.dy ~= dy) then
        accel = 1
    end

    currentDirection = { dx = dx, dy = dy }

    -- Stop any existing movement timer
    if moveTimer then
        moveTimer:stop()
    end

    -- Immediate movement
    moveMouse(dx, dy)

    -- Start continuous movement
    moveTimer = hs.timer.doEvery(0.05, function()
        if currentDirection then
            moveMouse(currentDirection.dx, currentDirection.dy)
        end
    end)
end

function stopMoving()
    currentDirection = nil
    if moveTimer then
        moveTimer:stop()
        moveTimer = nil
    end
    accel = 1
end

-- Mouse movement logic
function moveMouse(dx, dy)
    local pos = hs.mouse.absolutePosition()
    pos.x = pos.x + dx * accel * baseMove
    pos.y = pos.y + dy * accel * baseMove
    hs.mouse.absolutePosition(pos)

    -- If left click is held, send drag events during movement
    if isLeftClickHeld then
        local dragEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, pos)
        dragEvent:post()
    end

    accel = math.min(accel + accelStep, accelMax)

    if accelTimer then accelTimer:stop() end
    accelTimer = hs.timer.doAfter(0.3, function()
        accel = 1
    end)
end

-- Click functions
function leftClick()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.leftClick(pos)
end

function rightClick()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.rightClick(pos)
end

-- Scroll control functions
function startScrolling(dx, dy)
    -- If direction changed, reset acceleration
    if currentScrollDirection and (currentScrollDirection.dx ~= dx or currentScrollDirection.dy ~= dy) then
        scrollAccel = 1
    end

    currentScrollDirection = { dx = dx, dy = dy }

    -- Stop any existing scroll timer
    if scrollTimer then
        scrollTimer:stop()
    end

    -- Immediate scroll
    performScroll(dx, dy)

    -- Start continuous scrolling
    scrollTimer = hs.timer.doEvery(0.05, function()
        if currentScrollDirection then
            performScroll(currentScrollDirection.dx, currentScrollDirection.dy)
        end
    end)
end

function stopScrolling()
    currentScrollDirection = nil
    if scrollTimer then
        scrollTimer:stop()
        scrollTimer = nil
    end
    scrollAccel = 1
end

-- Scroll function - fixed to properly handle horizontal and vertical scrolling
function performScroll(dx, dy)
    -- For horizontal scrolling, we need to use the first parameter
    -- For vertical scrolling, we use the second parameter
    local scrollX = dx * scrollAccel * baseScroll
    local scrollY = dy * scrollAccel * baseScroll

    -- Hammerspoon's scrollWheel expects {horizontal, vertical} format
    hs.eventtap.scrollWheel({ scrollX, scrollY }, {}, "pixel")

    scrollAccel = math.min(scrollAccel + 1, 10)

    -- Reset acceleration after period of inactivity
    if scrollAccelTimer then scrollAccelTimer:stop() end
    scrollAccelTimer = hs.timer.doAfter(0.3, function()
        scrollAccel = 1
    end)
end

-- Left click hold functions
function startLeftClickHold()
    local pos = hs.mouse.absolutePosition()
    -- Try using CGEvent directly for better compatibility with screenshot tools
    local event = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos)
    event:post()
    isLeftClickHeld = true
    print("Left click hold started - try selecting area")
end

function releaseLeftClick()
    local pos = hs.mouse.absolutePosition()
    -- Generate mouse drag event first, then mouse up
    local dragEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, pos)
    dragEvent:post()

    -- Small delay before releasing
    hs.timer.doAfter(0.05, function()
        local upEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos)
        upEvent:post()
    end)

    isLeftClickHeld = false
    print("Left click hold released")
end

-- Screenshot selection functionality
local screenshotMode = false
local startPos = nil

function startScreenshotSelection()
    screenshotMode = true
    startPos = hs.mouse.absolutePosition()
    print("Screenshot selection started - move to end position and press Enter")
end

function completeScreenshotSelection()
    if not screenshotMode or not startPos then
        return
    end

    local endPos = hs.mouse.absolutePosition()

    -- Calculate the selection rectangle
    local x = math.min(startPos.x, endPos.x)
    local y = math.min(startPos.y, endPos.y)
    local width = math.abs(endPos.x - startPos.x)
    local height = math.abs(endPos.y - startPos.y)

    -- Take screenshot of selected area
    local rect = hs.geometry.rect(x, y, width, height)
    local image = hs.screen.mainScreen():snapshot(rect)

    if image then
        -- Save to clipboard and file
        hs.pasteboard.writeObject(image)

        -- Save to desktop with timestamp
        local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
        local filename = os.getenv("HOME") .. "/Desktop/Screenshot_" .. timestamp .. ".png"
        image:saveToFile(filename)

        print("Screenshot saved to " .. filename .. " and copied to clipboard")
        hs.alert.show("Screenshot captured!")
    else
        print("Failed to capture screenshot")
        hs.alert.show("Screenshot failed!")
    end

    screenshotMode = false
    startPos = nil
end

-- Edge movement functions
function moveToScreenEdge(direction)
    local screen = hs.screen.mainScreen()
    local frame = screen:fullFrame()
    local currentPos = hs.mouse.absolutePosition()
    local newPos = { x = currentPos.x, y = currentPos.y }

    if direction == "left" then
        newPos.x = frame.x
    elseif direction == "right" then
        newPos.x = frame.x + frame.w - 1
    elseif direction == "up" then
        newPos.y = frame.y
    elseif direction == "down" then
        newPos.y = frame.y + frame.h - 1
    end

    hs.mouse.absolutePosition(newPos)
end

-- Fast movement control functions
function startMovingFast(dx, dy)
    -- If direction changed, reset acceleration
    if currentDirection and (currentDirection.dx ~= dx or currentDirection.dy ~= dy) then
        accel = 1
    end

    currentDirection = { dx = dx, dy = dy }

    -- Stop any existing movement timer
    if moveTimer then
        moveTimer:stop()
    end

    -- Immediate fast movement
    moveMouseFast(dx, dy)

    -- Start continuous fast movement
    moveTimer = hs.timer.doEvery(0.03, function()
        if currentDirection then
            moveMouseFast(currentDirection.dx, currentDirection.dy)
        end
    end)
end

-- Fast mouse movement logic
function moveMouseFast(dx, dy)
    local pos = hs.mouse.absolutePosition()
    pos.x = pos.x + dx * accel * fastMove
    pos.y = pos.y + dy * accel * fastMove
    hs.mouse.absolutePosition(pos)

    -- If left click is held, send drag events during movement
    if isLeftClickHeld then
        local dragEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, pos)
        dragEvent:post()
    end

    accel = math.min(accel + accelStep, accelMax)

    if accelTimer then accelTimer:stop() end
    accelTimer = hs.timer.doAfter(0.3, function()
        accel = 1
    end)
end
