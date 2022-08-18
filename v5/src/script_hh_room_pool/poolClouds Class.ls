property pClouds

on construct me 
  pClouds = [:]
  f = 1
  repeat while f <= 4
    pClouds.addProp("pilvi" & f, createObject(#temp, "Pelle Cloud Class"))
    tSprite = getVisualizer(#pooltower).getSprById("pilvi" & f)
    tStartPointX = [711, 888, 515, 318].getAt(f)
    pClouds.getAt("pilvi" & f).prepare(tSprite, tStartPointX)
    f = (1 + f)
  end repeat
  return(receivePrepare(me.getID()))
end

on deconstruct me 
  pClouds = void()
  removePrepare(me.getID())
  return TRUE
end

on prepare me 
  call(#update, pClouds)
end
