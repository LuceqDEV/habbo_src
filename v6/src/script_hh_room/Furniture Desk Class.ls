property pChanges, pActive

on prepare me, tdata 
  if (tdata.getAt("SWITCHON") = "ON") then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (tValue = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 4 then
    return()
  end if
  tNewNameA = "hc_dsk_c_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameB = "hc_dsk_d_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameC = "hc_dsk_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  if memberExists(tNewNameA) then
    tmember = member(abs(getmemnum(tNewNameA)))
    me.getPropRef(#pSprList, 3).castNum = tmember.number
    me.getPropRef(#pSprList, 3).width = tmember.width
    me.getPropRef(#pSprList, 3).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameB)))
    me.getPropRef(#pSprList, 4).castNum = tmember.number
    me.getPropRef(#pSprList, 4).width = tmember.width
    me.getPropRef(#pSprList, 4).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameC)))
    me.getPropRef(#pSprList, 5).castNum = tmember.number
    me.getPropRef(#pSprList, 5).width = tmember.width
    me.getPropRef(#pSprList, 5).height = tmember.height
  end if
  pChanges = 0
end

on setOn me 
  pActive = 1
end

on setOff me 
  pActive = 0
end

on select me 
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "SWITCHON" & "/" & tStr)
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY])
  end if
  return TRUE
end
