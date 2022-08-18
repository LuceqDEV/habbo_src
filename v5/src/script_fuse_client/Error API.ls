on constructErrorManager  
  if objectp(gError) then
    return(gError)
  end if
  tClass = value(convertToPropList(field(0), "\r").getAt("error.manager.class")).getAt(1)
  gError = script(tClass).new()
  gError.construct()
  try()
  createObject(#error_manager, gError)
  catch()
  return(gError)
end

on deconstructErrorManager  
  if not objectp(gError) then
    return FALSE
  end if
  gError.deconstruct()
  gError = void()
  return TRUE
end

on getErrorManager  
  if not objectp(gError) then
    return(constructErrorManager())
  end if
  return(gError)
end

on error tObject, tMsg, tMethod 
  return(getErrorManager().error(tObject, tMsg, tMethod))
end

on SystemAlert tObject, tMsg, tMethod 
  return(getErrorManager().SystemAlert(tObject, tMsg, tMethod))
end

on setDebugLevel tLevel 
  return(getErrorManager().setDebugLevel(tLevel))
end

on printErrors  
  return(getErrorManager().print())
end
