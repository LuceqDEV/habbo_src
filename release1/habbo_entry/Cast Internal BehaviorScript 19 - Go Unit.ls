property num
global gUnits, gChosenUnitIp, gChosenUnitPort

on beginSprite me
  sprite(me.spriteNum).visible = 0
end

on exitFrame me
  if getmyUnit(me) = VOID then
    sprite(me.spriteNum).visible = 0
  else
    sprite(me.spriteNum).visible = 1
  end if
end

on endSprite me
  sprite(me.spriteNum).visible = 1
end

on getmyUnit me
  if voidp(gUnits) then
    return 
  end if
  repeat with l in gUnits
    if num = l[5] then
      return l
    end if
  end repeat
  return VOID
end

on mouseDown me
  if voidp(gUnits) then
    return 
  end if
  unit = getmyUnit(me)
  if unit <> VOID then
    host = unit[3]
    gChosenUnitIp = char offset("/", host) + 1 to host.length of host
    gChosenUnitPort = unit[4]
    goUnit(unit[6])
  end if
end

on getPropertyDescriptionList me
  return [#num: [#comment: "Num", #format: #integer, #default: 1]]
end
