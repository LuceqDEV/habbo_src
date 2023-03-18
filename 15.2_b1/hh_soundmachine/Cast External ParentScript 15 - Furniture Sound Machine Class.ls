on setID me, tid
  callAncestor(#setID, [me], tid)
  executeMessage(#sound_machine_created, me.getID(), 1)
  return 1
end

on deconstruct me
  executeMessage(#sound_machine_removed, me.getID())
  callAncestor(#deconstruct, [me])
  return 1
end

on define me, tProps
  tRetVal = callAncestor(#define, [me], tProps)
  if voidp(tProps[#stripId]) then
    executeMessage(#sound_machine_defined, me.getID())
  end if
  return 1
end

on select me
  tOwner = 0
  tSession = getObject(#session)
  if tSession <> 0 then
    if tSession.GET("room_owner") then
      tOwner = 1
    end if
  end if
  if the doubleClick and tOwner then
    tStateOn = 0
    if me.pState = 2 then
      tStateOn = 1
    end if
    executeMessage(#sound_machine_selected, [#id: me.getID(), #furniOn: tStateOn])
  else
    return callAncestor(#select, [me])
  end if
  return 1
end

on changeState me, tStateOn
  tNewState = 1
  if tStateOn then
    tNewState = 2
  end if
  return getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: string(tNewState)])
end

on setState me, tNewState
  callAncestor(#setState, [me], tNewState)
  if voidp(tNewState) then
    return 0
  end if
  tStateOn = 0
  if me.pState = 2 then
    tStateOn = 1
  end if
  executeMessage(#sound_machine_set_state, [#id: me.getID(), #furniOn: tStateOn])
end
