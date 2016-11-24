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
#myName = "TFMV 1.2.0"

Global mapPath.s = ProgramParameter()
Global mapFactor,normalize.b

Global otigMap,origMap,sizedMap,sizedNormMap,mapWidth,mapHeight,centerX,centerY,luaChanged
Global centerXR,centerYR,mapFactorX.d,mapFactorY.d,gameX.d,gameY.d,rangeFrom.f,rangeTo.f,waterAt.f
Global openIcon,configIcon,reloadIcon,topIcon,aboutIcon,fitIcon
Define ev,textW,textH

Enumeration regexps
  #pos
  #name
  #sizeFactor
  #fileName
  #range
EndEnumeration

Enumeration events #PB_Event_FirstCustomValue
  #evUpdateInfo
  #evUpdateAll
EndEnumeration

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
ToolBarSeparator()
ToolBarImageButton(5,ImageID(aboutIcon))
ToolBarToolTip(0,0,"Open another map")
ToolBarToolTip(0,1,"Edit map.lua")
ToolBarToolTip(0,2,"Reload current map")
ToolBarToolTip(0,3,"Stay on top")
ToolBarToolTip(0,4,"Fit map to window")
ToolBarToolTip(0,5,"About")
CreateStatusBar(0,WindowID(0))
AddStatusBarField(30)
AddStatusBarField(150)
AddStatusBarField(300)

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  AddKeyboardShortcut(0,#PB_Shortcut_Control|#PB_Shortcut_C,10)
CompilerElse
  AddKeyboardShortcut(0,#PB_Shortcut_Command|#PB_Shortcut_C,10)
CompilerEndIf
RemoveKeyboardShortcut(0,#PB_Shortcut_Tab)

CanvasGadget(0,0,ToolBarHeight(0),500,500-ToolBarHeight(0)-StatusBarHeight(0))
SetGadgetAttribute(0,#PB_Canvas_Cursor,#PB_Cursor_Cross)

SmartWindowRefresh(0,#True)

;If sciEnabled
;  SetToolBarButtonState(0,1,#True)
;  initSci()
;EndIf

PostEvent(#evUpdateAll)
Define filecheckThread,curX.d,curY.d,curXPre.d,curYPre.d

Repeat
  ev = WaitWindowEvent(200)
  If Not IsThread(filecheckThread)
    filecheckThread = CreateThread(@fileCheck(),2000)
  EndIf
  Select ev
    Case #PB_Event_SizeWindow,#evUpdateAll
      If Not IsImage(img)
        If Not loadMap()
          message("Can't load heightmap.png",#mError)
        EndIf
      EndIf
      If IsGadget(0) : FreeGadget(0) : EndIf
      If IsGadget(10) : FreeGadget(10) : EndIf
      If GetToolBarButtonState(0,4)
        CanvasGadget(0,0,ToolBarHeight(0),WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0))
      Else
        ScrollAreaGadget(10,0,ToolBarHeight(0),WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0),ImageWidth(img),ImageHeight(img),10,#PB_ScrollArea_BorderLess)
        SetGadgetColor(10,#PB_Gadget_BackColor,$000000)
        CanvasGadget(0,0,0,ImageWidth(img),ImageHeight(img))
        CloseGadgetList()
      EndIf
      StartDrawing(CanvasOutput(0))
      FrontColor($000000)
      Box(0,0,WindowWidth(0),WindowHeight(0))
      DrawingFont(FontID(0))
      FrontColor($ffffff)
      textW = TextWidth("L O A D I N G")
      textH = TextHeight("L O A D I N G")
      DrawText(WindowWidth(0)/2-textW/2,WindowHeight(0)/2-textH/2,"L O A D I N G",$FFFFFF)
      StopDrawing()
      While WindowEvent() : Wend
      If GetToolBarButtonState(0,4)
        drawMap(WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0))
      Else
        drawMap(ImageWidth(img),ImageHeight(img))
      EndIf
      luaChanged = GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
      settings(#True)
    Case #evUpdateInfo
      drawMap(WindowWidth(0),WindowHeight(0)-ToolBarHeight(0)-StatusBarHeight(0),#True)
      luaChanged = GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
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
            If IsImage(img) : FreeImage(img) : EndIf
            PostEvent(#evUpdateAll)
          EndIf
        Case 1
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
            RunProgram(mapPath + "map.lua")
          CompilerElse
            RunProgram("open",mapPath + "map.lua","")
          CompilerEndIf
        Case 2
          PostEvent(#evUpdateAll)
        Case 3
          If GetToolBarButtonState(0,3)
            StickyWindow(0,#True)
          Else
            StickyWindow(0,#False)
          EndIf
        Case 4
          PostEvent(#evUpdateAll)
        Case 5
          ;message(~"Transport Fever Map Viewer\ncreated by deseven, 2016")
          If IsImage(img) : FreeImage(img) : EndIf
          normalize = ~ normalize
          PostEvent(#evUpdateAll)
        Case 10
          SetClipboardText("pos = { " + StrD(gameX,3) + ", " + StrD(gameY,3) + " }")
          StatusBarText(0,2,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (copied!)")
      EndSelect
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 0
        Select EventType()
          Case #PB_EventType_LeftClick
            SetClipboardText("pos = { " + StrD(gameX,3) + ", " + StrD(gameY,3) + " }")
            StatusBarText(0,2,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (copied!)")
          Case #PB_EventType_MouseMove
            If curX <> GetGadgetAttribute(0,#PB_Canvas_MouseX) Or curY <> GetGadgetAttribute(0,#PB_Canvas_MouseY)
              curXPre = curX
              curYPre = curY
              curX = GetGadgetAttribute(0,#PB_Canvas_MouseX)
              curY = GetGadgetAttribute(0,#PB_Canvas_MouseY)
              If curX > 0 And curY > 0
                StatusBarText(0,1,"Image: " + StrF(curX/mapFactorX,0) + ", " + StrF(curY/mapFactorY,0))
                gameX = (curX-centerXR)/mapFactorX*mapFactor
                gameY = (curY-centerYR)/mapFactorY*mapFactor*-1
                CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                  StatusBarText(0,2,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (ctrl-c or click to copy)")
                CompilerElse
                  StatusBarText(0,2,"Game: " + StrD(gameX,3) + ", " + StrD(gameY,3) + " (" + #command + "C or click to copy)")
                CompilerEndIf
              EndIf
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
  EndDataSection
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
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