property pFontData, pDontProfile, pTextMem, pUnderliningDisabled, pTextRenderMode, pNeedFill

on prepare me 
  me.pOffX = 0
  me.pOffY = 0
  me.pOwnW = me.getProp(#pProps, #width)
  me.pOwnH = me.getProp(#pProps, #height)
  me.pScrolls = []
  if me.getProp(#pProps, #style) = #unique then
    me.pOwnX = 0
    me.pOwnY = 0
  else
    me.pOwnX = me.getProp(#pProps, #locH)
    me.pOwnY = me.getProp(#pProps, #locV)
  end if
  pFontData = [:]
  pFontData.setAt(#color, me.getProp(#pProps, #txtColor))
  pFontData.setAt(#bgColor, me.getProp(#pProps, #txtBgColor))
  pFontData.setAt(#key, me.getProp(#pProps, #key))
  pFontData.setAt(#wordWrap, me.getProp(#pProps, #wordWrap))
  pFontData.setAt(#alignment, symbol(me.getProp(#pProps, #alignment)))
  pFontData.setAt(#font, me.getProp(#pProps, #font))
  pFontData.setAt(#fontSize, me.getProp(#pProps, #fontSize))
  pFontData.setAt(#fontStyle, me.getProp(#pProps, #fontStyle))
  if integerp(me.getProp(#pProps, #fixedLineSpace)) then
    if me.getProp(#pProps, #fixedLineSpace) = me.getProp(#pProps, #fontSize) then
      me.setProp(#pProps, #fixedLineSpace, me.getProp(#pProps, #fixedLineSpace) + 1)
    end if
    pFontData.setAt(#fixedLineSpace, me.getProp(#pProps, #fixedLineSpace))
  else
    pFontData.setAt(#fixedLineSpace, me.getProp(#pProps, #fontSize) + 1)
  end if
  if voidp(pFontData.getAt(#key)) then
    pFontData.setAt(#key, "")
  end if
  if pFontData.getAt(#bgColor) <> rgb(255, 255, 255) then
    pNeedFill = 1
  else
    pNeedFill = 0
  end if
  if variableExists("text.render.compatibility.mode") then
    pTextRenderMode = getVariable("text.render.compatibility.mode")
  else
    pTextRenderMode = 1
  end if
  if variableExists("text.underlining.disabled") then
    pUnderliningDisabled = getVariable("text.underlining.disabled")
  else
    pUnderliningDisabled = 0
  end if
  me.initResources(pFontData)
  me.setProfiling()
  return(me.createImgFromTxt())
end

on setProfiling  
  if voidp(pDontProfile) then
    pDontProfile = 1
    if getObjectManager().managerExists(#variable_manager) then
      if variableExists("profile.fields.enabled") then
        pDontProfile = 0
      end if
    end if
  end if
end

on setText me, tText 
  tText = string(tText)
  pFontData.setAt(#text, tText)
  tRect = rect(me.pOwnX, me.pOwnY, me.pOwnX + me.pOwnW, me.pOwnY + me.pOwnH)
  undefined.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return(1)
end

on getText me 
  return(pFontData.getAt(#text))
end

on setFont me, tStruct 
  pFontData.font = tStruct.getaProp(#font)
  pFontData.fontStyle = tStruct.getaProp(#fontStyle)
  pFontData.fontSize = tStruct.getaProp(#fontSize)
  pFontData.color = tStruct.getaProp(#color)
  pFontData.fixedLineSpace = tStruct.getaProp(#lineHeight)
  tRect = rect(me.pOwnX, me.pOwnY, me.pOwnX + me.pOwnW, me.pOwnY + me.pOwnH)
  undefined.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return(1)
end

on getFont me 
  tStruct = getStructVariable("struct.font.empty")
  tStruct.setaProp(#font, pFontData.font)
  tStruct.setaProp(#fontStyle, pFontData.fontStyle)
  tStruct.setaProp(#fontSize, pFontData.fontSize)
  tStruct.setaProp(#color, pFontData.color)
  tStruct.setaProp(#lineHeight, pFontData.fixedLineSpace)
  return(tStruct)
end

on registerScroll me, tID 
  if voidp(me.pScrolls) then
    me.prepare()
  end if
  if not voidp(tID) then
    if me.getPos(tID) = 0 then
      me.add(tID)
    end if
  else
    if me.count(#pScrolls) = 0 then
      return(0)
    end if
  end if
  tSourceRect = rect(me.pOffX, me.pOffY, me.pOffX + me.pOwnW, me.pOffY + me.pOwnH)
  tScrollList = []
  tWndObj = getWindowManager().GET(me.pMotherId)
  repeat while me.pScrolls <= undefined
    tScrollId = getAt(undefined, tID)
    tScrollList.add(tWndObj.getElement(tScrollId))
  end repeat
  me.createImgFromTxt()
  call(#updateData, tScrollList, tSourceRect, me.rect)
end

on initResources me, tFontProps 
  tMemNum = getResourceManager().getmemnum("visual window text")
  if tMemNum = 0 then
    tMemNum = getResourceManager().createMember("visual window text", #text)
    pTextMem = member(tMemNum)
    pTextMem.boxType = #adjust
  else
    pTextMem = member(tMemNum)
  end if
  executeMessage(#invalidateCrapFixRegion)
  return(1)
end

on createImgFromTxt me 
  if not pDontProfile then
    startProfilingTask("Text Wrapper::createImgFromTxt")
  end if
  pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(pFontData.getAt(#fontStyle)) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    i = 1
    repeat while i <= pFontData.getAt(#fontStyle).count(#item)
      tList.add(symbol(pFontData.getAt(#fontStyle).getProp(#item, i)))
      i = 1 + i
    end repeat
    the itemDelimiter = tDelim
    pFontData.setAt(#fontStyle, tList)
  end if
  if pUnderliningDisabled then
    if listp(pFontData.getAt(#fontStyle)) then
      if pFontData.getAt(#fontStyle).getPos(#underline) <> 0 then
        pFontData.getAt(#fontStyle).deleteOne(#underline)
        if pFontData.getAt(#fontStyle).count = 0 then
          pFontData.getAt(#fontStyle).append(#plain)
        end if
      end if
    end if
  end if
  if not voidp(pFontData.getAt(#text)) then
    pTextMem.text = pFontData.getAt(#text)
    pFontData.setAt(#text, void())
  else
    if pFontData.getAt(#key) = "" then
      pTextMem.text = ""
    else
      if pFontData.getAt(#key).getProp(#char, 1) = "%" then
        tKey = symbol(pFontData.getAt(#key).getProp(#char, 2, length(pFontData.getAt(#key))))
        pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(pFontData.getAt(#key)) then
          pTextMem.text = getTextManager().GET(pFontData.getAt(#key))
        else
          error(me, "Text not found:" && pFontData.getAt(#key), #createImgFromTxt, #minor)
          pTextMem.text = pFontData.getAt(#key)
        end if
      end if
    end if
  end if
  pFontData.setAt(#text, pTextMem.text)
  if pTextMem.fontStyle <> pFontData.getAt(#fontStyle) then
    pTextMem.fontStyle = pFontData.getAt(#fontStyle)
  end if
  if pTextMem.wordWrap <> pFontData.getAt(#wordWrap) then
    pTextMem.wordWrap = pFontData.getAt(#wordWrap)
  end if
  if pTextMem.alignment <> pFontData.getAt(#alignment) then
    pTextMem.alignment = pFontData.getAt(#alignment)
  end if
  if pTextMem.font <> pFontData.getAt(#font) then
    pTextMem.font = pFontData.getAt(#font)
  end if
  if pTextMem.fontSize <> pFontData.getAt(#fontSize) then
    pTextMem.fontSize = pFontData.getAt(#fontSize)
  end if
  if pTextMem.fixedLineSpace <> pFontData.getAt(#fixedLineSpace) then
    pTextMem.fixedLineSpace = pFontData.getAt(#fixedLineSpace)
  end if
  if me.pScaleH = #center then
    tWidth = pTextMem.charPosToLoc(pTextMem.count(#char)).locH + 16
    if me.getProp(#pProps, #style) = #unique then
      me.pLocX = me.pLocX + (me.pwidth - tWidth / 2)
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = me.pOwnX + (me.pOwnW - tWidth / 2)
      me.pOwnW = tWidth
    end if
    pTextMem.rect = rect(0, 0, tWidth, pTextMem.height)
  else
    if me.getProp(#pProps, #style) = #unique then
      me.pwidth = pTextMem.width
      me.pOwnW = me.pwidth
    else
      me.pOwnW = pTextMem.width
    end if
  end if
  if pTextRenderMode = 2 then
    tFakeAlpha = image(pTextMem.width, pTextMem.height, 8)
    tFakeAlpha.copyPixels(pTextMem.image, pTextMem.rect, tFakeAlpha.rect, [#ink:8])
  end if
  if pTextRenderMode = 1 then
    if pTextMem.bgColor <> pFontData.getAt(#bgColor) then
      pTextMem.bgColor = pFontData.getAt(#bgColor)
    end if
    if pTextMem.color <> pFontData.getAt(#color) then
      pTextMem.color = pFontData.getAt(#color)
    end if
  else
    if pTextRenderMode = 2 then
      tFakeSrc = image(pTextMem.width, pTextMem.height, 32)
      tFakeSrc.fill(tFakeSrc.rect, [#color:pFontData.getAt(#color), #shape:#rect])
    end if
  end if
  if me.count(#pScrolls) > 0 then
    tHeight = pTextMem.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if me.pimage = void() then
    return(0)
  end if
  if pTextMem = void() then
    return(0)
  end if
  if voidp(me.pimage) then
    return(0)
  end if
  if voidp(pTextMem) then
    return(0)
  end if
  if pNeedFill then
    me.fill(me.rect, me.getProp(#pFontData, #bgColor))
  end if
  if pTextRenderMode = 1 then
    me.copyPixels(pTextMem.image, me.rect, me.rect, [#ink:8])
  else
    if pTextRenderMode = 2 then
      me.copyPixels(tFakeSrc, me.rect, me.rect, [#maskImage:tFakeAlpha])
    end if
  end if
  executeMessage(#invalidateCrapFixRegion)
  if not pDontProfile then
    finishProfilingTask("Text Wrapper::createImgFromTxt")
  end if
  return(1)
end

on handlers  
  return([])
end
