on prepare(me, tdata)
  if tdata.getAt("SWITCHON") = "ON" then
    setOn(me)
    pChanges = 1
  else
    setOff(me)
    pChanges = 0
  end if
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 8 then
    return()
  end if
  tNewNameA = "bath_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameB = "bath_f_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameC = "bath_g_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameD = "bath_h_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  if memberExists(tNewNameA) then
    tmember = member(abs(getmemnum(tNewNameA)))
    me.getPropRef(#pSprList, 5).castNum = tmember.number
    me.getPropRef(#pSprList, 5).width = tmember.width
    me.getPropRef(#pSprList, 5).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameB)))
    me.getPropRef(#pSprList, 6).castNum = tmember.number
    me.getPropRef(#pSprList, 6).width = tmember.width
    me.getPropRef(#pSprList, 6).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameC)))
    me.getPropRef(#pSprList, 7).castNum = tmember.number
    me.getPropRef(#pSprList, 7).width = tmember.width
    me.getPropRef(#pSprList, 7).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameD)))
    me.getPropRef(#pSprList, 8).castNum = tmember.number
    me.getPropRef(#pSprList, 8).width = tmember.width
    me.getPropRef(#pSprList, 8).height = tmember.height
  end if
  pChanges = 0
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
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SWITCHON" & "/" & tStr)
  else
    getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY)
  end if
  return(1)
  exit
end