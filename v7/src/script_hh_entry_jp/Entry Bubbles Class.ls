on construct(me)
  pBubblesImg = image(132, 336, 32)
  pMaskMember = member(getmemnum("hoteltubemask"))
  pCanvMember = member(getmemnum("bubbles_canvas"))
  pCanvMember.image = image(132, 328, 32)
  i = 1
  repeat while i <= 150
    tBubble = member("bubble" & random(3)).image
    tLocH = random(132)
    tLocV = random(336)
    tDrawLoc = tBubble.rect + rect(tLocH, tLocV, tLocH, tLocV)
    pBubblesImg.copyPixels(tBubble, tDrawLoc, tBubble.rect, [#ink:36])
    i = 1 + i
  end repeat
  me.updateMember()
  pLastUpdate = the milliSeconds
  return(1)
  exit
end

on update(me)
  if the milliSeconds - pLastUpdate > 66 then
    if random(4) > 1 then
      tBubble = member("bubble" & random(3)).image
      tLocH = random(132)
      tDrawLoc = tBubble.rect + rect(tLocH, 330, tLocH, 330)
      pBubblesImg.copyPixels(tBubble, tDrawLoc, tBubble.rect, [#ink:36, #blendLevel:random(2) * 128])
    end if
    pBubblesImg.copyPixels(pBubblesImg, rect(0, 0, 132, 334), rect(0, 2, 132, 336), [#ink:0])
    pBubblesImg.fill(0, 334, 132, 336, rgb(255, 255, 255))
    me.updateMember()
    pLastUpdate = the milliSeconds
  end if
  exit
end

on updateMember(me)
  image.copyPixels(pBubblesImg, pBubblesImg.rect, pBubblesImg.rect, [#ink:0, #maskImage:pMaskMember.image])
  exit
end