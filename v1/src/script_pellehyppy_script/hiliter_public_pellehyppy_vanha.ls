property hiliteSprite, stuffX, stuffY, stuffDirection
global xoffset, yoffset, xSize, ySize, hiliter, lasth, lastV, gUserSprites, gChosenUser, gChosenUserSprite, gChosenObject, gUserColors, gXtraFeatureSprite, gChosenStripLevel, gXFactor, gYFactor, gHFactor, gpUiButtons, gGameContext

on beginSprite me
  hiliteSprite = 0
  hiliteSprite = sprMan_getPuppetSprite()
  if (hiliteSprite < 1) then
    return 
  end if
  hiliter = me
  put " " into field "mobilename"
  put " " into field "mobilecustom"
  placingStuff = 0
end

on placeStuff me, tstuffType, stuffModel, tstuffX, tstuffY, tstuffDirection, stripId
  beep(1)
end

on moveStuff me, stuffSprite
  beep(1)
end

on placeItem me, titemType, stripId
  beep(1)
end

on hiliteExitframe me
  if voidp(gChosenUser) then
    set the loc of sprite hiliteSprite to point(-1000, 1000)
    if (the mouseV < 482) then
      member("helpbox").text = EMPTY
    end if
  else
    if ((gChosenObject.pFlipped.findPos(#sd) <> VOID) and (gChosenObject.pSprites.findPos(#hd) <> VOID)) then
      loc = sprite(getProp(gChosenObject.pSprites, #hd)).loc
      characterdir = getProp(gChosenObject.pDirections, #bd)
      if (getProp(gChosenObject.pFlipped, #hd) = 1) then
        loc = (loc - [gXFactor, 0])
      end if
      if (characterdir > 3) then
        characterdir = (characterdir - 4)
      end if
      set the member of sprite hiliteSprite to ("memberhilite_small_" & characterdir)
      set the loc of sprite hiliteSprite to loc
      sprite(hiliteSprite).locZ = sprite(getProp(gChosenObject.pSprites, #hd)).locZ
      s = getaProp(gChosenObject, #name)
      if (getCustom(gChosenObject) <> EMPTY) then
        temp = getCustom(gChosenObject)
        if (temp.line.count > 1) then
          if (temp.line[1] <> EMPTY) then
            s = ((((s && "-") && temp.line[1]) && "-") && temp.line[2])
          else
            s = ((s && "-") && temp.line[2])
          end if
        else
          s = ((s && "-") && temp)
        end if
      end if
      if ((the mouseV < 482) and (member("helpbox").text <> s)) then
        member("helpbox").text = s
      end if
    else
      set the loc of sprite hiliteSprite to point(-1000, 1000)
    end if
  end if
  if ((lasth = the mouseH) and (lastV = the mouseV)) then
    return 
  end if
  hils = getWorldCoordinate(the mouseH, the mouseV)
  lasth = the mouseH
  lastV = the mouseV
  if the optionDown then
    put hils
  end if
  if rollover(660) then
    hils = VOID
  end if
  iSpr = me.spriteNum
  if not voidp(hils) then
    hilitex = getAt(hils, 1)
    hilitey = getAt(hils, 2)
    hiliteH = getAt(hils, 3)
    screenCoord = getScreenCoordinate(hilitex, hilitey, hiliteH)
    set the locH of sprite iSpr to screenCoord[1]
    set the locV of sprite iSpr to screenCoord[2]
    if (hiliteH < 7) then
      sprite(iSpr).locH = 1000
    end if
  else
    set the locH of sprite iSpr to -10000
    set the locV of sprite iSpr to -10000
  end if
end

on mouseDown me, brokenClickFromItem
  if rollover(660) then
    return 
  end if
  rollSpr = rollover()
  o = getaProp(gUserSprites, rollSpr)
  if voidp(o) then
    repeat with i = 1 to count(gUserSprites)
      if rollover(getPropAt(gUserSprites, i)) then
        o = getAt(gUserSprites, i)
        rollSpr = getPropAt(gUserSprites, i)
        exit repeat
      end if
    end repeat
  end if
  if voidp(o) then
    hils = getWorldCoordinate(the mouseH, the mouseV)
    if not voidp(hils) then
      if (objectp(gGameContext) and (the movieName contains "gf_gamehall")) then
        if (visible(gGameContext) = 1) then
          return 
        end if
      end if
      sendFuseMsg((("Move" && getAt(hils, 1)) && getAt(hils, 2)))
    end if
    if objectp(gChosenObject) then
      call(#hideSpecialInfo, gChosenObject)
    end if
    emptyInfoFields(me)
    Hide_hilitedAvatar(me, 712)
    gChosenUser = VOID
    put " " into field "mobilename"
    put " " into field "mobilecustom"
    member("item.info_name").text = " "
    member("item.info_text").text = " "
  else
    gChosenUser = getName(o)
    gChosenObject = o
    gChosenUserSprite = rollSpr
    set the ink of sprite hiliteSprite to 36
    hils = getWorldCoordinate(the mouseH, the mouseV)
    Custom = getCustom(o)
    put Custom into field "mobilecustom"
    put gChosenUser into field "mobilename"
    hiliteAvatar(me, o, 712)
    myMatchEmName = EMPTY
    if listp(gChosenObject.specialXtras) then
      put gChosenObject.specialXtras
      if stringp(getaProp(gChosenObject.specialXtras, "matchem")) then
        myMatchEmName = ((RETURN & "MatchEm-nimi:") && getaProp(gChosenObject.specialXtras, "matchem"))
      end if
    end if
    member("item.info_text").text = (getCustom(gChosenObject) & myMatchEmName)
    if (myMatchEmName.length > 0) then
      member("item.info_text").word[(the number of words in (getCustom(gChosenObject) & myMatchEmName) - 1)].Hyperlink = "http://kolumbus.fi/matchem/homman_nimi.jsp"
    end if
    member("item.info_name").text = getaProp(gChosenObject, #name)
    emptyInfoFields(me)
    fcolor = integer(getaProp(gUserColors, gChosenUser))
    if not voidp(hils) then
      hilitex = getAt(hils, 1)
      hilitey = getAt(hils, 2)
      sendFuseMsg((("LOOKTO " & hilitex) && hilitey))
    end if
  end if
end

on hiliteAvatar me, ChosenObject, whichSprite
end

on showMyEy me, ChosenObject, whichSprite
  part = "ey"
  memName = ((((((((("h_" & "std") & "_") & part) & "_") & getaProp(ChosenObject.myEy, #models)) & "_") & "2") & "_") & 0)
  memNum = getmemnum(memName)
  sprite(whichSprite).member = memNum
  if (part = "sd") then
    sprite(whichSprite).blend = 16
  end if
  sprite(whichSprite).bgColor = getaProp(ChosenObject.myEy, #colors)
  sprite(whichSprite).ink = getaProp(ChosenObject.myEy, #Inks)
  sprite(whichSprite).loc = point(685, 392)
  sprite(whichSprite).locZ = (getaProp(ChosenObject.myEy, #LocZShifts) + 100000)
  sprite(whichSprite).rotation = 180
  sprite(whichSprite).skew = 180
end

on Hide_hilitedAvatar me, whichSpr
end

on emptyInfoFields me
  global gInfofieldIconSprite
  sendSprite(gInfofieldIconSprite, #setIcon, "x")
end

on limitLoc coordinate, top
end
