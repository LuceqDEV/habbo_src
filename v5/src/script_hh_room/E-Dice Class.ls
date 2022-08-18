property pValue, pActive, pAnimStart

on prepare me, tdata 
  pActive = 1
  pAnimStart = 0
  if not voidp(tdata.getAt("VALUE")) then
    pValue = tdata.getAt("VALUE")
  else
    pValue = 0
  end if
  return TRUE
end

on select me 
  if rollover(me.getProp(#pSprList, 2)) then
    if the doubleClick then
      tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
      if not tUserObj then
        return TRUE
      end if
      if abs((tUserObj.pLocX - me.pLocX)) > 1 or abs((tUserObj.pLocY - me.pLocY)) > 1 then
        tX = (me.pLocX - 1)
        repeat while tX <= (me.pLocX + 1)
          tY = (me.pLocY - 1)
          repeat while tY <= (me.pLocY + 1)
            if (tY = me.pLocY) or (tX = me.pLocX) then
              if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
                getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && tX && tY)
                return TRUE
              end if
            end if
            tY = (1 + tY)
          end repeat
          tX = (1 + tX)
        end repeat
        exit repeat
      end if
      getThread(#room).getComponent().getRoomConnection().send(#room, "THROW_DICE /" & me.getID())
    end if
  else
    if rollover(me.getProp(#pSprList, 1)) and the doubleClick then
      getThread(#room).getComponent().getRoomConnection().send(#room, "DICE_OFF /" & me.getID())
      return TRUE
    end if
  end if
  return TRUE
end

on diceThrown me, tValue 
  pActive = 1
  pValue = tValue
  if pValue > 0 then
    pAnimStart = the milliSeconds
  end if
end

on update me 
  if pActive then
    if me.count(#pSprList) < 2 then
      return()
    end if
    tSprite = me.getProp(#pSprList, 2)
    if (the milliSeconds - pAnimStart) < 2000 or (random(100) = 2) and pValue <> 0 then
      if (tSprite.castNum = getmemnum("edice_b_0_1_1_0_7")) then
        tmember = member(getmemnum("edice_b_0_1_1_0_0"))
      else
        tmember = member(getmemnum("edice_b_0_1_1_0_7"))
      end if
    else
      tmember = member(getmemnum("edice_b_0_1_1_0_" & pValue))
      pActive = 0
    end if
    tSprite.castNum = tmember.number
    tSprite.width = tmember.width
    tSprite.height = tmember.height
  end if
end
