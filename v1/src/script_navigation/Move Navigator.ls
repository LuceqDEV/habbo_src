property lastm, dragOn, context

on exitFrame me
  if (the mouseDown and dragOn) then
    p = (the mouseLoc - lastm)
    if (p <> point(0, 0)) then
      context = getaProp(me, #context)
      if (context <> VOID) then
        move(context, p[1], p[2])
      end if
      lastm = the mouseLoc
    end if
  else
    dragOn = 0
  end if
end

on mouseDown me
  dragOn = 1
  lastm = the mouseLoc
end
