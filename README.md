# sysctrl

A JS library focused on controlling the inputs and outputs of the system

### Supported Platforms
- MacOS

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [API](#api)
  - [mouse(id)](#mouseid)
  - [screen(id)](#screenid)
- [License](#license)

## Installation

```bash
npm install sysctrl,
```

## Usage

### [Mouse](#mouseid)
```js
const sysctrl = require('sysctrl');

// get primary mouse
mouse = sysctrl.mouse(0)

// move mouse
mouse.move(100, 200)

// where are we now?
console.log(`Mouse X: ${mouse.x}`); // 100
console.log(`Mouse Y: ${mouse.y}`); // 200

// hold down primary
mouse.buttonDown(0);

// what am i doing?
console.log(`Current Button: ${mouse.currentButton}`); // 1

// release primary
mouse.buttonUp(0);

// what am i doing now?
console.log(`Current Button: ${mouse.currentButton}`); // 0
```

### [Screen](#screenid)
```js
const sysctrl = require('sysctrl');

// get primary screen
screen = sysctrl.screen(0)

// what is my resolution?
console.log(`Resolution: ${screen.width}x${screen.height}`);
```

## API

### mouse(id)

Creates a controller for a mouse device.  

- **Parameters**
  - `id` *(integer, optional)* – The mouse to control. `0` = primary system mouse. Defaults to `0`.

- **Properties**
  - `x` *(integer)* – Current X position of the mouse.  
  - `y` *(integer)* – Current Y position of the mouse.  
  - `currentButton` *(integer)* – Currently pressed button:  
    - `0` = none  
    - `1` = primary  
    - `2` = secondary  
    - `3` = middle

- **Methods**
  - `move(x, y, options)` – Move the mouse to coordinates `(x, y)`.  
    - `options.duration` *(ms)* – Time to move.  
    - `options.easeIn` *(integer)* – Ease-in factor.  
    - `options.easeOut` *(integer)* – Ease-out factor.

  - `click(button, options)` – Click a mouse button.  
    - `button` *(integer)* – `1` = primary, `2` = secondary, `3` = middle.  
    - `options.clickAmount` *(integer)* – Number of clicks.  
    - `options.timePerClick` *(ms)* – Delay between clicks.

  - `mouseDown(button)` – Press a mouse button down.  
  - `mouseUp(button)` – Release a mouse button.  

  - `scroll(dx, dy, options)` – Scroll by `dx` / `dy` pixels.  
    - `options.duration`, `options.easeIn`, `options.easeOut` same as `move`.

  - `drag(x1, y1, x2, y2, button, options)` – Drag from `(x1, y1)` to `(x2, y2)` while holding `button`.  
    - `options.duration`, `options.easeIn`, `options.easeOut` same as `move`.

### screen(id)

Creates a controller for a screen device.

- **Parameters**
  - `id` *(integer, optional)* – The screen to query. `0` = primary system screen. Defaults to `0`.

- **Properties**
  - `width` *(integer)* – Width of the screen in pixels.  
  - `height` *(integer)* – Height of the screen in pixels.

## License

SEE LICENSE IN [LICENSE](LICENSE)