on prepare(me, tdata)
  pChanges = 1
  pTiming = 1
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
  exit
end

on update(me)
  pTiming = not pTiming
  if not pChanges then
    return()
  end if
  if not pTiming then
    return()
  end if
  if me.count(#pSprList) < 3 then
    return()
  end if
  if me.pXFactor = 32 then
    tClass = "s_fireplace_polyfon"
  else
    tClass = "fireplace_polyfon"
  end if
  if pActive then
    tmember = member(getmemnum(tClass & "_c_0_2_1_4_" & random(10)))
  else
    tmember = member(getmemnum(tClass & "_c_0_2_1_4_0"))
    pChanges = 0
  end if
  me.getPropRef(#pSprList, 3).castNum = tmember.number
  me.getPropRef(#pSprList, 3).width = tmember.width
  me.getPropRef(#pSprList, 3).height = tmember.height
  exit
end

on setOn(me)
  pActive = 1
  exit
end

on setOff(me)
  pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return(1)
  exit
end