property pSprite, pAnimFrame, pSpeed, pStartPointX

on prepare me, tSprite, tStartPointX 
  pAnimFrame = 0
  pSprite = tSprite
  pStartPointX = tStartPointX
  tRand = (random(50) - 25)
  pSprite.locH = (tStartPointX + tRand)
  pSprite.locV = ((tStartPointX - tRand) / 2)
  pSpeed = (random(3) - 1)
  tRand = random(5)
  tmember = member(getmemnum("pilvi" & tRand))
  pSprite.member = tmember
  pSprite.width = tmember.width
  pSprite.height = tmember.height
  return TRUE
end

on update me 
  pAnimFrame = (pAnimFrame + 1)
  if ((pAnimFrame mod pSpeed) = 0) then
    pSprite.locH = (pSprite.locH + 1)
    if ((pSprite.locH mod 2) = 0) then
      pSprite.locV = (pSprite.locV + 1)
    end if
    if pSprite.locH > (the stage.rect.width + 45) then
      me.reset()
    end if
  end if
end

on reset me 
  pSpeed = (random(3) - 1)
  tmember = member(getmemnum("dew_pilvi" & random(5)))
  pSprite.locH = pStartPointX
  pSprite.locV = -40
  pSprite.member = tmember
  pSprite.width = tmember.width
  pSprite.height = tmember.height
end
