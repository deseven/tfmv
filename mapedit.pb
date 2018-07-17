CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  IncludeFile "getimage.pbi"
  LoadFont(0,"Arial",18,#PB_Font_HighQuality)
  LoadFont(1,"Arial",8,#PB_Font_HighQuality|#PB_Font_Bold)
  LoadFont(2,"Arial",8,#PB_Font_HighQuality)
CompilerElse
  IncludeFile "osx.pbi"
  LoadFont(0,"Calibri",22)
  LoadFont(1,"Calibri",12,#PB_Font_Bold)
  LoadFont(2,"Calibri",10)
CompilerEndIf

EnableExplicit

#myNameShort = "TFMV"
#myName = "TFMV 1.3.0"

Global mapPath.s = ProgramParameter()
Global mapFactor,normalized.b,originalSize.b

Global origMap,origNormMap,sizedMap,sizedNormMap,origMapWidth,origMapHeight,sizedMapWidth,sizedMapHeight,centerX,centerY,luaChanged
Global centerXR,centerYR,mapFactorX.d,mapFactorY.d,gameX.d,gameY.d,rangeFrom.f,rangeTo.f,waterAt.f,filecheckThread
Global openIcon,configIcon,reloadIcon,topIcon,aboutIcon,fitIcon,normIcon
Define ev,mapLoaded,dragStart

Enumeration regexps
  #pos
  #name
  #sizeFactor
  #fileName
  #range
EndEnumeration

Enumeration events #PB_Event_FirstCustomValue
  #evUpdate
  #evSize
  #evSizeForce
  #evLoadMap
  #evUpdateData
EndEnumeration

Enumeration objTypes
  #objTown
  #objIndustry
EndEnumeration

Structure object
  type.b
  name.s
  x.d
  y.d
  size.l
EndStructure

NewList objects.object()
Dim heights.f(0,0)

CreateRegularExpression(#pos,~".*pos[ ]*=[ ]*{[ ]*([0-9-.]+)[ ]*,[ ]*([0-9-.]+)[ ]*}")
CreateRegularExpression(#name,~".*name[ ]*=[ ]*_\\(\"([^\"]+)\"\\)")
CreateRegularExpression(#sizeFactor,~".*sizeFactor[ ]*=[ ]*([0-9-.]+)")
CreateRegularExpression(#fileName,~".*fileName[ ]*=[ ]*\"([^\"]+)\"")
CreateRegularExpression(#range,~".*range[ ]*=[ ]*{[ ]*([0-9-.]+)[ ]*,[ ]*([0-9-.]+)[ ]*}")

IncludeFile "proc.pb"

init()

OpenWindow(0,0,0,800,800,#myName + " - " + mapPath,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget)
CreateToolBar(0,WindowID(0))
ToolBarImageButton(0,ImageID(openIcon))
ToolBarImageButton(1,ImageID(configIcon))
ToolBarImageButton(2,ImageID(reloadIcon))
ToolBarSeparator()
ToolBarImageButton(3,ImageID(topIcon),#PB_ToolBar_Toggle)
ToolBarImageButton(4,ImageID(fitIcon),#PB_ToolBar_Toggle)
SetToolBarButtonState(0,4,#True)
ToolBarImageButton(5,ImageID(normIcon),#PB_ToolBar_Toggle)
ToolBarSeparator()
ToolBarImageButton(6,ImageID(aboutIcon))
ToolBarToolTip(0,0,"Open another map")
ToolBarToolTip(0,1,"Edit map.lua")
ToolBarToolTip(0,2,"Reload current map")
ToolBarToolTip(0,3,"Stay on top")
ToolBarToolTip(0,4,"Fit map to window")
ToolBarToolTip(0,5,"Split by heightlevels")
ToolBarToolTip(0,6,"About")
CreateStatusBar(0,WindowID(0))
AddStatusBarField(150)
AddStatusBarField(300)
AddStatusBarField(100)


CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  AddKeyboardShortcut(0,#PB_Shortcut_Control|#PB_Shortcut_C,10)
CompilerElse
  AddKeyboardShortcut(0,#PB_Shortcut_Command|#PB_Shortcut_C,10)
CompilerEndIf
RemoveKeyboardShortcut(0,#PB_Shortcut_Tab)

CanvasGadget(0,0,ToolBarHeight(0),WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0))
SetGadgetAttribute(0,#PB_Canvas_Cursor,#PB_Cursor_Cross)

;SmartWindowRefresh(0,#True)

;If sciEnabled
;  SetToolBarButtonState(0,1,#True)
;  initSci()
;EndIf

PostEvent(#evLoadMap)
Define curX.d,curY.d,curXPre.d,curYPre.d

Repeat
  ev = WaitWindowEvent(200)
  Select ev
    Case #evUpdateData
      Debug "update data event"
      parseLua()
      PostEvent(#evUpdate)
    Case #evLoadMap
      Debug "load event"
      mapLoaded = #False
      If Not loadMap()
        message("Can't load heightmap.png",#mError)
      Else
        mapLoaded = #True
      EndIf
      Debug "posting size force"
      PostEvent(#evSizeForce)
    Case #PB_Event_SizeWindow,#evSize
      Debug "size event"
      If mapLoaded
        If Not originalSize
          sizeMap(WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0))
        EndIf
        Debug "posting update"
        PostEvent(#evUpdate)
      EndIf
    Case #evSizeForce
      Debug "size force event"
      If mapLoaded
        sizeMap(WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0),#True)
        Debug "posting update"
        PostEvent(#evUpdate)
      EndIf
    Case #evUpdate
      Debug "update event"
      If IsGadget(0) : FreeGadget(0) : EndIf
      If IsGadget(10) : FreeGadget(10) : EndIf
      If Not originalSize
        CanvasGadget(0,0,ToolBarHeight(0),WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0))
      Else
        ScrollAreaGadget(10,0,ToolBarHeight(0),WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0),ImageWidth(origMap),ImageHeight(origMap),10,#PB_ScrollArea_BorderLess)
        SetGadgetColor(10,#PB_Gadget_BackColor,$000000)
        CanvasGadget(0,0,0,ImageWidth(origMap),ImageHeight(origMap))
        CloseGadgetList()
      EndIf
      SetGadgetAttribute(0,#PB_Canvas_Cursor,#PB_Cursor_Cross)
      If Not originalSize
        drawMap(WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0),originalSize,normalized)
      Else
        drawMap(ImageWidth(origMap),ImageHeight(origMap),originalSize,normalized)
      EndIf
    Case #PB_Event_Menu
      Select EventMenu()
        Case 0
          Define prevMapPath.s = mapPath
          mapPath.s = PathRequester("Please choose your map folder",GetPathPart(mapPath))
          If FileSize(mapPath + "heightmap.png") < 1 Or FileSize(mapPath + "map.lua") < 1
            If Len(mapPath)
              message("Please select a folder with your map (this is where your heightmap.png and map.lua are located).",#mError)
            EndIf
            mapPath = prevMapPath
          Else
            SetWindowTitle(0,#myName + " - " + mapPath)
            settings(#True)
            luaChanged = GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
            PostEvent(#evLoadMap)
          EndIf
        Case 1
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
            RunProgram(mapPath + "map.lua")
          CompilerElse
            RunProgram("open",mapPath + "map.lua","")
          CompilerEndIf
        Case 2
          luaChanged = GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
          PostEvent(#evLoadMap)
        Case 3
          If GetToolBarButtonState(0,3)
            StickyWindow(0,#True)
          Else
            StickyWindow(0,#False)
          EndIf
        Case 4
          originalSize = ~ originalSize
          PostEvent(#evUpdate)
        Case 5
          normalized = ~ normalized
          PostEvent(#evUpdate)
        Case 6
          message(~"Transport Fever Map Viewer\ncreated by deseven, 2016")
        Case 10
          SetClipboardText("pos = { " + StrD(gameX,3) + ", " + StrD(gameY,3) + " }")
          StatusBarText(0,2,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (copied!)")
      EndSelect
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 0
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            dragStart = #True
          Case #PB_EventType_LeftButtonUp
            dragStart = #False
          Case #PB_EventType_LeftClick
            SetClipboardText("pos = { " + StrD(gameX,3) + ", " + StrD(gameY,3) + " }")
            StatusBarText(0,1,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (copied!)")
          Case #PB_EventType_MouseMove
            If curX <> GetGadgetAttribute(0,#PB_Canvas_MouseX) Or curY <> GetGadgetAttribute(0,#PB_Canvas_MouseY)
              curXPre = curX
              curYPre = curY
              curX = GetGadgetAttribute(0,#PB_Canvas_MouseX)
              curY = GetGadgetAttribute(0,#PB_Canvas_MouseY)
              If curX > 0 And curY > 0
                If originalSize
                  StatusBarText(0,0,"Image: " + StrF(curX,0) + ", " + StrF(curY,0))
                  If ArraySize(heights(),1) >= curX And ArraySize(heights(),2) >= curY
                    StatusBarText(0,2,"Height: " + StrF(heights(Int(curX),Int(curY)),2) + "m")
                  Else
                    StatusBarText(0,2,"Height: 0m")
                  EndIf
                  gameX = (curX-centerX)*mapFactor
                  gameY = (curY-centerY)*mapFactor*-1
                Else
                  StatusBarText(0,0,"Image: " + StrF(curX/mapFactorX,0) + ", " + StrF(curY/mapFactorY,0))
                  If ArraySize(heights(),1) >= curX/mapFactorX And ArraySize(heights(),2) >= curY/mapFactorY
                    StatusBarText(0,2,"Height: " + StrF(heights(Int(curX/mapFactorX),Int(curY/mapFactorY)),2) + "m")
                  Else
                    StatusBarText(0,2,"Height: 0m")
                  EndIf
                  gameX = (curX-centerXR)/mapFactorX*mapFactor
                  gameY = (curY-centerYR)/mapFactorY*mapFactor*-1
                EndIf
                CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                  StatusBarText(0,1,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (ctrl-c or click to copy)")
                CompilerElse
                  StatusBarText(0,1,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (" + #command + "C or click to copy)")
                CompilerEndIf
              EndIf
            EndIf
            If dragStart
              ForEach objects()
                If originalSize
                  Define locX.f = objects()\x
                  Define locY.f = objects()\y
                Else
                  locX = objects()\x * mapFactorX
                  locY = objects()\y * mapFactorY
                EndIf
                If curX >= locX - objects()\size/2 And curX <= locX + objects()\size/2
                  If curY >= locY - objects()\size/2 And curY <= locY + objects()\size/2
                    If originalSize
                      objects()\x = curX
                      objects()\y = curY
                    Else
                      objects()\x = curX / mapFactorX
                      objects()\y = curY / mapFactorY
                    EndIf
                    PostEvent(#evUpdate)
                    Break
                  EndIf
                EndIf
              Next
            EndIf
          Case #PB_EventType_MouseWheel
            If IsGadget(10)
              Define wheel = GetGadgetAttribute(0,#PB_Canvas_WheelDelta)
              SetGadgetAttribute(10,#PB_ScrollArea_Y,GetGadgetAttribute(10,#PB_ScrollArea_Y)-wheel*5)
            EndIf
        EndSelect
      EndIf
  EndSelect
ForEver

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  DataSection
    openIcon:
    IncludeBinary "icns\open.ico"
    reloadIcon:
    IncludeBinary "icns\reload.ico"
    configIcon:
    IncludeBinary "icns\config.ico"
    topIcon:
    IncludeBinary "icns\top.ico"
    aboutIcon:
    IncludeBinary "icns\about.ico"
    fitIcon:
    IncludeBinary "icns\fit.ico"
    normIcon:
    IncludeBinary "icns\norm.ico"
  EndDataSection
CompilerEndIf
; IDE Options = PureBasic 5.50 (Windows - x64)
; Folding = -
; EnableXP
; UseIcon = map.ico
; Executable = tfmv.exe
; CompileSourceDirectory
; IncludeVersionInfo
; VersionField0 = 1,1,0,0
; VersionField1 = 1,1,0,0
; VersionField2 = solution
; VersionField3 = TF map view
; VersionField4 = 1.1
; VersionField5 = 1.1
; VersionField6 = map viewer for TF series
; VersionField7 = tfmv.exe
; VersionField8 = tfmv.exe
; VersionField9 = deseven, 2016
; VersionField14 = http://deseven.info