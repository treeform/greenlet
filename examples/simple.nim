import greenlet

var
  gr1*: ptr Greenlet
  gr2*: ptr Greenlet

proc func1*(arg: pointer): pointer =
  echo "in func1 (greenlet 1)"
  gr2.switchTo()
  echo "back in func1 (greenlet 1)"
  gr2.switchTo()
  echo "back again in func1 (greenlet 1)"
  return nil

proc func2*(arg: pointer): pointer =
  echo "in func2 (greenlet 2)"
  gr1.switchTo()
  echo "back in func2 (greenlet 2)"
  return nil

gr1 = newGreenlet(func1)
gr2 = newGreenlet(func2)

# if (gr1 == nil) or (gr2 == nil):
#   echo "error: could not allocate greenlets"
#   quit(1)
  
echo "greenlet 1 started: ", gr1.started
echo "greenlet 2 started: ", gr2.started

echo "entering greenlet 1"
gr1.switchTo()

echo "greenlet 1 dead: ", gr1.dead
echo "greenlet 2 dead: ", gr2.dead

echo "re-entering greenlet 1"
gr1.switchTo() 

echo "greenlet 1 dead: ", gr1.dead
echo "greenlet 2 dead: ", gr2.dead

destroy(gr1)
destroy(gr2)

