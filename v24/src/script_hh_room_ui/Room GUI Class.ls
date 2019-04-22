on construct(me)
  pRoomBarID = "RoomBarProgram"
  pRoomInfoID = "RoomInfoProgram"
  pObjectDispID = "ObjectDisplayerProgram"
  createObject(pRoomInfoID, "Room Info Class")
  createObject(pRoomBarID, "Room Bar Class")
  createObject(pObjectDispID, "Room Object Displayer Class")
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showRoomBar(me, tLayout)
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.showRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.showRoomBar(tLayout)
  end if
  if threadExists("new_user_help") then
    tComponent = getThread("new_user_help").getComponent()
    if tComponent.isChatHelpOn() then
      tRoomBarObj.applyChatHelpText()
    end if
  end if
  exit
end

on hideRoomBar(me)
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.hideRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.hideRoomBar()
  end if
  exit
end

on setRollOverInfo(me, tInfoText)
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.setRollOverInfo(tInfoText)
  end if
  exit
end

on showInfostand(me)
  nothing()
  exit
end

on hideInfoStand(me)
  tObjDisp = getObject(pObjectDispID)
  tObjDisp.clearWindowDisplayList()
  exit
end

on showObjectInfo(me, tObjType)
  tObjDisp = getObject(pObjectDispID)
  tObjDisp.showObjectInfo(tObjType)
  exit
end

on showVote(me)
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.showVote()
  end if
  exit
end