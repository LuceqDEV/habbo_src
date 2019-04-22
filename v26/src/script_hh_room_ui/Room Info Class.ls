on construct(me)
  pWindowID = "RoomInfoWindow"
  pEventInfoWindowID = "EventInfoWindow"
  pUseRatings = 0
  if variableExists("room.rating.enable") then
    if getVariable("room.rating.enable") = 1 then
      pUseRatings = 1
    end if
  end if
  registerMessage(#roomRatingChanged, me.getID(), #updateRatingData)
  registerMessage(#roomEventInfoUpdated, me.getID(), #updateRoomEventInfo)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showRoomInfo(me)
  tRoomData = getThread(#room).getComponent().getRoomData()
  if listp(tRoomData) then
    tRoomType = tRoomData.getaProp(#type)
  end if
  if tRoomType = #private then
    tWndObj = me.createInfoWindow()
    if tWndObj = 0 then
      return(0)
    end if
    tRoomData = getThread(#room).getComponent().pSaveData
    tWndObj.getElement("room_info_room_name").setText(tRoomData.getAt(#name))
    tWndObj.getElement("room_info_owner").setText(getText("room_owner") && tRoomData.getAt(#owner))
    me.updateRatingData()
    me.updateRoomEventInfo()
  else
    me.hideRoomInfo()
  end if
  exit
end

on hideRoomInfo(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if windowExists(pEventInfoWindowID) then
    removeWindow(pEventInfoWindowID)
  end if
  exit
end

on createInfoWindow(me)
  if not windowExists(pWindowID) then
    tSuccess = createWindow(pWindowID, "room_info.window", 10, 420)
    if tSuccess = 0 then
      return(0)
    else
      tWndObj = getWindow(pWindowID)
      tWndObj.lock()
      tWndObj.registerProcedure(#eventProcInfo, me.getID())
      return(tWndObj)
    end if
  else
    return(getWindow(pWindowID))
  end if
  exit
end

on sendFlatRate(me, tValue)
  getThread(#room).getComponent().getRoomConnection().send("RATEFLAT", [#integer:tValue])
  exit
end

on updateRatingData(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if not tWndObj.elementExists("room_info_rate_plus") then
    return(0)
  end if
  if not pUseRatings then
    me.hideRatingElements()
    return(1)
  end if
  tRoomRatings = getThread(#room).getComponent().getRoomRating()
  if tRoomRatings.getAt(#rate) = -1 then
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 0)
  else
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 1)
    tRateText = getText("room_info_rated") && tRoomRatings.getAt(#rate)
    tWndObj.getElement("room_info_rate_value").setText(tRateText)
  end if
  exit
end

on hideRatingElements(me)
  tWndObj = getWindow(pWindowID)
  tWndObj.getElement("room_info_rate_room").setProperty(#visible, 0)
  tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 0)
  tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 0)
  tWndObj.getElement("room_info_rate_value").setProperty(#visible, 0)
  exit
end

on updateRoomEventInfo(me)
  tRoomEventData = getThread(#room).getComponent().getRoomEvent()
  if voidp(tRoomEventData) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if tWnd = 0 then
    return(0)
  end if
  tLinkElem = tWnd.getElement("roominfo_event_link")
  tHostID = tRoomEventData.getaProp(#hostID)
  if tHostID > 0 then
    tLinkElem.show()
    tName = tRoomEventData.getaProp(#name)
    tLinkElem.setText(tName)
  else
    tLinkElem.hide()
  end if
  exit
end

on showEventInfo(me)
  tRoomEventData = getThread(#room).getComponent().getRoomEvent()
  createWindow(pEventInfoWindowID, "eventinfo_bubble.window")
  tWnd = getWindow(pEventInfoWindowID)
  tWnd.merge("room_info_event_details.window")
  tName = tRoomEventData.getaProp(#name)
  tDesc = tRoomEventData.getaProp(#desc)
  tWnd.getElement("room_info_event_details_header").setText(tName)
  tWnd.getElement("room_info_event_details_text").setText(tDesc)
  tWnd.registerProcedure(#eventProcEventInfo, me.getID(), #mouseUp)
  tWnd.moveTo(5, 355)
  tSessionObj = getObject(#session)
  tUserRights = tSessionObj.GET("user_rights")
  tRoomOwner = tSessionObj.GET("room_owner")
  tCanQuit = tUserRights.getOne("fuse_cancel_roomevent") <> 0
  if tRoomOwner or tCanQuit then
    tWnd.getElement("room_info_event_details_quit").show()
    tWnd.getElement("room_info_event_details_edit").show()
  else
    tWnd.getElement("room_info_event_details_quit").hide()
    tWnd.getElement("room_info_event_details_edit").hide()
  end if
  exit
end

on removeEventInfo(me)
  removeWindow(pEventInfoWindowID)
  exit
end

on quitEvent(me)
  tConn = getConnection(getVariable("connection.info.id", #info))
  tConn.send("QUIT_ROOMEVENT")
  me.removeEventInfo()
  exit
end

on editEvent(me)
  executeMessage(#editRoomevent)
  me.removeEventInfo()
  exit
end

on eventProcInfo(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "room_info_rate_plus" then
    me.sendFlatRate(1)
  else
    if me = "room_info_rate_minus" then
      me.sendFlatRate(-1)
    else
      if me = "roominfo_event_link" then
        me.showEventInfo()
      end if
    end if
  end if
  exit
end

on eventProcEventInfo(me, tEvent, tSprID, tParam)
  if me = "room_info_event_details_close" then
    me.removeEventInfo()
  else
    if me = "room_info_event_details_quit" then
      me.quitEvent()
    else
      if me = "room_info_event_details_edit" then
        me.editEvent()
      end if
    end if
  end if
  exit
end