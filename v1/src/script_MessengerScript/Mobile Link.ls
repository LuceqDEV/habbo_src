on beginSprite me 
  if gPhonenumberOk then
    sprite(me.spriteNum).member.text = AddTextToField("MobilePhoneLinkActive")
  else
    sprite(me.spriteNum).member.text = AddTextToField("MobilePhoneLinkInactive")
  end if
end
