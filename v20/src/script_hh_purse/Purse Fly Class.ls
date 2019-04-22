on define(me, tsprite, tCount)
  tWndObj = getWindow(getText("win_purse", "Habbo Purse"))
  pElement = tWndObj.getElement("fly_" & tCount)
  pElement.setProperty(#visible, 1)
  pFlyMember = 1
  pMyDir = 1
  pMyDir = [1, 3, 1, 4].getAt(tCount)
  pWinTop = 120
  pWinBottom = 185
  pWinLeft = 45
  pWinRight = 285
  pMyNum = tCount
  pWayCounter = 1
  return(1)
  exit
end

on animateFly(me)
  tList = getWindow(getText("win_purse", "Habbo Purse")).getProperty(#spriteList)
  tSpr = tList.getAt("fly_" & pMyNum)
  tFly = member(getmemnum("purse_fly" & pFlyMember))
  pElement.setProperty(#member, tFly)
  pElement.setProperty(#width, tFly.width)
  pElement.setProperty(#height, tFly.height)
  tLocX = pElement.getProperty(#locX)
  tLocY = pElement.getProperty(#locY)
  if me = tLocX < pWinLeft then
    if pMyDir = 2 then
      tSpr.flipH = 0
      pMyDir = 1
    else
      pWayCounter = 6
    end if
  else
    if me = tLocX > pWinRight then
      if pMyDir = 1 then
        tSpr.flipH = 1
        pMyDir = 2
      else
        pWayCounter = 1
      end if
    else
      if me = tLocY > pWinBottom then
        if pMyDir = 4 then
          tSpr.flipV = 0
          pMyDir = 3
        else
          pWayCounter = 11
        end if
      else
        if me = tLocY < pWinTop then
          if pMyDir = 3 then
            tSpr.flipV = 1
            pMyDir = 4
          else
            pWayCounter = 0
          end if
        end if
      end if
    end if
  end if
  if pMyDir < 3 then
    if me = pWayCounter <= 10 then
      tY = 2
    else
      if me = pWayCounter > 10 and pWayCounter <= 20 then
        tY = -2
      else
        if me = pWayCounter > 20 then
          pWayCounter = 0
        end if
      end if
    end if
    pFlyMember = 3 + pFlyMember = 3
  else
    if me = pWayCounter <= 5 then
      tX = -5
    else
      if me = pWayCounter > 5 and pWayCounter <= 10 then
        tX = 5
      else
        if me = pWayCounter > 10 then
          pWayCounter = 0
        end if
      end if
    end if
    pFlyMember = 1 + pFlyMember = 1
  end if
  if me = 1 then
    pElement.moveTo(tLocX + 7, tLocY + tY)
  else
    if me = 2 then
      pElement.moveTo(tLocX - 7, tLocY + tY)
    else
      if me = 3 then
        pElement.moveTo(tLocX + tX, tLocY - 3)
      else
        if me = 4 then
          pElement.moveTo(tLocX + tX, tLocY + 3)
        end if
      end if
    end if
  end if
  pWayCounter = pWayCounter + 1
  exit
end

on hideFlies(me)
  tWndObj = getWindow(getText("win_purse", "Habbo Purse"))
  pElement = tWndObj.getElement("fly_" & pMyNum)
  pElement.setProperty(#visible, 0)
  exit
end