import greenlet

var g = newGreenlet proc (arg: pointer): pointer =
  echo "in func1 (greenlet 1)"
  rootGreenlet().switchTo()
  echo "exiting func1 (greenlet 1)"
  return nil

echo "entering greenlet 1"
g.switchTo()

echo "exiting program"

#if g.dead: 
g.destroy()

echo "really done"


