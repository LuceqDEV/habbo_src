property pMainWindowId, pGoButtonImages, pJoinButtonImage, pWriterPlainNormLeft, pWriterListPlainNormLeft, pWriterPlainNormRight, pWriterPlainBoldLeft, pWriterLinkRight

on construct me
  pMainWindowId = "GAME"
  tPlainFontStruct = getStructVariable("struct.font.plain")
  createWriter("gs_plain_norm_left", tPlainFontStruct)
  pWriterPlainNormLeft = getWriter("gs_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap: 0, #fixedLineSpace: tPlainFontStruct[#lineHeight]])
  createWriter("gs_list_plain_norm_left", tPlainFontStruct)
  pWriterListPlainNormLeft = getWriter("gs_list_plain_norm_left")
  pWriterListPlainNormLeft.define([#wordWrap: 0, #fixedLineSpace: 16])
  createWriter("gs_plain_norm_right", tPlainFontStruct)
  pWriterPlainNormRight = getWriter("gs_plain_norm_right")
  pWriterPlainNormRight.setProperty(#alignment, #right)
  pWriterPlainNormRight.define([#wordWrap: 0])
  tBoldFontStruct = getStructVariable("struct.font.bold")
  createWriter("gs_plain_bold_left", tBoldFontStruct)
  pWriterPlainBoldLeft = getWriter("gs_plain_bold_left")
  tStruct = getStructVariable("struct.font.link")
  tStruct.setaProp(#fontStyle, [#underline])
  tStruct.setaProp(#font, tBoldFontStruct[#font])
  createWriter("gs_link_right", tStruct)
  pWriterLinkRight = getWriter("gs_link_right")
  me.renderButtonImages()
  return 1
end

on deconstruct me
  removeWriter("gs_plain_norm_left")
  pWriterPlainNormLeft = VOID
  removeWriter("gs_plain_norm_right")
  pWriterPlainNormRight = VOID
  removeWriter("gs_plain_bold_left")
  pWriterPlainBoldLeft = VOID
  removeWriter("gs_link_right")
  pWriterLinkRight = VOID
  pGoButtonImages = VOID
  pJoinButtonImage = VOID
  return 1
end

on defineWindow me, tID
  pMainWindowId = tID
  return 1
end

on renderButtonImages me
  pGoButtonImages = [:]
  repeat with tstate in ["created", "started", "finished"]
    tButtonImage = image(92, 12, 8)
    tImage = pWriterLinkRight.render(getText("gs_button_go_" & tstate))
    tLocH = 80 - tImage.width
    tButtonImage.copyPixels(tImage, tImage.rect + rect(tLocH, 0, tLocH, 0), tImage.rect)
    tImage = member(getmemnum("sw_arr")).image
    tButtonImage.copyPixels(tImage, tImage.rect + rect(84, 1, 84, 1), tImage.rect)
    pGoButtonImages.addProp(tstate, tButtonImage)
  end repeat
  pJoinButtonImage = image(191, 16, 8)
  tImage = pWriterLinkRight.render(getText("bb_link_join"))
  tLocH = 176 - tImage.width
  pJoinButtonImage.copyPixels(tImage, tImage.rect + rect(tLocH, 3, tLocH, 3), tImage.rect)
  tImage = member(getmemnum("sw_arr")).image
  pJoinButtonImage.copyPixels(tImage, tImage.rect + rect(180, 4, 180, 4), tImage.rect)
  return 1
end

on renderTournamentLogo me, tTournamentLogoMemNum
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  if tTournamentLogoMemNum = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_logo_tournament")
  if tElem <> 0 then
    tmember = member(tTournamentLogoMemNum)
    if (tmember.type = #bitmap) and (tElem <> 0) then
      tElem.setProperty(#cursor, "cursor.finger")
      tElem.setProperty(#image, tmember.image)
    end if
  end if
  return 1
end

on renderInstanceList me, tList, tStartIndex, tCount
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to tCount
    tIndex = tStartIndex + (i - 1)
    tElem = tWndObj.getElement("gs_area_gameList" & i)
    if tElem = 0 then
      return 0
    end if
    if tIndex <= tList.count then
      tItem = tList[tIndex]
      tImage = me.getInstanceListItemBg(tItem[#state])
      tTextImg = pWriterPlainBoldLeft.render(tItem[#name])
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 3, 32, 3), tTextImg.rect)
      tTextImg = pWriterPlainNormRight.render(me.convertSecToMinSec(tItem[#gameLength]))
      tLocH = tImage.width - tTextImg.width - 3
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(tLocH, 3, tLocH, 3), tTextImg.rect)
      tTextImg = pWriterPlainNormLeft.render(tItem[#host][#name])
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 15, 32, 15), tTextImg.rect)
      tTextImg = pWriterPlainNormLeft.render(getText("sw_fieldname_" & tItem[#fieldType]))
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 28, 32, 28), tTextImg.rect)
      tGoButtonImage = pGoButtonImages[tItem[#state]]
      if tGoButtonImage <> VOID then
        tLocH = tImage.width - tGoButtonImage.width - 5
        tImage.copyPixels(tGoButtonImage, tGoButtonImage.rect + rect(tLocH, 26, tLocH, 26), tGoButtonImage.rect, [#ink: 36])
      end if
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tImage = me.getInstanceListItemBg(#empty)
      tTextImg = pWriterPlainNormLeft.render("---")
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 24, 32, 24), tTextImg.rect)
      tElem.setProperty(#cursor, 0)
    end if
    tElem.feedImage(tImage)
  end repeat
  return 1
end

on getInstanceListItemBg me, tstate
  case tstate of
    #created:
      tImage1 = member(getmemnum("sw_bg_grn4")).image
      tImage2 = member(getmemnum("sw_ico_thumb")).image
      tRegPoint2 = member(getmemnum("sw_ico_thumb")).regPoint
    #started:
      tImage1 = member(getmemnum("sw_bg_red4")).image
      tImage2 = member(getmemnum("sw_ico_bounce")).image
      tRegPoint2 = member(getmemnum("sw_ico_bounce")).regPoint
    #finished:
      tImage1 = member(getmemnum("sw_bg_gry4")).image
      tImage2 = member(getmemnum("sw_ico_flag")).image
      tRegPoint2 = member(getmemnum("sw_ico_flag")).regPoint
    #empty:
      tImage1 = member(getmemnum("sw_bg_emp3")).image
  end case
  tImage = image(191, 40, 8, member(getmemnum("snow_war2 Palette")))
  tImage.copyPixels(tImage1, tImage.rect, tImage1.rect)
  if tImage2 <> VOID then
    tImage.copyPixels(tImage2, tImage2.rect + rect(3 - tRegPoint2.locH, 7 - tRegPoint2.locV, 3 - tRegPoint2.locH, 7 - tRegPoint2.locV), tImage2.rect, [#ink: 8, #maskImage: tImage2.createMatte()])
  end if
  return tImage
end

on renderInstanceDetailTop me, tName, tHostName, tstate, tStateStr, tSpecs
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_header_gameChsn")
  if tElem <> 0 then
    tElem.setText(tName)
  end if
  tImage = image(191, 48, 8, member(getmemnum("snow_war2 Palette")))
  case tstate of
    #created:
      tStateIconMember = member(getmemnum("sw_ico_thumb"))
      tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
    #started:
      tStateIconMember = member(getmemnum("sw_ico_bounce"))
      tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
    #finished:
      tStateIconMember = member(getmemnum("sw_ico_flag"))
      tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
  end case
  if tBgImageMember = member(0) then
    return 0
  end if
  tBgImage = tBgImageMember.image
  tImage.copyPixels(tBgImage, tImage.rect, tBgImage.rect)
  tAddOffset = 0
  tTextImg = pWriterPlainNormLeft.render(tHostName)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 4 + tAddOffset, 32, 4 + tAddOffset), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tStateStr)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 20 + tAddOffset, 32, 20 + tAddOffset), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tSpecs)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 36 + tAddOffset, 32, 36 + tAddOffset), tTextImg.rect)
  if tStateIconMember = VOID then
    return 0
  end if
  tStateIcon = tStateIconMember.image
  tStRegpoint = tStateIconMember.regPoint
  tImage.copyPixels(tStateIcon, tStateIcon.rect + rect(3 - tStRegpoint.locH, 13 - tStRegpoint.locV, 3 - tStRegpoint.locH, 13 - tStRegpoint.locV), tStateIcon.rect, [#ink: 8, #maskImage: tStateIcon.createMatte()])
  tElem = tWndObj.getElement("gs_area_gameInfo")
  if tElem <> 0 then
    tElem.feedImage(tImage)
  end if
  return 1
end

on renderInstanceDetailButton me, tButtonState, tGameState
  tResult = image(191, 16, 8)
  tBlend = 255
  case tButtonState of
    #start, #start_dimmed:
      tBg = member(getmemnum("sw_lnk_px_1")).image
      tText = getText("gs_button_start")
      if tButtonState = #start_dimmed then
        tBlend = 50
        tButtonState = #start
      end if
    #spectate:
      tBg = member(getmemnum("sw_bg_px")).image
      tText = getText("gs_button_spectate")
    #spectateInfo:
      tBg = member(getmemnum("sw_bg_px")).image
      tText = getText("gs_text_spectate")
    otherwise:
      tText = EMPTY
  end case
  if ilk(tBg) <> #image then
    return 0
  end if
  tResult.paletteRef = tBg.paletteRef
  tResult.copyPixels(tBg, tResult.rect, tBg.rect)
  tWidth = tResult.width
  if (tButtonState = #start) or (tButtonState = #spectate) then
    tImage = pWriterLinkRight.render(tText)
    tLocH = tWidth - tImage.width - 10
    tResult.copyPixels(tImage, tImage.rect + rect(tLocH - 5, 3, tLocH - 5, 3), tImage.rect, [#blendLevel: tBlend])
    tImage = member(getmemnum("sw_arr")).image
    tResult.copyPixels(tImage, tImage.rect + rect(tWidth - 12, 4, tWidth - 12, 4), tImage.rect, [#ink: 36, #blendLevel: tBlend])
  else
    if tText <> #empty then
      tImage = pWriterPlainBoldLeft.render(tText)
      tLocH = (tWidth / 2) - (tImage.width / 2)
      tResult.copyPixels(tImage, tImage.rect + rect(tLocH, 3, tLocH, 3), tImage.rect)
    end if
  end if
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_link_gameInfo")
  tElem.feedImage(tResult)
  case tButtonState of
    #empty, #spectateInfo:
      tElem.setProperty(#cursor, 0)
    otherwise:
      tElem.setProperty(#cursor, "cursor.finger")
  end case
end

on renderInstanceDetailTeams me, tParams, tUserName, tHost, tOwnTeam
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  repeat with tTeamNum = 1 to tParams[#numTeams]
    tImage = tWndObj.getElement("gs_area_team" & tTeamNum).getProperty(#buffer)
    if tImage.type <> #bitmap then
      return 0
    end if
    tImage = tImage.image
    tBallImage = member(getmemnum("sw_ico_team" & tParams[#teams][tTeamNum][#id])).image
    if tBallImage <> VOID then
      tImage.copyPixels(tBallImage, tBallImage.rect + rect(5, 6, 5, 6), tBallImage.rect)
    end if
    tText = EMPTY
    tPlayers = tParams[#teams][tTeamNum][#players]
    repeat with tPlayerNum = 1 to tPlayers.count
      tText = tText & tPlayers[tPlayerNum][#name] & RETURN
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      tNotMe = tPlayers[tPlayerNum][#name] <> tUserName
      if tElem <> 0 then
        tElem.setProperty(#visible, tHost and (tParams[#state] = #created) and tNotMe)
      end if
    end repeat
    repeat with tPlayerNum = tPlayers.count + 1 to 12
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
    end repeat
    tAddedOffset = 0
    tTextImg = pWriterListPlainNormLeft.render(tText)
    tImage.copyPixels(tTextImg, tTextImg.rect + rect(30, -3 + tAddedOffset, 30, -3 + tAddedOffset), tTextImg.rect)
    if tParams[#state] = #finished then
      tText = EMPTY
      repeat with tPlayerNum = 1 to tPlayers.count
        tText = tText & tPlayers[tPlayerNum][#score] & RETURN
      end repeat
      pWriterPlainNormRight.define([#fixedLineSpace: 16])
      tTextImg = pWriterPlainNormRight.render(tText)
      tOffsetH = 158
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(tOffsetH, -3 + tAddedOffset, tOffsetH, -3 + tAddedOffset), tTextImg.rect)
      tTextImg = pWriterListPlainNormLeft.render(getText("gs_scores_team_" & tParams[#teams][tTeamNum][#id]))
      tOffsetV = tImage.height - 18
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(30, tOffsetV, 30, tOffsetV), tTextImg.rect, [#ink: 36])
      tTextImg = pWriterPlainNormRight.render(string(tParams[#teams][tTeamNum][#score]))
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(tOffsetH, tOffsetV, tOffsetH, tOffsetV), tTextImg.rect)
    end if
  end repeat
  repeat with tTeamNum = 1 to 4
    tElem = tWndObj.getElement("gs_link_team" & tTeamNum)
    if tElem <> 0 then
      if (tTeamNum = tOwnTeam) or (tParams[#state] <> #created) then
        tElem.setProperty(#visible, 0)
        next repeat
      end if
      tElem.setProperty(#visible, 1)
      tElem.feedImage(pJoinButtonImage)
    end if
  end repeat
end

on renderPageNumber me, tPage, tNumPages
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.getElement("gs_txt_pageNumber").setText(tPage & "/" & tNumPages)
  tElem = tWndObj.getElement("gs_arrow_pageBack")
  if tPage > 1 then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
  tElem = tWndObj.getElement("gs_arrow_pageFwd")
  if tPage < tNumPages then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
end

on updateRadioButton me, tElement, tListOfOthersElements
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).setProperty(#image, tOnImg)
  end if
  repeat with tRadioElement in tListOfOthersElements
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).setProperty(#image, tOffImg)
    end if
  end repeat
end

on convertSecToMinSec me, tTime
  tMin = tTime / 60
  tSec = tTime mod 60
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return tMin & ":" & tSec
end
