property pCurtainsLocZ, pSplashs, pTimer

on construct me 
  pTimer = 0
  createObject("dew_clouds", "Mountain Clouds Class")
  createObject("dew_camera", "FUSE screen Class")
  initThread("mountain.index")
  initThread("paalu.index")
  receivePrepare(me.getID())
  me.prepareRoom()
  return TRUE
end

on deconstruct me 
  removePrepare(me.getID())
  removeObject("dew_clouds")
  removeObject("dew_camera")
  removeObject(#waterripples)
  closeThread(#mountain)
  closeThread(#paalu)
  return TRUE
end

on prepareRoom me 
  pCurtainsLocZ = [:]
  f = 1
  repeat while f <= 2
    tSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ.setAt("curtains" & f, tSprite.locZ)
    tSprite.locZ = (tSprite.locZ - 2000)
    f = (1 + f)
  end repeat
  tProps = [:]
  pSplashs = [:]
  pSplashs.addProp("Splash0", createObject(#temp, "AnimSprite Class"))
  tProps.setAt(#visible, 0)
  tProps.setAt(#AnimFrames, 10)
  tProps.setAt(#startFrame, 0)
  tProps.setAt(#MemberName, "splash_")
  tProps.setAt(#id, "Splash0")
  pSplashs.getAt("Splash0").setData(tProps)
  createObject(#waterripples, "Water Ripple Effects Class")
  getObject(#waterripples).Init("vesi1")
end

on showprogram me, tMsg 
  if not voidp(tMsg) then
    tDest = tMsg.getAt(#show_dest)
    tCommand = tMsg.getAt(#show_command)
    tParam = tMsg.getAt(#show_params)
    if tDest contains "cam" then
      if objectExists("dew_camera") then
        call(symbol("fuseShow_" & tCommand), getObject("dew_camera"), tParam)
      end if
    else
      if tDest contains "Splash" then
        me.splash(tDest, tCommand)
      else
        if tDest contains "curtains" then
          me.curtains(tDest, tCommand)
        end if
      end if
    end if
  end if
end

on curtains me, tid, tCommand 
  if (tCommand = "open") then
    tmember = member(getmemnum("dew_verho_auki"))
    tlocz = (pCurtainsLocZ.getAt(tid) - 2000)
  else
    if (tCommand = "close") then
      tmember = member(getmemnum("dew_verho_kiinni"))
      tlocz = (pCurtainsLocZ.getAt(tid) - 1000)
    end if
  end if
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if (tRoomVis = 0) then
    return FALSE
  end if
  tRoomVis.getSprById(tid).setMember(tmember)
  tRoomVis.getSprById(tid).locZ = tlocz
  return TRUE
end

on splash me, tDest, tCommand 
  if not voidp(pSplashs.getAt(tDest)) then
    call(#Activate, pSplashs.getAt(tDest))
  end if
end

on prepare me 
  pTimer = not pTimer
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if pTimer then
    i = 1
    repeat while i <= 3
      tRoomVis.getSprById("putous" && i).member = member(getmemnum("dew_putous" & i & "_" & random(7)))
      i = (1 + i)
    end repeat
  end if
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
end
