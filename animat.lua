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
  self.interval = newInterval
end

-- Adjusts the animation speed by a multiplier.
-- @param multiplier Speed multiplier (must be > 0)
function animMethods:setSpeed(multiplier)
  assert(type(multiplier) == "number" and multiplier > 0, "Invalid speed multiplier")
  self.interval = self.interval / multiplier
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
  local originX = self.flipH and quadW or (ox or 0)
  local originY = self.flipV and quadH or (oy or 0)
  love.graphics.draw(image, frame, x, y, r or 0, scaleX, scaleY, originX, originY)
end

-- Creates a frame grid generator for spritesheets.
-- @param frameWidth Width of each frame
-- @param frameHeight Height of each frame
-- @param imageWidth Width of the image (optional)
-- @param imageHeight Height of the image (optional)
-- @return A function that returns a list of quads when given column and row ranges
function animat.newGrid(frameWidth, frameHeight, imageWidth, imageHeight)
  if not imageHeight and type(frameWidth) == "userdata" and frameWidth:type() == "Image" then
    local spriteSheet = frameWidth
    frameWidth = frameHeight
    frameHeight = imageWidth
    imageWidth = spriteSheet:getWidth()
    imageHeight = spriteSheet:getHeight()
  end

  local grid = function(columns, rows)
    local quads = {}

    local function parseRange(str)
      local start, finish = str:match("^(%d+)-(%d+)$")
      if start then
        return tonumber(start), tonumber(finish)
      else
        local value = tonumber(str)
        assert(value, "Invalid range string: " .. tostring(str))
        return value, value
      end
    end

    local startCol, endCol = parseRange(columns)
    local startRow, endRow
    if type(rows) == "string" then
      startRow, endRow = parseRange(rows)
    else
      startRow, endRow = rows, rows
    end

    for row = startRow, endRow do
      for col = startCol, endCol do
        local quad = love.graphics.newQuad(
          (col - 1) * frameWidth,
          (row - 1) * frameHeight,
          frameWidth,
          frameHeight,
          imageWidth,
          imageHeight
        )
        table.insert(quads, quad)
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
    interval = interval or 0.1,
    timer = 0,
    currentFrame = 1,
    playing = true,
    flipH = false,
    flipV = false,
  }
  return setmetatable(anim, { __index = animMethods })
end

return animat
