<<<<<<< HEAD
# animat
=======
# 🌀 Animat

**Animat** is a lightweight and responsive animation library for managing sprite animations in the [LÖVE2D](https://love2d.org) framework. Inspired by `anim8`, it focuses on simplicity and flexibility.

---

## ✨ Features

- Time-based animation updates
- Playback controls: play, pause, reset
- Horizontal and vertical flipping support
- Easy quad generation via grid system
- Dynamic speed adjustment

---

## 🚀 Installation

Just copy the `animat.lua` file into your LÖVE2D project:

```lua
local animat = require("animat")
```

---

## 🧪 Example Usage

```lua
-- Load sprite and create animation
local sprite = love.graphics.newImage("spritesheet.png")
local grid = animat.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
local animation = animat.newAnimation(grid("1-4", 1), 0.1)

function love.update(dt)
  animation:update(dt)
end

function love.draw()
  animation:draw(sprite, 100, 100)
end
```

---

## 🧱 API

### `animat.newGrid(w, h, imageWidth, imageHeight)`
Returns a function that generates a list of `Quad` objects based on column and row ranges.

### `animat.newAnimation(frames, interval)`
Creates a new animation object with the given frames and frame interval.

### Animation object methods:
- `update(dt)`
- `draw(image, x, y, r, sx, sy, ox, oy)`
- `pause()`, `resume()`, `reset()`
- `setFrame(n)`, `setInterval(t)`, `setSpeed(m)`
- `setFlipH(true/false)`, `getFlipH()`
- `setFlipV(true/false)`, `getFlipV()`

---

## 📄 License

MIT © 2025 Rafael de Carvalho Bluhm

---

## 📫 Contributing

Contributions, ideas, and improvements are welcome! Feel free to open an issue or a pull request.
>>>>>>> def1156 (first commit)
