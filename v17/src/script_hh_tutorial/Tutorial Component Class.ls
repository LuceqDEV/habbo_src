on construct me 
  me.pEnabled = 0
  me.pRunning = 0
  me.pWaitingForPrefs = 1
  me.pDefaultTutorial = getVariable("tutorial.name.new_user_flow")
  me.pMessages = [:]
  pMessages.setaProp(#userlogin, #getUserProperties)
  pMessages.setaProp(#restart_tutorial, #restartTutorial)
  pMessages.setaProp(#updateAvailableFlatCategories, #startDefaultTutorial)
  pMessages.setaProp(#enterRoom, #hideTutorial)
  pMessages.setaProp(#roomReady, #showTutorial)
  pMessages.setaProp(#leaveRoom, #showTutorial)
  pMessages.setaProp(#tutorial_send_console_message, #sendConsoleMessage)
  pMessages.setaProp(#tutorial_open_guestrooms_tab, #openGuestroomsTab)
  pMessages.setaProp(#tutorial_open_publicrooms_tab, #openPublicroomsTab)
  pMessages.setaProp(#exit_tutorial, #exitTutorial)
  pMessages.setaProp(#getHotelClosedDisconnectStatus, #hideTutorial)
  me.registerClientMessages(1)
  return(1)
end

on deconstruct me 
  me.registerClientMessages(0)
  return(1)
end

on registerClientMessages me, tBool 
  if pMessages.ilk <> #propList then
    return(error(me, "Message list not initialized.", #registerClientMessages, #major))
  end if
  tMsgNo = 1
  repeat while tMsgNo <= me.count(#pMessages)
    tMessage = pMessages.getPropAt(tMsgNo)
    tHandler = pMessages.getAt(tMsgNo)
    if tBool then
      registerMessage(tMessage, me.getID(), tHandler)
    else
      unregisterMessage(tMessage, me.getID())
    end if
    tMsgNo = 1 + tMsgNo
  end repeat
end

on showTutorial me 
  if not me.pRunning or not me.pEnabled then
    return(0)
  end if
  me.getInterface().show()
  return(1)
end

on hideTutorial me 
  me.getInterface().hide()
  return(1)
end

on getUserProperties me 
  tSession = getObject(#session)
  me.pUserName = tSession.GET(#userName)
  me.pUserSex = tSession.GET(#user_sex)
  me.pEnabledOnServer = tSession.GET(#tutorial_enabled, 0)
  me.getInterface().setUserSex(me.pUserSex)
end

on startDefaultTutorial me 
  me.startTutorial(me.pDefaultTutorial)
end

on restartTutorial me 
  me.pEnabled = 1
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #startTutorial, #major))
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer:1])
  me.startTutorial(me.pDefaultTutorial)
  me.sendTrackingRequest(#restart)
end

on setEnabled me, tBoolean 
  me.pEnabled = tBoolean
  if me.pEnabled and me.pWaitingForPrefs and me.pRunning then
    me.pWaitingForPrefs = 0
    me.startTutorial()
  end if
  return(1)
end

on startTutorial me, tTutorialName 
  if not me.pEnabledOnServer then
    return(0)
  end if
  me.pRunning = 1
  if not voidp(tTutorialName) then
    me.pTutorialName = tTutorialName
  end if
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #startTutorial, #major))
  end if
  if me.pWaitingForPrefs then
    tConn.send("GET_ACCOUNT_PREFERENCES")
    return(0)
  end if
  if not me.pEnabled or voidp(me.pTutorialName) then
    return(0)
  end if
  tConn.send("GET_TUTORIAL_CONFIGURATION", [#string:me.pTutorialName])
  return(1)
end

on setTutorialConfig me, tConfigList 
  me.pTutorialID = tConfigList.getAt(#id)
  me.pTutorialName = tConfigList.getAt(#name)
  me.pTopics = tConfigList.getaProp(#topics)
  tTopicNum = 1
  repeat while tTopicNum <= me.count(#pTopics)
    tTextKey = me.pTutorialName & "_" & me.getProp(#pTopics, tTopicNum)
    me.setProp(#pTopics, tTopicNum, tTextKey)
    tTopicNum = 1 + tTopicNum
  end repeat
  me.pTopicStatuses = tConfigList.getaProp(#statuses)
  me.getInterface().show()
  me.getInterface().showMenu(#welcome)
end

on setTopicConfig me, tTopicConfig 
  me.pTopicID = tTopicConfig.getAt(#id)
  me.pSteps = tTopicConfig.getAt(#steps)
  tTopicName = pTopics.getaProp(me.pTopicID)
  tStepNum = 1
  repeat while tStepNum <= me.count(#pSteps)
    tStepName = me.getPropRef(#pSteps, tStepNum).getAt(#name)
    tContentList = me.getPropRef(#pSteps, tStepNum).getAt(#content)
    tContentNum = 1
    repeat while tContentNum <= tContentList.count
      tContentName = tContentList.getAt(tContentNum).getAt(#textKey)
      tTextKey = tTopicName & "_" & tStepName & "_" & tContentName
      tContentList.getAt(tContentNum).setAt(#textKey, tTextKey)
      tContentNum = 1 + tContentNum
    end repeat
    me.getPropRef(#pSteps, tStepNum).getAt(#tutor).setAt(#textKey, tTopicName & "_" & tStepName & "_tutor")
    tStepNum = 1 + tStepNum
  end repeat
  me.pCurrentStepNumber = 0
  me.nextStep()
  return(1)
end

on selectTopic me, tTopicID 
  if tTopicID <> #menu then
    if tTopicID = #Cancel then
      me.getInterface().showMenu()
      return(1)
    else
      if tTopicID = #quit then
        me.exitTutorial()
        executeMessage(#show_navigator)
        return(1)
      else
        if tTopicID = #otherwise then
          nothing()
        end if
      end if
    end if
    tTopicName = pTopics.getaProp(tTopicID)
    tURLKey = tTopicName & "_url"
    if textExists(tURLKey) then
      tURL = getText(tURLKey)
      openNetPage(tURL)
    end if
    me.pCurrentTopicID = tTopicID
    pTopics.pCurrentTopicNumber = me.getPos(pTopics.getaProp(tTopicID))
    tConn = getConnection(getVariable("connection.info.id"))
    if voidp(tConn) then
      return(error(me, "Connection not found.", #startTutorial, #major))
    end if
    tConn.send("GET_TUTORIAL_TOPIC_CONFIGURATION", [#integer:tTopicID])
  end if
end

on nextStep me 
  if not me.pEnabled or not me.pRunning then
    return(0)
  end if
  if me.count(#pSteps) = 0 then
    return(1)
  end if
  me.pCurrentStepNumber = me.pCurrentStepNumber + 1
  if me.pCurrentStepNumber > me.count(#pSteps) then
    return(0)
  end if
  me.sendTrackingRequest(#step)
  me.pCurrentStepID = pSteps.getPropAt(me.pCurrentStepNumber)
  tTopic = me.getProp(#pSteps, me.pCurrentStepNumber)
  me.clearTriggers()
  me.clearRestrictions()
  me.setTriggers(tTopic.getAt(#triggers))
  me.setRestrictions(tTopic.getAt(#restrictions))
  me.executePrerequisites(tTopic.getAt(#prerequisites))
  me.getInterface().setBubbles(tTopic.getAt(#content))
  tTutorList = tTopic.getAt(#tutor)
  if me.pCurrentStepNumber = me.count(#pSteps) then
    tLinkList = [:]
    tNextTopicNumber = me.pCurrentTopicNumber + 1
    if tNextTopicNumber <= me.count(#pTopics) then
      tNextTopicID = pTopics.getPropAt(tNextTopicNumber)
      tNextTopicName = me.getProp(#pTopics, tNextTopicNumber)
      tLinkList.setaProp(tNextTopicID, tNextTopicName)
    end if
    tLinkList.setaProp(#menu, "tutorial_select_another_topic")
    tTutorList.setaProp(#links, tLinkList)
    tStatusList = [#menu:1]
    tTutorList.setaProp(#statuses, tStatusList)
    me.completeTopic(me.pTopicID)
  end if
  me.getInterface().setTutor(tTutorList)
end

on completeTopic me, tTopicID 
  pTopicStatuses.setaProp(tTopicID, 1)
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #startTutorial, #major))
  end if
  me.sendTrackingRequest(#topicCompleted)
  tConn.send("COMPLETE_TUTORIAL_TOPIC", [#integer:tTopicID])
  tConn.send("GET_TUTORIAL_STATUS", [#integer:me.pTutorialID])
end

on executePrerequisites me, tPrerequisiteList 
  i = 1
  repeat while i <= tPrerequisiteList.count
    tMessage = tPrerequisiteList.getPropAt(i)
    tParam = tPrerequisiteList.getAt(i)
    executeMessage(symbol(tMessage), tParam)
    i = 1 + i
  end repeat
end

on setTriggers me, tTriggerList 
  if not listp(tTriggerList) then
    return(0)
  end if
  repeat while tTriggerList <= undefined
    tTrigger = getAt(undefined, tTriggerList)
    registerMessage(symbol(tTrigger), me.getID(), #nextStep)
  end repeat
  me.pTriggerList = tTriggerList
end

on setRestrictions me, tRestrictionList 
  if not listp(tRestrictionList) then
    return(0)
  end if
  repeat while tRestrictionList <= undefined
    tRestriction = getAt(undefined, tRestrictionList)
    registerMessage(symbol(tRestriction), me.getID(), #restriction)
  end repeat
  me.pRestrictionList = tRestrictionList
end

on clearTriggers me, tForced 
  if not listp(me.pTriggerList) then
    return(0)
  end if
  repeat while me.pTriggerList <= undefined
    tTrigger = getAt(undefined, tForced)
    unregisterMessage(symbol(tTrigger), me.getID())
    tHandler = pMessages.getaProp(tTrigger)
    if not voidp(tHandler) then
      registerMessage(tTrigger, me.getID(), tHandler)
      if not tForced then
        call(tHandler, me)
      end if
    end if
  end repeat
  me.pTriggerList = []
end

on clearRestrictions me, tForced 
  if not listp(me.pRestrictionList) then
    return(0)
  end if
  repeat while me.pRestrictionList <= undefined
    tRestriction = getAt(undefined, tForced)
    unregisterMessage(symbol(tRestriction), me.getID())
    tHandler = pMessages.getaProp(tRestriction)
    if not voidp(tHandler) then
      registerMessage(tRestriction, me.getID(), tHandler)
      if not tForced then
        call(tHandler, me)
      end if
    end if
  end repeat
  me.pRestrictionList = []
end

on exitTutorial me 
  me.pRunning = 0
  me.getInterface().hide()
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #exitTutorial, #major))
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer:0])
  me.pEnabled = 0
  me.sendTrackingRequest(#quit)
end

on restriction me 
  me.getInterface().showMenu(#offtopic)
end

on getTopics me 
  return(me.pTopics)
end

on showMenu me 
  me.clearTriggers(1)
  me.clearRestrictions(1)
  me.getInterface().showMenu()
end

on setTopicResult me, tBoolReward 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #stopTutorial, #major))
  end if
  tConn.send("GET_TUTORIAL_STATUS", [#integer:me.pTutorialID])
end

on setTutorialStatus me, tStatusList 
  me.pTopicStatuses = tStatusList
end

on getProperty me, tProp 
  if tProp = #topics then
    return(me.pTopics)
  else
    if tProp = #statuses then
      return(me.pTopicStatuses)
    end if
  end if
end

on sendTrackingRequest me, tCase 
  if tCase = #step then
    tTopicName = pTopics.getaProp(me.pTopicID)
    tTrackMsg = "/client/tutorial/" & tTopicName & "/" & string(me.pCurrentStepNumber)
  else
    if me = #topicCompleted then
      tTopicName = pTopics.getaProp(me.pTopicID)
      tTrackMsg = "/client/tutorial/" & tTopicName & "/completed"
    else
      if me = #quit then
        tTrackMsg = "/client/tutorial/closed"
      else
        if me = #restart then
          tTrackMsg = "/client/tutorial/restarted"
        else
          return(0)
        end if
      end if
    end if
  end if
  executeMessage(#sendTrackingPoint, tTrackMsg)
  return(1)
end

on tryExit me 
  tPrerequisites = [:]
  tPrerequisites.setaProp(#hide_navigator, void())
  tPrerequisites.setaProp(#hide_purse, void())
  tPrerequisites.setaProp(#hide_messenger, void())
  tBubbles = [:]
  tBubble = [:]
  tBubble.setaProp(#textKey, "tutorial_help_button_bubble")
  tBubble.setaProp(#targetID, "help_icon_image")
  tBubble.setaProp(#direction, 5)
  tBubble.setaProp(#offsetx, 0)
  tBubble.setaProp(#offsety, 0)
  tBubbles.setaProp(#help, tBubble)
  tBubble = [:]
  tBubble.setaProp(#textKey, "tutorial_restart_button_bubble")
  tBubble.setaProp(#targetID, "help_restart_tutorial")
  tBubble.setaProp(#direction, 6)
  tBubble.setaProp(#offsetx, 50)
  tBubble.setaProp(#offsety, 0)
  tBubbles.setaProp(#restart, tBubble)
  tTutor = [:]
  tTutor.setaProp(#textKey, "tutorial_quit_confirmation")
  tTutor.setaProp(#targetID, "tutor")
  tTutor.setaProp(#direction, 1)
  tTutor.setaProp(#offsetx, 20)
  tTutor.setaProp(#offsety, 310)
  tTutor.setaProp(#links, [#quit:"tutorial_quit", #Cancel:"cancel"])
  me.clearTriggers(1)
  me.clearRestrictions(1)
  me.executePrerequisites(tPrerequisites)
  me.getInterface().setBubbles(tBubbles)
  me.getInterface().setTutor(tTutor)
end

on sendConsoleMessage me, tTextKey 
  if not objectExists(#messenger_component) then
    return(error(me, "Messenger component not found", #sendConsoleMessage, #major))
  end if
  if getObject(#messenger_component).getPropRef(#pItemList, #messages).count > 0 then
    return(1)
  end if
  tText = getText(tTextKey)
  tMsg = [#campaign:1, #id:"3", #url:"http://www.fi", #message:tText]
  getObject("messenger_component").receive_Message(tMsg)
end

on openGuestroomsTab me 
  executeMessage(#show_navigator)
  getObject(#navigator_interface).ChangeWindowView("nav_gr0")
  getObject(#navigator_component).expandHistoryItem(1)
  executeMessage(#hide_navigator)
end

on openPublicroomsTab me 
  executeMessage(#show_navigator)
  getObject(#navigator_interface).ChangeWindowView("nav_pr")
  getObject(#navigator_component).expandHistoryItem(1)
  executeMessage(#hide_navigator)
end
