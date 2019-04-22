on construct(me)
  pCurtainsLocZ = []
  tProps = []
  pSplashs = []
  initThread("thread.pelle")
  return(1)
  exit
end

on deconstruct(me)
  closeThread(#pellehyppy)
  removeUpdate(me.getID())
  if objectExists(#waterripples) then
    removeObject(#waterripples)
  end if
  pSplashs = void()
  me.removeArrowCursor()
  return(1)
  exit
end

on prepare(me)
  pCurtainsLocZ = []
  f = 1
  repeat while f <= 2
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ.setAt("curtains" & f, tSpr.locZ)
    tSpr.locZ = tSpr.locZ - 2000
    f = 1 + f
  end repeat
  tProps = []
  pSplashs = []
  pSplashs.addProp("Splash0", createObject(#temp, "AnimSprite Class"))
  tProps.setAt(#visible, 0)
  tProps.setAt(#AnimFrames, 10)
  tProps.setAt(#startFrame, 0)
  tProps.setAt(#MemberName, "splash_")
  tProps.setAt(#id, "Splash0")
  pSplashs.getAt("Splash0").setData(tProps)
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  getObject(#waterripples).Init("vesi1")
  repeat while me <= undefined
    tid = getAt(undefined, undefined)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tid)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
  exit
end

on showprogram(me, tMsg)
  if voidp(tMsg) then
    return(0)
  end if
  tDest = tMsg.getAt(#show_dest)
  tCommand = tMsg.getAt(#show_command)
  tParm = tMsg.getAt(#show_params)
  if tDest contains "curtains" then
    me.curtains(tDest, tCommand)
  else
    if tDest contains "Splash" then
      me.splash(tDest, tCommand)
    end if
  end if
  exit
end

on curtains(me, tid, tCommand)
  if me = "open" then
    tmember = getMember("verhot auki")
  else
    if me = "close" then
      tmember = getMember("verho kiinni")
    end if
  end if
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return(0)
  end if
  tVisObj.getSprById(tid).setMember(tmember)
  return(1)
  exit
end

on splash(me, tDest, tCommand)
  if voidp(pSplashs.getAt(tDest)) then
    return(0)
  end if
  call(#Activate, pSplashs.getAt(tDest))
  exit
end

on update(me)
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or the mouseH > 694 then
    me.poolArrows()
  end if
  exit
end

on poolArrows(me)
  tStartPos = [19, 3]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return(me.removeArrowCursor())
  end if
  if tStartPos.getAt(1) - tloc.getAt(1) = tStartPos.getAt(2) - tloc.getAt(2) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_r")), member(getmemnum("cursor_arrow_r_mask"))])
  else
    me.removeArrowCursor()
  end if
  exit
end

on removeArrowCursor(me)
  pArrowCursor = 0
  cursor(-1)
  return(1)
  exit
end

on poolTeleport(me, tEvent, tSprID, tParm)
  tMyIndex = getObject(#session).GET("user_index")
  tObject = getThread(#room).getComponent().getUserObject(tMyIndex)
  if tObject = 0 then
    return(error(me, "Userobject not found:" && tMyIndex, #poolTeleport))
  end if
  tloc = tObject.getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParm)
  if not tSprID contains "pool_clickarea" and tloc.getAt(3) < 7 then
    getConnection(getVariable("connection.room.id")).send("MOVE", [#short:21, #short:28])
  else
    if tSprID contains "pool_clickarea" and tloc.getAt(3) = 7 then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short:20, #short:28])
    end if
  end if
  exit
end