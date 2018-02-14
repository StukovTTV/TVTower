SuperStrict
Import "Dig/base.gfx.gui.checkbox.bmx"
Import "Dig/base.gfx.gui.button.bmx"
Import "Dig/base.gfx.gui.list.selectlist.bmx"
Import "common.misc.gamegui.bmx"
Import "game.screen.base.bmx"
Import "game.stationmap.bmx"
Import "game.player.bmx"
Import "game.room.base.bmx"
Import "game.roomhandler.base.bmx"




Type TGameGUIBasicStationmapPanel Extends TGameGUIAccordeonPanel
'	Field selectedStation:TStationBase
	Field list:TGUISelectList
	Field renewButton:TGUIButton
	Field renewInfoButton:TGUIButton
	Field actionButton:TGUIButton
	Field cancelButton:TGUIButton
	Field tooltips:TTooltipBase[]

	Field listExtended:Int = False
	Field detailsBackgroundH:Int
	Field listBackgroundH:Int
	Field localeKey_NewItem:String = "NEW_ITEM"
	Field localeKey_BuyItem:String = "BUY_ITEM"
	Field localeKey_SellItem:String = "SELL_ITEM"
	
	Field _eventListeners:TLink[]
	Global headerColor:TColor = New TColor.Create(75,75,75)
	Global subHeaderColor:TColor = New TColor.Create(115,115,115)


	Method Create:TGameGUIBasicStationmapPanel(pos:TVec2D, dimension:TVec2D, value:String, State:String = "")
		Super.Create(pos, dimension, value, State)

		actionButton = New TGUIButton.Create(New TVec2D.Init(0, 0), New TVec2D.Init(150, 28), "", "STATIONMAP")
		actionButton.spriteName = "gfx_gui_button.datasheet"

		renewButton = New TGUIButton.Create(New TVec2D.Init(0, 0), New TVec2D.Init(150, 28), "", "STATIONMAP")
		renewButton.spriteName = "gfx_gui_button.datasheet"

		renewInfoButton = New TGUIButton.Create(New TVec2D.Init(145, 0), New TVec2D.Init(30, 28), "i", "STATIONMAP")
		renewInfoButton.caption.color = TColor.clBlue.copy()
		renewInfoButton.spriteName = "gfx_gui_button.datasheet"

		cancelButton = New TGUIButton.Create(New TVec2D.Init(145, 0), New TVec2D.Init(30, 28), "X", "STATIONMAP")
		cancelButton.caption.color = TColor.clRed.copy()
		cancelButton.spriteName = "gfx_gui_button.datasheet"

		list = New TGUISelectList.Create(New TVec2D.Init(610,133), New TVec2D.Init(178, 100), "STATIONMAP")
		'scroll by one entry at a time
		list.scrollItemHeightPercentage = 1.0
		list.SetListOption(GUILIST_SCROLL_TO_NEXT_ITEM, True)


		cancelButton.SetParent(Self)
		actionButton.SetParent(Self)
		renewInfoButton.SetParent(Self)
		renewButton.SetParent(Self)
		list.SetParent(Self)

		'panel handles them (similar to a child - but with manual draw/update calls)
		GuiManager.Remove(cancelButton)
		GuiManager.Remove(actionButton)
		GuiManager.Remove(renewInfoButton)
		GuiManager.Remove(renewButton)
		GuiManager.Remove(list)


		tooltips = New TTooltipBase[5]
		For Local i:Int = 0 Until tooltips.length
			tooltips[i] = New TGUITooltipBase.Initialize("", "", New TRectangle.Init(0,0,-1,-1))
			tooltips[i].parentArea = New TRectangle
			tooltips[i].SetOrientationPreset("TOP")
			tooltips[i].offset = New TVec2D.Init(0,+5)
			tooltips[i].SetOption(TGUITooltipBase.OPTION_PARENT_OVERLAY_ALLOWED)
			'standard icons should need a bit longer for tooltips to show up
			tooltips[i].dwellTime = 500
		Next


		'=== remove all registered event listeners
		EventManager.unregisterListenersByLinks(_eventListeners)
		_eventListeners = New TLink[0]

		'=== register event listeners
		_eventListeners :+ [ EventManager.registerListenerMethod( "guiobject.onClick", Self, "OnClickCancelButton", cancelButton ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "guiobject.onClick", Self, "OnClickActionButton", actionButton ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "guiobject.onClick", Self, "OnClickRenewButton", renewButton ) ]
		'localize the button
		'we have to refresh the gui station list as soon as we remove or add a station
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.removeStation", OnChangeStationMapStation ) ]
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.addStation", OnChangeStationMapStation ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "GUISelectList.onSelectEntry", Self, "OnSelectEntryList", list ) ]

		Return Self
	End Method


	Method SetLanguage()
		Local strings:String[] = [GetLocale("REACH"), GetLocale("Increase"), GetLocale("CONSTRUCTION_TIME"), GetLocale("RUNNING_COSTS"), GetLocale("PRICE")]
		strings = strings[.. tooltips.length]

		For Local i:Int = 0 Until tooltips.length
			If tooltips[i] Then tooltips[i].SetContent(strings[i])
		Next
	End Method


	Method OnClickActionButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		if TScreenHandler_StationMap.mapInformationFrame
			'ignore clicks as long as map info screen is shown ?
			'if TScreenHandler_StationMap.mapInformationFrame.IsOpen() Then Return False

			'or close window
			if TScreenHandler_StationMap.mapInformationFrame.IsOpen() Then TScreenHandler_StationMap.mapInformationFrame.Close()
		endif


		If TScreenHandler_StationMap.IsInBuyActionMode()
			If TScreenHandler_StationMap.selectedStation And TScreenHandler_StationMap.selectedStation.GetReach() > 0
				'add the station (and buy it)
				If GetStationMap( GetPlayerBase().playerID ).AddStation(TScreenHandler_StationMap.selectedStation, True)
					ResetActionMode(TScreenHandler_StationMap.MODE_NONE)
				EndIf
			EndIf

		ElseIf TScreenHandler_StationMap.IsInSellActionMode()
			'do not check reach - to allow selling "unused transmitters" / unconnected uplinks
			If TScreenHandler_StationMap.selectedStation 'And TScreenHandler_StationMap.selectedStation.GetReach() > 0
				'remove the station (and sell it)
				If GetStationMap( GetPlayerBase().playerID ).RemoveStation(TScreenHandler_StationMap.selectedStation, True)
					ResetActionMode(TScreenHandler_StationMap.MODE_NONE)
				EndIf
			EndIf

		Else
			'open up satellite selection frame for the satellite link panel
			If GetBuyActionMode() = TScreenHandler_StationMap.MODE_BUY_SATELLITE_UPLINK
				TScreenHandler_StationMap.satelliteSelectionFrame.Open()
			EndIf

			ResetActionMode( GetBuyActionMode() )
		EndIf

		Return True
	End Method


	Method OnClickCancelButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		ResetActionMode(TScreenHandler_StationMap.MODE_NONE)
	End Method


	Method OnClickRenewButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		'try to renew a contract
		TScreenHandler_StationMap.selectedStation.RenewContract(12 * TWorldTime.DAYLENGTH)
	End Method
	

	'an entry was selected - make the linked station the currently selected station
	Method OnSelectEntryList:Int(triggerEvent:TEventBase)
		Local senderList:TGUISelectList = TGUISelectList(triggerEvent._sender)
		If Not senderList Then Return False
		If Not TScreenHandler_StationMap.currentSubRoom Then Return False
		If Not TScreenHandler_StationMap.currentSubRoom Or Not GetPlayerBaseCollection().IsPlayer(TScreenHandler_StationMap.currentSubRoom.owner) Then Return False

		'set the linked station as selected station
		'also set the stationmap's userAction so the map knows we want to sell
		Local item:TGUISelectListItem = TGUISelectListItem(senderList.getSelectedEntry())
		If item
			TScreenHandler_StationMap.selectedStation = TStationBase(item.data.get("station"))
			If TScreenHandler_StationMap.selectedStation
				'force stat refresh (so we can display decrease properly)!
				TScreenHandler_StationMap.selectedStation.GetReachDecrease(True)
			EndIf

			SetActionMode( GetSellActionMode() )

			'close potentially open item
			'if TScreenHandler_StationMap.mapInformationFrame.IsOpen() Then TScreenHandler_StationMap.mapInformationFrame.Close()
		EndIf
	End Method


	Method SetActionMode(mode:Int)
		TScreenHandler_StationMap.SetActionMode(mode)
	End Method


	Method ResetActionMode(mode:Int=0)
		TScreenHandler_StationMap.ResetActionMode(mode)

		'remove selection
		TScreenHandler_StationMap.selectedStation = Null

		'reset gui list
		list.deselectEntry()
	End Method


	Method GetBuyActionMode:Int()
		Return TScreenHandler_StationMap.MODE_NONE
	End Method


	Method GetSellActionMode:Int()
		Return TScreenHandler_StationMap.MODE_NONE
	End Method


	Method RefreshList(playerID:Int=-1)
		If playerID <= 0 Then playerID = GetPlayerBase().playerID

		'first fill of stationlist
		list.EmptyList()
		'remove potential highlighted item
		list.deselectEntry()

		'keep them sorted the way we added the stations
		list.setListOption(GUILIST_AUTOSORT_ITEMS, False)
	End Method


	'override to resize list accordingly
	Method onStatusAppearanceChange:Int()
		Super.onStatusAppearanceChange()

		list.Resize(GetContentScreenWidth()- 2, -1)
	End Method
	

	Method Update:Int()
		If isOpen
			'move list to here...
			If list.rect.position.GetX() <> 2
				list.SetPosition(2, GetHeaderHeight() + 3 )
'local tt:TTypeID = TTypeId.ForObject(self)
'print tt.name() + "   " + GetContentScreenWidth()
				'list.rect.dimension.SetX(GetContentScreenWidth() - 23)
				'resizing is done when status changes
'				list.Resize(GetContentScreenWidth() - 23, -1)
			EndIf

			'adjust list size if needed
			Local listH:Int = listBackgroundH - 6
			If listBackgroundH > 0 And list.GetHeight() <> listH
				list.Resize(-1, listH)
'				list.RecalculateElements()
			EndIf

			
			renewButton.SetPosition(5, GetHeaderHeight() + GetBodyHeight() - 34 - 30 )
			renewInfoButton.SetPosition(5 + 150, GetHeaderHeight() + GetBodyHeight() - 34 - 30 )
			actionButton.SetPosition(5, GetHeaderHeight() + GetBodyHeight() - 34 )
			cancelButton.SetPosition(5 + 150, GetHeaderHeight() + GetBodyHeight() - 34 )

			UpdateActionButton()

			list.Update()
			renewButton.Update()
			renewInfoButton.Update()
			actionButton.Update()
			cancelButton.Update()
		EndIf


		'update count in title
		If TScreenHandler_StationMap.currentSubRoom 
			SetValue( GetHeaderValue() )
		EndIf


		For Local t:TTooltipBase = EachIn tooltips
			t.Update()
		Next


		'call update after button updates so mouse events are properly
		'emitted
		Super.Update()
	End Method


	Method UpdateActionButton:Int()
		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		If TScreenHandler_StationMap.IsInBuyActionMode()
			If Not TScreenHandler_StationMap.selectedStation
				If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_BUY_SATELLITE_UPLINK
					actionButton.SetValue(GetLocale("SELECT_SATELLITE")+" ...")
				Else
					actionButton.SetValue(GetLocale("SELECT_LOCATION")+" ...")
				EndIf
				actionButton.disable()
			Else
				Local finance:TPlayerFinance = GetPlayerFinance(GetPlayerBase().playerID)
				If finance And finance.canAfford(TScreenHandler_StationMap.selectedStation.GetPrice())
					actionButton.SetValue(GetLocale( localeKey_BuyItem))
					actionButton.enable()
				Else
					actionButton.SetValue(GetLocale("TOO_EXPENSIVE"))
					actionButton.disable()
				EndIf
			EndIf

		ElseIf TScreenHandler_StationMap.IsInSellActionMode()
			'different owner or not paid or not sellable
			If TScreenHandler_StationMap.selectedStation
				If TScreenHandler_StationMap.selectedStation.owner <> GetPlayerBase().playerID
					actionButton.SetValue(GetLocale("WRONG_PLAYER"))
					actionButton.disable()
				ElseIf Not TScreenHandler_StationMap.selectedStation.HasFlag(TVTStationFlag.SELLABLE)
					actionButton.SetValue(GetLocale("UNSELLABLE"))
					actionButton.disable()
				ElseIf Not TScreenHandler_StationMap.selectedStation.HasFlag(TVTStationFlag.PAID)
					actionButton.SetValue(GetLocale( localeKey_SellItem ))
					actionButton.disable()
				Else
					actionButton.SetValue(GetLocale( localeKey_SellItem ))
					actionButton.enable()
				EndIf
			EndIf

		Else
			actionButton.SetValue(GetLocale( localeKey_NewItem ))
			actionButton.enable()
		EndIf

		Return True
	End Method


	'override
	Method DrawBody()
		'draw nothing if not open
		If Not isOpen Then Return

		
		Local skin:TDatasheetSkin = GetSkin()
		If skin
			Local contentX:Int = GetScreenX()
			Local contentY:Int = GetScreenY()
			Local contentW:Int = GetScreenWidth()
			Local currentY:Int = contentY + GetHeaderHeight()


			DrawBodyContent(contentX, contentY, contentW, currentY)


			If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_NONE
				renewButton.Hide()
				renewInfoButton.Hide()
				cancelButton.Hide()
				renewButton.Resize(contentW - 10, -1)
				actionButton.Resize(contentW - 10, -1)
			Else
				renewButton.Resize(150, -1)
				actionButton.Resize(150, -1)
				cancelButton.Show()
			EndIf

		EndIf

		list.Draw()
		renewInfoButton.Draw()
		renewButton.Draw()
		actionButton.Draw()
		cancelButton.Draw()


		if TScreenHandler_StationMap.actionMode <> TScreenHandler_StationMap.MODE_NONE
			For Local t:TTooltipBase = EachIn tooltips
				t.Render()
			Next
		endif
	End Method


	Method DrawBodyContent(contentX:Int, contentY:Int, contentW:Int, contentH:Int)
		'by default draw nothing
	End Method
End Type




Type TGameGUIAntennaPanel Extends TGameGUIBasicStationmapPanel
	Method Create:TGameGUIAntennaPanel(pos:TVec2D, dimension:TVec2D, value:String, State:String = "")
		Super.Create(pos, dimension, value, State)

		localeKey_NewItem = "NEW_STATION"
		localeKey_BuyItem = "BUY_STATION"
		localeKey_SellItem = "SELL_STATION"

		'=== register custom event listeners
		'localize the button
		'we have to refresh the gui station list as soon as we remove or add a station
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.removeStation", OnChangeStationMapStation ) ]
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.addStation", OnChangeStationMapStation ) ]

		Return Self
	End Method


	'override
	Method GetBuyActionMode:Int()
		Return TScreenHandler_StationMap.MODE_BUY_ANTENNA
	End Method


	'override
	Method GetSellActionMode:Int()
		Return TScreenHandler_StationMap.MODE_SELL_ANTENNA
	End Method


	'===================================
	'EVENTS: Connect GUI elements
	'===================================


	'rebuild the stationList - eg. when changed the room (other office)
	Method RefreshList(playerID:Int=-1)
		Super.RefreshList(playerID)

		If playerID <= 0 Then playerID = GetPlayerBase().playerID

		Local listContentWidth:Int = list.GetContentScreenWidth()
		For Local station:TStationAntenna = EachIn GetStationMap(playerID).Stations
			Local item:TGUISelectListItem = New TGUISelectListItem.Create(New TVec2D, New TVec2D.Init(listContentWidth,20), station.GetLongName())
			'fill complete width
			item.SetListItemOption(GUILISTITEM_AUTOSIZE_WIDTH, True)
			'link the station to the item
			item.data.Add("station", station)
			item._customDrawContent = TScreenHandler_StationMap.DrawMapStationListEntryContent
			list.AddItem( item )
		Next
	End Method


	Method GetHeaderValue:String()
		If TScreenHandler_StationMap.currentSubRoom And GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner)
			Return GetLocale( "STATIONS" ) + ": " + GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner).GetStationCount(TVTStationType.ANTENNA)
		Else
			Return GetLocale( "STATIONS" ) + ": -/-"
		EndIf
	End Method


	Method DrawBodyContent(contentX:Int,contentY:Int,contentW:Int,currentY:Int)
		Local skin:TDatasheetSkin = GetSkin()
		If Not skin Then Return

		Local section:TStationMapSection
		If TScreenHandler_StationMap.selectedStation Then section = GetStationMapCollection().GetSectionByName(TScreenHandler_StationMap.selectedStation.GetSectionName())

		Local boxH:Int = skin.GetBoxSize(100, -1, "").GetY()
		Local boxAreaH:Int = 0
		Local showDetails:Int = False
		Local showPermissionText:Int = False
		Local permissionTextH:int = 24
		'only show when buying/looking for a new
		If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_BUY_ANTENNA 
			If TScreenHandler_StationMap.selectedStation And section And section.NeedsBroadcastPermission(TScreenHandler_StationMap.selectedStation.owner, TVTStationType.SATELLITE_UPLINK)
				showPermissionText = True
			EndIf
		EndIf
		If TScreenHandler_StationMap.selectedStation Then showDetails = True
		If TScreenHandler_StationMap.actionMode = GetSellActionMode() Then showDetails = True
		If TScreenHandler_StationMap.actionMode = GetBuyActionMode() Then showDetails = True

		'update information
		detailsBackgroundH = actionButton.GetScreenHeight() + 2*6 + (showDetails<>False)*(24 + (boxH+2)*2) + showPermissionText * permissionTextH
		
		listBackgroundH = GetBodyHeight() - detailsBackgroundH
		
		skin.RenderContent(contentX, currentY, contentW, listBackgroundH, "2")
		skin.RenderContent(contentX, currentY + listBackgroundH, contentW, detailsBackgroundH, "1_top")


		'=== LIST ===
		currentY :+ listBackgroundH
	

		'=== BOXES ===
		If TScreenHandler_StationMap.actionMode <> TScreenHandler_StationMap.MODE_NONE
			Local price:String = "", reach:String = "", reachChange:String = "", runningCost:String =""
			Local headerText:String
			Local subHeaderText:String
			Local canAfford:Int = True
			Local selectedStation:TStationBase = TScreenHandler_StationMap.selectedStation

			Select TScreenHandler_StationMap.actionMode
				Case TScreenHandler_StationMap.MODE_SELL_ANTENNA
					If selectedStation
						headerText = selectedStation.GetLongName()
						'fix incorrect built (eg. code-tests with station ads before worldtime is set)
						if selectedStation.built = 0 then selectedStation.built = GetWorldTime().GetTimeStart()
						subHeaderText = GetWorldTime().GetFormattedGameDate(selectedStation.built)
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
						reachChange = MathHelper.DottedValue( -1 * selectedStation.GetReachDecrease() )
						price = TFunctions.convertValue(selectedStation.GetSellPrice(), 2, 0)
						If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
							runningCost = "-/-"
						Else
							runningCost = TFunctions.convertValue(selectedStation.GetCurrentRunningCosts(), 2, 0)
						EndIf
					EndIf

				Case TScreenHandler_StationMap.MODE_BUY_ANTENNA
					headerText = GetLocale( localeKey_NewItem )

					'=== BOXES ===
					If selectedStation
						local totalPrice:int = GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner).GetTotalStationBuyPrice(selectedStation)

						subHeaderText = GetLocale("MAP_COUNTRY_"+selectedStation.GetSectionName())

						'stationName = Koordinaten?
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
						reachChange = MathHelper.DottedValue(selectedStation.GetReachIncrease())
						price = TFunctions.convertValue( totalPrice, 2, 0)
						If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
							runningCost = "-/-"
						Else
							runningCost = TFunctions.convertValue(selectedStation.GetRunningCosts(), 2, 0)
						EndIf

						Local finance:TPlayerFinance = GetPlayerFinance(TScreenHandler_StationMap.currentSubRoom.owner)
						canAfford = (Not finance Or finance.canAfford(totalPrice))
					EndIf
			End Select


			currentY :+ 2
			skin.fontNormal.drawBlock("|b|"+headerText+"|/b|", contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, headerColor, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
			'currentY :+ skin.fontNormal._fSize
			currentY :+ 14
			skin.fontNormal.drawBlock(subHeaderText, contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			currentY :+ 15 + 3


			Local halfW:Int = (contentW - 10)/2 - 2
			'=== BOX LINE 1 ===
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, reach, "audience", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_BUY
				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, reachChange, "audienceIncrease", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			Else
				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, reachChange, "audienceIncrease", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER, "bad")
			EndIf
			tooltips[0].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[1].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)


			'=== BOX LINE 2 (optional) ===
			tooltips[2].parentArea.SetXY(-1000,0)
			If TScreenHandler_StationMap.actionMode = GetBuyActionMode()
				'TODO: individual build time for stations ("GetStationConstructionTime()")?
				If GameRules.stationConstructionTime > 0
					currentY :+ boxH
					skin.RenderBox(contentX + 5, currentY, halfW-5, -1, GameRules.stationConstructionTime + "h", "runningTime", "neutral", skin.fontNormal)
					tooltips[2].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
				EndIf
			EndIf

			'=== BOX LINE 3 ===
			currentY :+ boxH
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, runningCost, "moneyRepetitions", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_SELL_ANTENNA
				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER)
			Else
				'fetch financial state of room owner (not player - so take care
				'if the player is allowed to do this)
				If canAfford
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER)
				Else
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER,"bad")
				EndIf
			EndIf
			tooltips[3].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[4].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)

			currentY :+ boxH

			If showPermissionText And section And selectedStation
				If Not section.HasBroadcastPermission(selectedStation.owner)
					skin.fontNormal.drawBlock(getLocale("PRICE_INCLUDES_X_FOR_BROADCAST_PERMISSION").Replace("%X%", "|b|"+TFunctions.convertValue(section.GetBroadcastPermissionPrice(selectedStation.owner), 2, 0) + " " + GetLocale("CURRENCY")+"|/b|"), contentX + 5, currentY, contentW - 10, permissionTextH, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
				Else
					currentY :- 1 'align it a bit better
					skin.fontNormal.drawBlock(getLocale("BROADCAST_PERMISSION_EXISTING"), contentX + 5, currentY, contentW - 10, permissionTextH, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
				EndIf
			EndIf
		EndIf

		'=== BUTTONS ===
		'actionButton.rect.position.SetXY(contentX + 5, currentY + 3)
		'cancelButton.rect.position.SetXY(contentX + 5 + 150, currentY + 3)
	End Method
End Type




Type TGameGUICableNetworkPanel Extends TGameGUIBasicStationmapPanel

	Method Create:TGameGUICableNetworkPanel(pos:TVec2D, dimension:TVec2D, value:String, State:String = "")
		Super.Create(pos, dimension, value, State)

		localeKey_NewItem = "NEW_CABLE_NETWORK_UPLINK"
		localeKey_BuyItem = "SIGN_UPLINK"
		localeKey_SellItem = "CANCEL_UPLINK"


		'=== register custom event listeners
		'localize the button
		'we have to refresh the gui station list as soon as we remove or add a station
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.removeStation", OnChangeStationMapStation ) ]
'		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.addStation", OnChangeStationMapStation ) ]

		Return Self
	End Method


	'override
	Method GetBuyActionMode:Int()
		Return TScreenHandler_StationMap.MODE_BUY_CABLE_NETWORK_UPLINK
	End Method


	'override
	Method GetSellActionMode:Int()
		Return TScreenHandler_StationMap.MODE_SELL_CABLE_NETWORK_UPLINK
	End Method



	'rebuild the stationList - eg. when changed the room (other office)
	Method RefreshList(playerID:Int=-1)
		Super.RefreshList(playerID)

		If playerID <= 0 Then playerID = GetPlayerBase().playerID

		Local listContentWidth:Int = list.GetContentScreenWidth()
		For Local station:TStationCableNetworkUplink = EachIn GetStationMap(playerID).Stations
			Local item:TGUISelectListItem = New TGUISelectListItem.Create(New TVec2D, New TVec2D.Init(listContentWidth,20), station.GetLongName())
			'fill complete width
			item.SetListItemOption(GUILISTITEM_AUTOSIZE_WIDTH, True)
			'link the station to the item
			item.data.Add("station", station)
			item._customDrawContent = TScreenHandler_StationMap.DrawMapStationListEntryContent
			list.AddItem( item )
		Next
	End Method


	Method GetHeaderValue:String()
		If TScreenHandler_StationMap.currentSubRoom And GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner)
			Return GetLocale( "CABLE_NETWORK_UPLINKS" ) + ": " + GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner).GetStationCount(TVTStationType.CABLE_NETWORK_UPLINK)
		Else
			Return GetLocale( "CABLE_NETWORK_UPLINKS" ) + ": -/-"
		EndIf
	End Method


	Method DrawBodyContent(contentX:Int,contentY:Int,contentW:Int,currentY:Int)
		Local skin:TDatasheetSkin = GetSkin()
		If Not skin Then Return
		
		Local selectedStation:TStationBase = TScreenHandler_StationMap.selectedStation
		Local boxH:Int = skin.GetBoxSize(100, -1, "").GetY()
		Local boxAreaH:Int = 0
		Local showDetails:Int = False
		If selectedStation Then showDetails = True
		If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_SELL_CABLE_NETWORK_UPLINK Then showDetails = True
		If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_BUY_CABLE_NETWORK_UPLINK Then showDetails = True

		'update information
		detailsBackgroundH = actionButton.GetScreenHeight() + 2*6 + (showDetails<>False)*(24 + (boxH+2)*2)
		listBackgroundH = GetBodyHeight() - detailsBackgroundH
		
		skin.RenderContent(contentX, currentY, contentW, listBackgroundH, "2")
		skin.RenderContent(contentX, currentY + listBackgroundH, contentW, detailsBackgroundH, "1_top")


		'=== LIST ===
		currentY :+ listBackgroundH
	

		'=== BOXES ===
		If TScreenHandler_StationMap.actionMode <> TScreenHandler_StationMap.MODE_NONE
			Local price:String = "", reach:String = "", reachChange:String = "", runningCost:String =""
			local payPenalty:int = False
			Local headerText:String
			Local subHeaderText:String
			Local canAfford:Int = True

			Select TScreenHandler_StationMap.actionMode
				Case TScreenHandler_StationMap.MODE_SELL_CABLE_NETWORK_UPLINK
					If selectedStation
						headerText = selectedStation.GetLongName()
						subHeaderText = GetWorldTime().GetFormattedGameDate(selectedStation.built)
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
'not needed
'						reachChange = MathHelper.DottedValue(selectedStation.GetReachDecrease())
						if selectedStation.GetSellPrice() < 0
							price = TFunctions.convertValue( - selectedStation.GetSellPrice(), 2, 0)
							payPenalty = True
						else
							price = TFunctions.convertValue(selectedStation.GetSellPrice(), 2, 0)
						endif

						If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
							runningCost = "-/-"
						Else
							runningCost = TFunctions.convertValue(selectedStation.GetRunningCosts(), 2, 0)
						EndIf
					EndIf

				Case TScreenHandler_StationMap.MODE_BUY_CABLE_NETWORK_UPLINK
					headerText = GetLocale( localeKey_NewItem )

					'=== BOXES ===
					If selectedStation
						subHeaderText = GetLocale("MAP_COUNTRY_"+selectedStation.GetSectionName())

						'stationName = Koordinaten?
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
'not needed
'						reachChange = MathHelper.DottedValue(selectedStation.GetReachIncrease())
						price = TFunctions.convertValue(selectedStation.getPrice(), 2, 0)

						If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
							runningCost = "-/-"
						Else
							runningCost = TFunctions.convertValue(selectedStation.GetRunningCosts(), 2, 0)
						EndIf

						Local finance:TPlayerFinance = GetPlayerFinance(TScreenHandler_StationMap.currentSubRoom.owner)
						canAfford = (Not finance Or finance.canAfford(selectedStation.GetPrice()))
					EndIf
			End Select


			currentY :+ 2
			skin.fontNormal.drawBlock("|b|"+headerText+"|/b|", contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, headerColor, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
			'currentY :+ skin.fontNormal._fSize
			currentY :+ 14
			skin.fontNormal.drawBlock(subHeaderText, contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			currentY :+ 15 + 3


			Local halfW:Int = (contentW - 10)/2 - 2
			'=== BOX LINE 1 ===
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, reach, "audience", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)


			If selectedStation
				Local subscriptionText:String
				Local cableNetwork:TStationMap_CableNetwork = GetStationMapCollection().GetCableNetworkByGUID( TStationCableNetworkUplink(selectedStation).cableNetworkGUID)
				If TScreenHandler_StationMap.actionMode = GetBuyActionMode()
					subscriptionText = cableNetwork.GetDefaultSubscribedChannelDuration()
				Else
					subscriptionText = selectedStation.GetSubscriptionTimeLeft()
				EndIf
				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, subscriptionText, "duration", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			EndIf
			tooltips[0].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[1].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)

			'=== BOX LINE 2 (optional) ===
			tooltips[2].parentArea.SetXY(-1000,0)
			If TScreenHandler_StationMap.actionMode = GetBuyActionMode()
				'TODO: individual build time for stations ("GetStationConstructionTime()")?
				If GameRules.stationConstructionTime > 0
					currentY :+ boxH
					skin.RenderBox(contentX + 5, currentY, halfW-5, -1, GameRules.stationConstructionTime + "h", "runningTime", "neutral", skin.fontNormal)
					tooltips[2].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
				EndIf
			EndIf

			'=== BOX LINE 3 ===
			currentY :+ boxH
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, runningCost, "moneyRepetitions", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_SELL_ANTENNA
				if payPenalty
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "bad", skin.fontBold, ALIGN_RIGHT_CENTER)
				else
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "good", skin.fontBold, ALIGN_RIGHT_CENTER)
				endif
			Else
				'fetch financial state of room owner (not player - so take care
				'if the player is allowed to do this)
				If canAfford
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER)
				Else
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER,"bad")
				EndIf
			EndIf
			tooltips[3].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[4].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)

			currentY :+ boxH
		EndIf

		'=== BUTTONS ===
		'actionButton.rect.position.SetXY(contentX + 5, currentY + 3)
		'cancelButton.rect.position.SetXY(contentX + 5 + 150, currentY + 3)
	End Method
End Type




Type TGameGUISatellitePanel Extends TGameGUIBasicStationmapPanel
	Field renewContractTooltips:TTooltipBase[]

	Method Create:TGameGUISatellitePanel(pos:TVec2D, dimension:TVec2D, value:String, State:String = "")
		Super.Create(pos, dimension, value, State)

		localeKey_NewItem = "NEW_SATELLITE_UPLINK"
		localeKey_BuyItem = "SIGN_UPLINK"
		localeKey_SellItem = "CANCEL_UPLINK"


		renewContractTooltips = New TTooltipBase[2]
		For Local i:Int = 0 Until renewContractTooltips.length
			renewContractTooltips[i] = New TGUITooltipBase.Initialize("", "", New TRectangle.Init(0,0,-1,-1))
			renewContractTooltips[i].parentArea = New TRectangle
			renewContractTooltips[i].SetOrientationPreset("TOP")
			renewContractTooltips[i].offset = New TVec2D.Init(0,+5)
			renewContractTooltips[i].SetOption(TGUITooltipBase.OPTION_PARENT_OVERLAY_ALLOWED)
			'standard icons should need a bit longer for tooltips to show up
			renewContractTooltips[i].dwellTime = 50
			renewContractTooltips[i].SetContent("i="+i)
			

			'manually set to hovered when needed
			renewContractTooltips[i].SetOption(TTooltipBase.OPTION_MANUAL_HOVER_CHECK)
		Next


		'=== register custom event listeners
		'localize the button
		'we have to refresh the gui station list as soon as we remove or add a station
		'_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.removeStation", OnChangeStationMapStation ) ]
		'_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.addStation", OnChangeStationMapStation ) ]

		Return Self
	End Method


	'override
	Method GetBuyActionMode:Int()
		Return TScreenHandler_StationMap.MODE_BUY_SATELLITE_UPLINK
	End Method


	'override
	Method GetSellActionMode:Int()
		Return TScreenHandler_StationMap.MODE_SELL_SATELLITE_UPLINK
	End Method


	'override
	Method OnClickRenewButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		local satLink:TStationSatelliteUplink = TStationSatelliteUplink(TScreenHandler_StationMap.selectedStation)
		if not satLink then return False


		'select new satellite
		if satLink.IsShutDown()
			if not TScreenHandler_StationMap.satelliteSelectionFrame.IsOpen()
				TScreenHandler_StationMap.satelliteSelectionFrame.Open()
			else
				if TScreenHandler_StationMap.satelliteSelectionFrame.selectedSatellite
					satLink.satelliteGUID = TScreenHandler_StationMap.satelliteSelectionFrame.selectedSatellite.getGUID()
					'local tmpSatLink:TStationBase = GetStationMap(satLink.owner).GetTemporarySatelliteUplinkStationBySatelliteGUID( TScreenHandler_StationMap.satelliteSelectionFrame.selectedSatellite.GetGUID() )
					'tmpSatLink.refreshData()
					satLink.refreshData()
					'sign potential contracts (= add connections)
					satLink.SignContract( -1 )

					ResetActionMode(TScreenHandler_StationMap.MODE_NONE)

rem
					'if tmpSatLink.GetReach() > 0
					if satLink.GetReach() > 0
						'add the station (and buy it)
						If GetStationMap( satLink.owner ).RemoveStation(satLink, True)
						If GetStationMap( satLink.owner ).AddStation(satLink, True)
							ResetActionMode(TScreenHandler_StationMap.MODE_NONE)
						EndIf
					endif
endrem
				EndIf
			endif
		else

			Return Super.OnClickRenewButton(triggerEvent)
		
			'try to renew a contract
			'TScreenHandler_StationMap.selectedStation.RenewContract(12 * TWorldTime.DAYLENGTH)
		endif
	End Method


	'override
	Method UpdateActionButton:int()
		'ignore clicks if not in the own office
		If Not TScreenHandler_StationMap.currentSubRoom Or TScreenHandler_StationMap.currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		Super.UpdateActionButton()

		
		renewButton.SetValue(GetLocale("RENEW_CONTRACT"))

		local openFrame:int = TScreenHandler_StationMap.satelliteSelectionFrame and TScreenHandler_StationMap.satelliteSelectionFrame.IsOpen()
		local selectedSatellite:TStationMap_Satellite = TScreenHandler_StationMap.satelliteSelectionFrame.selectedSatellite
'		actionButton.Disable()
'		renewButton.Disable()


		if TScreenHandler_StationMap.selectedStation

			'disable action button if subscription not possible
			if openFrame
				actionButton.Enable()
				if selectedSatellite
					if not selectedSatellite.CanSubscribeChannel(GetPlayerBase().playerID, -1) or selectedSatellite.IsSubscribedChannel(GetPlayerBase().playerID)
						actionButton.Disable()
					endif
				endif
			endif
	

			'sat uplinks can be sold extra
			If TScreenHandler_StationMap.selectedStation.IsShutDown()
				If TStationSatelliteUplink(TScreenHandler_StationMap.selectedStation)
					actionButton.SetValue(GetLocale("SELL_TRANSMITTER"))
'					if not openFrame
'						actionButton.Enable()
'					endif

					if openFrame
						if selectedSatellite
							renewInfoButton.Enable()
							renewButton.Enable()
						else
							renewInfoButton.Disable()
							renewButton.Disable()
						endif
						renewButton.SetValue(GetLocale("SIGN_UPLINK"))
						renewInfoButton.Enable()
					else
						renewButton.SetValue(GetLocale("SELECT_SATELLITE"))
						renewInfoButton.Disable()
'						renewButton.enable()
					endif
				EndIf
			EndIf
		EndIf

		return True
	End Method



	'rebuild the stationList - eg. when changed the room (other office)
	Method RefreshList(playerID:Int=-1)
		Super.RefreshList(playerID)

		If playerID <= 0 Then playerID = GetPlayerBase().playerID

		Local listContentWidth:Int = list.GetContentScreenWidth()
		For Local station:TStationSatelliteUplink = EachIn GetStationMap(playerID).Stations
			Local item:TGUISelectListItem = New TGUISelectListItem.Create(New TVec2D, New TVec2D.Init(listContentWidth,20), station.GetLongName())
			'fill complete width
			item.SetListItemOption(GUILISTITEM_AUTOSIZE_WIDTH, True)
			'link the station to the item
			item.data.Add("station", station)
			item._customDrawContent = TScreenHandler_StationMap.DrawMapStationListEntryContent
			list.AddItem( item )
		Next
	End Method


	Method GetHeaderValue:String()
		If TScreenHandler_StationMap.currentSubRoom And GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner)
			Return GetLocale( "SATELLITE_UPLINKS" ) + ": " + GetStationMap(TScreenHandler_StationMap.currentSubRoom.owner).GetStationCount(TVTStationType.SATELLITE_UPLINK)
		Else
			Return GetLocale( "SATELLITE_UPLINKS" ) + ": -/-"
		EndIf
	End Method


	'override
	Method Update:Int()
		if renewButton.IsVisible()
			if TScreenHandler_StationMap.selectedStation and not TScreenHandler_StationMap.selectedStation.IsShutDown()
				if renewButton.IsHovered() or renewInfoButton.IsHovered()
					For Local t:TTooltipBase = EachIn renewContractTooltips
						t.SetOption(TTooltipBase.OPTION_MANUALLY_HOVERED)
						'skip dwelling
						t.SetStep(TTooltipBase.STEP_ACTIVE)
						t.Update()
					Next
				else
					For Local t:TTooltipBase = EachIn renewContractTooltips
						t.SetOption(TTooltipBase.OPTION_MANUALLY_HOVERED, False)
						t.Update()
					Next
				endif
			endif
		endif

		return Super.Update()
	End Method
	

	'override
	Method DrawBody()
		Super.DrawBody()

		if renewButton.IsVisible()
			if TScreenHandler_StationMap.selectedStation and not TScreenHandler_StationMap.selectedStation.IsShutDown()
				For Local t:TTooltipBase = EachIn renewContractTooltips
					t.Render()
				Next
			endif
		endif
	End Method


	Method DrawBodyContent(contentX:Int,contentY:Int,contentW:Int,currentY:Int)
		Local skin:TDatasheetSkin = GetSkin()
		If Not skin Then Return
		
		Local selectedStation:TStationBase = TScreenHandler_StationMap.selectedStation
		Local boxH:Int = skin.GetBoxSize(100, -1, "").GetY()
		Local boxAreaH:Int = 0
		Local showDetails:Int = False
		If selectedStation Then showDetails = True
		If TScreenHandler_StationMap.actionMode = GetSellActionMode() Then showDetails = True
		If TScreenHandler_StationMap.actionMode = GetBuyActionMode() Then showDetails = True

		Local showIncludesHardwareText:int = False
		Local includesHardwareTextH:int = 24

		'update information
		detailsBackgroundH = actionButton.GetScreenHeight() + 2*6 + (showDetails<>False)*(24 + (boxH+2)*2)
		If TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_SELL_SATELLITE_UPLINK or TScreenHandler_StationMap.actionMode = TScreenHandler_StationMap.MODE_SELL_CABLE_NETWORK_UPLINK
			if selectedStation
				detailsBackgroundH :+ renewButton.GetScreenHeight() + 3

				if TStationSatelliteUplink(selectedStation).IsShutdown()
					showIncludesHardwareText = True
					detailsBackgroundH :+ includesHardwareTextH
				endif
			EndIf
		EndIf

		listBackgroundH = GetBodyHeight() - detailsBackgroundH
		
		skin.RenderContent(contentX, currentY, contentW, listBackgroundH, "2")
		skin.RenderContent(contentX, currentY + listBackgroundH, contentW, detailsBackgroundH, "1_top")


		'=== LIST ===
		currentY :+ listBackgroundH
	

		'=== BOXES ===
		If TScreenHandler_StationMap.actionMode <> TScreenHandler_StationMap.MODE_NONE
			Local price:String = "", reach:String = "", reachChange:String = "", runningCost:String =""
			Local payPenalty:int
			Local headerText:String
			Local subHeaderText:String
			Local canAfford:Int = True

			Select TScreenHandler_StationMap.actionMode
				Case TScreenHandler_StationMap.MODE_SELL_SATELLITE_UPLINK
					If selectedStation
						headerText = selectedStation.GetLongName()
						subHeaderText = GetWorldTime().GetFormattedGameDate(selectedStation.built)
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
'not needed
'						reachChange = MathHelper.DottedValue(selectedStation.GetReachDecrease())

						'reassign to new satellite?
						if TScreenHandler_StationMap.satelliteSelectionFrame.IsOpen() and TScreenHandler_StationMap.satelliteSelectionFrame.selectedSatellite
							price = TFunctions.convertValue( selectedStation.GetBuyPrice(), 2, 0)
							runningCost = TFunctions.convertValue(selectedStation.GetCurrentRunningCosts(), 2, 0)
						else

							if selectedStation.GetSellPrice() < 0
								price = TFunctions.convertValue( - selectedStation.GetSellPrice(), 2, 0)
								payPenalty = True
							else
								price = TFunctions.convertValue(selectedStation.GetSellPrice(), 2, 0)
							endif

							If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
								runningCost = "-/-"
							Else
								runningCost = TFunctions.convertValue(selectedStation.GetRunningCosts(), 2, 0)
							EndIf
						endif
					EndIf
					renewButton.Show()
					renewInfoButton.Show()

				Case TScreenHandler_StationMap.MODE_BUY_SATELLITE_UPLINK
					headerText = GetLocale( localeKey_NewItem )

					'=== BOXES ===
					If selectedStation
						subHeaderText = selectedStation.GetName()

						'stationName = Koordinaten?
						reach = TFunctions.convertValue(selectedStation.GetReach(), 2)
'not needed
'						reachChange = MathHelper.DottedValue(selectedStation.GetReachIncrease())
						price = TFunctions.convertValue(selectedStation.getPrice(), 2, 0)

						If selectedStation.HasFlag(TVTStationFlag.NO_RUNNING_COSTS)
							runningCost = "-/-"
						Else
							runningCost = TFunctions.convertValue(selectedStation.GetRunningCosts(), 2, 0)
						EndIf

						Local finance:TPlayerFinance = GetPlayerFinance(TScreenHandler_StationMap.currentSubRoom.owner)
						canAfford = (Not finance Or finance.canAfford(selectedStation.GetPrice()))
					EndIf
					renewButton.Hide()
					renewInfoButton.Hide()
			End Select


			currentY :+ 2
			skin.fontNormal.drawBlock("|b|"+headerText+"|/b|", contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, headerColor, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
			'currentY :+ skin.fontNormal._fSize
			currentY :+ 14
			skin.fontNormal.drawBlock(subHeaderText, contentX + 5, currentY, contentW - 10,  16, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			currentY :+ 15 + 3


			Local halfW:Int = (contentW - 10)/2 - 2
			'=== BOX LINE 1 ===
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, reach, "audience", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
'not needed
'			if TScreenHandler_StationMap.actionMode = GetBuyActionMode()
'				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, reachChange, "audienceIncrease", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
'			else
'				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, "-"+reachChange, "audienceIncrease", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER, "bad")
'			endif
			tooltips[0].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
'not needed
'			tooltips[1].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)

			'=== BOX LINE 2 (optional) ===
			tooltips[2].parentArea.SetXY(-1000,0)

			If TScreenHandler_StationMap.actionMode = GetBuyActionMode()
				'TODO: individual build time for stations ("GetStationConstructionTime()")?
				If GameRules.stationConstructionTime > 0
					currentY :+ boxH
					skin.RenderBox(contentX + 5, currentY, halfW-5, -1, GameRules.stationConstructionTime + "h", "runningTime", "neutral", skin.fontNormal)
					tooltips[2].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
				EndIf
			EndIf

			If selectedStation
				Local subscriptionText:String
				Local satellite:TStationMap_Satellite = GetStationMapCollection().GetSatelliteByGUID( TStationSatelliteUplink(selectedStation).satelliteGUID)
				local duration:int
				If TScreenHandler_StationMap.actionMode = GetBuyActionMode()
					duration = satellite.GetDefaultSubscribedChannelDuration()
				Else
					duration = selectedStation.GetSubscriptionTimeLeft()
				EndIf
				if duration >= TWorldTime.DAYLENGTH
					subscriptionText = GetWorldTime().GetFormattedDuration(duration, "d h")
				else
					subscriptionText = GetWorldTime().GetFormattedDuration(duration, "h i")
				endif

				skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, subscriptionText, "duration", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			EndIf
			renewContractTooltips[0].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)

			'=== BOX LINE 3 ===
			currentY :+ boxH
			skin.RenderBox(contentX + 5, currentY, halfW-5, -1, runningCost, "moneyRepetitions", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			If TScreenHandler_StationMap.actionMode = GetSellActionMode()
				if payPenalty
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "bad", skin.fontBold, ALIGN_RIGHT_CENTER)
				else
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "good", skin.fontBold, ALIGN_RIGHT_CENTER)
				endif
			Else
				'fetch financial state of room owner (not player - so take care
				'if the player is allowed to do this)
				If canAfford
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER)
				Else
					skin.RenderBox(contentX + 5 + halfW-5 + 4, currentY, halfW+5, -1, price, "money", "neutral", skin.fontBold, ALIGN_RIGHT_CENTER,"bad")
				EndIf
			EndIf
			renewContractTooltips[1].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[3].parentArea.SetXY(contentX + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[4].parentArea.SetXY(contentX + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)

			currentY :+ boxH


			If showIncludesHardwareText
				skin.fontNormal.drawBlock(getLocale("PRICE_INCLUDES_X_FOR_HARDWARE").Replace("%X%", "|b|"+TFunctions.convertValue(123, 2, 0) + " " + GetLocale("CURRENCY")+"|/b|"), contentX + 5, currentY, contentW - 10, includesHardwareTextH, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			EndIf
		EndIf

		'renewButton.rect.position.SetXY(contentX + 5, currentY + 3)

		'=== BUTTONS ===
		'actionButton.rect.position.SetXY(contentX + 5, currentY + 3)
		'cancelButton.rect.position.SetXY(contentX + 5 + 150, currentY + 3)
	End Method
End Type




Type TSatelliteSelectionFrame
	Field area:TRectangle
	Field contentArea:TRectangle
	Field headerHeight:Int
	Field listHeight:Int
	Field selectedSatellite:TStationMap_Satellite
	Field satelliteList:TGUISelectList
	Field tooltips:TTooltipBase[]
	Field _open:Int = True

	Field _eventListeners:TLink[]


	Method New()
		If Not area Then area = New TRectangle.Init(402, 96, 190, 212)
		If Not contentArea Then contentArea = New TRectangle

		satelliteList = New TGUISelectList.Create(New TVec2D.Init(410, 121), New TVec2D.Init(178, 100), "STATIONMAP")
		'scroll by one entry at a time
		satelliteList.scrollItemHeightPercentage = 1.0
		satelliteList.SetListOption(GUILIST_SCROLL_TO_NEXT_ITEM, True)

		'panel handles them (similar to a child - but with manual draw/update calls)
		'satelliteList.SetParent(self)
		GuiManager.Remove(satelliteList)


		tooltips = New TTooltipBase[4]
		For Local i:Int = 0 Until tooltips.length
			tooltips[i] = New TGUITooltipBase.Initialize("", "", New TRectangle.Init(0,0,-1,-1))
			tooltips[i].parentArea = New TRectangle
			tooltips[i].SetOrientationPreset("TOP")
			tooltips[i].offset = New TVec2D.Init(0,+5)
			tooltips[i].SetOption(TGUITooltipBase.OPTION_PARENT_OVERLAY_ALLOWED)
			'standard icons should need a bit longer for tooltips to show up
			tooltips[i].dwellTime = 500
		Next

		'fill with content
		RefreshSatellitesList()


		'=== remove all registered event listeners
		EventManager.unregisterListenersByLinks(_eventListeners)
		_eventListeners = New TLink[0]

		'=== register event listeners
		'we have to refresh the gui station list as soon as we remove or add a station
		_eventListeners :+ [ EventManager.registerListenerMethod( "stationmapcollection.removeSatellite", Self, "OnChangeSatellites" ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "stationmapcollection.addSatellite", Self, "OnChangeSatellites" ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "stationmapcollection.launchSatellite", Self, "OnChangeSatellites" ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "GUISelectList.onSelectEntry", Self, "OnSelectEntryList", satelliteList ) ]

'		return self
	End Method

	
	Method SetLanguage()
		Local strings:String[] = [GetLocale("BROADCAST_QUALITY"), GetLocale("MARKET_SHARE"), GetLocale("REQUIRED_CHANNEL_IMAGE"), GetLocale("SUBSCRIBED_CHANNELS")]
		strings = strings[.. tooltips.length]

		For Local i:Int = 0 Until tooltips.length
			If tooltips[i] Then tooltips[i].SetContent(strings[i])
		Next
	End Method


	Method OnChangeSatellites:Int(triggerEvent:TEventBase)
		RefreshSatellitesList()
	End Method


	'an entry was selected - make the linked station the currently selected station
	Method OnSelectEntryList:Int(triggerEvent:TEventBase)
		Local senderList:TGUISelectList = TGUISelectList(triggerEvent._sender)
		If Not senderList Then Return False
		If senderList <> satelliteList Then Return False
		If Not TScreenHandler_StationMap.currentSubRoom Then Return False
		If Not GetPlayerBaseCollection().IsPlayer(TScreenHandler_StationMap.currentSubRoom.owner) Then Return False

		'set the linked satellite as the selected one
		Local item:TGUISelectListItem = TGUISelectListItem(senderList.getSelectedEntry())
		If item
			selectedSatellite = TStationMap_Satellite(item.data.get("satellite"))
		EndIf
	End Method


	Method SelectSatellite:Int(satellite:TStationMap_Satellite)
		selectedSatellite = satellite
		If Not selectedSatellite
			satelliteList.DeselectEntry()

			Return True
		Else
			For Local i:TGUIListItem = EachIn satelliteList.entries
				Local itemSatellite:TStationMap_Satellite = TStationMap_Satellite(i.data.get("satellite"))
				If itemSatellite = satellite
					satelliteList.SelectEntry(i)

					Return True
				EndIf
			Next
		EndIf

		Return False
	End Method


	Method IsOpen:Int()
		Return _open
	End Method


	Method Close:Int()
		SelectSatellite(Null)
		
		_open = False
		Return True
	End Method


	Method Open:Int()
		_open = True
		Return True
	End Method


	Method RefreshSatellitesList:Int()
		satelliteList.EmptyList()
		'remove potential highlighted item
		satelliteList.deselectEntry()

		'keep them sorted the way we added the stations
		satelliteList.setListOption(GUILIST_AUTOSORT_ITEMS, False)


		Local listContentWidth:Int = satelliteList.GetContentScreenWidth()

		If GetStationMapCollection().satellites
			For Local satellite:TStationMap_Satellite = EachIn GetStationMapCollection().satellites
				If Not satellite.IsLaunched() Then Continue
				
				Local item:TGUISelectListItem = New TGUISelectListItem.Create(New TVec2D, New TVec2D.Init(listContentWidth,20), satellite.name)
	
				'fill complete width
				item.SetListItemOption(GUILISTITEM_AUTOSIZE_WIDTH, True)
	
				'link the station to the item
				item.data.Add("satellite", satellite)
				item._customDrawContent = DrawSatelliteListEntryContent
				satelliteList.AddItem( item )
			Next
		EndIf

		Return True
	End Method


	'custom drawing function for list entries
	Function DrawSatelliteListEntryContent:Int(obj:TGUIObject)
		Local item:TGUISelectListItem = TGUISelectListItem(obj)
		If Not item Then Return False

		Local satellite:TStationMap_Satellite = TStationMap_Satellite(item.data.Get("satellite"))
		If Not satellite Then Return False

		Local sprite:TSprite
		If satellite.IsSubscribedChannel(GetPlayerBase().playerID)
			sprite = GetSpriteFromRegistry(satellite.listSpriteNameOn)
		Else
			sprite = GetSpriteFromRegistry(satellite.listSpriteNameOff)
		EndIf

		Local paddingLR:Int = 2
		Local textOffsetX:Int = paddingLR + sprite.GetWidth() + 5
		Local textOffsetY:Int = 2
		Local textW:Int = item.GetScreenWidth() - textOffsetX - paddingLR

		Local currentColor:TColor = New TColor.Get()
		Local entryColor:TColor
		Local leftValue:string = item.GetValue()
		local highlight:int = False

		'draw with different color according status
		If satellite.IsSubscribedChannel(GetPlayerBase().playerID)
			entryColor = New TColor.Create(80,130,50, currentColor.a)
			highlight = True
		ElseIf not satellite.CanSubscribeChannel(GetPlayerBase().playerID)
			entryColor = New TColor.Create(130,80,50, currentColor.a)
			entryColor.a = currentColor.a * 0.85
			highlight = True
		Else
			entryColor = item.valueColor '.copy().AdjustFactor(50)
'			entryColor.a = currentColor.a * 0.5
		EndIf

		if highlight
			entryColor.SetRGB()
			SetAlpha entryColor.a * 0.5
			DrawRect(Int(item.GetScreenX() + paddingLR), item.GetScreenY(), sprite.GetWidth(), item.rect.getH())
			currentColor.SetRGBA()
		endif

		'draw antenna
		sprite.Draw(Int(item.GetScreenX() + paddingLR), item.GetScreenY() + 0.5*item.rect.getH(), -1, ALIGN_LEFT_CENTER)
		item.GetFont().DrawBlock(leftValue, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), textW - 5, Int(item.GetScreenHeight() - textOffsetY), ALIGN_LEFT_CENTER, entryColor, , , , False)
	End Function
	
	
	Method Update:Int()
		If contentArea
			If satelliteList.rect.GetX() <> contentArea.GetX()
				satelliteList.SetPosition(contentArea.GetX(), contentArea.GetY() + 16)
			EndIf
			If satelliteList.GetWidth() <> contentArea.GetW()
				satelliteList.Resize(contentArea.GetW())
			EndIf
		EndIf

	
		satelliteList.update()

		For Local t:TTooltipBase = EachIn tooltips
			t.Update()
		Next
	End Method


	Method Draw:Int()
		Local skin:TDatasheetSkin = GetDatasheetSkin("stationMapPanel")
		If Not skin Then Return False

		Local owner:Int = GetPlayer().playerID
		If TScreenHandler_StationMap.currentSubRoom Then owner = TScreenHandler_StationMap.currentSubRoom.owner

		Local detailsH:Int = 90 * (selectedSatellite<>Null)
		'local boxH:int = skin.GetBoxSize(100, -1, "").GetY()
		contentArea.SetW( skin.GetContentW( area.GetW() ) )
		contentArea.SetX( area.GetX() + skin.GetContentX() )
		contentarea.SetY( area.GetY() + skin.GetContentY() )
		contentArea.SetH( area.GetH() - (skin.GetContentPadding().GetTop() + skin.GetContentPadding().GetBottom()) )

		headerHeight = 16
		listHeight = contentArea.GetH() - headerHeight - detailsH

		'resize list if needed
		If listHeight <> satelliteList.GetHeight()
			satelliteList.Resize(-1, listHeight)
		EndIf


		Local currentY:Int = contentArea.GetY()


		Local headerText:String = GetLocale("SATELLITES")
		Local titleColor:TColor = New TColor.Create(75,75,75)
		Local subTitleColor:TColor = New TColor.Create(115,115,115)



		'=== HEADER ===
		skin.RenderContent(contentArea.GetX(), contentArea.GetY(), contentArea.GetW(), headerHeight, "1_top")
		skin.fontNormal.drawBlock("|b|"+headerText+"|/b|", contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  headerHeight, ALIGN_CENTER_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
		currentY :+ headerHeight

		'=== LIST ===
		skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), listHeight, "2")
		satelliteList.Draw()
		currentY :+ listHeight


		'=== SATELLITE DETAILS ===
		If selectedSatellite
			Local titleText:String = selectedSatellite.name
			Local subtitleText:String = GetLocale("NOT_LAUNCHED_YET")
			If selectedSatellite.IsLaunched()
				subtitleText = GetLocale("LAUNCHED")+": " + GetWorldTime().GetFormattedDate(selectedSatellite.launchTime, GameConfig.dateFormat)
			EndIf

			skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), detailsH, "1_top")
			currentY :+ 2
			skin.fontNormal.drawBlock("|b|"+titleText+"|/b|", contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  16, ALIGN_CENTER_CENTER, titleColor, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
			currentY :+ 14
			skin.fontNormal.drawBlock(subTitleText, contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  16, ALIGN_CENTER_CENTER, subTitleColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			currentY :+ 15 + 3


			Local halfW:Int = (contentArea.GetW() - 10)/2 - 2
			Local boxH:Int = skin.GetBoxSize(100, -1, "").GetY()
			'=== BOX LINE 1 ===
			'local qualityText:string = "-/-"
			'if selectedSatellite.quality <> 100
			'	qualityText = MathHelper.NumberToString((selectedSatellite.quality-100), 0, True)+"%"
			'endif
			Local qualityText:String = MathHelper.NumberToString(selectedSatellite.quality, 0, True)+"%"
			Local marketShareText:String = MathHelper.NumberToString(100*selectedSatellite.populationShare, 1, True)+"%"

			If selectedSatellite.quality < 100
				skin.RenderBox(contentArea.GetX() + 5, currentY, halfW-5, -1, qualityText, "quality", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER, "bad")
			Else
				skin.RenderBox(contentArea.GetX() + 5, currentY, halfW-5, -1, qualityText, "quality", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			EndIf
			skin.RenderBox(contentArea.GetX() + 5 + halfW-5 + 4, currentY, halfW+5, -1, marketShareText, "marketShare", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			tooltips[0].parentArea.SetXY(contentArea.GetX() + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[1].parentArea.SetXY(contentArea.GetX() + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)



			currentY :+ boxH
			Local minImageText:String = MathHelper.NumberToString(100*selectedSatellite.minimumChannelImage, 1, True)+"%"

			If Not GetPublicImage(owner) Or GetPublicImage(owner).GetAverageImage() < selectedSatellite.minimumChannelImage
				skin.RenderBox(contentArea.GetX() + 5, currentY, halfW-5, -1, minImageText, "image", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER, "bad")
			Else
				skin.RenderBox(contentArea.GetX() + 5, currentY, halfW-5, -1, minImageText, "image", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			EndIf


			'draw "used by channel xy" box
			Local channelX:Int = contentArea.GetX() + 5 + halfW-5 + 4
			skin.RenderBox(channelX, currentY, halfW+5, -1, "", "audience", "neutral", skin.fontNormal, ALIGN_RIGHT_CENTER)
			tooltips[2].parentArea.SetXY(contentArea.GetX() + 5, currentY).SetWH(halfW+5, boxH)
			tooltips[3].parentArea.SetXY(contentArea.GetX() + 5 + halfW-5 +4, currentY).SetWH(halfW+5, boxH)



			channelX :+ 27
			Local oldColor:TColor = New TColor.Get()
			For Local i:Int = 1 To 4
				SetColor 50,50,50
				SetAlpha oldcolor.a * 0.4
				DrawRect(channelX, currentY + 6, 11,11)
				If selectedSatellite.IsSubscribedChannel(i)
					GetPlayerBase(i).color.SetRGB()
					SetAlpha oldColor.a
				Else
					SetColor 255,255,255
					SetAlpha oldColor.a *0.5
				EndIf
				DrawRect(channelX+1, currentY + 7, 9,9)
				'GetSpriteFromRegistry("gfx_gui_button.datasheet").DrawArea(channelX, currentY + 4, 14, 14)
				channelX :+ 13
			Next
			oldColor.SetRGBA()

		EndIf


		skin.RenderBorder(area.GetX(), area.GetY(), area.GetW(), area.GetH())

		'debug
		Rem
		DrawRect(contentArea.GetX(), contentArea.GetY(), 20, contentArea.GetH() )
		Setcolor 255,0,0
		DrawRect(contentArea.GetX() + 10, contentArea.GetY(), 20, headerHeight )
		Setcolor 255,255,0
		DrawRect(contentArea.GetX() + 20, contentArea.GetY() + headerHeight, 20, listHeight )
		Setcolor 255,0,255
		DrawRect(contentArea.GetX() + 30, contentArea.GetY() + headerHeight + listHeight, 20, detailsH )
		endrem

		For Local t:TTooltipBase = EachIn tooltips
			t.Render()
		Next
	End Method
End Type





Type TStationMapInformationFrame
	Field area:TRectangle
	Field contentArea:TRectangle
	Field headerHeight:Int
	Field countryInformationHeight:Int = 90
	Field sectionListHeight:Int
	Field sectionListHeaderHeight:Int = 16
	Field selectedSection:TStationMapSection
	Field sectionList:TGUISelectList
	Field tooltips:TTooltipBase[]
	Field _open:Int = True
	Global subHeaderColor:TColor = New TColor.Create(115,115,115)

	Field _eventListeners:TLink[]


	Method New()
		sectionList = New TGUISelectList.Create(New TVec2D.Init(410,153), New TVec2D.Init(378, 100), "STATIONMAP")
		'scroll by one entry at a time
		sectionList.scrollItemHeightPercentage = 1.0
		sectionList.SetListOption(GUILIST_SCROLL_TO_NEXT_ITEM, True)

		'panel handles them (similar to a child - but with manual draw/update calls)
		GuiManager.Remove(sectionList)

		tooltips = New TTooltipBase[4]
		For Local i:Int = 0 Until tooltips.length
			tooltips[i] = New TGUITooltipBase.Initialize("", "", New TRectangle.Init(0,0,-1,-1))
			tooltips[i].parentArea = New TRectangle
			tooltips[i].SetOrientationPreset("TOP")
			tooltips[i].offset = New TVec2D.Init(0,+5)
			tooltips[i].SetOption(TGUITooltipBase.OPTION_PARENT_OVERLAY_ALLOWED)
			'standard icons should need a bit longer for tooltips to show up
			tooltips[i].dwellTime = 500
		Next

		'fill with content
		RefreshSectionList()


		'=== remove all registered event listeners
		EventManager.unregisterListenersByLinks(_eventListeners)
		_eventListeners = New TLink[0]

		'=== register event listeners
		'we have to refresh the gui station list as soon as we remove or add a station
		_eventListeners :+ [ EventManager.registerListenerMethod( "stationmapcollection.addSection", Self, "OnChangeSections" ) ]
		_eventListeners :+ [ EventManager.registerListenerMethod( "GUISelectList.onSelectEntry", Self, "OnSelectEntryList", sectionList ) ]

'		return self
	End Method

	
	Method SetLanguage()
		Local strings:String[] = [GetLocale("BROADCAST_QUALITY"), GetLocale("MARKET_SHARE"), GetLocale("REQUIRED_CHANNEL_IMAGE"), GetLocale("SUBSCRIBED_CHANNELS")]
		strings = strings[.. tooltips.length]

		For Local i:Int = 0 Until tooltips.length
			If tooltips[i] Then tooltips[i].SetContent(strings[i])
		Next
	End Method


	Method OnChangeSections:Int(triggerEvent:TEventBase)
		RefreshSectionList()
	End Method


	'an entry was selected - make the linked section the currently selected one
	Method OnSelectEntryList:Int(triggerEvent:TEventBase)
		Local senderList:TGUISelectList = TGUISelectList(triggerEvent._sender)
		If Not senderList Then Return False
		If senderList <> sectionList Then Return False
		If Not TScreenHandler_StationMap.currentSubRoom Then Return False
		If Not GetPlayerBaseCollection().IsPlayer(TScreenHandler_StationMap.currentSubRoom.owner) Then Return False

		'set the linked satellite as the selected one
		Local item:TGUISelectListItem = TGUISelectListItem(senderList.getSelectedEntry())
		If item
			selectedSection = TStationMapSection(item.data.get("section"))
		EndIf
	End Method


	Method SelectSection:Int(section:TStationMapSection)
		selectedSection = section
		If Not selectedSection
			sectionList.DeselectEntry()

			Return True
		Else
			For Local i:TGUIListItem = EachIn sectionList.entries
				Local itemSection:TStationMapSection = TStationMapSection(i.data.get("section"))
				If itemSection = section
					sectionList.SelectEntry(i)

					Return True
				EndIf
			Next
		EndIf

		Return False
	End Method


	Method IsOpen:Int()
		Return _open
	End Method


	Method Close:Int()
		SelectSection(Null)
		
		_open = False
		Return True
	End Method


	Method Open:Int()
		_open = True
		Return True
	End Method


	'custom drawing function for list entries
	Function DrawMapSectionListEntryContent:Int(obj:TGUIObject)
		Local item:TGUISelectListItem = TGUISelectListItem(obj)
		If Not item Then Return False

		Local section:TStationMapSection = TStationMapSection(item.data.Get("section"))
		If Not section Then Return False

		local owner:int = 0
		if TScreenHandler_StationMap.currentSubRoom then owner = TScreenHandler_StationMap.currentSubRoom.owner

		Local valueA:String = GetLocale("MAP_COUNTRY_"+item.GetValue())
		Local valueB:String = section.HasBroadcastPermission(owner)
		Local valueC:String = MathHelper.NumberToString(section.GetPressureGroupsChannelSympathy(owner)*100,2) +"%"
		Local valueD:String = TFunctions.convertValue(section.GetPopulation(), 2, 0)
		Local paddingLR:Int = 2
		Local textOffsetX:Int = paddingLR + 5
		Local textOffsetY:Int = 2
		Local textW:Int = item.GetScreenWidth() - textOffsetX - paddingLR
		Local colY:Int = Int(item.GetScreenY() + textOffsetY)
		Local colHeight:Int = Int(item.GetScreenHeight() - textOffsetY)
		Local colWidthA:Int = 0.5 * textW
		Local colWidthB:Int = 0.1 * textW
		Local colWidthC:Int = 0.1 * textW
		Local colWidthD:Int = 0.3 * textW

		Local currentColor:TColor = New TColor.Get()
		Local entryColor:TColor

		'draw with different color according status
		entryColor = item.valueColor.copy()
		entryColor.a = currentColor.a

		'draw antenna
		entryColor.SetRGBA()
		item.GetFont().DrawBlock(valueA, Int(item.GetScreenX() + textOffsetX), colY, colWidthA, colHeight, ALIGN_LEFT_CENTER, item.valueColor, , , , False)
		textOffsetX :+ colWidthA
		item.GetFont().DrawBlock(valueB, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), colWidthB, colHeight, ALIGN_RIGHT_CENTER, item.valueColor)
		textOffsetX :+ colWidthB
		item.GetFont().DrawBlock(valueC, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), colWidthC, colHeight, ALIGN_RIGHT_CENTER, item.valueColor)
		textOffsetX :+ colWidthB
		item.GetFont().DrawBlock(valueD, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), colWidthD, colHeight, ALIGN_RIGHT_CENTER, item.valueColor)
		textOffsetX :+ colWidthB

		currentColor.SetRGBA()
	End Function
	

	Method RefreshSectionList:Int()
		sectionList.EmptyList()
		'remove potential highlighted item
		sectionList.deselectEntry()

		'keep them sorted the way we added the stations
		sectionList.setListOption(GUILIST_AUTOSORT_ITEMS, False)


		Local listContentWidth:Int = sectionList.GetContentScreenWidth()

		If GetStationMapCollection().sections
			For Local section:TStationMapSection = EachIn GetStationMapCollection().sections
				Local item:TGUISelectListItem = New TGUISelectListItem.Create(New TVec2D, New TVec2D.Init(listContentWidth,20), section.name)
	
				'fill complete width
				item.SetListItemOption(GUILISTITEM_AUTOSIZE_WIDTH, True)
	
				'link the station to the item
				item.data.Add("section", section)
				item._customDrawContent = DrawMapSectionListEntryContent
				sectionList.AddItem( item )
			Next
		EndIf

		Return True
	End Method

	
	Method Update:Int()
		If contentArea
			If sectionList.rect.GetX() <> contentArea.GetX()
				sectionList.SetPosition(contentArea.GetX(), contentArea.GetY() + 16 + countryInformationHeight + sectionListHeaderHeight)
			EndIf
			If sectionList.GetWidth() <> contentArea.GetW()
				sectionList.Resize(contentArea.GetW())
			EndIf
		EndIf
	
		sectionList.update()

		For Local t:TTooltipBase = EachIn tooltips
			t.Update()
		Next
	End Method


	Method Draw:Int()
		Local skin:TDatasheetSkin = GetDatasheetSkin("stationMapPanel")
		If Not skin Then Return False

		Local owner:Int = GetPlayer().playerID
		If TScreenHandler_StationMap.currentSubRoom Then owner = TScreenHandler_StationMap.currentSubRoom.owner

		If Not area Then area = New TRectangle.Init(170, 5, 400, 348)
		If Not contentArea Then contentArea = New TRectangle

		Local detailsH:Int = 90 * (selectedSection<>Null)
		'local boxH:int = skin.GetBoxSize(100, -1, "").GetY()
		contentArea.SetW( skin.GetContentW( area.GetW() ) )
		contentArea.SetX( area.GetX() + skin.GetContentX() )
		contentarea.SetY( area.GetY() + skin.GetContentY() )
		contentArea.SetH( area.GetH() - (skin.GetContentPadding().GetTop() + skin.GetContentPadding().GetBottom()) )

		headerHeight = 16
		sectionListHeight = contentArea.GetH() - headerHeight - countryInformationHeight - detailsH - sectionListHeaderHeight

		'resize list if needed
		If sectionListHeight <> sectionList.GetHeight()-5
			sectionList.Resize(-1, sectionListHeight-5)
		EndIf


		Local currentY:Int = contentArea.GetY()


		Local headerText:String = GetLocale("COUNTRYNAME_ISO3166_"+GetStationMapCollection().GetMapISO3166Code())
		Local titleColor:TColor = New TColor.Create(75,75,75)
		Local subTitleColor:TColor = New TColor.Create(115,115,115)



		'=== HEADER ===
		skin.RenderContent(contentArea.GetX(), contentArea.GetY(), contentArea.GetW(), headerHeight, "1_top")
		skin.fontBold.drawBlock(headerText, contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  headerHeight, ALIGN_CENTER_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
		currentY :+ headerHeight

		'=== COUNTRY DETAILS ===
		skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), countryInformationHeight, "1")
		local lineH:int = 14
		local col1W:int = 100
		local col2W:int = 60
		local col3W:int = 110
		local col4W:int = 70
		local col1:int = contentArea.GetX() + 5
		local col3:int = contentArea.GetX2() - 5 - col3W - col4W
		local col2:int = col1 + col1W
		local col4:int = col3 + col3W
		local textY:int = currentY + 5
		skin.fontNormal.drawBlock("|b|"+GetLocale("POPULATION")+":|/b|", col1, textY + 0*lineH, col1W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock(TFunctions.DottedValue(GetStationMapCollection().GetPopulation()), col2, textY + 0*lineH, col2W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock("|b|"+GetLocale("STATIONMAP_SECTIONS_NAME")+":|/b|", col1, textY + 1*lineH, col1W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock(GetStationMapCollection().sections.Count(), col2, textY + 1*lineH, col2W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)

		skin.fontNormal.drawBlock("|b|"+GetLocale("RECEIVER_SHARE")+"|/b|", col3, textY + 0*lineH, col3W + col4W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock(GetLocale("ANTENNA_RECEIVERS")+":", col3, textY + 1*lineH, col3W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.4,True, True)
		skin.fontNormal.drawBlock(MathHelper.NumberToString(GetStationMapCollection().GetAveragePopulationAntennaShare()*100, 2)+"%", col4, textY + 1*lineH, col4W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock(GetLocale("SATELLITE_RECEIVERS")+":", col3, textY + 2*lineH, col3W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.4,True, True)
		skin.fontNormal.drawBlock(MathHelper.NumberToString(GetStationMapCollection().GetAveragePopulationSatelliteShare()*100, 2)+"%", col4, textY + 2*lineH, col4W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)
		skin.fontNormal.drawBlock(GetLocale("CABLE_NETWORK_RECEIVERS")+":", col3, textY + 3*lineH, col3W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.4,True, True)
		skin.fontNormal.drawBlock(MathHelper.NumberToString(GetStationMapCollection().GetAveragePopulationCableShare()*100, 2)+"%", col4, textY + 3*lineH, col4W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)

		local statusText:string = GetLocale("AS_OF_DATEX").Replace("%DATEX%", GetWorldTime().GetFormattedGameDate(GetStationMapCollection().GetLastCensusTime()))
		statusText :+ ". " + GetLocale("NEXT_CENSUS_AT_DATEX").Replace("%DATEX%", GetWorldTime().GetFormattedGameDate(GetStationMapCollection().GetNextCensusTime()))
		skin.fontNormal.drawBlock("|i|"+statusText+"|/i|", contentArea.GetX() + 5, textY + 4*lineH, contentArea.GetW()- 10,  30, ALIGN_CENTER_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
		currentY :+ countryInformationHeight


		'=== LIST ===
		skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), sectionListHeight + sectionListHeaderHeight, "2")
		skin.fontNormal.drawBlock(GetLocale("STATIONMAP_SECTION_NAME"), contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  headerHeight, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
		skin.fontNormal.drawBlock("Sendegenehm.", contentArea.GetX() + 5 + 0.2*contentArea.GetW(), currentY, contentArea.GetW() - 10,  headerHeight, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
		skin.fontNormal.drawBlock("Image", contentArea.GetX() + 5 + 0.4*contentArea.GetW(), currentY, contentArea.GetW() - 10,  headerHeight, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
		currentY :+ sectionListHeaderHeight

'		skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), sectionListHeight, "2")
		sectionList.Draw()
		currentY :+ sectionListHeight


		'=== SECTION DETAILS ===
		If selectedSection
			'col1W :- 30
			'col2  :- 30
			'col2W :+ 30
			Local titleText:String = GetLocale("MAP_COUNTRY_"+ selectedSection.name)

			skin.RenderContent(contentArea.GetX(), currentY, contentArea.GetW(), 17, "1_top")
'			currentY :+ 2
			skin.fontNormal.drawBlock("|b|"+titleText+"|/b|", contentArea.GetX() + 5, currentY, contentArea.GetW() - 10,  16, ALIGN_CENTER_CENTER, titleColor, TBitmapFont.STYLE_SHADOW,1,0.2,True, True)
			currentY :+ 14 + 3
			skin.RenderContent(contentArea.GetX(), currentY , contentArea.GetW(), detailsH - 17, "1")

			textY = currentY + 2

			local pressureGroups:string 'TVTPressureGroup.GetAsString(pgID).Split(",")
			local pressureGroupIndexes:int[] = TVTPressureGroup.GetIndexes(selectedSection.pressureGroups)
			if not pressureGroupIndexes then throw "ups"
			For local pgIndex:int = eachIn TVTPressureGroup.GetIndexes(selectedSection.pressureGroups)
				if pressureGroups
					pressureGroups :+ ", " + GetLocale("PRESSURE_GROUPS_"+ TVTPressureGroup.GetAsString( TVTPressureGroup.GetAtIndex(pgIndex) ))
				else
					pressureGroups :+ GetLocale("PRESSURE_GROUPS_"+ TVTPressureGroup.GetAsString( TVTPressureGroup.GetAtIndex(pgIndex) ))
				endif
			Next
			skin.fontNormal.drawBlock("|b|"+GetLocale("POPULATION")+":|/b|", col1, textY + 0*lineH, col1W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
			skin.fontNormal.drawBlock(TFunctions.DottedValue(selectedSection.GetPopulation()), col2, textY + 0*lineH, col2W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)

			local cableNetworkText:string
			if GetStationMapCollection().GetCableNetworksInSectionCount(selectedSection.name, True) > 0
				cableNetworkText:string = GetLocale("YES")
			else
				cableNetworkText:string = GetLocale("NO")
				rem
				local firstCableNetwork:TStationMap_CableNetwork = GetStationMapCollection().GetFirstCableNetworkBySectionName(selectedSection.name)
				if firstCableNetwork and firstCableNetwork.launchTime >= 0
					cableNetworkText = GetWorldTime().GetFormattedDate(firstCableNetwork.launchTime)
				else
					cableNetworkText = "-/-"
				endif
				endrem
			endif
			skin.fontNormal.drawBlock("|b|"+GetLocale("CABLE_NETWORK")+":|/b|", col1, textY + 1*lineH, col1W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
			skin.fontNormal.drawBlock(cableNetworkText, col2, textY + 1*lineH, col2W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)

			skin.fontNormal.drawBlock("|b|"+GetLocale("PRESSURE_GROUPS")+":|/b| " + pressureGroups, col1, textY + 2*lineH, col1W + col2W,  3*14, ALIGN_LEFT_TOP, skin.textColorNeutral)

			skin.fontNormal.drawBlock("|b|"+GetLocale("BROADCAST_PERMISSION")+":|/b|", col3, textY + 0*lineH, col3W+col4W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral)
			skin.fontNormal.drawBlock(GetLocale("PRICE")+":", col3, textY + 1*lineH, col3W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.4,True, True)
			skin.fontNormal.drawBlock(TFunctions.DottedValue(selectedSection.GetBroadcastPermissionPrice(owner))+" " + GetLocale("CURRENCY"), col4, textY + 1*lineH, col4W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)
			skin.fontNormal.drawBlock(GetLocale("CHANNEL_IMAGE")+":", col3, textY + 2*lineH, col3W,  14, ALIGN_LEFT_CENTER, skin.textColorNeutral, TBitmapFont.STYLE_SHADOW,1,0.4,True, True)
			skin.fontNormal.drawBlock(GetLocale("MIN_VALUEX").Replace("%VALUEX%", MathHelper.NumberToString(100*selectedSection.broadcastPermissionMinimumChannelImage, 1, True)+"%"), col4, textY + 2*lineH, col4W,  14, ALIGN_RIGHT_CENTER, skin.textColorNeutral)
			if selectedSection.HasBroadcastPermission(owner)
				skin.fontNormal.drawBlock(getLocale("BROADCAST_PERMISSION_EXISTING"), col3, textY + 3*lineH, col3W+col4W, 14, ALIGN_LEFT_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			else
				skin.fontNormal.drawBlock(getLocale("BROADCAST_PERMISSION_MISSING"), col3, textY + 3*lineH, col3W+col4W, 14, ALIGN_LEFT_CENTER, subHeaderColor, TBitmapFont.STYLE_EMBOSS,1,0.75,True, True)
			endif

'nur , wenn keine Genehmigung vorliegt
'			If Not GetPublicImage(owner) Or GetPublicImage(owner).GetAverageImage() < selectedSection.broadcastPermissionMinimumChannelImage
		EndIf


		skin.RenderBorder(area.GetX(), area.GetY(), area.GetW(), area.GetH())

		'debug
		Rem
		DrawRect(contentArea.GetX(), contentArea.GetY(), 20, contentArea.GetH() )
		Setcolor 255,0,0
		DrawRect(contentArea.GetX() + 10, contentArea.GetY(), 20, headerHeight )
		Setcolor 255,255,0
		DrawRect(contentArea.GetX() + 20, contentArea.GetY() + headerHeight, 20, sectionListHeight )
		Setcolor 255,0,255
		DrawRect(contentArea.GetX() + 30, contentArea.GetY() + headerHeight + listHeight, 20, detailsH )
		endrem

		For Local t:TTooltipBase = EachIn tooltips
			t.Render()
		Next
	End Method
End Type




Type TScreenHandler_StationMap
	Global guiAccordeon:TGUIAccordeon
	Global satelliteSelectionFrame:TSatelliteSelectionFrame
	Global mapInformationFrame:TStationMapInformationFrame

	Global actionMode:Int = 0
	Global actionConfirmed:Int = False

	Global mouseoverSection:TStationMapSection
	Global selectedStation:TStationBase
	Global mouseoverStation:TStationBase
	Global mouseoverStationPosition:TVec2D


	Global guiShowStations:TGUICheckBox[4]
	Global guiFilterButtons:TGUICheckBox[3]
	Global guiInfoButton:TGUIButton
	Global mapBackgroundSpriteName:String = ""


	Global currentSubRoom:TRoomBase = Null
	Global lastSubRoom:TRoomBase = Null

	Global LS_stationmap:TLowerString = TLowerString.Create("stationmap")

	Global _eventListeners:TLink[]

	Const PRODUCT_NONE:Int = 0
	Const PRODUCT_STATION:Int = 1
	Const PRODUCT_CABLE_NETWORK:Int = 2
	Const PRODUCT_SATELLITE:Int = 3

	Const MODE_NONE:Int                      =  0
	Const MODE_BUY:Int                       =  1
	Const MODE_SELL:Int                      =  2
	Const MODE_SELL_ANTENNA:Int              =  4 + MODE_SELL
	Const MODE_BUY_ANTENNA:Int               =  8 + MODE_BUY
	Const MODE_SELL_CABLE_NETWORK_UPLINK:Int = 16 + MODE_SELL
	Const MODE_BUY_CABLE_NETWORK_UPLINK:Int  = 32 + MODE_BUY
	Const MODE_SELL_SATELLITE_UPLINK:Int     = 64 + MODE_SELL
	Const MODE_BUY_SATELLITE_UPLINK:Int      =128 + MODE_BUY

	'=== THEME CONFIG === 
	Const titleH:Int = 18
	Const subTitleH:Int = 16
	Const sheetWidth:Int = 211
	Const buttonAreaPaddingY:Int = 4
	Const boxAreaPaddingY:Int = 4
	

	Function Initialize:Int()
		Local screen:TIngameScreen = TIngameScreen(ScreenCollection.GetScreen("screen_office_stationmap"))
		If Not screen Then Return False

		'remove background from stationmap screen
		'(we draw the map and then the screen bg)
		If screen.backgroundSpriteName <> ""
			mapBackgroundSpriteName = screen.backgroundSpriteName
			screen.backgroundSpriteName = ""
		EndIf
		
		'=== create gui elements if not done yet
		If Not guiInfoButton
			guiAccordeon = New TGameGUIAccordeon.Create(New TVec2D.Init(586, 64), New TVec2D.Init(211, 317), "", "STATIONMAP")
			TGameGUIAccordeon(guiAccordeon).skinName = "stationmapPanel"

			Local p:TGUIAccordeonPanel
			p = New TGameGUIAntennaPanel.Create(New TVec2D.Init(-1, -1), New TVec2D.Init(-1, -1), "Stations", "STATIONMAP")
			p.Open()
			guiAccordeon.AddPanel(p, 0)
			p = New TGameGUICableNetworkPanel.Create(New TVec2D.Init(-1, -1), New TVec2D.Init(-1, -1), "Cable Networks", "STATIONMAP")
			guiAccordeon.AddPanel(p, 1)
			p = New TGameGUISatellitePanel.Create(New TVec2D.Init(-1, -1), New TVec2D.Init(-1, -1), "Satellites", "STATIONMAP")
			guiAccordeon.AddPanel(p, 2)


			'== info panel
			guiInfoButton = New TGUIButton.Create(New TVec2D.Init(610, 15), New TVec2D.Init(20, 28), "", "STATIONMAP")
			guiInfoButton.spriteName = "gfx_gui_button.datasheet"
			guiInfoButton.SetTooltip( New TGUITooltipBase.Initialize(GetLocale("SHOW_MAP_DETAILS"), GetLocale("CLICK_TO_SHOW_ADVANCED_MAP_INFORMATION"), New TRectangle.Init(0,0,-1,-1)) )
			guiInfoButton.GetTooltip()._minContentDim = New TVec2D.Init(120,-1)
			guiInfoButton.GetTooltip()._maxContentDim = New TVec2D.Init(150,-1)
			guiInfoButton.GetTooltip().SetOrientationPreset("BOTTOM", 10)

			For Local i:Int = 0 Until guiFilterButtons.length
				guiFilterButtons[i] = New TGUICheckBox.Create(New TVec2D.Init(695 + i*23, 30 ), New TVec2D.Init(20, 20), String(i + 1), "STATIONMAP")
				guiFilterButtons[i].ShowCaption(False)
				guiFilterButtons[i].data.AddNumber("stationType", i+1)
				'guiFilterButtons[i].SetUnCheckedTintColor( TColor.Create(255,255,255) )
				guiFilterButtons[i].SetUnCheckedTintColor( TColor.Create(210,210,210, 0.75) )
				guiFilterButtons[i].SetCheckedTintColor( TColor.Create(245,255,240) )

				guiFilterButtons[i].uncheckedSpriteName = "gfx_datasheet_icon_" + TVTStationType.GetAsString(i+1) + ".off"
				guiFilterButtons[i].checkedSpriteName = "gfx_datasheet_icon_" + TVTStationType.GetAsString(i+1) + ".on"

				guiFilterbuttons[i].SetTooltip( New TGUITooltipBase.Initialize("", GetLocale("TOGGLE_DISPLAY_OF_STATIONTYPE").Replace("%STATIONTYPE%", GetLocale(TVTStationType.GetAsString(i+1)+"S")), New TRectangle.Init(0,60,-1,-1)) )
				guiFilterbuttons[i].GetTooltip()._minContentDim = New TVec2D.Init(80,-1)
				guiFilterbuttons[i].GetTooltip()._maxContentDim = New TVec2D.Init(120,-1)
				guiFilterbuttons[i].GetTooltip().SetOrientationPreset("BOTTOM", 10)
			Next


			For Local i:Int = 0 To 3
				guiShowStations[i] = New TGUICheckBox.Create(New TVec2D.Init(695 + i*23, 30 ), New TVec2D.Init(20, 20), String(i + 1), "STATIONMAP")
				guiShowStations[i].ShowCaption(False)
				guiShowStations[i].data.AddNumber("playerNumber", i+1)

				guiShowStations[i].SetTooltip( New TGUITooltipBase.Initialize("", GetLocale("TOGGLE_DISPLAY_OF_PLAYER_X").Replace("%X%", i+1), New TRectangle.Init(0,60,-1,-1)) )
				guiShowStations[i].GetTooltip()._minContentDim = New TVec2D.Init(80,-1)
				guiShowStations[i].GetTooltip()._maxContentDim = New TVec2D.Init(120,-1)
				guiShowStations[i].GetTooltip().SetOrientationPreset("BOTTOM", 10)
			Next
		EndIf


		satelliteSelectionFrame = New TSatelliteSelectionFrame
		mapInformationFrame = New TStationMapInformationFrame


		'=== reset gui element options to their defaults
		For Local i:Int = 0 Until guiShowStations.length
			guiShowStations[i].SetChecked( True, False)
		Next
		For Local i:Int = 0 Until guiFilterButtons.length
			guiFilterButtons[i].SetChecked( True, False)
		Next


		'=== remove all registered event listeners
		EventManager.unregisterListenersByLinks(_eventListeners)
		_eventListeners = New TLink[0]


		'=== register event listeners
		'unset "selected station" when other panels get opened 
		_eventListeners :+ [ EventManager.registerListenerFunction( "guiaccordeon.onOpenPanel", OnOpenOrCloseAccordeonPanel, guiAccordeon ) ]
		_eventListeners :+ [ EventManager.registerListenerFunction( "guiaccordeon.onClosePanel", OnOpenOrCloseAccordeonPanel, guiAccordeon ) ]

		'we have to refresh the gui station list as soon as we remove or add a station
		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.removeStation", OnChangeStationMapStation ) ]
		_eventListeners :+ [ EventManager.registerListenerFunction( "stationmap.addStation", OnChangeStationMapStation ) ]
'		_eventListeners :+ [ EventManager.registerListenerFunction( "station.SetActive", OnChangeStation ) ]
'		_eventListeners :+ [ EventManager.registerListenerFunction( "station.SetInactive", OnChangeStation ) ]
		_eventListeners :+ [ EventManager.registerListenerFunction( "station.onShutDown", OnChangeStation ) ]
		_eventListeners :+ [ EventManager.registerListenerFunction( "station.onResume", OnChangeStation ) ]

		'player enters station map screen - set checkboxes according to station map config
		_eventListeners :+ [ EventManager.registerListenerFunction("screen.onBeginEnter", onEnterStationMapScreen, screen ) ]

		'register checkbox changes
		For Local i:Int = 0 Until guiShowStations.length
			_eventListeners :+ [ EventManager.registerListenerFunction("guiCheckBox.onSetChecked", OnSetChecked_StationMapFilters, guiShowStations[i]) ]
		Next
		For Local i:Int = 0 Until guiFilterButtons.length
			_eventListeners :+ [ EventManager.registerListenerFunction("guiCheckBox.onSetChecked", OnSetChecked_StationMapFilters, guiFilterButtons[i]) ]
		Next

		_eventListeners :+ [ EventManager.registerListenerFunction( "guiobject.onClick", OnClickInfoButton, guiInfoButton ) ]
	
		'to update/draw the screen
		_eventListeners :+ TRoomHandler._RegisterScreenHandler( onUpdateStationMap, onDrawStationMap, screen )

		'(re-)localize content
		SetLanguage()
	End Function


	Function SetLanguage()
		If Not guiInfoButton Then Return
		
		guiInfoButton.SetCaption("?")

		guiInfoButton.GetTooltip().SetTitle( GetLocale("SHOW_MAP_DETAILS") )
		guiInfoButton.GetTooltip().SetContent( GetLocale("CLICK_TO_SHOW_ADVANCED_MAP_INFORMATION") )

		For Local i:Int = 0 Until guiFilterButtons.length
			guiFilterbuttons[i].GetTooltip().SetContent( GetLocale("TOGGLE_DISPLAY_OF_STATIONTYPE").Replace("%STATIONTYPE%", "|b|"+GetLocale(TVTStationType.GetAsString(i+1)+"S")+"|/b|") )
		Next
		
		For Local i:Int = 0 To 3
			guiShowStations[i].GetTooltip().SetContent( GetLocale("TOGGLE_DISPLAY_OF_PLAYER_X").Replace("%X%", i+1) )
		Next

		For Local p:TGameGUIBasicStationmapPanel = EachIn guiAccordeon.panels
			p.SetLanguage()
		Next

		If satelliteSelectionFrame Then satelliteSelectionFrame.SetLanguage()
		If mapInformationFrame Then mapInformationFrame.SetLanguage()
	End Function


	Function SetActionMode(mode:Int)
		actionMode = mode
	End Function


	Function HasActionMode:Int(mode:Int, flag:Int)
		Return (mode & flag) > 0
	End Function


	Function IsInBuyActionMode:Int()
		Return HasActionMode(actionMode, MODE_BUY)
	End Function


	Function IsInSellActionMode:Int()
		Return HasActionMode(actionMode, MODE_SELL)
	End Function


	Function _DrawStationMapInfoPanel:Int(x:Int,y:Int, room:TRoomBase)
		'=== PREPARE VARIABLES ===
		Local sheetHeight:Int = 0 'calculated later

		Local skin:TDatasheetSkin = GetDatasheetSkin("stationmapPanel")

		Local contentW:Int = skin.GetContentW(sheetWidth)
		Local contentX:Int = x + skin.GetContentX()
		Local contentY:Int = y + skin.GetContentY()

		'=== CALCULATE SPECIAL AREA HEIGHTS ===
		Local buttonH:Int = 0
		Local buttonAreaH:Int = 0, bottomAreaH:Int = 0

		buttonAreaH = guiInfoButton.rect.GetH() + buttonAreaPaddingY*2

		bottomAreaH :+ buttonAreaH
	
		'total height
		sheetHeight = bottomAreaH + skin.GetContentPadding().GetTop() + skin.GetContentPadding().GetBottom()


		'=== RENDER ===
	

		'=== BUTTON / CHECKBOX AREA ===
		skin.RenderContent(contentX, contentY, contentW, bottomAreaH, "1_top")


		'=== BUTTON ===
		'move buy button accordingly
		contentY :+ buttonAreaPaddingY
		Local buttonX:Int = contentX + 5
		guiInfoButton.rect.dimension.SetX(25)
		guiInfoButton.rect.position.SetXY(contentX + 5, contentY)
		buttonX :+ guiInfoButton.rect.GetW() + 6

		For Local i:Int = 0 Until guiFilterButtons.length
			guiFilterButtons[i].rect.position.SetXY(buttonX, contentY + ((guiInfoButton.rect.GetH() - guiFilterButtons[i].rect.GetH())/2) )
			buttonX :+ guiFilterButtons[i].rect.GetW()
		Next
		
		For Local i:Int = 0 Until guiShowStations.length
			guiShowStations[i].rect.position.SetXY(contentX + 8 + 50+15+30 + 21*i, contentY + ((guiInfoButton.rect.GetH() - guiShowStations[i].rect.GetH())/2) )
		Next
		contentY :+ buttonAreaPaddingY


		'=== OVERLAY / BORDER ===
		skin.RenderBorder(x, y, sheetWidth, sheetHeight)
	End Function

	
 	Function onDrawStationMap:Int( triggerEvent:TEventBase )
		'local screen:TScreen	= TScreen(triggerEvent._sender)
		Local room:TRoomBase = TRoomBase( triggerEvent.GetData().get("room") )
		If Not room Then Return 0

		'draw map
		GetSpriteFromRegistry("map_Surface").Draw(0,0)

		'disable sections when there is no active cable network there
		If actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
			Local foundDisabledSections:Int = 0
			For Local section:TStationMapSection = EachIn GetStationMapCollection().sections
				If section.activeCableNetworkCount = 0
					DrawImage(section.GetDisabledOverlay(), section.rect.GetX(), section.rect.GetY())
					foundDisabledSections :+ 1
				EndIf
			Next
			'draw normal ones on top - but only if needed
			'this is done to avoid "available sections" to get hidden
			If foundDisabledSections > 0
				For Local section:TStationMapSection = EachIn GetStationMapCollection().sections
					If section.activeCableNetworkCount > 0
						DrawImage(section.GetEnabledOverlay(), section.rect.GetX(), section.rect.GetY())
					EndIf
				Next
			EndIf
		EndIf

		'gray out sections when there is no broadcast permission
		If actionMode = MODE_BUY_ANTENNA
			Local oldCol:TColor = New TColor.Get()
			Local foundNoPermissionSections:Int = 0
			For Local section:TStationMapSection = EachIn GetStationMapCollection().sections
				If Not section.HasBroadcastPermission(room.owner)
					SetColor 225,175,50
					SetAlpha 0.40 * oldCol.a
					DrawImage(section.GetDisabledOverlay(), section.rect.GetX(), section.rect.GetY())
					'SetAlpha 0.25 * oldCol.a
					'section.GetHighlightBorderSprite().Draw(section.rect.GetX(), section.rect.GetY())
					
					foundNoPermissionSections :+ 1
				EndIf
			Next
			oldCol.setRGBA()
			'draw normal ones on top - but only if needed
			'this is done to avoid "available sections" to get hidden
			If foundNoPermissionSections > 0
				For Local section:TStationMapSection = EachIn GetStationMapCollection().sections
					If section.HasBroadcastPermission(room.owner)
						DrawImage(section.GetEnabledOverlay(), section.rect.GetX(), section.rect.GetY())
					EndIf
				Next
			EndIf
		EndIf
		
		'when selecting a station position with the mouse or a
		'cable network or a satellite
		If actionMode = MODE_BUY_ANTENNA Or actionMode = MODE_BUY_SATELLITE_UPLINK Or actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
			SetAlpha Float(0.8 + 0.2 * Sin(MilliSecs()/6))
			DrawImage(GetStationMapCollection().populationImageOverlay, 0,0)
			SetAlpha 1.0
		EndIf



		'overlay with alpha channel screen
		GetSpriteFromRegistry(mapBackgroundSpriteName).Draw(0,0)


		_DrawStationMapInfoPanel(586, 7, room)

		'debug draw station map sections
		'TStationMapSection.DrawAll()

		'backgrounds
		If mouseoverStation And mouseoverStation = selectedStation
			'avoid drawing it two times...
			mouseoverStation.DrawBackground(True, True)
		Else
			'also draw the station used for buying/searching
			If mouseoverStation Then mouseoverStation.DrawBackground(False, True)
			'also draw the station used for buying/searching
			If selectedStation Then selectedStation.DrawBackground(True, False)
		EndIf

		
		'draw stations and tooltips
		GetStationMap(room.owner).Draw()

		'also draw the station used for buying/searching
		If mouseoverStation Then mouseoverStation.Draw()
		'also draw the station used for buying/searching
		If selectedStation Then selectedStation.Draw(True)


		'draw activation tooltip for all other stations
		'- only draw them while NOT placing a new one (to ease spot finding)
		If actionMode <> MODE_BUY_ANTENNA And actionMode <> MODE_BUY_SATELLITE_UPLINK And actionMode <> MODE_BUY_CABLE_NETWORK_UPLINK
			For Local station:TStationBase = EachIn GetStationMap(room.owner).Stations
				If mouseoverStation = station Then Continue
				If station.IsActive() Then Continue

				station.DrawActivationTooltip()
			Next
		EndIf
		
		If mapInformationFrame.IsOpen()
			mapInformationFrame.Draw()
		EndIf
		

		GUIManager.Draw( LS_stationmap )

		For Local i:Int = 0 To 3
			guiShowStations[i].SetUncheckedTintColor( GetPlayerBase(i+1).color.Copy().AdjustBrightness(+0.25).AdjustSaturation(-0.35), False)
			guiShowStations[i].SetCheckedTintColor( GetPlayerBase(i+1).color ) '.Copy().AdjustBrightness(0.25)
			'guiShowStations[i].tintColor = GetPlayerBase(i+1).color '.Copy().AdjustBrightness(0.25)
		Next

		GetGameBase().cursorstate = 0
		'draw a kind of tooltip over a mouseoverStation
		If mouseoverStation
			GetGameBase().cursorstate = 1
			mouseoverStation.DrawInfoTooltip()
		else
			'if over a section, draw special tooltip displaying reasons
			'why we cannot build there
			If mouseoverSection and currentSubRoom
				if actionMode = MODE_BUY_ANTENNA
					GetGameBase().cursorstate = 3
					mouseoverSection.DrawChannelStatusTooltip(currentSubRoom.owner, TVTStationType.ANTENNA )
				elseif actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
					GetGameBase().cursorstate = 3
					mouseoverSection.DrawChannelStatusTooltip(currentSubRoom.owner, TVTStationType.CABLE_NETWORK_UPLINK )
				endif
			EndIf
		EndIf


		'draw satellite selection frame
'		if actionMode = MODE_BUY_SATELLITE_UPLINK
			If satelliteSelectionFrame.IsOpen()
				satelliteSelectionFrame.Draw()
			EndIf
'		endif
	End Function


	Function onUpdateStationMap:Int( triggerEvent:TEventBase )
		'local screen:TScreen	= TScreen(triggerEvent._sender)
		Local room:TRoomBase = TRoomBase( triggerEvent.GetData().get("room") )
		If Not room Then Return 0

		'backup room if it changed
		If currentSubRoom <> lastSubRoom
			lastSubRoom = currentSubRoom

			'if we changed the room meanwhile - we have to rebuild the stationList
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(0)).RefreshList()
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(1)).RefreshList()
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(2)).RefreshList()
		EndIf

		currentSubRoom = room

		GetStationMap(room.owner).Update()

		'process right click
		If MOUSEMANAGER.isClicked(2) Or MouseManager.IsLongClicked(1)
			Local reset:Int = (selectedStation Or mouseoverStation Or satelliteSelectionFrame.IsOpen() or mapInformationFrame.IsOpen())

			If mapInformationFrame.IsOpen()
				mapInformationFrame.Close()
			EndIf

			if satelliteSelectionFrame.IsOpen()
				'reassigning to an empty one?
				if selectedStation 'and selectedStation.IsShutDown()
					satelliteSelectionFrame.SelectSatellite(null)
					satelliteSelectionFrame.Close()
				else
					ResetActionMode(0)
				endif
			else
				ResetActionMode(0)
			endif

			If reset
				MOUSEMANAGER.ResetKey(2)
				MOUSEMANAGER.ResetKey(1) 'also normal clicks
			EndIf
		EndIf


		If satelliteSelectionFrame.IsOpen()
			If Not selectedStation And TScreenHandler_StationMap.actionMode <> TScreenHandler_StationMap.MODE_BUY_SATELLITE_UPLINK
				satelliteSelectionFrame.Close()
			EndIf
		EndIf


		'If actionMode = MODE_BUY_ANTENNA or actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
		'	mouseoverSection = GetStationMapCollection().GetSection( MouseManager.GetPosition().GetIntX(), MouseManager.GetPosition().GetIntY() )
		'EndIf
rem
		If not mouseoverStation and mouseoverSection and currentSubRoom
			if actionMode = MODE_BUY_ANTENNA or actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
				GetGameBase().cursorstate = 3
				print "invalid"
			endif
		endif
endrem		

		'buying stations using the mouse
		'1. searching
		If actionMode = MODE_BUY_ANTENNA
			'create a temporary station if not done yet
			If Not mouseoverStation Then mouseoverStation = GetStationMap(room.owner).GetTemporaryAntennaStation( MouseManager.GetPosition().GetIntX(), MouseManager.GetPosition().GetIntY() )
			Local mousePos:TVec2D = New TVec2D.Init( MouseManager.x, MouseManager.y)

			'if the mouse has moved - refresh the station data and move station
			If Not mouseoverStation.pos.isSame( mousePos )
				mouseoverStation.pos.CopyFrom(mousePos)
				mouseoverStation.refreshData()
				'refresh state information
				mouseoverStation.GetSectionName(True)
			EndIf

			Local hoveredMapSection:TStationMapSection
			If mouseoverStation Then hoveredMapSection = GetStationMapCollection().GetSection(Int(mouseoverStation.pos.x), Int(mouseoverStation.pos.y))

			'if mouse gets clicked, we store that position in a separate station
			If MOUSEMANAGER.isClicked(1)
				'check reach and valid federal state
				If hoveredMapSection And mouseoverStation.GetReach() > 0
					selectedStation = GetStationMap(room.owner).GetTemporaryAntennaStation( mouseoverStation.pos.GetIntX(), mouseoverStation.pos.GetIntY() )
				EndIf
			EndIf

			'no antennagraphic in foreign countries
			'-> remove the station so it wont get displayed
			If Not hoveredMapSection Or mouseoverStation.GetReach() <= 0
				mouseoverStation = Null
				mouseoverStationPosition = Null
			EndIf

			If selectedStation
				Local selectedMapSection:TStationMapSection = GetStationMapCollection().GetSection(Int(selectedStation.pos.x), Int(selectedStation.pos.y))

				If Not selectedMapSection Or selectedStation.GetReach() <= 0 Then selectedStation = Null
			EndIf


		ElseIf actionMode = MODE_BUY_CABLE_NETWORK_UPLINK
			'if the mouse has moved or nothing was created yet
			'refresh the station data and move station
			If Not mouseoverStation Or Not mouseoverStationPosition Or Not mouseoverStationPosition.isSame( MouseManager.GetPosition() )
				mouseoverSection = GetStationMapCollection().GetSection( MouseManager.GetPosition().GetIntX(), MouseManager.GetPosition().GetIntY() )
				If mouseoverSection
					Local cableNetwork:TStationMap_CableNetwork = GetStationMapCollection().GetFirstCableNetworkBySectionName(mouseoverSection.name)
					If cableNetwork And cableNetwork.IsLaunched()
						mouseoverStationPosition = MouseManager.GetPosition().Copy()
						mouseoverStation = GetStationMap(room.owner).GetTemporaryCableNetworkUplinkStationByCableNetwork( cableNetwork )
						mouseoverStation.refreshData()
						'refresh state information
						'DO NOT TRUST: Brandenburg's center is berlin - leading
						'              to sectionname = berlin
						mouseOverStation.sectionName = mouseoverSection.name
						'mouseoverStation.GetSectionName(true)
					'remove cache
					Else
						mouseoverStation = Null
						mouseoverStationPosition = Null
					EndIf
				'remove cache
				ElseIf mouseoverStation
					mouseoverStation = Null
					mouseoverStationPosition = Null
				EndIf
			EndIf

			Local hoveredMapSection:TStationMapSection
			If mouseoverStation And mouseoverStationPosition
				hoveredMapSection = GetStationMapCollection().GetSection(Int(mouseoverStationPosition.x), Int(mouseoverStationPosition.y))
			EndIf

			'if mouse gets clicked, we store that position in a separate station
			If MOUSEMANAGER.isClicked(1)
				'check reach and valid federal state
				If hoveredMapSection And mouseoverStation.GetReach() > 0
					Local cableNetwork:TStationMap_CableNetwork = GetStationMapCollection().GetCableNetworkByGUID(TStationCableNetworkUplink(mouseOverStation).cableNetworkGUID)
					If cableNetwork And cableNetwork.IsLaunched()
						selectedStation = GetStationMap(room.owner).GetTemporaryCableNetworkUplinkStationByCableNetwork( cableNetwork )
						If selectedStation
							selectedStation.refreshData()
							'refresh state information
							selectedStation.sectionName = hoveredMapSection.name
							'selectedStation.GetSectionName(true)
						EndIf
					EndIf
				EndIf
			EndIf

			'no antennagraphic in foreign countries
			'-> remove the station so it wont get displayed
			If Not hoveredMapSection Or mouseoverStation.GetReach() <= 0
				mouseoverStation = Null
				mouseoverStationPosition = Null
			EndIf

			If selectedStation
				Local selectedMapSection:TStationMapSection = GetStationMapCollection().GetSection(Int(selectedStation.pos.x), Int(selectedStation.pos.y))

				If Not selectedMapSection Or selectedStation.GetReach() <= 0 Then selectedStation = Null
			EndIf
			
		ElseIf actionMode = MODE_BUY_SATELLITE_UPLINK
			If satelliteSelectionFrame.selectedSatellite
				Local satLink:TStationSatelliteUplink = TStationSatelliteUplink(selectedStation)
				'only create a temporary sat link station if a satellite was
				'selected
				If satelliteSelectionFrame.selectedSatellite
					If Not satLink Or satLink.satelliteGUID <> satelliteSelectionFrame.selectedSatellite.GetGUID()
						selectedStation = GetStationMap(room.owner).GetTemporarySatelliteUplinkStationBySatelliteGUID( satelliteSelectionFrame.selectedSatellite.GetGUID() )
						selectedStation.refreshData()
					EndIf
				EndIf
			EndIf

Rem
			'if the mouse has moved or nothing was created yet
			'refresh the station data and move station
			if not mouseoverStation or not mouseoverStationPosition or not mouseoverStationPosition.isSame( MouseManager.GetPosition() )
				local mouseOverSection:TStationMapSection = GetStationMapCollection().GetSection( MouseManager.GetPosition().GetIntX(), MouseManager.GetPosition().GetIntY() )
				if mouseOverSection
					mouseoverStationPosition = MouseManager.GetPosition().Copy()
					mouseoverStation = GetStationMap(room.owner).GetTemporarySatelliteStation( mouseOverSection.name )
					mouseoverStation.refreshData()
					'refresh state information
					mouseOverStation.sectionName = mouseOverSection.name
				'remove cache
				elseif mouseoverStation
					mouseoverStation = null
					mouseoverStationPosition = null
				endif
			endif

			local hoveredMapSection:TStationMapSection
			if mouseoverStation and mouseoverStationPosition
				hoveredMapSection = GetStationMapCollection().GetSection(Int(mouseoverStationPosition.x), Int(mouseoverStationPosition.y))
			endif

			'if mouse gets clicked, we store that position in a separate station
			if MOUSEMANAGER.isClicked(1)
				'check reach and valid federal state
				if hoveredMapSection and mouseoverStation.GetReach() > 0
					selectedStation = GetStationMap(room.owner).GetTemporarySatelliteStation( mouseoverStation.sectionName )
					selectedStation.refreshData()
					'refresh state information
					selectedStation.sectionName = hoveredMapSection.name
				endif
			endif

			'no antennagraphic in foreign countries
			'-> remove the station so it wont get displayed
			if not hoveredMapSection or mouseoverStation.GetReach() <= 0
				mouseoverStation = null
				mouseoverStationPosition = null
			endif

			if selectedStation
				local selectedMapSection:TStationMapSection = GetStationMapCollection().GetSection(Int(selectedStation.pos.x), Int(selectedStation.pos.y))

				if not selectedMapSection or selectedStation.GetReach() <= 0 then selectedStation = null
			endif
endrem
		EndIf



		'select satellite of the currently selected satlink
		If TStationSatelliteUplink(selectedStation)
			Local satLink:TStationSatelliteUplink = TStationSatelliteUplink(selectedStation)
			Local satellite:TStationMap_Satellite = GetStationMapCollection().GetSatelliteByGUID( satLink.satelliteGUID )
			If satellite <> satelliteSelectionFrame.selectedSatellite
				if not satLink.IsShutDown()
					satelliteSelectionFrame.SelectSatellite( GetStationMapCollection().GetSatelliteByGUID( satLink.satelliteGUID ) )
				endif
			EndIf
		EndIf


		'no info screen while something is selected
		if selectedStation 
			if TScreenHandler_StationMap.mapInformationFrame.IsOpen() Then TScreenHandler_StationMap.mapInformationFrame.Close()
		endif


		If mapInformationFrame.IsOpen()
			'no interaction
			'if actionMode <> MODE_NONE Then ResetActionMode(MODE_NONE)
			
			mapInformationFrame.Update()
		EndIf
		

		If satelliteSelectionFrame.IsOpen()
			satelliteSelectionFrame.Update()
		EndIf

		
		GUIManager.Update( LS_stationmap )
	End Function


	Function OnOpenOrCloseAccordeonPanel:Int( triggerEvent:TEventBase )
		Local accordeon:TGameGUIAccordeon = TGameGUIAccordeon(triggerEvent.GetSender())
		If Not accordeon Or accordeon <> guiAccordeon Then Return False 

		Local panel:TGameGUIAccordeonPanel = TGameGUIAccordeonPanel(triggerEvent.GetData().Get("panel"))

		If triggerEvent.IsTrigger("guiaccordeon.onClosePanel".ToLower())
			if mapInformationFrame.IsOpen()
				mapInformationFrame.Close()
			endif
			
			ResetActionMode(TScreenHandler_StationMap.MODE_NONE)
		EndIf
	End Function


	Function OnChangeStationMapStation:Int( triggerEvent:TEventBase )
		'do nothing when not in a room
		If Not currentSubRoom Then Return False

		if TScreenHandler_StationMap.selectedStation
			if triggerEvent.IsTrigger("StationMap.removeStation")
				'reset action mode (so also "selection") if the
				'station just got removed/sold 
				if TScreenHandler_StationMap.selectedStation = TStationBase(triggerEvent.GetData().Get("station"))
					TScreenHandler_StationMap.ResetActionMode(0)
				endif
			endif
		endif

		TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(0)).RefreshList( currentSubRoom.owner )
		TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(1)).RefreshList( currentSubRoom.owner )
		TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(2)).RefreshList( currentSubRoom.owner )
	End Function


	Function OnChangeStation:Int( triggerEvent:TEventBase )
		'do nothing when not in a room
		If Not currentSubRoom Then Return False

		local station:TStationBase = TStationBase(triggerEvent.GetSender())
		if not station or station.owner <> currentSubRoom.owner then return False

		if TStationAntenna(station)
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(0)).RefreshList( currentSubRoom.owner )
		elseif TStationCableNetworkUplink(station)
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(1)).RefreshList( currentSubRoom.owner )
		elseif TStationSatelliteUplink(station)
			TGameGUIBasicStationmapPanel(guiAccordeon.GetPanelAtIndex(2)).RefreshList( currentSubRoom.owner )
		endif
	End Function


	Function ResetActionMode(mode:Int=0)
		SetActionMode(mode)
		actionConfirmed = False
		'remove selection
		selectedStation = Null
		mouseoverStation = Null
		mouseoverStationPosition = Null
	End Function


	'===================================
	'Stationmap: Connect GUI elements
	'===================================

	Function OnClickInfoButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		ResetActionMode(0)

		mapInformationFrame.Open()
	End Function


	Function OnUpdate_ActionButton:Int(triggerEvent:TEventBase)
		Local button:TGUIButton = TGUIButton(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not currentSubRoom Or currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		Select actionMode
			Case MODE_BUY_ANTENNA
				If Not selectedStation
					button.SetValue(GetLocale("SELECT_LOCATION")+" ...")
					button.disable()
				Else
					Local finance:TPlayerFinance = GetPlayerFinance(GetPlayerBase().playerID)
					If finance And finance.canAfford(selectedStation.GetPrice())
						button.SetValue(GetLocale("BUY_STATION"))
						button.enable()
					Else
						button.SetValue(GetLocale("TOO_EXPENSIVE"))
						button.disable()
					EndIf
				EndIf

			Case MODE_SELL_ANTENNA
				'different owner or not paid or not sellable
				If selectedStation
					If selectedStation.owner <> GetPlayerBase().playerID
						button.disable()
						button.SetValue(GetLocale("WRONG_PLAYER"))
					ElseIf Not selectedStation.HasFlag(TVTStationFlag.SELLABLE)
						button.SetValue(GetLocale("UNSELLABLE"))
						button.disable()
					ElseIf Not selectedStation.HasFlag(TVTStationFlag.PAID)
						button.SetValue(GetLocale("SELL_STATION"))
						button.disable()
					Else
						button.SetValue(GetLocale("SELL_STATION"))
						button.enable()
					EndIf
				EndIf

			Case MODE_BUY_CABLE_NETWORK_UPLINK
				If Not selectedStation
					button.SetValue(GetLocale("SELECT_LOCATION")+" ...")
					button.disable()
				Else
					Local finance:TPlayerFinance = GetPlayerFinance(GetPlayerBase().playerID)
					If finance And finance.canAfford(selectedStation.GetPrice())
						button.SetValue(GetLocale("SIGN_UPLINK"))
						button.enable()
					Else
						button.SetValue(GetLocale("TOO_EXPENSIVE"))
						button.disable()
					EndIf
				EndIf

			Case MODE_SELL_CABLE_NETWORK_UPLINK
				'different owner or not paid or not sellable
				If selectedStation
					If selectedStation.owner <> GetPlayerBase().playerID
						button.disable()
						button.SetValue(GetLocale("WRONG_PLAYER"))
					ElseIf Not selectedStation.HasFlag(TVTStationFlag.SELLABLE)
						button.SetValue(GetLocale("UNSELLABLE"))
						button.disable()
					ElseIf Not selectedStation.HasFlag(TVTStationFlag.PAID)
						button.SetValue(GetLocale("CANCEL_UPLINK"))
						button.disable()
					Else
						button.SetValue(GetLocale("CANCEL_UPLINK"))
						button.enable()
					EndIf
				EndIf


			Default
				button.SetValue(GetLocale("NEW_STATION"))
				button.enable()
		End Select
	End Function


	'custom drawing function for list entries
	Function DrawMapStationListEntryContent:Int(obj:TGUIObject)
		Local item:TGUISelectListItem = TGUISelectListItem(obj)
		If Not item Then Return False

		Local station:TStationBase = TStationBase(item.data.Get("station"))
		If Not station Then Return False

		Local sprite:TSprite
		If station.CanBroadcast()
			sprite = GetSpriteFromRegistry(station.listSpriteNameOn)
		Else
			sprite = GetSpriteFromRegistry(station.listSpriteNameOff)
		EndIf

		Local rightValue:String = TFunctions.convertValue(station.GetReach(), 2, 0)
		Local paddingLR:Int = 2
		Local textOffsetX:Int = paddingLR + sprite.GetWidth() + 5
		Local textOffsetY:Int = 2
		Local textW:Int = item.GetScreenWidth() - textOffsetX - paddingLR

		Local currentColor:TColor = New TColor.Get()
		Local entryColor:TColor
		Local rightValueColor:TColor
		Local leftValue:string = item.GetValue()

		'draw with different color according status
		If station.CanBroadcast()
			'colorize antenna for "not sellable ones
			If Not station.HasFlag(TVTStationFlag.SELLABLE)
				entryColor = New TColor.Create(130,80,50, currentColor.a)
				rightValueColor = entryColor
			Else
				entryColor = item.valueColor.copy()
				entryColor.a = currentColor.a
				rightValueColor = entryColor
			EndIf
		Else If station.IsShutdown()
			entryColor = New TColor.Create(90,90,60, currentColor.a)
			leftValue = GetLocale("UNUSED_TRANSMITTER")
			if TStationSatelliteUplink(station) and not TStationSatelliteUplink(station).satelliteGUID 
				rightValue = ""
			endif
			'leftValue = "|color="+(150 + 50*Sin(Millisecs()*0.5))+",90,90|!!|/color| " + leftValue 
			rightValueColor = entryColor
		Else
			entryColor = item.valueColor.copy().AdjustFactor(50)
			entryColor.a = currentColor.a * 0.5
			rightValueColor = entryColor
		EndIf


		'draw antenna
		sprite.Draw(Int(item.GetScreenX() + paddingLR), item.GetScreenY() + 0.5*item.rect.getH(), -1, ALIGN_LEFT_CENTER)
		Local rightValueWidth:Int = item.GetFont().GetWidth(rightValue)
'		item.GetFont().DrawBlock(int(TGUIScrollablePanel(item._parent).scrollPosition.y)+"/"+int(TGUIScrollablePanel(item._parent).scrollLimit.y)+" "+item.GetValue(), Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), textW, int(item.GetScreenHeight() - textOffsetY), ALIGN_LEFT_CENTER, item.valueColor)
		item.GetFont().DrawBlock(leftValue, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), textW - rightValueWidth - 5, Int(item.GetScreenHeight() - textOffsetY), ALIGN_LEFT_CENTER, entryColor, , , , False)
		item.GetFont().DrawBlock(rightValue, Int(item.GetScreenX() + textOffsetX), Int(item.GetScreenY() + textOffsetY), textW, Int(item.GetScreenHeight() - textOffsetY), ALIGN_RIGHT_CENTER, rightValueColor)
	End Function
	

	'set checkboxes according to stationmap config
	Function onEnterStationMapScreen:Int(triggerEvent:TEventBase)
		'only players can "enter screens" - so just use "inRoom"
		Local owner:Int = 0
		If GetPlayer().GetFigure().inRoom Then owner = GetPlayer().GetFigure().inRoom.owner
		If owner = 0 Then owner = GetPlayerBase().playerID
		
		For Local i:Int = 0 To 3
			Local show:Int = GetStationMap(owner).GetShowStation(i+1)
			guiShowStations[i].SetChecked(show)
		Next
	End Function


	Function OnSetChecked_StationMapFilters:Int(triggerEvent:TEventBase)
		Local button:TGUICheckBox = TGUICheckBox(triggerEvent._sender)
		If Not button Then Return False

		'ignore clicks if not in the own office
		If Not currentSubRoom Or currentSubRoom.owner <> GetPlayerBase().playerID Then Return False

		'player filter
		Local player:Int = button.data.GetInt("playerNumber", -1)
		If player >= 0
			If Not GetPlayerCollection().IsPlayer(player) Then Return False

			'only set if not done already
			If GetStationMap(GetPlayerBase().playerID).GetShowStation(player) <> button.isChecked()
				TLogger.Log("StationMap", "Stationmap #"+GetPlayerBase().playerID+" show stations for player "+player+": "+button.isChecked(), LOG_DEBUG)
				GetStationMap(GetPlayerBase().playerID).SetShowStation(player, button.isChecked())
			EndIf
		EndIf

		'station type filter
		Local stationType:Int = button.data.GetInt("stationType", -1)
		If stationType >= 0
			'only set if not done already
			If GetStationMap(GetPlayerBase().playerID).GetShowStationType(stationType) <> button.isChecked()
				TLogger.Log("StationMap", "Stationmap #"+GetPlayerBase().playerID+" show station type "+stationType+": "+button.isChecked(), LOG_DEBUG)
				GetStationMap(GetPlayerBase().playerID).SetShowStationType(stationType, button.isChecked())
			EndIf
		EndIf
	End Function
End Type