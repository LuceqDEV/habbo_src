property pProp, pMaxWidth, pFixedSize, pButtonText, pAlignment, pOrigWidth, pBlend, pClickPass, pButtonImg, pCachedImgs

on prepare me 
  tField = me.getProp(#pProps, #type) & me.getProp(#pProps, #model) & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if (pProp = 0) then
    return FALSE
  end if
  pmodel = me.getProp(#pProps, #model)
  pOrigWidth = me.getProp(#pProps, #width)
  pMaxWidth = me.getProp(#pProps, #maxwidth)
  pFixedSize = me.getProp(#pProps, #fixedsize)
  pAlignment = me.getProp(#pProps, #alignment)
  pButtonText = getText(me.getProp(#pProps, #key))
  pBlend = me.getProp(#pProps, #blend)
  pCachedImgs = [:]
  if not integerp(pMaxWidth) then
    pMaxWidth = 300
  end if
  if voidp(pFixedSize) then
    pFixedSize = 0
  end if
  me.UpdateImageObjects(void(), #up)
  me.pimage = me.createButtonImg(pButtonText, #up)
  tTempOffset = me.pSprite.member.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pwidth = me.pimage.width
  me.pheight = me.pimage.height
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  if (pAlignment = #center) then
    me.pLocX = (me.pLocX - ((me.pwidth - pOrigWidth) / 2))
  else
    if (pAlignment = #right) then
      me.pLocX = (me.pLocX - (me.pwidth - pOrigWidth))
    end if
  end if
  me.pSprite.loc = point(me.pLocX, me.pLocY)
  me.pSprite.width = me.pwidth
  me.pSprite.height = me.pheight
  return TRUE
end

on Activate me 
  me.pSprite.blend = 100
  pBlend = 100
  return TRUE
end

on deactivate me 
  me.changeState(#up)
  me.pSprite.blend = 50
  pBlend = 50
  return TRUE
end

on mouseDown me 
  if pBlend < 100 or me.pSprite.blend < 100 then
    return FALSE
  end if
  pClickPass = 1
  me.changeState(#down)
  return TRUE
end

on mouseUp me 
  if pBlend < 100 or me.pSprite.blend < 100 then
    return FALSE
  end if
  if (pClickPass = 0) then
    return FALSE
  end if
  pClickPass = 0
  me.changeState(#up)
  return TRUE
end

on mouseUpOutSide me 
  if pBlend < 100 or me.pSprite.blend < 100 then
    return FALSE
  end if
  pClickPass = 0
  me.changeState(#up)
  return FALSE
end

on render me 
  me.pBuffer.image.fill(me.pBuffer.image.rect, rgb(255, 255, 255))
  me.pBuffer.image.copyPixels(me.pimage, me.pBuffer.image.rect, me.pimage.rect, me.pParams)
end

on changeState me, tstate 
  me.UpdateImageObjects(void(), tstate)
  me.pimage = me.createButtonImg(pButtonText, tstate)
  me.render()
end

on UpdateImageObjects me, tPalette, tstate 
  pButtonImg = [:]
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat while [#left, #middle, #right] <= tstate
    f = getAt(tstate, tPalette)
    tDesc = pProp.getAt(tstate).getAt(#members).getAt(f)
    tmember = member(getmemnum(tDesc.getAt(#member)))
    if not voidp(tDesc.getAt(#palette)) then
      me.pPalette = member(getmemnum(tDesc.getAt(#palette)))
    else
      me.pPalette = tPalette
    end if
    tImage = tmember.image.duplicate()
    if tDesc.getAt(#flipH) then
      tImage = me.flipH(tImage)
    end if
    if tDesc.getAt(#flipV) then
      tImage = me.flipV(tImage)
    end if
    pButtonImg.addProp(symbol(f), tImage)
  end repeat
end

on createButtonImg me, tText, tstate 
  if not voidp(pCachedImgs.getAt(tstate)) then
    return(pCachedImgs.getAt(tstate))
  end if
  tMemNum = getmemnum("common.button.text")
  if (tMemNum = 0) then
    tMemNum = createMember("common.button.text", #text)
  end if
  tTextMem = member(tMemNum)
  tFontDesc = pProp.getAt(tstate).getAt(#text)
  tFont = tFontDesc.getAt(#font)
  tFontStyle = list(symbol(tFontDesc.getAt(#fontStyle)))
  tFontSize = tFontDesc.getAt(#fontSize)
  tColor = rgb(tFontDesc.getAt(#color))
  tBgColor = rgb(tFontDesc.getAt(#bgColor))
  tBoxType = tFontDesc.getAt(#boxType)
  tSpace = (tFontDesc.getAt(#fontSize) + 2)
  tMarginH = tFontDesc.getAt(#marginH)
  tMarginV = tFontDesc.getAt(#marginV)
  if (tTextMem.wordWrap = 1) then
    tTextMem.wordWrap = 0
  end if
  if tTextMem.font <> tFont then
    tTextMem.font = tFont
  end if
  if tTextMem.fontStyle <> tFontStyle then
    tTextMem.fontStyle = tFontStyle
  end if
  if tTextMem.fontSize <> tFontSize then
    tTextMem.fontSize = tFontSize
  end if
  if tTextMem.color <> tColor then
    tTextMem.color = tColor
  end if
  if tTextMem.bgColor <> tBgColor then
    tTextMem.bgColor = tBgColor
  end if
  if tTextMem.boxType <> tBoxType then
    tTextMem.boxType = tBoxType
  end if
  if tTextMem.fixedLineSpace <> tSpace then
    tTextMem.fixedLineSpace = tSpace
  end if
  if tTextMem.text <> tText then
    tTextMem.text = tText
  end if
  if (pFixedSize = 1) then
    tCharPosH = tTextMem.locToCharPos(point((pOrigWidth - (tMarginH * 2)), 5))
    tTextWidth = tTextMem.charPosToLoc(tCharPosH).locH
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = pOrigWidth
  else
    tTextWidth = (tTextMem.charPosToLoc(tTextMem.count(#char)).locH + tFontDesc.getAt(#fontSize))
    if (tTextWidth + (tMarginH * 2)) > pMaxWidth then
      tTextWidth = (pMaxWidth - (tMarginH * 2))
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = (tTextWidth + (tMarginH * 2))
  end if
  tNewImg = image(tWidth, pButtonImg.getAt(#left).height, me.pDepth, me.pPalette)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= tstate
    i = getAt(tstate, tText)
    tStartPointX = tEndPointX
    if ([#left, #middle, #right] = #left) then
      tEndPointX = (tEndPointX + pButtonImg.getProp(i).width)
    else
      if ([#left, #middle, #right] = #middle) then
        tEndPointX = (((tEndPointX + tWidth) - pButtonImg.getProp(#left).width) - pButtonImg.getProp(#right).width)
      else
        if ([#left, #middle, #right] = #right) then
          tEndPointX = (tEndPointX + pButtonImg.getProp(i).width)
        end if
      end if
    end if
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(pButtonImg.getProp(i), tdestrect, pButtonImg.getProp(i).rect)
  end repeat
  tDstRect = (tTextImg.rect + rect(1, tMarginV, 1, tMarginV))
  if ([#left, #middle, #right] = #left) then
    tDstRect = (tDstRect + rect(pButtonImg.getProp(#left).width, 0, pButtonImg.getProp(#left).width, 0))
  else
    if ([#left, #middle, #right] = #center) then
      tDstRect = ((tDstRect + rect((tNewImg.width / 2), 0, (tNewImg.width / 2), 0)) - rect((tTextWidth / 2), 0, (tTextWidth / 2), 0))
    else
      if ([#left, #middle, #right] = #right) then
        tDstRect = ((tDstRect + rect(tNewImg.width, 0, tNewImg.width, 0)) - rect((tTextWidth + pButtonImg.getProp(#right).width), 0, (tTextWidth + pButtonImg.getProp(#right).width), 0))
      end if
    end if
  end if
  tNewImg.copyPixels(tTextImg, tDstRect, tTextImg.rect, [#ink:36])
  pCachedImgs.setAt(tstate, tNewImg)
  return(tNewImg)
end

on flipH me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on flipV me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end
