on construct me 
  getThread(#room).getComponent().getClassContainer().set("hububar", ["Passive Object Class", "Hububar Class"])
  initThread("hubu.index")
  return TRUE
end

on deconstruct me 
  closeThread(#hubu)
  return TRUE
end

on prepare me 
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  repeat while ["goawaybus"] <= undefined
    tid = getAt(undefined, undefined)
    tSprite = tRoomVis.getSprById(tid)
    registerProcedure(tSprite, #busTeleport, me.getID(), #mouseDown)
  end repeat
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return FALSE
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPar = tMsg.getAt(#show_params)
end

on busTeleport me, tEvent, tSprID, tParm 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if (tConnection = 0) then
    return FALSE
  end if
  if (tSprID = "goawaybus") then
    tConnection.send("CHANGEWORLD", "0")
  end if
end
