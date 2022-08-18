property pHiliterId, pGeometryId, pContainerID, pSafeTraderID, pArrowObjID, pObjMoverID, pLoaderBarID, pRoomSpaceId, pBottomBarId, pInfoStandId, pSelectedObj, pInterfaceId, pDoorBellID, pVisitorQueue, pBannerLink, pInfoConnID, pCoverSpr, pSelectedType, pDelConfirmID, pPlcConfirmID, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pClickAction, pFloodblocking, pFloodTimer, pFloodEnterCount, pDanceState, pRingingUser, pDeleteType, pDeleteObjID

on construct me 
  pInfoConnID = getVariable("connection.info.id")
  pRoomConnID = getVariable("connection.room.id")
  pObjMoverID = "Room_obj_mover"
  pHiliterId = "Room_hiliter"
  pGeometryId = "Room_geometry"
  pContainerID = "Room_container"
  pSafeTraderID = "Room_safe_trader"
  pArrowObjID = "Room_arrow_hilite"
  pRoomSpaceId = "Room_visualizer"
  pBottomBarId = "Room_bar"
  pInfoStandId = "Room_info_stand"
  pInterfaceId = "Room_interface"
  pDelConfirmID = "Delete item?"
  pLoaderBarID = "Loading room"
  pPlcConfirmID = getText("win_place", "Place item?")
  pDoorBellID = getText("win_doorbell", "Doorbell")
  pDanceState = 0
  pClickAction = #null
  pSelectedObj = ""
  pSelectedType = ""
  pDeleteObjID = ""
  pDeleteType = ""
  pRingingUser = ""
  pVisitorQueue = []
  pBannerLink = 0
  createObject(pHiliterId, "Room Hiliter Class")
  createObject(pGeometryId, "Room Geometry Class")
  createObject(pContainerID, "Container Hand Class")
  createObject(pSafeTraderID, "Safe Trader Class")
  createObject(pArrowObjID, "Select Arrow Class")
  createObject(pObjMoverID, "Object Mover Class")
  getObject(pObjMoverID).setProperty(#geometry, getObject(pGeometryId))
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  return TRUE
end

on deconstruct me 
  pClickAction = #null
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  return(me.hideAll())
end

on showRoom me, tRoomId 
  if not memberExists(tRoomId & ".room") then
    return(error(me, "Room description not found:" && tRoomId, #showRoom))
  end if
  me.showTrashCover()
  if windowExists(pLoaderBarID) then
    activateWindow(pLoaderBarID)
  end if
  tRoomField = tRoomId & ".room"
  createVisualizer(pRoomSpaceId, tRoomField)
  tVisObj = getVisualizer(pRoomSpaceId)
  tLocX = tVisObj.getProperty(#locX)
  tLocY = tVisObj.getProperty(#locY)
  tlocz = tVisObj.getProperty(#locZ)
  tdata = getObject(#layout_parser).parse(tRoomField).getProp(#roomdata, 1)
  tdata.setAt(#offsetz, tlocz)
  tdata.setAt(#offsetx, tdata.getAt(#offsetx))
  tdata.setAt(#offsety, tdata.getAt(#offsety))
  me.getGeometry().define(tdata)
  tSprList = tVisObj.getProperty(#spriteList)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)
  tHiliterSpr = tVisObj.getSprById("hiliter")
  if not tHiliterSpr then
    me.getHiliter().deconstruct()
    error(me, "Hiliter not found in room description!!!", #showRoom)
  else
    me.getHiliter().define([#sprite:tHiliterSpr, #geometry:pGeometryId])
    receiveUpdate(pHiliterId)
  end if
  me.getArrowHiliter().Init()
  pClickAction = "moveHuman"
  return TRUE
end

on hideRoom me 
  removeUpdate(pHiliterId)
  pClickAction = #null
  pSelectedObj = ""
  me.hideArrowHiliter()
  me.hideTrashCover()
  if visualizerExists(pRoomSpaceId) then
    removeVisualizer(pRoomSpaceId)
  end if
  return TRUE
end

on showRoomBar me 
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 452)
    tWndObj = getWindow(pBottomBarId)
    tWndObj.lock(1)
    tWndObj.merge("room_bar.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
    executeMessage(#messageUpdateRequest)
    executeMessage(#buddyUpdateRequest)
    if (me.getComponent().getRoomData().type = #private) then
      tRoomData = me.getComponent().pSaveData
      tRoomTxt = getText("room_name") && tRoomData.getAt(#name) & "\r" & getText("room_owner") && tRoomData.getAt(#owner)
      tWndObj.getElement("room_info_text").setText(tRoomTxt)
    else
      tWndObj.getElement("room_info_text").hide()
    end if
    return TRUE
  end if
  return FALSE
end

on hideRoomBar me 
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    removeWindow(pBottomBarId)
  end if
end

on showInfostand me 
  if not windowExists(pInfoStandId) then
    createWindow(pInfoStandId, "info_stand.window", 552, 332)
    tWndObj = getWindow(pInfoStandId)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInfoStand, me.getID(), #mouseUp)
  end if
  return TRUE
end

on hideInfoStand me 
  if windowExists(pInfoStandId) then
    return(removeWindow(pInfoStandId))
  end if
end

on showInterface me, tObjType 
  tSession = getObject(#session)
  if (tObjType = "active") or (tObjType = "item") then
    tSomeRights = 0
    tUserName = tSession.get("user_name")
    tOwnUser = me.getComponent().getUserObject(tUserName)
    if (tOwnUser = 0) then
      return(error(me, "Own user not found!", #showInterface))
    end if
    if tOwnUser.getInfo().ctrl <> 0 then
      tSomeRights = 1
    end if
    if not tSomeRights then
      return(me.hideInterface(#hide))
    end if
  end if
  tCtrlType = ""
  if tSession.get("room_controller") then
    tCtrlType = "ctrl"
  end if
  if tSession.get("room_owner") then
    tCtrlType = "owner"
  end if
  if (tObjType = "user") then
    if (pSelectedObj = tSession.get("user_name")) then
      tCtrlType = "personal"
    else
      if (tCtrlType = "") then
        tCtrlType = "friend"
      end if
    end if
  end if
  tButtonList = getVariableValue("interface.cmds." & tObjType & "." & tCtrlType)
  if not tButtonList then
    return(me.hideInterface(#hide))
  end if
  if (tButtonList.count = 0) then
    return(me.hideInterface(#hide))
  end if
  if (tObjType = "item") then
    tObjType = "active"
  end if
  if (tCtrlType = "personal") then
    tObjType = "personal"
  end if
  if (me.getComponent().getRoomData().type = #private) then
    if (tObjType = "user") then
      if pSelectedObj <> tSession.get("user_name") then
        if (me.getComponent().getUserObject(pSelectedObj).getInfo().ctrl = 0) then
          tButtonList.deleteOne("take_rights")
        else
          if (me.getComponent().getUserObject(pSelectedObj).getInfo().ctrl = "furniture") then
            tButtonList.deleteOne("give_rights")
          else
            if (me.getComponent().getUserObject(pSelectedObj).getInfo().ctrl = "useradmin") then
              tButtonList.deleteOne("give_rights")
            end if
          end if
        end if
      end if
    end if
  else
    tButtonList.deleteOne("take_rights")
    tButtonList.deleteOne("give_rights")
    tButtonList.deleteOne("kick")
  end if
  tWndObj = getWindow(pInterfaceId)
  tLayout = "object_interface.window"
  if (tWndObj = 0) then
    createWindow(pInterfaceId, tLayout, 545, 466)
    tWndObj = getWindow(pInterfaceId)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInterface, me.getID())
  else
    tWndObj.show()
  end if
  repeat while tWndObj.getProperty(#spriteList) <= undefined
    tSpr = getAt(undefined, tObjType)
    tSpr.visible = 0
  end repeat
  tRightMargin = 4
  repeat while tWndObj.getProperty(#spriteList) <= undefined
    tAction = getAt(undefined, tObjType)
    tElem = tWndObj.getElement(tAction & ".button")
    if tElem <> 0 then
      tSpr = tElem.getProperty(#sprite)
      tSpr.visible = 1
      tRightMargin = ((tRightMargin + tElem.getProperty(#width)) + 2)
      tSpr.locH = (the stage.rect.width - tRightMargin)
    end if
  end repeat
  if (tObjType = "user") and tCtrlType <> "personal" then
    if threadExists(#messenger) then
      tBuddyData = getThread(#messenger).getComponent().getBuddyData()
      if tBuddyData.online.getPos(pSelectedObj) > 0 then
        tWndObj.getElement("friend.button").deactivate()
      else
        tWndObj.getElement("friend.button").Activate()
      end if
    end if
    if tButtonList.getPos("trade") > 0 then
      if me.getComponent().getRoomID() <> "private" then
        tWndObj.getElement("trade.button").deactivate()
      end if
    end if
  end if
  return TRUE
end

on hideInterface me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if (tHideOrRemove = #remove) then
      return(removeWindow(pInterfaceId))
    else
      return(tWndObj.hide())
    end if
  end if
  return FALSE
end

on showObjectInfo me, tObjType 
  tWndObj = getWindow(pInfoStandId)
  if not tWndObj then
    return FALSE
  end if
  if (tObjType = "user") then
    tObj = me.getComponent().getUserObject(pSelectedObj)
  else
    if (tObjType = "active") then
      tObj = me.getComponent().getActiveObject(pSelectedObj)
    else
      if (tObjType = "item") then
        tObj = me.getComponent().getItemObject(pSelectedObj)
      else
        error(me, "Unsupported object type:" && tObjType, #showObjectInfo)
        tObj = 0
      end if
    end if
  end if
  if (tObj = 0) then
    tProps = 0
  else
    tProps = tObj.getInfo()
  end if
  if listp(tProps) then
    tWndObj.getElement("bg_darken").show()
    tWndObj.getElement("info_name").show()
    tWndObj.getElement("info_text").show()
    tWndObj.getElement("info_name").setText(tProps.getAt(#name))
    tWndObj.getElement("info_text").setText(tProps.getAt(#custom))
    tElem = tWndObj.getElement("info_image")
    if (ilk(tProps.getAt(#image)) = #image) then
      tElem.resizeTo(tProps.getAt(#image).width, tProps.getAt(#image).height)
      tElem.getProperty(#sprite).member.regPoint = point((tProps.getAt(#image).width / 2), tProps.getAt(#image).height)
      tElem.feedImage(tProps.getAt(#image))
    end if
    tElem = tWndObj.getElement("info_badge")
    tElem.clearImage()
    if ilk(tProps.getAt(#badge), #string) then
      tBadgeMember = member(getmemnum("Mod Badge" && tProps.getAt(#badge)))
      if tBadgeMember.number > 0 then
        tElem.feedImage(tBadgeMember.image)
        if (tProps.getAt(#name) = getObject(#session).get(#userName)) then
          tElem.setProperty(#cursor, "cursor.finger")
        else
          tElem.setProperty(#cursor, 0)
        end if
        if (tProps.getAt(#badge_visible) = 1) then
          tElem.setProperty(#blend, 100)
        else
          tElem.setProperty(#blend, 40)
        end if
      end if
    end if
    return TRUE
  else
    return(me.hideObjectInfo())
  end if
end

on hideObjectInfo me 
  if not windowExists(pInfoStandId) then
    return FALSE
  end if
  tWndObj = getWindow(pInfoStandId)
  tWndObj.getElement("info_image").clearImage()
  tWndObj.getElement("bg_darken").hide()
  tWndObj.getElement("info_name").hide()
  tWndObj.getElement("info_text").hide()
  tWndObj.getElement("info_badge").clearImage()
  return TRUE
end

on showArrowHiliter me, tUserID 
  return(me.getArrowHiliter().show(tUserID))
end

on hideArrowHiliter me 
  return(me.getArrowHiliter().hide())
end

on showDoorBell me, tName 
  if windowExists(pDoorBellID) then
    pVisitorQueue.append(tName)
    return TRUE
  end if
  if not createWindow(pDoorBellID, "habbo_basic.window", 250, 200) then
    return(error(me, "Couldn't create window to show ringing doorbell!", #showDoorBell))
  end if
  pRingingUser = tName
  tText = getText("room_doorbell", "rings the doorbell...")
  tWndObj = getWindow(pDoorBellID)
  tWndObj.merge("habbo_decision_dialog.window")
  tWndObj.setProperty(#locZ, 2000000)
  tWndObj.lock(1)
  tWndObj.getElement("habbo_decision_text_a").setText(tName)
  tWndObj.getElement("habbo_decision_text_b").setText(tText)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDoorBell, me.getID(), #mouseUp)
  return TRUE
end

on hideDoorBell me 
  if not windowExists(pDoorBellID) then
    return FALSE
  end if
  removeWindow(pDoorBellID)
  pRingingUser = ""
  if pVisitorQueue.count > 0 then
    tName = pVisitorQueue.getAt(1)
    pVisitorQueue.deleteAt(1)
    me.showDoorBell(tName)
  end if
  return TRUE
end

on showLoaderBar me, tCastLoadId, tText 
  if not windowExists(pLoaderBarID) then
    tSession = getObject(#session)
    if getObject(#session).exists("ad_memnum") then
      tShowAd = 1
      tWindowType = "room_loader.window"
      tAdText = string(tSession.get("ad_text"))
      pBannerLink = string(tSession.get("ad_link"))
      tAdMember = member(tSession.get("ad_memnum"))
      if (tAdMember.type = #bitmap) then
        tAdImage = tAdMember.image
      else
        tAdImage = image(1, 1, 8)
      end if
    else
      tShowAd = 0
      tWindowType = "room_loader_small.window"
      pBannerLink = 0
    end if
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    tWndObj.merge(tWindowType)
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
    if tShowAd then
      tWndObj.getElement("room_banner_pic").feedImage(tAdImage)
      tWndObj.getElement("room_banner_link").setText(tAdText)
      if pBannerLink <> 0 then
        tWndObj.getElement("room_banner_link").setProperty(#cursor, "cursor.arrow")
      else
        tWndObj.getElement("room_banner_link").setProperty(#cursor, 0)
      end if
      if connectionExists(pInfoConnID) then
        getConnection(pInfoConnID).send(#info, "ADVIEW" && getObject(#session).get("ad_id"))
      end if
    end if
  else
    tWndObj = getWindow(pLoaderBarID)
  end if
  if not voidp(tCastLoadId) then
    tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
    showLoadingBar(tCastLoadId, [#buffer:tBuffer, #bgColor:rgb(255, 255, 255)])
  end if
  if stringp(tText) then
    tWndObj.getElement("general_loader_text").setText(tText)
  end if
  return TRUE
end

on hideLoaderBar me 
  if windowExists(pLoaderBarID) then
    removeWindow(pLoaderBarID)
  end if
end

on showTrashCover me, tlocz, tColor 
  if voidp(pCoverSpr) then
    if not integerp(tlocz) then
      tlocz = 0
    end if
    if not ilk(tColor, #color) then
      tColor = rgb(0, 0, 0)
    end if
    pCoverSpr = sprite(reserveSprite(me.getID()))
    if not memberExists("Room Trash Cover") then
      createMember("Room Trash Cover", #bitmap)
    end if
    tmember = member(getmemnum("Room Trash Cover"))
    tmember.image = image(1, 1, 8)
    tmember.image.setPixel(0, 0, tColor)
    pCoverSpr.member = tmember
    pCoverSpr.loc = point(0, 0)
    pCoverSpr.width = the stage.rect.width
    pCoverSpr.height = the stage.rect.height
    pCoverSpr.locZ = tlocz
    pCoverSpr.blend = 100
    setEventBroker(pCoverSpr.spriteNum, "Trash Cover")
    updateStage()
  end if
end

on hideTrashCover me 
  if not voidp(pCoverSpr) then
    releaseSprite(pCoverSpr.spriteNum)
    pCoverSpr = void()
  end if
end

on hideAll me 
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).close()
  end if
  if objectExists(pSafeTraderID) then
    getObject(pSafeTraderID).close()
  end if
  if objectExists(pContainerID) then
    getObject(pContainerID).close()
  end if
  if objectExists(pArrowObjID) then
    getObject(pArrowObjID).hide()
  end if
  me.hideRoom()
  me.hideRoomBar()
  me.hideInfoStand()
  me.hideInterface(#remove)
  me.hideConfirmDelete()
  me.hideConfirmPlace()
  me.hideDoorBell()
  me.hideLoaderBar()
  me.hideTrashCover()
  me.hideLoaderBar()
  return TRUE
end

on getRoomVisualizer me 
  return(getVisualizer(pRoomSpaceId))
end

on getGeometry me 
  return(getObject(pGeometryId))
end

on getHiliter me 
  return(getObject(pHiliterId))
end

on getContainer me 
  return(getObject(pContainerID))
end

on getSafeTrader me 
  return(getObject(pSafeTraderID))
end

on getArrowHiliter me 
  return(getObject(pArrowObjID))
end

on getObjectMover me 
  return(getObject(pObjMoverID))
end

on getSelectedObject me 
  return(pSelectedObj)
end

on getPassiveObjectIntersectingRect me, tItemR 
  tPieceList = me.getComponent().getPassiveObject(#list)
  tPieceObjUnder = void()
  tPieceSprUnder = 0
  tPieceUnderLocZ = -1000000000
  repeat while tPieceList <= undefined
    tPiece = getAt(undefined, tItemR)
    tSprites = tPiece.getSprites()
    repeat while tPieceList <= undefined
      tPieceSpr = getAt(undefined, tItemR)
      tRp = sprite(tPieceSpr).member.regPoint
      tR = (rect(sprite(tPieceSpr).locH, sprite(tPieceSpr).locV, sprite(tPieceSpr).locH, sprite(tPieceSpr).locV) + rect(-tRp.getAt(1), -tRp.getAt(2), (sprite(tPieceSpr).member.width - tRp.getAt(1)), (sprite(tPieceSpr).member.height - tRp.getAt(2))))
      if intersect(tItemR, tR) <> rect(0, 0, 0, 0) and tPieceUnderLocZ < tPieceSpr.locZ then
        tPieceObjUnder = tPiece
        tPieceSprUnder = tPieceSpr
        tPieceUnderLocZ = tPieceSpr.locZ
      end if
    end repeat
  end repeat
  return([tPieceObjUnder, tPieceSprUnder])
end

on setRollOverInfo me, tInfo 
  tWndObj = getWindow(pBottomBarId)
  if tWndObj <> 0 then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
end

on startObjectMover me, tObjID, tStripID 
  if not objectExists(pObjMoverID) then
    createObject(pObjMoverID, "Object Mover Class")
  end if
  if (pSelectedType = "active") then
    pClickAction = "moveActive"
  else
    if (pSelectedType = "item") then
      pClickAction = "moveItem"
    else
      if (pSelectedType = "user") then
        return(error(me, "Can't move user objects!", #startObjectMover))
      end if
    end if
  end if
  return(getObject(pObjMoverID).define(tObjID, tStripID, pSelectedType))
end

on stopObjectMover me 
  if not objectExists(pObjMoverID) then
    return(error(me, "Object mover not found!", #stopObjectMover))
  end if
  pClickAction = "moveHuman"
  pSelectedObj = ""
  pSelectedType = ""
  me.hideObjectInfo()
  me.hideInterface(#hide)
  getObject(pObjMoverID).clear()
  return TRUE
end

on startTrading me, tTargetUser 
  if pSelectedType <> "user" then
    return FALSE
  end if
  if (tTargetUser = getObject(#session).get("user_name")) then
    return FALSE
  end if
  me.getComponent().getRoomConnection().send(#room, "TRADE_OPEN" & space() & "\t" & tTargetUser)
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).moveTrade()
  end if
  return TRUE
end

on stopTrading me 
  return(error(me, "TODO: stopTrading...!", #stopTrading))
  pClickAction = "moveHuman"
  if objectExists(pObjMoverID) then
    me.stopObjectMover()
  end if
  return TRUE
end

on showConfirmDelete me 
  if windowExists(pDelConfirmID) then
    return FALSE
  end if
  if not createWindow(pDelConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmDelete))
  end if
  tMsgA = getText("room_confirmDelete", "Confirm delete")
  tMsgB = getText("room_areYouSure", "Are you absolutely sure you want to delete this item?")
  tWndObj = getWindow(pDelConfirmID)
  tWndObj.merge("habbo_decision_dialog.window")
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDelConfirm, me.getID(), #mouseUp)
  return TRUE
end

on hideConfirmDelete me 
  if windowExists(pDelConfirmID) then
    removeWindow(pDelConfirmID)
  end if
end

on showConfirmPlace me 
  if not getObject(#session).get("user_rights").getOne("can_trade") then
    return FALSE
  end if
  if windowExists(pPlcConfirmID) then
    return FALSE
  end if
  if not createWindow(pPlcConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmPlace))
  end if
  tMsgA = getText("room_confirmPlace", "Confirm placement")
  tMsgB = getText("room_areYouSurePlace", "Are you absolutely sure you want to place this item?")
  tWndObj = getWindow(pPlcConfirmID)
  tWndObj.merge("habbo_decision_dialog.window")
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPlcConfirm, me.getID(), #mouseUp)
  return TRUE
end

on hideConfirmPlace me 
  if windowExists(pPlcConfirmID) then
    removeWindow(pPlcConfirmID)
  end if
end

on placeFurniture me, tObjID, tObjType 
  if (tObjType = "active") then
    tloc = getObject(pObjMoverID).getProperty(#loc)
    if not tloc then
      return FALSE
    end if
    tObj = me.getComponent().getActiveObject(tObjID)
    if (tObj = 0) then
      return(error(me, "Invalid active object:" && tObjID, #placeFurniture))
    end if
    tStripID = tObj.getaProp(#stripId)
    tStr = tStripID && tloc.getAt(1) && tloc.getAt(2) && tObj.getProp(#pDimensions, 1) && tObj.getProp(#pDimensions, 2) && tObj.getProp(#pDirection, 1)
    me.getComponent().removeActiveObject(tObj.getAt(#id))
    me.getComponent().getRoomConnection().send(#room, "PLACESTUFFFROMSTRIP" && tStr)
    me.getComponent().getRoomConnection().send(#room, "GETSTRIP new")
  else
    if (tObjType = "item") then
      tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
      if not tloc then
        return FALSE
      end if
      tObj = me.getComponent().getItemObject(tObjID)
      if (tObj = 0) then
        return(error(me, "Invalid item object:" && tObjID, #placeFurniture))
      end if
      tStripID = tObj.getaProp(#stripId)
      tStr = tStripID && tloc
      me.getComponent().removeItemObject(tObj.getAt(#id))
      me.getComponent().getRoomConnection().send(#room, "PLACEITEMFROMSTRIP" && tStr)
      me.getComponent().getRoomConnection().send(#room, "GETSTRIP new")
    else
      return FALSE
    end if
  end if
end

on updateMessageCount me, tMsgCount 
  if windowExists(pBottomBarId) then
    pNewMsgCount = value(tMsgCount)
    me.flashMessengerIcon()
  end if
  return TRUE
end

on updateBuddyrequestCount me, tReqCount 
  if windowExists(pBottomBarId) then
    pNewBuddyReq = value(tReqCount)
    me.flashMessengerIcon()
  end if
  return TRUE
end

on flashMessengerIcon me 
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return FALSE
  end if
  if pMessengerFlash then
    tmember = "mes_lite_icon"
    pMessengerFlash = 0
  else
    tmember = "mes_dark_icon"
    pMessengerFlash = 1
  end if
  if (pNewMsgCount = 0) and (pNewBuddyReq = 0) then
    tmember = "mes_dark_icon"
    if timeoutExists(#flash_messenger_icon) then
      removeTimeout(#flash_messenger_icon)
    end if
  else
    if not timeoutExists(#flash_messenger_icon) then
      createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return TRUE
end

on validateEvent me, tEvent, tSprID, tloc 
  if (call(#getID, sprite(the rollover).scriptInstanceList) = tSprID) then
    tSpr = sprite(the rollover)
    if (tSpr.member.type = #bitmap) and (tSpr.ink = 36) then
      tPixel = tSpr.member.image.getPixel((tloc.getAt(1) - tSpr.left), (tloc.getAt(2) - tSpr.top))
      if not tPixel then
        return FALSE
      end if
      if (tPixel.hexString() = "#FFFFFF") then
        tSpr.visible = 0
        tNextSpr = sprite(the rollover)
        tSpr.visible = 1
        call(tEvent, tNextSpr.scriptInstanceList)
        return FALSE
      else
        return TRUE
      end if
    else
      return TRUE
    end if
  else
    return TRUE
  end if
  return TRUE
end

on validateEvent2 me, tEvent, tSprID, tloc 
  if (call(#getID, sprite(the rollover).scriptInstanceList) = tSprID) then
    tSpr = sprite(the rollover)
    if (tSpr.member.type = #bitmap) and (tSpr.ink = 36) then
      tPixel = tSpr.member.image.getPixel((tloc.getAt(1) - tSpr.left), (tloc.getAt(2) - tSpr.top))
      if not tPixel then
        return FALSE
      end if
      if (tPixel.hexString() = "#FFFFFF") then
        tSpr.visible = 0
        call(tEvent, sprite(the rollover).scriptInstanceList)
        tSpr.visible = 1
        return FALSE
      else
        return TRUE
      end if
    else
      return TRUE
    end if
  else
    return TRUE
  end if
  return TRUE
end

on eventProcActiveRollOver me, tEvent, tSprID, tProp 
  if (tEvent = #mouseEnter) then
    me.setRollOverInfo(me.getComponent().getActiveObject(tSprID).getCustom())
  else
    if (tEvent = #mouseLeave) then
      me.setRollOverInfo("")
    end if
  end if
end

on eventProcUserRollOver me, tEvent, tSprID, tProp 
  if (pClickAction = "placeActive") then
    if (tEvent = #mouseEnter) then
      me.showArrowHiliter(tSprID)
    else
      me.showArrowHiliter(void())
    end if
  end if
  if (tEvent = #mouseEnter) then
    me.setRollOverInfo(tSprID)
  else
    if (tEvent = #mouseLeave) then
      me.setRollOverInfo("")
    end if
  end if
end

on eventProcItemRollOver me, tEvent, tSprID, tProp 
  if (tEvent = #mouseEnter) then
    me.setRollOverInfo(me.getComponent().getItemObject(tSprID).getCustom())
  else
    if (tEvent = #mouseLeave) then
      me.setRollOverInfo("")
    end if
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam 
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if the keyCode <> 36 then
      if (the keyCode = 76) then
        if pFloodblocking then
          if the milliSeconds < pFloodTimer then
            return FALSE
          else
            pFloodEnterCount = void()
          end if
        end if
        if voidp(pFloodEnterCount) then
          pFloodEnterCount = 0
          pFloodblocking = 0
          pFloodTimer = the milliSeconds
        else
          pFloodEnterCount = (pFloodEnterCount + 1)
          if pFloodEnterCount > 2 then
            if the milliSeconds < (pFloodTimer + 3000) then
              tChatField.setText("")
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, 30000)
              pFloodblocking = 1
              pFloodTimer = (the milliSeconds + 30000)
            else
              pFloodEnterCount = void()
            end if
          end if
        end if
        me.getComponent().sendChat(tChatField.getText())
        tChatField.setText("")
        return TRUE
      else
        if (the keyCode = 117) then
          tChatField.setText("")
        end if
      end if
      return FALSE
      if (getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100) then
        if (the keyCode = "int_messenger_image") then
          executeMessage(#show_hide_messenger)
        else
          if (the keyCode = "int_nav_image") then
            executeMessage(#show_hide_navigator)
          else
            if (the keyCode = "int_brochure_image") then
              executeMessage(#show_hide_catalogue)
            else
              if (the keyCode = "int_hand_image") then
                me.getContainer().openClose()
              else
                if (the keyCode = "int_speechmode_dropmenu") then
                  me.getComponent().setChatMode(tParam)
                else
                  if (the keyCode = "int_purse_image") then
                    executeMessage(#openGeneralDialog, #purse)
                  else
                    if (the keyCode = "int_help_image") then
                      executeMessage(#openGeneralDialog, #help)
                    else
                      if (the keyCode = "get_credit_text") then
                        executeMessage(#openGeneralDialog, #purse)
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcInfoStand me, tEvent, tSprID, tParam 
  if (tSprID = "info_badge") then
    tSession = getObject(#session)
    if (me.getSelectedObject() = tSession.get("user_name")) then
      if not tSession.exists("badge_visible") then
        tSession.set("badge_visible", 1)
      end if
      if tSession.get("badge_visible") then
        me.getComponent().getRoomConnection().send(#room, "HIDEBADGE")
        tSession.set("badge_visible", 0)
        me.showObjectInfo("user")
      else
        me.getComponent().getRoomConnection().send(#room, "SHOWBADGE")
        tSession.set("badge_visible", 1)
        me.showObjectInfo("user")
      end if
    end if
  end if
  return TRUE
end

on eventProcInterface me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp or pClickAction <> "moveHuman" then
    return FALSE
  end if
  tComponent = me.getComponent()
  if not tComponent.userObjectExists(pSelectedObj) then
    if not tComponent.activeObjectExists(pSelectedObj) then
      if not tComponent.itemObjectExists(pSelectedObj) then
        return(me.hideInterface(#hide))
      end if
    end if
  end if
  if (tSprID = "dance.button") then
    if pDanceState then
      tComponent.getRoomConnection().send(#room, "STOP Dance")
    else
      tComponent.getRoomConnection().send(#room, "STOP CarryDrink")
      tComponent.getRoomConnection().send(#room, "Dance")
    end if
    pDanceState = not pDanceState
    return TRUE
  else
    if (tSprID = "wave.button") then
      if pDanceState then
        tComponent.getRoomConnection().send(#room, "STOP Dance")
      end if
      return(tComponent.getRoomConnection().send(#room, "Wave"))
    else
      if (tSprID = "move.button") then
        return(me.startObjectMover(pSelectedObj))
      else
        if (tSprID = "rotate.button") then
          return(tComponent.getActiveObject(pSelectedObj).rotate())
        else
          if (tSprID = "pick.button") then
            if (tSprID = "active") then
              ttype = "stuff"
            else
              if (tSprID = "item") then
                ttype = "item"
              else
                return(me.hideInterface(#hide))
              end if
            end if
            return(tComponent.getRoomConnection().send(#room, "ADDSTRIPITEM" && "new" && ttype && pSelectedObj))
          else
            if (tSprID = "delete.button") then
              pDeleteObjID = pSelectedObj
              pDeleteType = pSelectedType
              return(me.showConfirmDelete())
            else
              if (tSprID = "kick.button") then
                tComponent.getRoomConnection().send(#room, "KILLUSER" && pSelectedObj)
                return(me.hideInterface(#hide))
              else
                if (tSprID = "give_rights.button") then
                  tComponent.getRoomConnection().send(#room, "ASSIGNRIGHTS" && pSelectedObj)
                  pSelectedObj = ""
                  me.hideObjectInfo()
                  me.hideInterface(#hide)
                  me.hideArrowHiliter()
                  return TRUE
                else
                  if (tSprID = "take_rights.button") then
                    tComponent.getRoomConnection().send(#room, "REMOVERIGHTS" && pSelectedObj)
                    pSelectedObj = ""
                    me.hideObjectInfo()
                    me.hideInterface(#hide)
                    me.hideArrowHiliter()
                    return TRUE
                  else
                    if (tSprID = "friend.button") then
                      executeMessage(#externalBuddyRequest, pSelectedObj)
                      return TRUE
                    else
                      if (tSprID = "trade.button") then
                        me.startTrading(pSelectedObj)
                        me.getContainer().open()
                        return TRUE
                      else
                        return(error(me, "Unknown object interface command:" && tSprID, #eventProcInterface))
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcRoom me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) and tSprID contains "command:" then
    return(me.getComponent().getRoomConnection().send(#room, tSprID.getProp(#word, 2, tSprID.count(#word))))
  end if
  if (tEvent = #mouseDown) then
    if (pClickAction = "moveHuman") then
      if tParam <> "object_selection" then
        pSelectedObj = ""
        me.hideObjectInfo()
        me.hideInterface(#hide)
        me.hideArrowHiliter()
      end if
      tloc = me.getGeometry().getWorldCoordinate(the mouseH, the mouseV)
      if listp(tloc) then
        return(me.getComponent().getRoomConnection().send(#room, "Move" && tloc.getAt(1) && tloc.getAt(2)))
      end if
    else
      if (pClickAction = "moveActive") then
        tloc = getObject(pObjMoverID).getProperty(#loc)
        if not tloc then
          return FALSE
        end if
        tObj = me.getComponent().getActiveObject(pSelectedObj)
        if (tObj = 0) then
          return(error(me, "Invalid active object:" && pSelectedObj, #eventProcRoom))
        end if
        me.getComponent().getRoomConnection().send(#room, "MOVESTUFF" && pSelectedObj && tloc.getAt(1) && tloc.getAt(2) && tObj.getProp(#pDirection, 1))
        me.stopObjectMover()
      else
        if (pClickAction = "placeActive") then
          if not getObject(#session).get("room_controller") then
            return FALSE
          end if
          if getObject(#session).get("room_owner") then
            me.placeFurniture(pSelectedObj, pSelectedType)
            me.hideInterface(#hide)
            me.hideObjectInfo()
            me.stopObjectMover()
          else
            tloc = getObject(pObjMoverID).getProperty(#loc)
            if not tloc then
              return FALSE
            end if
            if me.showConfirmPlace() then
              me.getObjectMover().pause()
            end if
          end if
        else
          if (pClickAction = "placeItem") then
            if not getObject(#session).get("room_controller") then
              return FALSE
            end if
            if getObject(#session).get("room_owner") then
              me.placeFurniture(pSelectedObj, pSelectedType)
              me.hideInterface(#hide)
              me.hideObjectInfo()
              me.stopObjectMover()
            else
              tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
              if not tloc then
                return FALSE
              end if
              if me.showConfirmPlace() then
                me.getObjectMover().pause()
              end if
            end if
          else
            if (pClickAction = "tradeItem") then
              put("Clicked floor while trading!!!")
            else
              return(error(me, "Unsupported click action:" && pClickAction, #eventProcRoom))
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcUserObj me, tEvent, tSprID, tParam 
  tObject = me.getComponent().getUserObject(tSprID)
  if (tObject = 0) then
    error(me, "User object not found:" && tSprID, #eventProcUserObj)
    return(me.eventProcRoom(tEvent, "floor"))
  end if
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "user", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if tObject.select() then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "user"
      me.showObjectInfo(pSelectedType)
      me.showInterface(pSelectedType)
      me.showArrowHiliter(tSprID)
    end if
    tloc = tObject.getLocation()
    me.getComponent().getRoomConnection().send(#room, "LOOKTO" && tloc.getAt(1) && tloc.getAt(2))
  else
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
  return TRUE
end

on eventProcActiveObj me, tEvent, tSprID, tParam 
  if not me.validateEvent2(tEvent, tSprID, the mouseLoc) then
    return FALSE
  end if
  tObject = me.getComponent().getActiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "active", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (tObject = 0) then
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return(error(me, "Active object not found:" && tSprID, #eventProcActiveObj))
  end if
  if pSelectedObj <> tSprID then
    pSelectedObj = tSprID
    pSelectedType = "active"
    me.showObjectInfo(pSelectedType)
    me.showInterface(pSelectedType)
    me.hideArrowHiliter()
  end if
  if the optionDown and getObject(#session).get("room_controller") then
    return(me.startObjectMover(pSelectedObj))
  end if
  if tObject.select() then
    return TRUE
  else
    return(me.eventProcRoom(tEvent, "floor", "object_selection"))
  end if
end

on eventProcPassiveObj me, tEvent, tSprID, tParam 
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    pass()
  end if
  tObject = me.getComponent().getPassiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "passive", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (tObject = 0) then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not tObject.select() then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
end

on eventProcItemObj me, tEvent, tSprID, tParam 
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return FALSE
  end if
  if the shiftDown then
    if me.getComponent().itemObjectExists(tSprID) then
      return(me.outputObjectInfo(tSprID, "item", the rollover))
    end if
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not me.getComponent().itemObjectExists(tSprID) then
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return(error(me, "Item object not found:" && tSprID, #eventProcItemObj))
  end if
  if me.getComponent().getItemObject(tSprID).select() then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "item"
      me.showObjectInfo(pSelectedType)
      me.showInterface(pSelectedType)
      me.hideArrowHiliter()
    end if
  else
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
end

on eventProcDoorBell me, tEvent, tSprID, tParam 
  if (tSprID = "habbo_decision_ok") then
    me.getComponent().getRoomConnection().send(#room, "LETUSERIN" && pRingingUser)
    me.hideDoorBell()
  else
    if tSprID <> "habbo_decision_cancel" then
      if (tSprID = "close") then
        me.hideDoorBell()
      end if
    end if
  end if
end

on eventProcDelConfirm me, tEvent, tSprID, tParam 
  if (tSprID = "habbo_decision_ok") then
    me.hideConfirmDelete()
    if (tSprID = "active") then
      me.getComponent().getRoomConnection().send(#room, "REMOVESTUFF" && pDeleteObjID)
    else
      if (tSprID = "item") then
        me.getComponent().getRoomConnection().send(#room, "REMOVEITEM" && "/" & pDeleteObjID)
      end if
    end if
    me.hideInterface(#hide)
    me.hideObjectInfo()
    pDeleteObjID = ""
    pDeleteType = ""
  else
    if tSprID <> "habbo_decision_cancel" then
      if (tSprID = "close") then
        me.hideConfirmDelete()
        pDeleteObjID = ""
      end if
    end if
  end if
end

on eventProcPlcConfirm me, tEvent, tSprID, tParam 
  if (tSprID = "habbo_decision_ok") then
    me.placeFurniture(pSelectedObj, pSelectedType)
    me.hideConfirmPlace()
    me.hideInterface(#hide)
    me.hideObjectInfo()
    me.stopObjectMover()
  else
    if tSprID <> "habbo_decision_cancel" then
      if (tSprID = "close") then
        me.getObjectMover().resume()
        me.hideConfirmPlace()
      end if
    end if
  end if
end

on eventProcBanner me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp then
    return FALSE
  end if
  if (tSprID = "room_banner_link") then
    if pBannerLink <> 0 then
      if connectionExists(pInfoConnID) and getObject(#session).exists("ad_id") then
        getConnection(pInfoConnID).send(#info, "ADCLICK" && getObject(#session).get("ad_id"))
      end if
      openNetPage(pBannerLink)
    end if
  else
    if (tSprID = "room_cancel") then
      me.getComponent().getRoomConnection().send(#room, "QUIT")
      executeMessage(#leaveRoom)
    end if
  end if
  return TRUE
end

on outputObjectInfo me, tSprID, tObjType, tSprNum 
  if (tObjType = "user") then
    tObj = me.getComponent().getUserObject(tSprID)
  else
    if (tObjType = "active") then
      tObj = me.getComponent().getActiveObject(tSprID)
    else
      if (tObjType = "passive") then
        tObj = me.getComponent().getPassiveObject(tSprID)
      else
        if (tObjType = "item") then
          tObj = me.getComponent().getItemObject(tSprID)
        end if
      end if
    end if
  end if
  if (tObj = 0) then
    return FALSE
  end if
  tInfo = tObj.getInfo()
  tdata = [:]
  tdata.setAt(#id, tObj.getID())
  tdata.setAt(#class, tInfo.getAt(#class))
  tdata.setAt(#x, tObj.pLocX)
  tdata.setAt(#y, tObj.pLocY)
  tdata.setAt(#h, tObj.pLocH)
  tdata.setAt(#dir, tObj.pDirection)
  tdata.setAt(#locH, sprite(tSprNum).locH)
  tdata.setAt(#locV, sprite(tSprNum).locV)
  tdata.setAt(#locZ, "")
  tSprList = tObj.getSprites()
  repeat while tObjType <= tObjType
    tSpr = getAt(tObjType, tSprID)
    tdata.setAt(#locZ, tdata.getAt(#locZ) && tSpr.locZ)
  end repeat
  put("- - - - - - - - - - - - - - - - - - - - - -")
  put("ID       " & tdata.getAt(#id))
  put("Class    " & tdata.getAt(#class))
  put("Member   " & sprite(tSprNum).member.name)
  put("World X  " & tdata.getAt(#x))
  put("World Y  " & tdata.getAt(#y))
  put("World H  " & tdata.getAt(#h))
  put("Dir      " & tdata.getAt(#dir))
  put("Scr X    " & tdata.getAt(#locH))
  put("Scr Y    " & tdata.getAt(#locV))
  put("Scr Z    " & tdata.getAt(#locZ))
  put("- - - - - - - - - - - - - - - - - - - - - -")
end

on null me 
end
