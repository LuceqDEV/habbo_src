on addWindows(me)
  me.pWindowID = "te"
  tService = me.getIGComponent("PreGame")
  if tService = 0 then
    return(0)
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return(0)
  end if
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamCount = tGameRef.getTeamCount()
  tTeams = tGameRef.getAllTeamData()
  pLoadingElements = []
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return(0)
  end if
  tScrollStartOffset = -100
  tTeamPos = 1
  repeat while tTeamPos <= tTeamCount - 1
    tWrapObjRef.addOneWindow(me.getWindowId(tTeamPos), "ig_pg_load_plrs_" & tTeamMaxSize & ".window", me.pWindowSetId, [#scrollFromLocX:tScrollStartOffset, #spaceBottom:0])
    me.setTeamColorBackground(me.getWindowId(tTeamPos), tTeamPos)
    tScrollStartOffset = tScrollStartOffset - 50
    tTeamPos = 1 + tTeamPos
  end repeat
  tWrapObjRef.addOneWindow(me.getWindowId(tTeamPos), "ig_pg_load_plrs_" & tTeamMaxSize & "_btm.window", me.pWindowSetId, [#scrollFromLocX:tScrollStartOffset, #spaceBottom:2])
  me.setTeamColorBackground(me.getWindowId(tTeamPos), tTeamPos)
  pTeamIndex = []
  repeat while me <= undefined
    tTeamInfo = getAt(undefined, undefined)
    tPlayers = tTeamInfo.getaProp(#players)
    repeat while me <= undefined
      tPlayerInfo = getAt(undefined, undefined)
      me.displayPlayer(tPlayerInfo)
    end repeat
  end repeat
  tTeamId = 1
  repeat while tTeamId <= tTeamCount
    if pTeamIndex.getaProp(tTeamId) = 0 then
      pTeamIndex.setaProp(tTeamId, [])
    end if
    tPlayerCount = pTeamIndex.getaProp(tTeamId).count
    i = tPlayerCount + 1
    repeat while i <= tTeamMaxSize
      me.displayPlayer(0, tTeamId, i)
      i = 1 + i
    end repeat
    tTeamId = 1 + tTeamId
  end repeat
  tWrapObjRef.moveTo(10, 10)
  return(1)
  exit
end

on update(me)
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter mod 5 > 0 then
    return(1)
  end if
  if pUpdateCounter >= 30 then
    pUpdateCounter = 0
  end if
  tPhase = pUpdateCounter / 5
  repeat while me <= undefined
    tElemInfo = getAt(undefined, undefined)
    tWndObj = getWindow(me.getWindowId(tElemInfo.getAt(1)))
    if tWndObj = 0 then
      return(0)
    end if
    tElem = tWndObj.getElement("ig_icon_player_" & tElemInfo.getAt(2))
    if tElem = 0 then
      return(0)
    end if
    tMemNum = getmemnum("ig_icon_loading_" & tPhase)
    if tMemNum = 0 then
      return(0)
    end if
    tElem.feedImage(me.alignIconImage(member(tMemNum).image, 19, 18))
  end repeat
  return(1)
  exit
end

on displayPlayer(me, tPlayerInfo, tTeamId, tPlayerPos)
  if tPlayerInfo <> void() then
    tTeamId = tPlayerInfo.getaProp(#team_id)
    tPlayerId = tPlayerInfo.getaProp(#id)
    if pTeamIndex.findPos(tTeamId) = 0 then
      tTeam = []
      pTeamIndex.setaProp(tTeamId, tTeam)
    else
      tTeam = pTeamIndex.getaProp(tTeamId)
    end if
    if tTeam.findPos(tPlayerId) = 0 then
      tPlayerPos = 1
      repeat while tPlayerPos <= tTeam.count
        if voidp(tTeam.getAt(tPlayerPos)) then
          tTeam.setAt(tPlayerPos, tPlayerId)
        else
          tPlayerPos = 1 + tPlayerPos
        end if
      end repeat
      if tTeam.findPos(tPlayerId) = 0 then
        tTeam.append(tPlayerId)
      end if
    end if
    tPlayerPos = tTeam.findPos(tPlayerId)
    tName = tPlayerInfo.getaProp(#name)
  else
    tName = "---"
  end if
  tWndObj = getWindow(me.getWindowId(tTeamId))
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("ig_icon_player_" & tPlayerPos)
  if tElem = 0 then
    return(0)
  end if
  if tPlayerInfo = 0 then
    tElem.hide()
  else
    tElem.show()
    pLoadingElements.setaProp(tPlayerId, [tTeamId, tPlayerPos])
    tMemNum = getmemnum("ig_icon_loading_0")
    if tMemNum <> 0 then
      tElem.feedImage(member(tMemNum).image)
    end if
  end if
  tElem = tWndObj.getElement("ig_name_player_" & tPlayerPos)
  if tElem = 0 then
    return(0)
  end if
  tOwnPlayer = tName = me.getOwnPlayerName()
  tFontStruct = tElem.getFont()
  if tOwnPlayer then
    tFontStruct.setaProp(#font, "vb")
  else
    tFontStruct.setaProp(#font, "v")
  end if
  tElem.setFont(tFontStruct)
  tElem.setText(tName)
  tFlagId = me.getBasicFlagId() & "_p_" & tTeamId & "_" & tPlayerPos
  me.removeFlagObject(tFlagId)
  return(1)
  exit
end

on displayPlayerDone(me, tID, tFigure, tsex)
  tElemInfo = pLoadingElements.getaProp(tID)
  if tElemInfo = 0 then
    return(0)
  end if
  tWndObj = getWindow(me.getWindowId(tElemInfo.getAt(1)))
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("ig_icon_player_" & tElemInfo.getAt(2))
  if tElem = 0 then
    return(0)
  end if
  tImage = me.getHeadImage(tFigure, tsex, 18, 18)
  if tImage <> 0 then
    tElem.feedImage(tImage)
  end if
  pLoadingElements.deleteProp(tID)
  return(1)
  exit
end

on displayPlayerLeft(me, tID)
  tTeamPos = 1
  repeat while tTeamPos <= pTeamIndex.count
    tPlayerPos = pTeamIndex.getAt(tTeamPos).findPos(tID)
    if tPlayerPos > 0 then
    else
      tTeamPos = 1 + tTeamPos
    end if
  end repeat
  if tPlayerPos = 0 then
    return(error(me, "Player not found.", #displayPlayerLeft))
  end if
  me.displayPlayer(0, tTeamPos, tPlayerPos)
  pTeamIndex.getAt(tTeamPos).setAt(tPlayerPos, void())
  tFlagId = me.getBasicFlagId() & "_p_" & tTeamPos & "_" & tPlayerPos
  me.removeFlagObject(tFlagId)
  tElemID = "ig_icon_player_" & tPlayerPos
  tColorDark = me.getTeamColorDark(tTeamPos)
  me.setInfoFlag(tFlagId, me.getWindowId(tTeamPos), tElemID, "PreGameUserLeft", tColorDark)
  return(1)
  exit
end