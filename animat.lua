-- animat.lua
-- A simple responsive library to manage sprite animations in LÖVE2D based in anim8

local animat = {
  _VERSION     = 'animat v0.0.1',
  _DESCRIPTION = 'A simple responsive animation library for LÖVE',
  _URL         = '',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2025 Rafael de Carvalho Bluhm

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- Shared methods for animation instances
local animMethods = {}

-- Updates the animation state based on delta time.
-- @param dt Delta time since last update
function animMethods:update(dt)
  if not self.playing then return end
  self.timer = self.timer + dt
  if self.timer >= self.interval then
    self.timer = self.timer - self.interval
    self.currentFrame = self.currentFrame % #self.frames + 1
  end
end

-- Returns the current frame (quad) of the animation.
-- @return The current love.graphics.Quad object
function animMethods:getCurrentFrame()
  return self.frames[self.currentFrame]
end

-- Resets the animation to the first frame.
function animMethods:reset()
  self.timer = 0
  self.currentFrame = 1
end

-- Pauses the animation playback.
function animMethods:pause()
  self.playing = false
end

-- Resumes the animation playback.
function animMethods:resume()
  self.playing = true
end

-- Sets the current frame of the animation.
-- @param frame Frame index to set
function animMethods:setFrame(frame)
  self.currentFrame = frame
end

-- Enables or disables horizontal flipping.
-- @param state Boolean indicating whether to flip horizontally
function animMethods:setFlipH(state)
  self.flipH = state
end

-- Returns whether the animation is flipped horizontally.
-- @return Boolean indicating horizontal flip state
function animMethods:getFlipH()
  return self.flipH
end

-- Enables or disables vertical flipping.
-- @param state Boolean indicating whether to flip vertically
function animMethods:setFlipV(state)
  self.flipV = state
end

-- Returns whether the animation is flipped vertically.
-- @return Boolean indicating vertical flip state
function animMethods:getFlipV()
  return self.flipV
end

-- Sets the interval between frames.
-- @param newInterval Frame interval in seconds (must be > 0)
function animMethods:setInterval(newInterval)
  assert(type(newInterval) == "number" and newInterval > 0, "Invalid interval")
  self.baseInterval = newInterval
  self.interval = self.baseInterval / self.speedMultiplier
end

-- Adjusts the animation speed by a multiplier.
-- @param multiplier Speed multiplier (must be > 0)
function animMethods:setSpeed(multiplier)
  assert(type(multiplier) == "number" and multiplier > 0, "Invalid speed multiplier")
  self.speedMultiplier = multiplier
  self.interval = self.baseInterval / self.speedMultiplier
end

-- Draws the current frame of the animation.
-- @param image The sprite sheet image
-- @param x X coordinate
-- @param y Y coordinate
-- @param r Rotation (optional)
-- @param sx Scale X (optional)
-- @param sy Scale Y (optional)
-- @param ox Origin X (optional)
-- @param oy Origin Y (optional)
function animMethods:draw(image, x, y, r, sx, sy, ox, oy)
  local frame = self:getCurrentFrame()
  local quadW, quadH = select(3, frame:getViewport())
  local scaleX = (sx or 1) * (self.flipH and -1 or 1)
  local scaleY = (sy or 1) * (self.flipV and -1 or 1)
  local originX = ox or 0
  local originY = oy or 0

  if self.flipH then
    originX = (ox or 0) * -1 + quadW
  end
  if self.flipV then
    originY = (oy or 0) * -1 + quadH
  end
  love.graphics.draw(image, frame, x, y, r or 0, scaleX, scaleY, originX, originY)
end

--- Creates a frame grid generator for spritesheets.
-- @param spriteSheet love.graphics.Image The spritesheet image.
-- @param columns number Number of columns in the spritesheet.
-- @param lines number Number of rows in the spritesheet.
-- @return function A grid function that returns quads when given column and row ranges (e.g., "1-6", 4).
function animat.newGrid(spriteSheet, columns, lines)
  -- Input validations
  assert(spriteSheet, "Sprite sheet is required")
  assert(type(columns) == "number" and columns > 0, "Invalid number of columns")
  assert(type(lines) == "number" and lines > 0, "Invalid number of lines")

  local imageWidth, imageHeight = spriteSheet:getWidth(), spriteSheet:getHeight()
  local frameWidth, frameHeight = imageWidth / columns, imageHeight / lines

  -- Verify frame dimensions
  assert(frameWidth > 0 and frameHeight > 0, "Invalid frame dimensions")

  local function parseRange(rangeStr)
    if type(rangeStr) == "number" then
      return rangeStr, rangeStr
    end
    local start, finish = rangeStr:match("^(%d+)-(%d+)$")
    start, finish = tonumber(start), tonumber(finish)
    assert(start and finish and start <= finish, "Invalid range format: " .. tostring(rangeStr))
    return start, finish
  end

  local function grid(colRange, rowRange)
    local quads = {}
    local startCol, endCol = parseRange(colRange)
    local startRow, endRow = parseRange(rowRange)

    -- Validate ranges
    assert(startCol >= 1 and endCol <= columns, "Column range out of bounds")
    assert(startRow >= 1 and endRow <= lines, "Row range out of bounds")

    for row = startRow, endRow do
      for col = startCol, endCol do
        table.insert(quads, love.graphics.newQuad(
          (col - 1) * frameWidth,
          (row - 1) * frameHeight,
          frameWidth,
          frameHeight,
          imageWidth,
          imageHeight
        ))
      end
    end

    return quads
  end

  return grid
end

-- Creates a new animation instance.
-- @param frames Table of love.graphics.Quad frames
-- @param interval Time interval between frames (default 0.1)
-- @return A new animation object
function animat.newAnimation(frames, interval)
  local anim = {
    frames = frames,
    baseInterval = interval or 0.1,
    speedMultiplier = 1,
    timer = 0,
    currentFrame = 1,
    playing = true,
    flipH = false,
    flipV = false,
  }
  anim.interval = anim.baseInterval / anim.speedMultiplier
  return setmetatable(anim, { __index = animMethods })
end

return animat
