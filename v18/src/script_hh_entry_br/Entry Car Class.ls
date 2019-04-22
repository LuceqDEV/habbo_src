on define(me, tsprite, tCount)
  tDirection = #left
  if tCount mod 2 = 1 then
    tDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  me.reset()
  return(1)
  exit
end

on reset(me)
  tmodel = ["car2", "car_b2", "car_c2"].getAt(random(3))
  pSprite.castNum = getmemnum(tmodel)
  if pDirection = #left then
    pSprite.flipH = 1
    pSprite.loc = point(490, 415)
    pOffset = [-2, -1]
    pTurnPnt = 180
  else
    pSprite.flipH = 0
    pSprite.loc = point(-20, 380)
    pOffset = [2, -1]
    pTurnPnt = 178
  end if
  pSprite.flipH = not pSprite.flipH
  pSprite.width = member.width
  pSprite.height = member.height
  if random(10) < 6 then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pWaitTime = random(250)
  exit
end

on update(me)
  pWaitTime = pWaitTime - 1
  if pWaitTime > 0 then
    return(0)
  end if
  pSprite.loc = pSprite.loc + pOffset
  if pSprite.locH = pTurnPnt then
    pOffset.setAt(2, -pOffset.getAt(2))
    tMemName = member.name
    tDirNum = integer(tMemName.getProp(#char, length(tMemName)))
    tDirNum = not tDirNum - 1 + 1
    tMemName = tMemName.getProp(#char, 1, length(tMemName) - 1) & tDirNum
    pSprite.castNum = getmemnum(tMemName)
    pSprite.width = member.width
    pSprite.height = member.height
  end if
  if pDirection = #left and pSprite.locH < -20 or pDirection = #right and pSprite.locH > 550 then
    me.reset()
  end if
  exit
end