#-------------------------------------------------------------------------
# base helper methods
#-------------------------------------------------------------------------
get = (id) ->
  document.getElementById id
hide = (id) ->
  get(id).style.visibility = "hidden"
  return
show = (id) ->
  get(id).style.visibility = null
  return
html = (id, html) ->
  get(id).innerHTML = html
  return
timestamp = ->
  new Date().getTime()
random = (min, max) ->
  min + (Math.random() * (max - min))
randomChoice = (choices) ->
  choices[Math.round(random(0, choices.length - 1))]
# http://paulirish.com/2011/requestanimationframe-for-smart-animating/

#-------------------------------------------------------------------------
# game constants
#-------------------------------------------------------------------------
# how long before piece drops by 1 row (seconds)
# width of tetris court (in blocks)
# height of tetris court (in blocks)
# width/height of upcoming preview (in blocks)

#-------------------------------------------------------------------------
# game variables (initialized during reset)
#-------------------------------------------------------------------------
# pixel size of a single tetris block
# 2 dimensional array (nx*ny) representing tetris court - either empty block or occupied by a 'piece'
# queue of user actions (inputs)
# true|false - game is in progress
# time since starting this game
# the current piece
# the next piece
# the current score
# the currently displayed score (it catches up to score in small chunks - like a spinning slot machine)
# number of completed rows in the current game
# how long before current piece drops by 1 row

#-------------------------------------------------------------------------
# tetris pieces
#
# blocks: each element represents a rotation of the piece (0, 90, 180, 270)
#         each element is a 16 bit integer where the 16 bits represent
#         a 4x4 set of blocks, e.g. j.blocks[0] = 0x44C0
#
#             0100 = 0x4 << 3 = 0x4000
#             0100 = 0x4 << 2 = 0x0400
#             1100 = 0xC << 1 = 0x00C0
#             0000 = 0x0 << 0 = 0x0000
#                               ------
#                               0x44C0
#
#-------------------------------------------------------------------------

#------------------------------------------------
# do the bit manipulation and iterate through each
# occupied block (x,y) for a given piece
#------------------------------------------------
eachblock = (type, x, y, dir, fn) ->
  bit = undefined
  result = undefined
  row = 0
  col = 0
  blocks = type.blocks[dir]
  bit = 0x8000
  while bit > 0
    fn x + col, y + row  if blocks & bit
    if ++col is 4
      col = 0
      ++row
    bit = bit >> 1
  return

#-----------------------------------------------------
# check if a piece can fit into a position in the grid
#-----------------------------------------------------
occupied = (type, x, y, dir) ->
  result = false
  eachblock type, x, y, dir, (x, y) ->
    result = true  if (x < 0) or (x >= nx) or (y < 0) or (y >= ny) or getBlock(x, y)
    return

  result
unoccupied = (type, x, y, dir) ->
  not occupied(type, x, y, dir)

#-----------------------------------------
# start with 4 instances of each piece and
# pick randomly until the 'bag is empty'
#-----------------------------------------
randomPiece = ->
  if pieces.length is 0
    pieces = [
      i
      i
      i
      i
      j
      j
      j
      j
      l
      l
      l
      l
      o
      o
      o
      o
      s
      s
      s
      s
      t
      t
      t
      t
      z
      z
      z
      z
    ]
  type = pieces.splice(random(0, pieces.length - 1), 1)[0]
  type: type
  dir: DIR.UP
  x: Math.round(random(0, nx - type.size))
  y: 0

#-------------------------------------------------------------------------
# GAME LOOP
#-------------------------------------------------------------------------
run = ->
  # attach keydown and resize events
  frame = ->
    now = timestamp()
    update Math.min(1, (now - last) / 1000.0) # using requestAnimationFrame have to be able to handle large delta's caused when it 'hibernates' in a background or non-visible tab
    draw()
    last = now
    requestAnimationFrame frame, canvas
    return
  addEvents()
  last = now = timestamp()
  resize() # setup all our sizing information
  reset() # reset the per-game variables
  frame() # start the first frame
  return
addEvents = ->
  document.addEventListener "keydown", keydown, false
  window.addEventListener "resize", resize, false
  return
resize = (event) ->
  canvas.width = canvas.clientWidth # set canvas logical size equal to its physical size
  canvas.height = canvas.clientHeight # (ditto)
  ucanvas.width = ucanvas.clientWidth
  ucanvas.height = ucanvas.clientHeight
  dx = canvas.width / nx # pixel size of a single tetris block
  dy = canvas.height / ny # (ditto)
  invalidate()
  invalidateNext()
  return
keydown = (ev) ->
  handled = false
  if playing
    switch ev.keyCode
      when KEY.LEFT
        actions.push DIR.LEFT
        handled = true
      when KEY.RIGHT
        actions.push DIR.RIGHT
        handled = true
      when KEY.UP
        actions.push DIR.UP
        handled = true
      when KEY.DOWN
        actions.push DIR.DOWN
        handled = true
      when KEY.ESC
        lose()
        handled = true
  else if ev.keyCode is KEY.SPACE
    play()
    handled = true
  ev.preventDefault()  if handled # prevent arrow keys from scrolling the page (supported in IE9+ and all other browsers)
  return

#-------------------------------------------------------------------------
# GAME LOGIC
#-------------------------------------------------------------------------
play = ->
  hide "start"
  reset()
  playing = true
  return
lose = ->
  show "start"
  setVisualScore()
  playing = false
  return
setVisualScore = (n) ->
  vscore = n or score
  invalidateScore()
  return
setScore = (n) ->
  score = n
  setVisualScore n
  return
addScore = (n) ->
  score = score + n
  return
clearScore = ->
  setScore 0
  return
clearRows = ->
  setRows 0
  return
setRows = (n) ->
  rows = n
  step = Math.max(speed.min, speed.start - (speed.decrement * rows))
  invalidateRows()
  return
addRows = (n) ->
  setRows rows + n
  return
getBlock = (x, y) ->
  (if blocks and blocks[x] then blocks[x][y] else null)
setBlock = (x, y, type) ->
  blocks[x] = blocks[x] or []
  blocks[x][y] = type
  invalidate()
  return
clearBlocks = ->
  blocks = []
  invalidate()
  return
clearActions = ->
  actions = []
  return
setCurrentPiece = (piece) ->
  current = piece or randomPiece()
  invalidate()
  return
setNextPiece = (piece) ->
  next = piece or randomPiece()
  invalidateNext()
  return
reset = ->
  dt = 0
  clearActions()
  clearBlocks()
  clearRows()
  clearScore()
  setCurrentPiece next
  setNextPiece()
  return
update = (idt) ->
  if playing
    setVisualScore vscore + 1  if vscore < score
    handle actions.shift()
    dt = dt + idt
    if dt > step
      dt = dt - step
      drop()
  return
handle = (action) ->
  switch action
    when DIR.LEFT
      move DIR.LEFT
    when DIR.RIGHT
      move DIR.RIGHT
    when DIR.UP
      rotate()
    when DIR.DOWN
      drop()
move = (dir) ->
  x = current.x
  y = current.y
  switch dir
    when DIR.RIGHT
      x = x + 1
    when DIR.LEFT
      x = x - 1
    when DIR.DOWN
      y = y + 1
  if unoccupied(current.type, x, y, current.dir)
    current.x = x
    current.y = y
    invalidate()
    true
  else
    false
rotate = ->
  newdir = ((if current.dir is DIR.MAX then DIR.MIN else current.dir + 1))
  if unoccupied(current.type, current.x, current.y, newdir)
    current.dir = newdir
    invalidate()
  return
drop = ->
  unless move(DIR.DOWN)
    addScore 10
    dropPiece()
    removeLines()
    setCurrentPiece next
    setNextPiece randomPiece()
    clearActions()
    lose()  if occupied(current.type, current.x, current.y, current.dir)
  return
dropPiece = ->
  eachblock current.type, current.x, current.y, current.dir, (x, y) ->
    setBlock x, y, current.type
    return

  return
removeLines = ->
  x = undefined
  y = undefined
  complete = undefined
  n = 0
  y = ny
  while y > 0
    complete = true
    x = 0
    while x < nx
      complete = false  unless getBlock(x, y)
      ++x
    if complete
      removeLine y
      y = y + 1 # recheck same line
      n++
    --y
  if n > 0
    addRows n
    addScore 100 * Math.pow(2, n - 1) # 1: 100, 2: 200, 3: 400, 4: 800
  return
removeLine = (n) ->
  x = undefined
  y = undefined
  y = n
  while y >= 0
    x = 0
    while x < nx
      setBlock x, y, (if (y is 0) then null else getBlock(x, y - 1))
      ++x
    --y
  return

#-------------------------------------------------------------------------
# RENDERING
#-------------------------------------------------------------------------
invalidate = ->
  invalid.court = true
  return
invalidateNext = ->
  invalid.next = true
  return
invalidateScore = ->
  invalid.score = true
  return
invalidateRows = ->
  invalid.rows = true
  return
draw = ->
  ctx.save()
  ctx.lineWidth = 1
  ctx.translate 0.5, 0.5 # for crisp 1px black lines
  drawCourt()
  drawNext()
  drawScore()
  drawRows()
  ctx.restore()
  return
drawCourt = ->
  if invalid.court
    ctx.clearRect 0, 0, canvas.width, canvas.height
    drawPiece ctx, current.type, current.x, current.y, current.dir  if playing
    x = undefined
    y = undefined
    block = undefined
    y = 0
    while y < ny
      x = 0
      while x < nx
        drawBlock ctx, x, y, block.color  if block = getBlock(x, y)
        x++
      y++
    ctx.strokeRect 0, 0, nx * dx - 1, ny * dy - 1 # court boundary
    invalid.court = false
  return
drawNext = ->
  if invalid.next
    padding = (nu - next.type.size) / 2 # half-arsed attempt at centering next piece display
    uctx.save()
    uctx.translate 0.5, 0.5
    uctx.clearRect 0, 0, nu * dx, nu * dy
    drawPiece uctx, next.type, padding, padding, next.dir
    uctx.strokeStyle = "black"
    uctx.strokeRect 0, 0, nu * dx - 1, nu * dy - 1
    uctx.restore()
    invalid.next = false
  return
drawScore = ->
  if invalid.score
    html "score", ("00000" + Math.floor(vscore)).slice(-5)
    invalid.score = false
  return
drawRows = ->
  if invalid.rows
    html "rows", rows
    invalid.rows = false
  return
drawPiece = (ctx, type, x, y, dir) ->
  eachblock type, x, y, dir, (x, y) ->
    drawBlock ctx, x, y, type.color
    return

  return
drawBlock = (ctx, x, y, color) ->
  ctx.fillStyle = color
  ctx.fillRect x * dx, y * dy, dx, dy
  ctx.strokeRect x * dx, y * dy, dx, dy
  return
unless window.requestAnimationFrame
  window.requestAnimationFrame = window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
    window.setTimeout callback, 1000 / 60
    return
KEY =
  ESC: 27
  SPACE: 32
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40

DIR =
  UP: 0
  RIGHT: 1
  DOWN: 2
  LEFT: 3
  MIN: 0
  MAX: 3

canvas = get("canvas")
ctx = canvas.getContext("2d")
ucanvas = get("upcoming")
uctx = ucanvas.getContext("2d")
speed =
  start: 0.6
  decrement: 0.005
  min: 0.1

nx = 10
ny = 20
nu = 5
dx = undefined
dy = undefined
blocks = undefined
actions = undefined
playing = undefined
dt = undefined
current = undefined
next = undefined
score = undefined
vscore = undefined
rows = undefined
step = undefined
i =
  size: 4
  blocks: [
    0x0f00
    0x2222
    0x00f0
    0x4444
  ]
  color: "cyan"

j =
  size: 3
  blocks: [
    0x44c0
    0x8e00
    0x6440
    0x0e20
  ]
  color: "blue"

l =
  size: 3
  blocks: [
    0x4460
    0x0e80
    0xc440
    0x2e00
  ]
  color: "orange"

o =
  size: 2
  blocks: [
    0xcc00
    0xcc00
    0xcc00
    0xcc00
  ]
  color: "yellow"

s =
  size: 3
  blocks: [
    0x06c0
    0x8c40
    0x6c00
    0x4620
  ]
  color: "green"

t =
  size: 3
  blocks: [
    0x0e40
    0x4c40
    0x4e00
    0x4640
  ]
  color: "purple"

z =
  size: 3
  blocks: [
    0x0c60
    0x4c80
    0xc600
    0x2640
  ]
  color: "red"

pieces = []
invalid = {}

#-------------------------------------------------------------------------
# FINALLY, lets run the game
#-------------------------------------------------------------------------
run()