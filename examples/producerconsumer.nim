import greenlet, random

randomize()

var
  consumer*: ptr Greenlet
  producer*: ptr Greenlet
  stack: seq[int]

proc consumerProc*(arg: pointer): pointer =
  while true:    
    while stack.len > 0:
      echo "consume ", stack.pop()
    if producer.dead:
      return
    producer.switchTo()

proc producerProc*(arg: pointer): pointer =
  for i in 0 .. 10:
    echo "produce ", i
    stack.add i
    if rand(2) == 0:
      echo "{"
      consumer.switchTo()
      echo "}"


consumer = newGreenlet(consumerProc)
producer = newGreenlet(producerProc)

producer.switchTo()
echo "{"
consumer.switchTo()
echo "}"

consumer.destroy()
producer.destroy()

