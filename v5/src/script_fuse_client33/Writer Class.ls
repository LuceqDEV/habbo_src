on construct(me)
  pDefRect = rect(0, 0, 480, 480)
  pTxtRect = void()
  pFntStru = void()
  pMember = member(getResourceManager().createMember("writer_" & getUniqueID(), #text))
  if pMember.number = 0 then
    return(0)
  else
    pMember.alignment = #left
    pMember.wordWrap = 0
    return(1)
  end if
  exit
end

on deconstruct(me)
  if ilk(pMember, #member) then
    getResourceManager().removeMember(pMember.name)
    pMember = void()
  end if
  return(1)
  exit
end

on define(me, tMetrics)
  if not ilk(tMetrics, #propList) then
    return(0)
  end if
  if stringp(tMetrics.getAt(#font)) then
    if pMember.font <> tMetrics.font then
      pMember.font = tMetrics.font
    end if
  end if
  if listp(tMetrics.getAt(#fontStyle)) then
    if pMember.fontStyle <> tMetrics.fontStyle then
      pMember.fontStyle = tMetrics.fontStyle
    end if
  end if
  if symbolp(tMetrics.getAt(#alignment)) then
    if pMember.alignment <> tMetrics.alignment then
      pMember.alignment = tMetrics.alignment
    end if
  end if
  if ilk(tMetrics.getAt(#color), #color) then
    if pMember.color <> tMetrics.color then
      pMember.color = tMetrics.color
    end if
  end if
  if ilk(tMetrics.getAt(#bgColor), #color) then
    if pMember.bgColor <> tMetrics.bgColor then
      pMember.bgColor = tMetrics.bgColor
    end if
  end if
  if integerp(tMetrics.getAt(#wordWrap)) then
    if pMember.wordWrap <> tMetrics.wordWrap then
      pMember.wordWrap = tMetrics.wordWrap
    end if
  end if
  if integerp(tMetrics.getAt(#antialias)) then
    if pMember.antialias <> tMetrics.antialias then
      pMember.antialias = tMetrics.antialias
    end if
  end if
  if integerp(tMetrics.getAt(#fontSize)) then
    if pMember.fontSize <> tMetrics.fontSize then
      pMember.fontSize = tMetrics.fontSize
    end if
  end if
  if integerp(tMetrics.getAt(#boxType)) then
    if pMember.boxType <> tMetrics.boxType then
      pMember.boxType = tMetrics.boxType
    end if
  end if
  if ilk(tMetrics.getAt(#rect), #rect) then
    if pMember.width <> tMetrics.width then
      pMember.rect = tMetrics.rect
    end if
  end if
  if pMember.fixedLineSpace <> pMember.fontSize then
    pMember.fixedLineSpace = pMember.fontSize
  end if
  if integerp(tMetrics.getAt(#fixedLineSpace)) then
    tTopSpacing = tMetrics.fixedLineSpace - pMember.fontSize
    if pMember.topSpacing <> tTopSpacing then
      pMember.topSpacing = tTopSpacing
    end if
  end if
  pTxtRect = tMetrics.getAt(#rect)
  return(1)
  exit
end

on render(me, tText, tRect)
  pMember.text = tText
  if tRect.ilk = #rect then
    if pMember.width <> tRect.width then
      pMember.rect = tRect
    end if
  else
    if voidp(pTxtRect) then
      tAlignment = pMember.alignment
      pMember.alignment = #left
      pMember.rect = pDefRect
      tTotal = length(tText.getProp(#line, 1))
      tWidth = pMember.charPosToLoc(tTotal).locH
      if tText.count(#line) > 1 then
        i = 2
        repeat while i <= tText.count(#line)
          tTotal = tTotal + length(tText.getProp(#line, i)) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
          i = 1 + i
        end repeat
      end if
      tWidth = tWidth + pMember.fontSize
      pMember.rect = rect(0, 0, tWidth, pMember.height)
      pMember.alignment = tAlignment
    else
      if pMember.width <> pTxtRect.width then
        pMember.rect = pTxtRect
      end if
    end if
  end if
  return(pMember.image)
  exit
end

on renderHTML(me, tHtml, tRect)
  tFont = me.getFont()
  pMember.html = tHtml
  if tRect.ilk = #rect then
    if pMember.width <> tRect.width then
      pMember.rect = tRect
    end if
  else
    if voidp(pTxtRect) then
      tAlignment = pMember.alignment
      pMember.alignment = #left
      pMember.rect = pDefRect
      tTotal = length(pMember.getProp(#line, 1))
      tWidth = pMember.charPosToLoc(tTotal).locH
      if pMember.count(#line) > 1 then
        i = 2
        repeat while i <= pMember.count(#line)
          tTotal = tTotal + length(pMember.getProp(#line, i)) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
          i = 1 + i
        end repeat
      end if
      tWidth = tWidth + pMember.fontSize
      pMember.rect = rect(0, 0, tWidth, pMember.height)
      pMember.alignment = tAlignment
    else
      if pMember.width <> pTxtRect.width then
        pMember.rect = pTxtRect
      end if
    end if
  end if
  me.setFont(tFont)
  return(pMember.image)
  exit
end

on setFont(me, tStruct)
  if tStruct.ilk <> #struct then
    return(error(me, "Font struct expected!", #setFont))
  end if
  if pMember.font <> tStruct.getaProp(#font) then
    pMember.font = tStruct.getaProp(#font)
  end if
  if pMember.fontSize <> tStruct.getaProp(#fontSize) then
    pMember.fontSize = tStruct.getaProp(#fontSize)
  end if
  if pMember.fontStyle <> tStruct.getaProp(#fontStyle) then
    pMember.fontStyle = tStruct.getaProp(#fontStyle)
  end if
  if pMember.color <> tStruct.getaProp(#color) then
    pMember.color = tStruct.getaProp(#color)
  end if
  if pMember.fixedLineSpace <> pMember.fontSize then
    pMember.fixedLineSpace = pMember.fontSize
  end if
  tLineHeight = pMember.fontSize + pMember.topSpacing
  if tLineHeight <> tStruct.getaProp(#lineHeight) then
    pMember.topSpacing = tStruct.getaProp(#lineHeight) - pMember.fontSize
  end if
  return(1)
  exit
end

on getFont(me)
  if voidp(pFntStru) then
    pFntStru = getStructVariable("struct.font.empty")
  end if
  pFntStru.setaProp(#font, pMember.font)
  pFntStru.setaProp(#fontStyle, pMember.fontStyle)
  pFntStru.setaProp(#fontSize, pMember.fontSize)
  pFntStru.setaProp(#color, pMember.color)
  tLineHeight = pMember.fontSize + pMember.topSpacing
  pFntStru.setaProp(#lineHeight, tLineHeight)
  return(pFntStru)
  exit
end

on setProperty(me, tKey, tValue)
  return(me.define([#tKey:tValue]))
  exit
end