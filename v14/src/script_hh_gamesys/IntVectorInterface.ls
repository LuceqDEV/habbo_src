on initIntVector()
  G_IntVectorScript = script("CIntVector")
  exit
end

on intvector(a_iX, a_iY, a_iZ)
  return(G_IntVectorScript.new(a_iX, a_iY, a_iZ))
  exit
end