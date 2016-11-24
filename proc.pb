; Macro initSci()
;   ScintillaGadget(1,500,ToolBarHeight(0),500,500-ToolBarHeight(0)-StatusBarHeight(0),@inputCallBack())
;   ScintillaSendMessage(1,#SCI_SETMARGINTYPEN,#SC_MARGIN_NUMBER,1)
;   ScintillaSendMessage(1,#SCI_SETMARGINWIDTHN,#SC_MARGIN_NUMBER,20)
;   ScintillaSendMessage(1,#SCI_SETWRAPMODE,2)
;   ScintillaSendMessage(1,#SCI_SETTABWIDTH,4)
;   ScintillaSendMessage(1,#SCI_SETLEXER,#SCLEX_LUA)
;   ScintillaSendMessage(1,#SCI_STYLECLEARALL)
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,#STYLE_DEFAULT,$000000)
;   ScintillaSendMessage(1,#SCI_STYLESETBACK,#STYLE_DEFAULT,$ffffff)
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,0,RGB($00,$00,00))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,32,RGB($ff,$00,00))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,1,RGB($d0,$f0,$f0))
;   ScintillaSendMessage(1,#SCI_STYLESETBACK,2,RGB($d0,$f0,$f0))
;   ScintillaSendMessage(1,#SCI_STYLESETBACK,8,RGB($e0,$ff,$ff))
;   ScintillaSendMessage(1,#SCI_STYLESETBACK,12,RGB($e0,$c0,$e0))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,4,RGB($00,$7f,$7f))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,5,RGB($00,$00,$7f))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,6,RGB($7f,$00,$7f))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,7,RGB($7f,$00,$7f))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,8,RGB($7f,$00,$7f))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,10,RGB($00,$00,$00))
;   ScintillaSendMessage(1,#SCI_STYLESETFORE,20,RGB($7f,$7f,$00))
; EndMacro

Enumeration message
  #mInfo
  #mQuestion
  #mError
EndEnumeration

Procedure message(message.s,type.b = #mInfo)
  Protected wndID.i
  If IsWindow(0) : wndID = WindowID(0) : EndIf
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Select type
      Case #mError
        MessageBox_(wndID,message,#myNameShort,#MB_OK|#MB_ICONERROR)
      Case #mQuestion
        If MessageBox_(wndID,message,#myNameShort,#MB_YESNO|#MB_ICONQUESTION) = #IDYES
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Default
        MessageBox_(wndID,message,#myName,#MB_OK|#MB_ICONINFORMATION)
    EndSelect
  CompilerElse
    Select type
      Case #mQuestion
        If MessageRequester(#myName,message,#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Default
        MessageRequester(#myName,message)
    EndSelect
  CompilerEndIf
  ProcedureReturn #True
EndProcedure

Procedure normalizeMap(image.i)
  Protected c, i, x, y, xMax, yMax
  
  If IsImage(image)
    
    StartDrawing(ImageOutput(image))
    xMax = OutputWidth()  - 1
    yMax = OutputHeight() - 1
    
    For y = 0 To yMax
      For x = 0 To xMax
        c = Point(x, y)
        
        Select c
          Case 0 to waterAt
            FrontColor($ff0000)
          Case 0 To $111111
            FrontColor($111111)
          Case $111111 To $222222
            FrontColor($222222)
          Case $222222 To $333333
            FrontColor($333333)
          Case $333333 To $444444
            FrontColor($444444)
          Case $444444 To $555555
            FrontColor($555555)
          Case $555555 To $666666
            FrontColor($666666)
          Case $666666 To $777777
            FrontColor($777777)
          Case $777777 To $888888
            FrontColor($888888)
          Case $888888 To $999999
            FrontColor($999999)
          Case $999999 To $AAAAAA
            FrontColor($AAAAAA)
          Case $AAAAAA To $BBBBBB
            FrontColor($BBBBBB)
          Case $BBBBBB To $CCCCCC
            FrontColor($CCCCCC)
          Case $CCCCCC To $DDDDDD
            FrontColor($DDDDDD)
          Case $DDDDDD To $EEEEEE
            FrontColor($EEEEEE)
          Case $EEEEEE To $FFFFFF
            FrontColor($FFFFFF)
        EndSelect
        Plot(x, y)
      Next x
    Next y
    StopDrawing()
    
  EndIf 
EndProcedure

Procedure drawWater(image.i)
  Protected c, i, x, y, xMax, yMax
  
  If IsImage(image)
    
    StartDrawing(ImageOutput(image))
    xMax = OutputWidth()  - 1
    yMax = OutputHeight() - 1
    FrontColor($ff0000)
    
    For y = 0 To yMax
      For x = 0 To xMax
        c = Point(x, y)
        Select c
          Case 0 to waterAt
            Plot(x, y)
        EndSelect
      Next x
    Next y
    StopDrawing()
    
  EndIf 
EndProcedure

; Procedure COLORIZE_IMAGE(color.i, image.i)
;   Protected c, i, x, y, xMax, yMax
;   Protected.d r, g, b
;   
;   r = Red(color)   / 1785
;   g = Green(color) / 1785
;   b = Blue(color)  / 1785
;   
;   If IsImage(image)
;     
;     StartDrawing(ImageOutput(image))
;     xMax = OutputWidth()  - 1
;     yMax = OutputHeight() - 1
;     
;     For y = 0 To yMax
;       For x = 0 To xMax
;         c = Point(x, y)
;         
;         i = (c & $FF) << 1 : c >> 8
;         i + (C & $FF) << 2 : c >> 8
;         i + (C & $FF)
;         Plot(x, y, RGB(r*i, g*i, b*i))
;       Next x
;     Next y
;     StopDrawing()
;     
;   EndIf 
; EndProcedure

; Procedure MakeScintillaText(text.s)
;   Static sciText.s
;   CompilerIf #PB_Compiler_Unicode
;     sciText = Space(StringByteLength(text, #PB_UTF8))
;     PokeS(@sciText, text, -1, #PB_UTF8)
;   CompilerElse
;     sciText = text
;   CompilerEndIf
;   ProcedureReturn @sciText
; EndProcedure

; Procedure.s GetLineIndent(ScintillaGadget, Line)
;   Protected Indent.s = ""
;   Protected Temp.s = ""
;   Protected *LineBuffer.Ascii = #Null
;   
;   If Line >= 0
;     Temp = Space(ScintillaSendMessage(ScintillaGadget, #SCI_LINELENGTH, Line))
;     ScintillaSendMessage(ScintillaGadget, #SCI_GETLINE, Line, @Temp)
;     *LineBuffer = @Temp
;     
;     While *LineBuffer\a = 9 Or *LineBuffer\a = 32
;       Indent + Chr(*LineBuffer\a)
;       *LineBuffer + SizeOf(Ascii)
;     Wend
;   EndIf
;   
;   ProcedureReturn Indent
; EndProcedure
; 
; Procedure inputCallBack(gadget,*scinotify.SCNotification)
;   Protected Line = 0
;   Protected Indent.s = ""
;   ;Debug *scinotify\nmhdr\code
;   ;Debug #SCN_MODIFIED
;   If *scinotify\nmhdr\code = #SCN_MODIFIED And (*scinotify\modificationType & #SC_PERFORMED_USER) And Not isLoading
;     ;ScintillaSendMessage(1,#SCI_COLOURISE,0,-1)
;     PostEvent(#evInput)
;   EndIf
;   If *scinotify\nmhdr\code = #SCN_CHARADDED
;     If *scinotify\ch = 10
;       Line = ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,ScintillaSendMessage(1,#SCI_GETCURRENTPOS))
;       Indent = GetLineIndent(gadget,Line-1)
;       ScintillaSendMessage(gadget,#SCI_REPLACESEL,0,MakeScintillaText(Indent))
;     EndIf
;   EndIf
; EndProcedure

Procedure settings(save = #False)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    openIcon = CatchImage(#PB_Any,?openIcon)
    reloadIcon = CatchImage(#PB_Any,?reloadIcon)
    configIcon = CatchImage(#PB_Any,?configIcon)
    topIcon = CatchImage(#PB_Any,?topIcon)
    aboutIcon = CatchImage(#PB_Any,?aboutIcon)
    fitIcon = CatchImage(#PB_Any,?fitIcon)
    If FileSize(GetEnvironmentVariable("APPDATA") + "\" + #myNameShort) <> -2
      CreateDirectory(GetEnvironmentVariable("APPDATA") + "\" + #myNameShort)
    EndIf
    If FileSize(GetEnvironmentVariable("APPDATA") + "\" + #myNameShort + "\config.ini") > 0
      OpenPreferences(GetEnvironmentVariable("APPDATA") + "\" + #myNameShort + "\config.ini")
    Else
      CreatePreferences(GetEnvironmentVariable("APPDATA") + "\" + #myNameShort + "\config.ini")
    EndIf
  CompilerElse
    Protected myPath.s = GetPathPart(ProgramFilename()) + "../Resources/"
    openIcon = LoadImageEx(myPath + "open.png")
    reloadIcon = LoadImageEx(myPath + "reload.png")
    configIcon = LoadImageEx(myPath + "config.png")
    topIcon = LoadImageEx(myPath + "top.png")
    aboutIcon = LoadImageEx(myPath + "about.png")
    fitIcon = LoadImageEx(myPath + "fit.png")
    If FileSize(GetEnvironmentVariable("HOME") + "/.config/" + #myNameShort) <> -2
      CreateDirectory(GetEnvironmentVariable("HOME") + "/.config")
      CreateDirectory(GetEnvironmentVariable("HOME") + "/.config/" + #myNameShort)
    EndIf
    If FileSize(GetEnvironmentVariable("HOME") + "/.config/" + #myNameShort + "/config.ini") > 0
      OpenPreferences(GetEnvironmentVariable("HOME") + "/.config/" + #myNameShort + "/config.ini")
    Else
      CreatePreferences(GetEnvironmentVariable("HOME") + "/.config/" + #myNameShort + "/config.ini")
    EndIf
  CompilerEndIf
  If save
    WritePreferenceString("lastPath",mapPath)
  Else
    mapPath = ReadPreferenceString("lastPath","")
  EndIf
  ClosePreferences()
EndProcedure

Procedure init()
  If Not Len(mapPath)
    settings()
  EndIf

  If FileSize(mapPath + "heightmap.png") < 1 Or FileSize(mapPath + "map.lua") < 0
    mapPath = PathRequester("Please choose your map folder",mapPath)
  EndIf

  If FileSize(mapPath + "heightmap.png") < 1 Or FileSize(mapPath + "map.lua") < 0
    message("You need to select a folder with your map (this is where your heightmap.png and map.lua are located).",#mError)
    End
  EndIf
  
  If Len(mapPath)
    settings(#True)
  EndIf
EndProcedure

Procedure ResizeImgAR(ImgID.l,width.l,height.l) 
  Define.l OriW, OriH, w, h, oriAR, newAR
  Define.f fw, fh

  OriW=ImageWidth(ImgID)
  OriH=ImageHeight(ImgID)

  If (OriH > OriW And height < width) Or (OriH < OriW And height > width)
    Swap width, height
  EndIf

  ; Calc Factor
  fw = width/OriW
  fh = height/OriH

  ; Calc AspectRatio
  oriAR = Round((OriW / OriH) * 10,0)
  newAR = Round((width / height) * 10,0)

  ; AspectRatio already correct?
  If oriAR = newAR 
    w = width
    h = height
  ElseIf OriW * fh <= width
    w = OriW * fh
    h = OriH * fh
  ElseIf OriH * fw <= height
    w = OriW * fw
    h = OriH * fw  
  EndIf

  ResizeImage(ImgID,w,h,#PB_Image_Smooth) 

EndProcedure

Procedure loadMap()
  If IsImage(origMap) : FreeImage(origMap) : EndIf
  If IsImage(origNormMap) : FreeImage(origNormMap) : EndIf
  origMap = ImageFromFile(mapPath + "heightmap.png") 
  
  If Not origMap
    ProcedureReturn #False
  EndIf
  
  CopyImage(origMap,origNormMap)
  normalizeMap(origNormMap)
  drawWater(origMap)
  
  mapWidth = ImageWidth(img)
  mapHeight = ImageHeight(img)
  centerX = mapWidth/2
  centerY = mapHeight/2
  ProcedureReturn #True
EndProcedure

Procedure drawMap(width,height,infoOnly = #False)
  Protected textW,textH
  Protected.s string,fileName,townName
  Protected.d locX,locY
  Protected.f boxSize,sizeFactor
  Static imgR
  If Not infoOnly
    If IsImage(imgR) : FreeImage(imgR) : EndIf
    CopyImage(img,imgR)
    If width <> ImageWidth(img) Or height <> ImageHeight(img)
      ResizeImgAR(imgR,width,height)
    EndIf
  EndIf
  Protected mapWidthR = ImageWidth(imgR)
  Protected mapHeightR = ImageHeight(imgR)
  centerXR = mapWidthR/2
  centerYR = mapHeightR/2
  mapFactorX.d = mapWidthR/mapWidth
  mapFactorY.d = mapHeightR/mapHeight
  mapFactor = 4
  waterAt = -1
  ;If mapWidth < 2000 And mapHeight < 2000
  ;  mapFactor = 4
  ;ElseIf mapWidth < 3000 And mapHeight < 3000
  ;  mapFactor = 4
  ;Else
  ;  mapFactor = 4
  ;EndIf
  StartDrawing(CanvasOutput(0))
  FrontColor($000000)
  Box(0,0,width,height)
  FrontColor($ffffff)
  DrawImage(ImageID(imgR),0,0)
  Protected firstLine = #True
  Protected sciText.s = ""
  If ReadFile(0,mapPath + "map.lua",#PB_File_SharedRead)
    While Eof(0) = 0
      string = ReadString(0)
      string = Trim(string)
      If FindString(string,"--") = 1
        Continue ; skipping commented lines
      EndIf
      If ExamineRegularExpression(#pos,string)
        If NextRegularExpressionMatch(#pos) ; got position here
          locX = ValD(RegularExpressionGroup(#pos,1))
          locY = ValD(RegularExpressionGroup(#pos,2))
          locY * -1 ; inverting Y coordinate
          locX = centerXR + (locX/mapFactor*mapFactorX)
          locY = centerYR + (locY/mapFactor*mapFactorY)
          If ExamineRegularExpression(#fileName,string)
            If NextRegularExpressionMatch(#fileName) ; this is an industry
              fileName = RegularExpressionGroup(#fileName,1)
              If CountString(fileName,"/")
                fileName = (StringField(fileName,CountString(fileName,"/")+1,"/"))
              EndIf
              fileName = (StringField(fileName,1,"."))
              If Not Len(fileName) : fileName = "industry" : EndIf
              boxSize = 2
              Box(locX-boxSize/2,locY-boxSize/2,boxSize,boxSize,$FF0000)
              DrawingMode(#PB_2DDrawing_Transparent)
              DrawingFont(FontID(2))
              textW = TextWidth(fileName)
              textH = TextHeight(fileName)
              DrawText(locX-textW/2,locY-boxSize/2-2-textH,fileName)
            Else ; this is a town
              If ExamineRegularExpression(#name,string)
                If NextRegularExpressionMatch(#name)
                  townName = RegularExpressionGroup(#name,1)
                Else
                  townName = "city"
                EndIf
              EndIf
              If ExamineRegularExpression(#sizeFactor,string)
                If NextRegularExpressionMatch(#sizeFactor)
                  sizeFactor = ValF(RegularExpressionGroup(#sizeFactor,1))
                Else
                  sizeFactor = 1.0
                EndIf
              EndIf
              boxSize = sizeFactor*6
              If boxSize < 1 : boxSize = 1 : EndIf
              Box(locX-boxSize/2,locY-boxSize/2,boxSize,boxSize,$0000FF)
              DrawingMode(#PB_2DDrawing_Transparent)
              DrawingFont(FontID(1))
              textW = TextWidth(townName)
              textH = TextHeight(townName)
              DrawText(locX-textW/2,locY-boxSize/2-2-textH,townName)
            EndIf
          EndIf
        ElseIf ExamineRegularExpression(#range,string) ; well maybe we have a range here?
          If NextRegularExpressionMatch(#range)
            rangeFrom = ValF(RegularExpressionGroup(#range,1))
            rangeTo = ValF(RegularExpressionGroup(#range,2))
            If rangeFrom <= 100
              waterAt = $FFFFFF/(rangeTo-rangeFrom)*(100-rangeFrom)
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
    CloseFile(0)
    SetWindowTitle(0,#myName + " - " + mapPath)
    StatusBarText(0,0,"@" + Str(mapFactor) + "x")
  Else
    message("Can't open map.lua",#mError)
  EndIf
  StopDrawing()
EndProcedure

Procedure fileCheck(interval)
  Repeat
    Delay(interval)
    If luaChanged <> GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
      PostEvent(#evUpdateInfo)
      ProcedureReturn
    EndIf
  ForEver
EndProcedure
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; Folding = --
; EnableXP