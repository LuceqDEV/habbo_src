on render me 
  tService = me.getIGComponent("LevelList")
  if tService = 0 then
    return(0)
  end if
  tItemRef = tService.getSelectedLevel()
  if tItemRef = 0 then
    return(0)
  end if
  tWndObj = getWindow(me.getWindowId("spec"))
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.unmerge()
  tWndObj.merge("ig_choose_duration.window")
  me.renderProperty(#duration, tItemRef.getProperty(#duration))
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return(0)
  end if
  tWrapObjRef.render()
  me.render()
  return(1)
end

on renderProperty me, tKey, tValue 
  if tKey = #duration then
    return(me.renderDuration((tValue / 60)))
  end if
  return(me.renderProperty(tKey, tValue))
end

on renderDuration me, tValue 
  tWndObj = getWindow(me.getWindowId("spec"))
  if tWndObj = 0 then
    return(0)
  end if
  repeat while [2, 3, 5] <= undefined
    i = getAt(undefined, tValue)
    tElement = tWndObj.getElement("ig_game_drt_" & i)
    if tElement <> 0 then
      tElement.setProperty(#blend, 0 + (i = tValue * 100))
    end if
  end repeat
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID, tIntParam 
  put("* eventProcMouseDown" && tEvent && tSprID && tParam && tWndID && tIntParam)
  tService = me.getIGComponent("LevelList")
  if tService = 0 then
    return(0)
  end if
  if tSprID = "ig_game_drt" then
    return(tService.setProperty(#duration, (tIntParam * 60)))
  end if
  return(0)
end
