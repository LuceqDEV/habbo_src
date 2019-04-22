on construct(me)
  registerListener(getVariable("connection.info.id"), me.getID(), [59:#handle_flatcreated, 33:#handle_error])
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return(1)
  exit
end

on deconstruct(me)
  unregisterListener(getVariable("connection.info.id"), me.getID(), [59:#handle_flatcreated, 33:#handle_error])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return(1)
  exit
end

on handle_flatcreated(me, tMsg)
  tid = content.getPropRef(#line, 1).getProp(#word, 1)
  tName = content.getProp(#line, 2)
  me.getInterface().flatcreated(tName, tid)
  exit
end

on handle_error(me, tMsg)
  tErr = tMsg.content
  if me = "Error creating a private room" then
    executeMessage(#alert, [#Msg:getText("roomatic_create_error")])
    return(me.getInterface().showHideRoomKiosk())
  end if
  return(1)
  exit
end