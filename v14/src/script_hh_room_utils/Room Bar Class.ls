property pBottomBarId, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pFloodblocking, pFloodTimer, pFloodEnterCount



on construct me 

  pBottomBarId = "RoomBarID"

  pFloodblocking = 0

  pMessengerFlash = 0

  pFloodTimer = 0

  pNewMsgCount = 0

  pNewBuddyReq = 0

  pFloodEnterCount = 0

  registerMessage(#notify, me.getID(), #notify)

  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)

  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)

  registerMessage(#soundSettingChanged, me.getID(), #updateSoundButton)

  return TRUE

end



on deconstruct me 

  unregisterMessage(#notify, me.getID())

  unregisterMessage(#updateMessageCount, me.getID())

  unregisterMessage(#updateBuddyrequestCount, me.getID())

  unregisterMessage(#objectFinalized, me.getID())

  unregisterMessage(#soundSettingChanged, me.getID())

  return TRUE

end



on showRoomBar me 

  if not windowExists(pBottomBarId) then

    createWindow(pBottomBarId, "empty.window", 0, 487)

  end if

  tWndObj = getWindow(pBottomBarId)

  if (tWndObj = 0) then

    return FALSE

  end if

  tWndObj.lock(1)

  tWndObj.unmerge()

  if getThread(#room).getComponent().getSpectatorMode() then

    tLayout = "room_bar_spectator.window"

  else

    tLayout = "room_bar.window"

  end if

  if not tWndObj.merge(tLayout) then

    return FALSE

  end if

  tWndObj.registerClient(me.getID())

  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)

  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)

  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)

  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)

  me.updateSoundButton()

  executeMessage(#messageUpdateRequest)

  executeMessage(#buddyUpdateRequest)

  return TRUE

end



on hideRoomBar me 

  if timeoutExists(#flash_messenger_icon) then

    removeTimeout(#flash_messenger_icon)

  end if

  if windowExists(pBottomBarId) then

    removeWindow(pBottomBarId)

  end if

end



on setSpeechDropdown me, tMode 

  tWndObj = getWindow(pBottomBarId)

  if (tWndObj = 0) then

    return TRUE

  end if

  tElem = tWndObj.getElement("int_speechmode_dropmenu")

  if (tElem = 0) then

    return TRUE

  end if

  tElem.setSelection(tMode, 1)

  return TRUE

end



on setRollOverInfo me, tInfo 

  tWndObj = getWindow(pBottomBarId)

  if tWndObj.elementExists("room_tooltip_text") then

    tWndObj.getElement("room_tooltip_text").setText(tInfo)

  end if

end



on updateMessageCount me, tMsgCount 

  if windowExists(pBottomBarId) then

    pNewMsgCount = value(tMsgCount)

    me.flashMessengerIcon()

  end if

  return TRUE

end



on updateBuddyrequestCount me, tReqCount 

  if windowExists(pBottomBarId) then

    pNewBuddyReq = value(tReqCount)

    me.flashMessengerIcon()

  end if

  return TRUE

end



on flashMessengerIcon me 

  tWndObj = getWindow(pBottomBarId)

  if (tWndObj = 0) then

    return FALSE

  end if

  if not tWndObj.elementExists("int_messenger_image") then

    return FALSE

  end if

  if pMessengerFlash then

    tmember = "mes_lite_icon"

    pMessengerFlash = 0

  else

    tmember = "mes_dark_icon"

    pMessengerFlash = 1

  end if

  if (pNewMsgCount = 0) and (pNewBuddyReq = 0) then

    tmember = "mes_dark_icon"

    if timeoutExists(#flash_messenger_icon) then

      removeTimeout(#flash_messenger_icon)

    end if

  else

    if pNewMsgCount > 0 then

      if not timeoutExists(#flash_messenger_icon) then

        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)

      end if

    else

      tmember = "mes_lite_icon"

      if timeoutExists(#flash_messenger_icon) then

        removeTimeout(#flash_messenger_icon)

      end if

    end if

  end if

  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))

  return TRUE

end



on updateSoundButton me 

  tWndObj = getWindow(pBottomBarId)

  if (tWndObj = 0) then

    return FALSE

  end if

  tstate = getSoundState()

  tElem = tWndObj.getElement("int_sound_image")

  if tElem <> 0 then

    if tstate then

      tMemNum = getmemnum("sounds_on_icon")

      if tMemNum > 0 then

        tElem.feedImage(member(tMemNum).image)

      end if

    else

      tMemNum = getmemnum("sounds_off_icon")

      if tMemNum > 0 then

        tElem.feedImage(member(tMemNum).image)

      end if

    end if

  end if

  tElem = tWndObj.getElement("int_sound_bg_image")

  if tElem <> 0 then

    if tstate then

      tMemNum = getmemnum("sounds_on_icon_sd")

      if tMemNum > 0 then

        tElem.feedImage(member(tMemNum).image)

      end if

    else

      tMemNum = getmemnum("sounds_off_icon_sd")

      if tMemNum > 0 then

        tElem.feedImage(member(tMemNum).image)

      end if

    end if

  end if

end



on eventProcRoomBar me, tEvent, tSprID, tParam 

  if (tEvent = #keyDown) and (tSprID = "chat_field") then

    tChatField = getWindow(pBottomBarId).getElement(tSprID)

    if the commandDown and (the keyCode = 8) or (the keyCode = 9) then

      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then

        tChatField.setText("")

        return TRUE

      end if

    end if

    if the keyCode <> 36 then

      if (the keyCode = 76) then

        if (tChatField.getText() = "") then

          return TRUE

        end if

        if pFloodblocking then

          if the milliSeconds < pFloodTimer then

            return FALSE

          else

            pFloodEnterCount = void()

          end if

        end if

        if voidp(pFloodEnterCount) then

          pFloodEnterCount = 0

          pFloodblocking = 0

          pFloodTimer = the milliSeconds

        else

          pFloodEnterCount = (pFloodEnterCount + 1)

          if pFloodEnterCount > 2 then

            if the milliSeconds < (pFloodTimer + 3000) then

              tChatField.setText("")

              createObject("FloodBlocking", "Flood Blocking Class")

              getObject("FloodBlocking").Init(pBottomBarId, tSprID, 30000)

              pFloodblocking = 1

              pFloodTimer = (the milliSeconds + 30000)

            else

              pFloodEnterCount = void()

            end if

          end if

        end if

        getThread(#room).getComponent().sendChat(tChatField.getText())

        tChatField.setText("")

        return TRUE

      else

        if (the keyCode = 117) then

          tChatField.setText("")

        end if

      end if

      return FALSE

      if (getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100) then

        if (tSprID = "int_help_image") then

          if (tEvent = #mouseUp) then

            executeMessage(#openGeneralDialog, #help)

          end if

          if (tEvent = #mouseEnter) then

            tInfo = getText("interface_icon_help", "interface_icon_help")

            me.setRollOverInfo(tInfo)

          else

            if (tEvent = #mouseLeave) then

              me.setRollOverInfo("")

            end if

          end if

        else

          if (tSprID = "int_hand_image") then

            if (tEvent = #mouseUp) then

              getThread(#room).getInterface().getContainer().openClose()

            end if

            if (tEvent = #mouseEnter) then

              tInfo = getText("interface_icon_hand", "interface_icon_hand")

              me.setRollOverInfo(tInfo)

            else

              if (tEvent = #mouseLeave) then

                me.setRollOverInfo("")

              end if

            end if

          else

            if (tSprID = "int_brochure_image") then

              if (tEvent = #mouseUp) then

                executeMessage(#show_hide_catalogue)

              end if

              if (tEvent = #mouseEnter) then

                tInfo = getText("interface_icon_catalog", "interface_icon_catalog")

                me.setRollOverInfo(tInfo)

              else

                if (tEvent = #mouseLeave) then

                  me.setRollOverInfo("")

                end if

              end if

            else

              if (tSprID = "int_purse_image") then

                if (tEvent = #mouseUp) then

                  executeMessage(#openGeneralDialog, #purse)

                end if

                if (tEvent = #mouseEnter) then

                  tInfo = getText("interface_icon_purse", "interface_icon_purse")

                  me.setRollOverInfo(tInfo)

                else

                  if (tEvent = #mouseLeave) then

                    me.setRollOverInfo("")

                  end if

                end if

              else

                if (tSprID = "int_nav_image") then

                  if (tEvent = #mouseUp) then

                    executeMessage(#show_hide_navigator)

                  end if

                  if (tEvent = #mouseEnter) then

                    tInfo = getText("interface_icon_navigator", "interface_icon_navigator")

                    me.setRollOverInfo(tInfo)

                  else

                    if (tEvent = #mouseLeave) then

                      me.setRollOverInfo("")

                    end if

                  end if

                else

                  if (tSprID = "int_messenger_image") then

                    if (tEvent = #mouseUp) then

                      executeMessage(#show_hide_messenger)

                    end if

                    if (tEvent = #mouseEnter) then

                      tInfo = getText("interface_icon_messenger", "interface_icon_messenger")

                      me.setRollOverInfo(tInfo)

                    else

                      if (tEvent = #mouseLeave) then

                        me.setRollOverInfo("")

                      end if

                    end if

                  else

                    if (tSprID = "int_hand_image") then

                      if (tEvent = #mouseUp) then

                        getThread(#room).getInterface().getContainer().openClose()

                      end if

                    else

                      if (tSprID = "get_credit_text") then

                        if (tEvent = #mouseUp) then

                          executeMessage(#openGeneralDialog, #purse)

                        end if

                      else

                        if (tSprID = "int_speechmode_dropmenu") then

                          if (tEvent = #mouseUp) then

                            getThread(#room).getComponent().setChatMode(tParam)

                          end if

                        else

                          if (tSprID = "int_tv_close") then

                            if (tEvent = #mouseUp) then

                              getThread(#room).getComponent().setSpectatorMode(0)

                            end if

                            if (tEvent = #mouseEnter) then

                              tInfo = getText("interface_icon_tv_close")

                              me.setRollOverInfo(tInfo)

                            else

                              if (tEvent = #mouseLeave) then

                                me.setRollOverInfo("")

                              end if

                            end if

                          else

                            if tSprID <> "int_sound_image" then

                              if (tSprID = "int_sound_bg_image") then

                                if (tEvent = #mouseUp) then

                                  setSoundState(not getSoundState())

                                  getThread(#room).getComponent().getRoomConnection().send("SET_SOUND_SETTING", [#integer:getSoundState()])

                                  me.updateSoundButton()

                                end if

                                if (tEvent = #mouseEnter) then

                                  tInfo = getText("interface_icon_sound", "interface_icon_sound")

                                  me.setRollOverInfo(tInfo)

                                else

                                  if (tEvent = #mouseLeave) then

                                    me.setRollOverInfo("")

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

