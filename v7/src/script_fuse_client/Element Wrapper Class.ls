property pElemList, pBuffer, pSprite, pLocX, pLocY, pScaleH, pwidth, pScaleV, pheight, pPalette, pVisible

on construct me 
  pElemList = []
  pPalette = #systemMac
  pScaleH = #fixed
  pScaleV = #fixed
  pLocX = 0
  pLocY = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  return TRUE
end

on deconstruct me 
  call(#deconstruct, pElemList)
  pElemList = []
  pBuffer = void()
  pSprite = void()
  return TRUE
end

on define me, tProps 
  pID = tProps.getAt(#id)
  pBuffer = tProps.getAt(#buffer)
  pSprite = tProps.getAt(#sprite)
  pLocX = tProps.getAt(#locX)
  pLocY = tProps.getAt(#locY)
  pwidth = pBuffer.width
  pheight = pBuffer.height
  pPalette = pBuffer.paletteRef
  return TRUE
end

on add me, tElement 
  if not objectp(tElement) then
    return FALSE
  end if
  if tElement.getProperty(#scaleH) <> #fixed then
    pScaleH = #scale
  end if
  if tElement.getProperty(#scaleV) <> #fixed then
    pScaleV = #scale
  end if
  pElemList.add(tElement)
  return TRUE
end

on show me 
  pVisible = 1
  pSprite.visible = 1
  return TRUE
end

on hide me 
  pVisible = 0
  pSprite.visible = 0
  return TRUE
end

on moveTo me, tLocX, tLocY 
  tOffX = (tLocX - pLocX)
  tOffY = (tLocY - pLocY)
  me.moveBy(tOffX, tOffY)
end

on moveBy me, tOffX, tOffY 
  pLocX = (pLocX + tOffX)
  pLocY = (pLocY + tOffY)
  pSprite.loc = (pSprite.loc + [tOffX, tOffY])
end

on resizeBy me, tOffW, tOffH 
  if tOffW <> 0 or tOffH <> 0 then
    if (pScaleH = #fixed) then
      tOffW = 0
    else
      if (pScaleH = #scale) then
        pwidth = (pwidth + tOffW)
      else
        if (pScaleH = #move) then
          me.moveBy(tOffW, 0)
        else
          if (pScaleH = #center) then
            me.moveBy((tOffW / 2), 0)
          end if
        end if
      end if
    end if
    if pScaleH <> #scale then
      tOffW = 0
    end if
    if (pScaleH = #fixed) then
      tOffH = 0
    else
      if (pScaleH = #scale) then
        pheight = (pheight + tOffH)
      else
        if (pScaleH = #move) then
          me.moveBy(0, tOffH)
        else
          if (pScaleH = #center) then
            me.moveBy(0, (tOffH / 2))
          end if
        end if
      end if
    end if
    if pScaleV <> #scale then
      tOffH = 0
    end if
    if tOffW <> 0 or tOffH <> 0 then
      if pwidth < 1 then
        pwidth = 1
      end if
      if pheight < 1 then
        pheight = 1
      end if
      pBuffer.image = image(pwidth, pheight, pBuffer.image.depth, pPalette)
      pBuffer.regPoint = point(0, 0)
      pSprite.width = pwidth
      pSprite.height = pheight
      pSprite.stretch = 0
      call(#resizeBy, pElemList, tOffW, tOffH)
    end if
  end if
end

on getProperty me, tProp 
  if (tProp = #image) then
    return(pBuffer.image)
  else
    if (tProp = #buffer) then
      return(pBuffer)
    else
      if (tProp = #member) then
        return(pBuffer)
      else
        if (tProp = #sprite) then
          return(pSprite)
        else
          if (tProp = #scaleH) then
            return(pScaleH)
          else
            if (tProp = #scaleV) then
              return(pScaleV)
            else
              if (tProp = #locX) then
                return(pLocX)
              else
                if (tProp = #locY) then
                  return(pLocY)
                else
                  if (tProp = #locH) then
                    return(pLocX)
                  else
                    if (tProp = #locV) then
                      return(pLocY)
                    else
                      if (tProp = #locZ) then
                        return(pSprite.locZ)
                      else
                        if (tProp = #width) then
                          return(pwidth)
                        else
                          if (tProp = #height) then
                            return(pheight)
                          else
                            if (tProp = #depth) then
                              return(pBuffer.image.depth)
                            else
                              if (tProp = #color) then
                                return(pSprite.color)
                              else
                                if (tProp = #bgColor) then
                                  return(pSprite.bgColor)
                                else
                                  if (tProp = #blend) then
                                    return(pSprite.blend)
                                  else
                                    if (tProp = #ink) then
                                      return(pSprite.ink)
                                    else
                                      if (tProp = #palette) then
                                        return(pPalette)
                                      else
                                        if (tProp = #visible) then
                                          return(pVisible)
                                        else
                                          if (tProp = #cursor) then
                                            return(pSprite.cursor)
                                          else
                                            return FALSE
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

on setProperty me, tProp, tValue 
  if (tProp = #scaleH) then
    pScaleH = tValue
  else
    if (tProp = #scaleV) then
      pScaleV = tValue
    else
      if (tProp = #locX) then
        me.moveTo(tValue, pLocY)
      else
        if (tProp = #locY) then
          me.moveTo(pLocX, tValue)
        else
          if (tProp = #locH) then
            me.moveTo(tValue, pLocY)
          else
            if (tProp = #locV) then
              me.moveTo(pLocX, tValue)
            else
              if (tProp = #width) then
                me.resizeBy((pwidth - tValue), 0)
              else
                if (tProp = #height) then
                  me.resizeBy(0, (pheight - tValue))
                else
                  if (tProp = #color) then
                    pSprite.color = tValue
                  else
                    if (tProp = #bgColor) then
                      pSprite.bgColor = tValue
                    else
                      if (tProp = #blend) then
                        pSprite.blend = tValue
                      else
                        if (tProp = #ink) then
                          pSprite.ink = tValue
                        else
                          if (tProp = #cursor) then
                            pSprite.setcursor(tValue)
                          else
                            if (tProp = #image) then
                              tRegPnt = pBuffer.regPoint
                              pBuffer.image = tValue
                              pBuffer.regPoint = tRegPnt
                              pSprite.width = pBuffer.width
                              pSprite.height = pBuffer.height
                              pwidth = pBuffer.width
                              pheight = pBuffer.height
                            else
                              if tProp <> #buffer then
                                if (tProp = #member) then
                                  pBuffer = tValue
                                  pwidth = pBuffer.width
                                  pheight = pBuffer.height
                                  pPalette = pBuffer.paletteRef
                                  pSprite.castNum = pBuffer.number
                                else
                                  if (tProp = #palette) then
                                    pPalette = tValue
                                    pBuffer.image.paletteRef = pPalette
                                  else
                                    if (tProp = #depth) then
                                      tImage = pBuffer.image.duplicate()
                                      pBuffer.image = image(tImage.width, tImage.height, tValue)
                                      pBuffer.image.copyPixels(tImage, tImage.rect, tImage.rect)
                                      pBuffer.image.paletteRef = pPalette
                                    else
                                      if (tProp = #visible) then
                                        if (tValue = 1) then
                                          me.show()
                                        else
                                          me.hide()
                                        end if
                                      else
                                        return FALSE
                                      end if
                                    end if
                                  end if
                                end if
                                return TRUE
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
        end if
      end if
    end if
  end if
end

on prepare me 
  call(#prepare, pElemList)
end

on render me 
  if pVisible then
    call(#render, pElemList)
  end if
end

on draw me, tRGB 
  call(#draw, pElemList, tRGB)
end
