property pTargetData, pDoorOpentimer, pAnimActive, pAnimTime, pProcessActive, pKickTime

on prepare me, tdata 
  pProcessActive = 0
  pAnimActive = 0
  pAnimTime = 10
  pKickTime = 0
  pTargetData = [:]
  if me.count(#pSprList) < 3 then
    return FALSE
  end if
  me.getPropRef(#pSprList, 3).visible = 0
  if tdata.count > 0 then
    me.updateStuffdata("DOOROPEN", tdata.getAt("DOOROPEN"))
  end if
  if getObject(#session).exists("target_door_ID") then
    if (getObject(#session).get("target_door_ID") = me.getID()) then
      getObject(#session).set("target_door_ID", 0)
      me.animate(12)
      me.delay(800, #kickOut)
    end if
  end if
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if me.count(#pSprList) < 3 then
    return FALSE
  end if
  if (tValue = "TRUE") then
    pDoorOpentimer = 18
  else
    tCurName = me.getPropRef(#pSprList, 1).member.name
    tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & 0
    tmember = member(abs(getmemnum(tNewName)))
    me.getPropRef(#pSprList, 1).castNum = tmember.number
    me.getPropRef(#pSprList, 1).width = tmember.width
    me.getPropRef(#pSprList, 1).height = tmember.height
    tMaskMem = me.getPropRef(#pSprList, 2).member.name
    tNewMask = tMaskMem.getProp(#char, 1, (length(tMaskMem) - 1)) & 0
    tmember = member(abs(getmemnum(tNewMask)))
    me.getPropRef(#pSprList, 2).castNum = tmember.number
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
    pDoorOpentimer = 0
  end if
end

on select me 
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if (tUserObj = 0) then
      return TRUE
    end if
    if (me.pLocX = tUserObj.pLocX) and (me.pLocY = tUserObj.pLocY) then
      return(me.tryDoor())
    end if
    tUserIsClose = 0
    if (me.getProp(#pDirection, 1) = 4) then
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        tUserIsClose = 1
      else
        return(getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY + 1)]))
      end if
    else
      if (me.getProp(#pDirection, 1) = 0) then
        if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
          tUserIsClose = 1
        else
          return(getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY - 1)]))
        end if
      else
        if (me.getProp(#pDirection, 1) = 2) then
          if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
            tUserIsClose = 1
          else
            return(getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX + 1), #short:me.pLocY]))
          end if
        else
          if (me.getProp(#pDirection, 1) = 6) then
            if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
              tUserIsClose = 1
            else
              return(getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX - 1), #short:me.pLocY]))
            end if
          end if
        end if
      end if
    end if
    if tUserIsClose then
      getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
      getThread(#room).getComponent().getRoomConnection().send("INTODOOR", me.getID())
      me.tryDoor()
    end if
  end if
  return TRUE
end

on tryDoor me 
  getObject(#session).set("current_door_ID", me.getID())
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("GETDOORFLAT", me.getID())
  end if
  return TRUE
end

on startTeleport me, tDataList 
  pTargetData = tDataList
  pProcessActive = 1
  me.animate(50)
  getThread(#room).getComponent().getRoomConnection().send("DOORGOIN", me.getID())
end

on doorLogin me 
  pProcessActive = 0
  getObject(#session).set("target_door_ID", pTargetData.getAt(#teleport))
  return(getThread(#room).getComponent().enterDoor(pTargetData))
end

on prepareToKick me, tIncomer 
  if (tIncomer = getObject(#session).get("user_name")) then
    pKickTime = 20
  end if
end

on kickOut me 
  tRoom = getThread(#room).getComponent()
  tRoom.getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
  if (me.getProp(#pDirection, 1) = 2) then
    tRoom.getRoomConnection().send("MOVE", [#short:(me.pLocX + 1), #short:me.pLocY])
  else
    tRoom.getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY + 1)])
  end if
end

on animate me, tTime 
  if voidp(tTime) then
    tTime = 25
  end if
  pAnimTime = tTime
  pAnimActive = 1
end

on update me 
  if me.count(#pSprList) < 3 then
    return FALSE
  end if
  if pDoorOpentimer > 0 then
    tCurName = me.getPropRef(#pSprList, 1).member.name
    tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & 1
    tmember = member(abs(getmemnum(tNewName)))
    me.getPropRef(#pSprList, 1).castNum = tmember.number
    me.getPropRef(#pSprList, 1).width = tmember.width
    me.getPropRef(#pSprList, 1).height = tmember.height
    tCurName = me.getPropRef(#pSprList, 2).member.name
    tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & 1
    tmember = member(abs(getmemnum(tNewName)))
    me.getPropRef(#pSprList, 2).castNum = tmember.number
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
    pDoorOpentimer = (pDoorOpentimer - 1)
    if (pDoorOpentimer = 0) then
      getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "DOOROPEN" & "/" & "FALSE")
    end if
  end if
  if pAnimActive > 0 then
    tName = me.getPropRef(#pSprList, 1).member.name
    if (tName.getProp(#char, length(tName)) = "1") then
      me.getPropRef(#pSprList, 3).visible = 0
    else
      pAnimActive = ((pAnimActive + 1) mod pAnimTime)
      tVisible = (pAnimActive mod 2)
      if tVisible and random(4) > 1 then
        me.getPropRef(#pSprList, 3).visible = 1
      else
        me.getPropRef(#pSprList, 3).visible = 0
      end if
    end if
  end if
  if pProcessActive and (pAnimActive = (pAnimTime - 1)) then
    return(me.doorLogin())
  end if
  if pKickTime > 0 then
    pKickTime = (pKickTime - 1)
    if (pKickTime = 0) then
      me.kickOut()
    end if
  end if
end
