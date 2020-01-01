import greenlet

var
  ping*: ptr Greenlet
  pong*: ptr Greenlet

proc pingProc*(arg: pointer): pointer =
  var value = 0
  while true: 
    let ptrValue = pong.switchTo(cast[pointer](unsafeAddr value))
    value = cast[ptr int](ptrValue)[]
    echo "ping ", value
    value += 1

proc pongProc*(arg: pointer): pointer =
  var value = 0
  while true: 
    let ptrValue = ping.switchTo(cast[pointer](unsafeAddr value))
    value = cast[ptr int](ptrValue)[]
    echo "pong ", value
    value += 1

ping = newGreenlet(pingProc)
pong = newGreenlet(pongProc)

let value = 0
discard ping.switchTo(cast[pointer](unsafeAddr value))

ping.destroy()
pong.destroy()

