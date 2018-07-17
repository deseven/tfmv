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

Procedure fileCheck(interval)
  Repeat
    Delay(interval)
    If luaChanged <> GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
      PostEvent(#evUpdateData)
      ProcedureReturn
    EndIf
  ForEver
EndProcedure

Procedure normalizeMap(image.i)
  Shared heights.f()
  Protected c, i, x, y, xMax, yMax
  
  If IsImage(image)
    
    StartDrawing(ImageOutput(image))
    xMax = OutputWidth()  - 1
    yMax = OutputHeight() - 1
    
    FreeArray(heights())
    Dim heights.f(xMax,yMax)
    
    For y = 0 To yMax
      For x = 0 To xMax
        
        c = Point(x, y)
        ; waterAt = $FFFFFF/(rangeTo-rangeFrom)*(100-rangeFrom)
        heights(x,y) = Point(x, y) / ($FFFFFF/(rangeTo-rangeFrom)) + rangeFrom
        
        Select c
          Case 0 To waterAt
            FrontColor($ffd000)
          Case 0 To $111111
            FrontColor($002907)
          Case $111111 To $222222
            FrontColor($003D0A)
          Case $222222 To $333333
            FrontColor($00520E)
          Case $333333 To $444444
            FrontColor($006611)
          Case $444444 To $555555
            FrontColor($007a14)
          Case $555555 To $666666
            FrontColor($008f18)
          Case $666666 To $777777
            FrontColor($00A31B)
          Case $777777 To $888888
            FrontColor($00B81F)
          Case $888888 To $999999
            FrontColor($00CC22)
          Case $999999 To $AAAAAA
            FrontColor($00E025)
          Case $AAAAAA To $BBBBBB
            FrontColor($00f529)
          Case $BBBBBB To $CCCCCC
            FrontColor($00ff2b)
          Case $CCCCCC To $DDDDDD
            FrontColor($1fff44)
          Case $DDDDDD To $EEEEEE
            FrontColor($33ff55)
          Case $EEEEEE To $FFFFFF
            FrontColor($47ff66)
        EndSelect
        Plot(x, y)
      Next x
    Next y
    StopDrawing()
    
  EndIf 
EndProcedure

Procedure drawWater(image.i)
  Protected c, i, x, y, xMax, yMax
  Protected.f factorRed,factorGreen,factorBlue
  factorGreen = $AA/$FF
  factorRed = $EE/$FF
  factorBlue = $11/$FF
  
  If IsImage(image)
    
    StartDrawing(ImageOutput(image))
    xMax = OutputWidth()  - 1
    yMax = OutputHeight() - 1
    
    For y = 0 To yMax
      For x = 0 To xMax
        c = Point(x, y)
        ;Debug Hex(c)
        If c <= waterAt + 1
          ;Debug Hex(c)
        EndIf
        ;Debug Hex(c)
        Select c
          Case 0 To waterAt
            ;FrontColor(RGB($00,Red(c),$AA))
            Plot(x, y,$ffd000)
          Default
            FrontColor(RGB(Red(c) * factorRed,$55 + (Green(c)*factorGreen),Blue(c) * factorBlue))
            Plot(x, y)
        EndSelect
      Next x
    Next y
    StopDrawing()
    
  EndIf 
EndProcedure

Procedure drawLoading(add.s = "")
  Protected textW,textH,textWA,textHA
  StartDrawing(CanvasOutput(0))
  FrontColor($000000)
  Box(0,0,WindowWidth(0),WindowHeight(0))
  DrawingFont(FontID(0))
  FrontColor($ffffff)
  textW = TextWidth("L O A D I N G")
  textH = TextHeight("L O A D I N G")
  DrawText(WindowWidth(0)/2-textW/2,WindowHeight(0)/2-textH/2,"L O A D I N G",$FFFFFF)
  If Len(add)
    DrawingFont(FontID(1))
    textWA = TextWidth(add)
    textHA = TextHeight(add)
    DrawText(WindowWidth(0)/2-textWA/2,WindowHeight(0)/2-textHA/2+textH,add,$FFFFFF)
  EndIf
  StopDrawing()
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
    While WindowEvent() : Wend
  CompilerEndIf
  ;Repeat
  ;  Protected ev = WindowEvent()
  ;  If Not ev : Break : EndIf
  ;  PostEvent(ev)
  ;ForEver
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
    normIcon = CatchImage(#PB_Any,?normIcon)
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
    normIcon = LoadImageEx(myPath + "norm.png")
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

Procedure ResizeImgAR(ImgID.i,width.l,height.l) 
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

Procedure sizeMap(width,height,force = #False)
  drawLoading("[resizing heightmap]")
  If Not force
    If IsImage(sizedMap)
      If width = ImageWidth(sizedMap) And height = ImageHeight(sizedMap)
        ProcedureReturn #True
      Else
        FreeImage(sizedMap)
      EndIf
    EndIf
    If IsImage(sizedNormMap) : FreeImage(sizedNormMap) : EndIf
  Else
    If IsImage(sizedMap) : FreeImage(sizedMap) : EndIf
  EndIf
  If IsImage(sizedNormMap) : FreeImage(sizedNormMap) : EndIf
  
  sizedMap = CopyImage(origMap,#PB_Any)
  sizedNormMap = CopyImage(origNormMap,#PB_Any)
  If width <> ImageWidth(origMap) Or height <> ImageHeight(origMap)
    ResizeImgAR(sizedMap,width,height)
    ResizeImgAR(sizedNormMap,width,height)
  EndIf
  sizedMapWidth = ImageWidth(sizedMap)
  sizedMapHeight = ImageHeight(sizedMap)
  centerXR = sizedMapWidth/2
  centerYR = sizedMapHeight/2
  mapFactorX = sizedMapWidth/origMapWidth
  mapFactorY = sizedMapHeight/origMapHeight
  ProcedureReturn #True
EndProcedure

Procedure parseLua()
  luaChanged = GetFileDate(mapPath + "map.lua",#PB_Date_Modified)
  Shared objects.object()
  mapFactor = 4
  Protected string.s,locX.d,locY.d
  ClearList(objects())
  If ReadFile(0,mapPath + "map.lua",#PB_File_SharedRead)
    While Eof(0) = 0
      string = ReadString(0)
      string = Trim(string)
      If FindString(string,"--") = 1
        Continue ; skipping commented lines
      EndIf
      If ExamineRegularExpression(#pos,string)
        If NextRegularExpressionMatch(#pos) ; got position here
          AddElement(objects())
          locX = ValD(RegularExpressionGroup(#pos,1))
          locY = ValD(RegularExpressionGroup(#pos,2))
          locY * -1 ; inverting Y coordinate
          objects()\x = centerX + (locX/mapFactor)
          objects()\y = centerY + (locY/mapFactor)
          If ExamineRegularExpression(#fileName,string)
            If NextRegularExpressionMatch(#fileName) ; this is an industry
              objects()\type = #objIndustry
              objects()\name = RegularExpressionGroup(#fileName,1)
              If CountString(objects()\name,"/")
                objects()\name = StringField(objects()\name,CountString(objects()\name,"/")+1,"/")
              EndIf
              objects()\name = (StringField(objects()\name,1,"."))
              If Not Len(objects()\name) : objects()\name = "industry" : EndIf
              objects()\size = 2
            Else ; this is a town
              objects()\type = #objTown
              If ExamineRegularExpression(#name,string)
                If NextRegularExpressionMatch(#name)
                  objects()\name = RegularExpressionGroup(#name,1)
                Else
                  objects()\name = "town"
                EndIf
              EndIf
              If ExamineRegularExpression(#sizeFactor,string)
                If NextRegularExpressionMatch(#sizeFactor)
                  objects()\size = Round(ValF(RegularExpressionGroup(#sizeFactor,1)) * 6,#PB_Round_Nearest)
                  If objects()\size < 2
                    objects()\size = 2
                  EndIf
                Else
                  objects()\size = 2
                EndIf
              EndIf
            EndIf
          EndIf
        ElseIf ExamineRegularExpression(#range,string) ; well maybe we have a range here?
          If NextRegularExpressionMatch(#range)
            rangeFrom = ValF(RegularExpressionGroup(#range,1))
            rangeTo = ValF(RegularExpressionGroup(#range,2))
            If rangeFrom <= 100
              waterAt = $FFFFFF/(rangeTo-rangeFrom)*(100-rangeFrom)
              ;Debug Hex(Val(StrF(waterAt,0)))
              Debug Hex(waterAt)
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
    CloseFile(0)
    SetWindowTitle(0,#myName + " - " + mapPath)
    If Not IsThread(filecheckThread)
      Debug "starting check thread"
      filecheckThread = CreateThread(@fileCheck(),2000)
    EndIf
  Else
    message("Can't open map.lua",#mError)
  EndIf
EndProcedure

Procedure loadMap()
  drawLoading("[reading heightmap]")
  If IsImage(origMap) : FreeImage(origMap) : EndIf
  If IsImage(origNormMap) : FreeImage(origNormMap) : EndIf
  origMap = ImageFromFile(mapPath + "heightmap.png") 
  origNormMap = CopyImage(origMap,#PB_Any)
  
  If Not origMap Or Not origNormMap Or Not IsImage(origMap) Or Not IsImage(origNormMap)
    ProcedureReturn #False
  EndIf
  
  origMapWidth = ImageWidth(origMap)
  origMapHeight = ImageHeight(origMap)
  centerX = origMapWidth/2
  centerY = origMapHeight/2
  
  drawLoading("[reading config]")
  parseLua()
  
  drawLoading("[calculating heightlevels]")
  normalizeMap(origNormMap)
  drawLoading("[drawing water]")
  drawWater(origMap)
  
  If IsImage(sizedMap) : FreeImage(sizedMap) : EndIf
  If IsImage(sizedNormMap) : FreeImage(sizedNormMap) : EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure drawMap(width,height,originalSize = #False,normalized = #False)
  Shared objects.object()
  Protected textW,textH
  Protected.s string,fileName,townName
  Protected.d locX,locY
  Protected.f boxSize,sizeFactor
  mapFactor = 4
  waterAt = -1
  StartDrawing(CanvasOutput(0))
  If originalSize
    If normalized
      ;Debug "drawing original sized normalized map"
      DrawImage(ImageID(origNormMap),0,0)
    Else
      ;Debug "drawing original sized map"
      DrawImage(ImageID(origMap),0,0)
    EndIf
  Else
    FrontColor($000000)
    Box(0,0,width,height)
    FrontColor($ffffff)
    If normalized
      ;Debug "drawing normalized map"
      DrawImage(ImageID(sizedNormMap),0,0)
    Else
      ;Debug "drawing map"
      DrawImage(ImageID(sizedMap),0,0)
    EndIf
  EndIf
  
  ForEach objects()
    boxSize = objects()\size
    If originalSize
      locX = objects()\x
      locY = objects()\y
    Else
      locX = objects()\x * mapFactorX
      locY = objects()\y * mapFactorY
    EndIf
    Select objects()\type
      Case #objTown
        Box(locX-boxSize/2,locY-boxSize/2,boxSize,boxSize,$0000FF)
        DrawingFont(FontID(1))
        textW = TextWidth(objects()\name)
        textH = TextHeight(objects()\name)
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        Box(locX-textW/2,locY-boxSize/2-2-textH,textW,textH,$55000000)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(locX-textW/2,locY-boxSize/2-2-textH,objects()\name)
        DrawingMode(#PB_2DDrawing_Default)
      Case #objIndustry
        Box(locX-boxSize/2,locY-boxSize/2,boxSize,boxSize,$FF0000)
        DrawingFont(FontID(2))
        textW = TextWidth(objects()\name)
        textH = TextHeight(objects()\name)
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        Box(locX-textW/2,locY-boxSize/2-2-textH,textW,textH,$33000000)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(locX-textW/2,locY-boxSize/2-2-textH,objects()\name)
        DrawingMode(#PB_2DDrawing_Default)
    EndSelect
  Next
  
  StopDrawing()
EndProcedure
; IDE Options = PureBasic 5.50 (Windows - x64)
; Folding = ---
; EnableXP