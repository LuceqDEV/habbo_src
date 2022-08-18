property pFontData, pTextMem, pNeedFill

on prepare me 
  me.pOffX = 0
  me.pOffY = 0
  me.pOwnW = me.getProp(#pProps, #width)
  me.pOwnH = me.getProp(#pProps, #height)
  me.pScrolls = []
  if (me.getProp(#pProps, #style) = #unique) then
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
    pFontData.setAt(#fixedLineSpace, me.getProp(#pProps, #fixedLineSpace))
  else
    pFontData.setAt(#fixedLineSpace, me.getProp(#pProps, #fontSize))
  end if
  if voidp(pFontData.getAt(#key)) then
    pFontData.setAt(#key, "")
  end if
  if pFontData.getAt(#bgColor) <> rgb(255, 255, 255) then
    pNeedFill = 1
  else
    pNeedFill = 0
  end if
  me.initResources(pFontData)
  return(me.createImgFromTxt())
end

on setText me, tText 
  tText = string(tText)
  pFontData.setAt(#text, tText)
  tRect = rect(me.pOwnX, me.pOwnY, (me.pOwnX + me.pOwnW), (me.pOwnY + me.pOwnH))
  me.pBuffer.image.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return TRUE
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
  tRect = rect(me.pOwnX, me.pOwnY, (me.pOwnX + me.pOwnW), (me.pOwnY + me.pOwnH))
  me.pBuffer.image.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return TRUE
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

on registerScroll me, tid 
  if voidp(me.pScrolls) then
    me.prepare()
  end if
  if not voidp(tid) then
    if (me.pScrolls.getPos(tid) = 0) then
      me.pScrolls.add(tid)
    end if
  else
    if (me.count(#pScrolls) = 0) then
      return FALSE
    end if
  end if
  tSourceRect = rect(me.pOffX, me.pOffY, (me.pOffX + me.pOwnW), (me.pOffY + me.pOwnH))
  tScrollList = []
  tWndObj = getWindowManager().get(me.pMotherId)
  repeat while me.pScrolls <= undefined
    tScrollId = getAt(undefined, tid)
    tScrollList.add(tWndObj.getElement(tScrollId))
  end repeat
  me.createImgFromTxt()
  call(#updateData, tScrollList, tSourceRect, me.pimage.rect)
end

on initResources me, tFontProps 
  tMemNum = getResourceManager().getmemnum("visual window text")
  if (tMemNum = 0) then
    tMemNum = getResourceManager().createMember("visual window text", #text)
    pTextMem = member(tMemNum)
    pTextMem.boxType = #adjust
  else
    pTextMem = member(tMemNum)
  end if
  return TRUE
end

on createImgFromTxt me 
  pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(pFontData.getAt(#fontStyle)) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    i = 1
    repeat while i <= pFontData.getAt(#fontStyle).count(#item)
      tList.add(symbol(pFontData.getAt(#fontStyle).getProp(#item, i)))
      i = (1 + i)
    end repeat
    the itemDelimiter = tDelim
    pFontData.setAt(#fontStyle, tList)
  end if
  if not voidp(pFontData.getAt(#text)) then
    pTextMem.text = pFontData.getAt(#text)
    pFontData.setAt(#text, void())
  else
    if (pFontData.getAt(#key) = "") then
      pTextMem.text = ""
    else
      if (pFontData.getAt(#key).getProp(#char, 1) = "%") then
        tKey = symbol(pFontData.getAt(#key).getProp(#char, 2, length(pFontData.getAt(#key))))
        pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(pFontData.getAt(#key)) then
          pTextMem.text = getTextManager().get(pFontData.getAt(#key))
        else
          error(me, "Text not found:" && pFontData.getAt(#key), #createImgFromTxt)
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
  if pTextMem.bgColor <> pFontData.getAt(#bgColor) then
    pTextMem.bgColor = pFontData.getAt(#bgColor)
  end if
  if pTextMem.font <> pFontData.getAt(#font) then
    pTextMem.font = pFontData.getAt(#font)
  end if
  if pTextMem.fontSize <> pFontData.getAt(#fontSize) then
    pTextMem.fontSize = pFontData.getAt(#fontSize)
  end if
  if pTextMem.color <> pFontData.getAt(#color) then
    pTextMem.color = pFontData.getAt(#color)
  end if
  if pTextMem.fixedLineSpace <> pFontData.getAt(#fixedLineSpace) then
    pTextMem.fixedLineSpace = pFontData.getAt(#fixedLineSpace)
  end if
  if (me.pScaleH = #center) then
    tWidth = (pTextMem.charPosToLoc(pTextMem.count(#char)).locH + 16)
    if (me.getProp(#pProps, #style) = #unique) then
      me.pLocX = (me.pLocX + ((me.pwidth - tWidth) / 2))
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = (me.pOwnX + ((me.pOwnW - tWidth) / 2))
      me.pOwnW = tWidth
    end if
    pTextMem.rect = rect(0, 0, tWidth, pTextMem.height)
  else
    if (me.getProp(#pProps, #style) = #unique) then
      me.pwidth = pTextMem.image.width
      me.pOwnW = me.pwidth
    else
      me.pOwnW = pTextMem.image.width
    end if
  end if
  if me.count(#pScrolls) > 0 then
    tHeight = pTextMem.rect.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if pNeedFill then
    me.pimage.fill(me.pimage.rect, me.getProp(#pFontData, #bgColor))
  end if
  me.pimage.copyPixels(pTextMem.image, me.pimage.rect, me.pimage.rect, [#ink:8])
  return TRUE
end
