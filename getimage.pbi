;============================================= 
; Library:         GetImage 
; Author:          Lloyd Gallant (netmaestro) 
; Date:            October 26, 2006 
; Target OS:       Microsoft Windows 
; Target Compiler: PureBasic 4.xx 
; Dependencies:    gdiplus.dll 
; License:         Open Source 
;============================================= 

Global PixelFormatIndexed        = $00010000 ; Indexes into a palette 
Global PixelFormatGDI            = $00020000 ; Is a GDI-supported format 
Global PixelFormatAlpha          = $00040000 ; Has an alpha component 
Global PixelFormatPAlpha         = $00080000 ; Pre-multiplied alpha 
Global PixelFormatExtended       = $00100000 ; Extended color 16 bits/channel 
Global PixelFormatCanonical      = $00200000 
Global PixelFormatUndefined      = 0 
Global PixelFormatDontCare       = 0 
Global PixelFormat1bppIndexed    = (1 | ( 1 << 8) |PixelFormatIndexed |PixelFormatGDI) 
Global PixelFormat4bppIndexed    = (2 | ( 4 << 8) |PixelFormatIndexed |PixelFormatGDI) 
Global PixelFormat8bppIndexed    = (3 | ( 8 << 8) |PixelFormatIndexed |PixelFormatGDI) 
Global PixelFormat16bppGrayScale = (4 | (16 << 8) |PixelFormatExtended) ; $100 
Global PixelFormat16bppRGB555    = (5 | (16 << 8) |PixelFormatGDI) 
Global PixelFormat16bppRGB565    = (6 | (16 << 8) |PixelFormatGDI) 
Global PixelFormat16bppARGB1555  = (7 | (16 << 8) |PixelFormatAlpha |PixelFormatGDI) 
Global PixelFormat24bppRGB       = (8 | (24 << 8) |PixelFormatGDI) 
Global PixelFormat32bppRGB       = (9 | (32 << 8) |PixelFormatGDI) 
Global PixelFormat32bppARGB      = (10 | (32 << 8) |PixelFormatAlpha |PixelFormatGDI |PixelFormatCanonical) 
Global PixelFormat32bppPARGB     = (11 | (32 << 8) |PixelFormatAlpha |PixelFormatPAlpha |PixelFormatGDI) 
Global PixelFormat48bppRGB       = (12 | (48 << 8) |PixelFormatExtended) 
Global PixelFormat64bppARGB      = (13 | (64 << 8) |PixelFormatAlpha  |PixelFormatCanonical |PixelFormatExtended) 
Global PixelFormat64bppPARGB     = (14 | (64 << 8) |PixelFormatAlpha  |PixelFormatPAlpha |PixelFormatExtended) 
Global PixelFormatMax            =  15  

CompilerIf Defined(GdiplusStartupInput, #PB_Structure) = 0 
  Structure GdiplusStartupInput 
    GdiPlusVersion.l 
    *DebugEventCallback.Debug_Event 
    SuppressBackgroundThread.l 
    SuppressExternalCodecs.l 
  EndStructure 
CompilerEndIf  

Structure StreamObject 
  block.l 
  *bits 
  stream.ISTREAM 
EndStructure 

Procedure StringToBStr (string$) ; By Zapman Inspired by Fr34k 
  Protected Unicode$ = Space(Len(String$)* 2 + 2) 
  Protected bstr_string.l 
  PokeS(@Unicode$, String$, -1, #PB_Unicode) 
  bstr_string = SysAllocString_(@Unicode$) 
  ProcedureReturn bstr_string 
EndProcedure 

ProcedureDLL ImageFromMem(Address, Length) 
  
  Protected lib 
  lib = OpenLibrary(#PB_Any, "gdiplus.dll") 
  If Not lib 
    ProcedureReturn 0 
  EndIf 
  
  input.GdiplusStartupInput 
  input\GdiPlusVersion = 1 
  
  CallFunction(lib, "GdiplusStartup", @*token, @input, #Null) 
  If *token 
    stream.streamobject 
    Stream\block = GlobalAlloc_(#GHND, Length) 
    Stream\bits = GlobalLock_(Stream\block) 
    CopyMemory(address, stream\bits, Length) 
    If CreateStreamOnHGlobal_(stream\bits, 0, @Stream\stream) = #S_OK 
      CallFunction(lib, "GdipCreateBitmapFromStream", Stream\stream , @*image) 
     Else 
      CallFunction(lib, "GdiplusShutdown", *token) 
      ProcedureReturn 0 
    EndIf 
    
    If *image 
      CallFunction(lib, "GdipGetImageWidth", *image, @Width.l) 
      CallFunction(lib, "GdipGetImageHeight", *image, @Height.l) 
      CallFunction(lib, "GdipGetImagePixelFormat", *image, @Format.l) 
      
      Select Format 
        Case PixelFormat1bppIndexed: bits_per_pixel = 1 
        Case PixelFormat4bppIndexed: bits_per_pixel = 4 
        Case PixelFormat8bppIndexed: bits_per_pixel = 8 
        Case PixelFormat16bppARGB1555: bits_per_pixel = 16 
        Case PixelFormat16bppGrayScale: bits_per_pixel = 16 
        Case PixelFormat16bppRGB555: bits_per_pixel = 16 
        Case PixelFormat16bppRGB565: bits_per_pixel = 16 
        Case PixelFormat24bppRGB: bits_per_pixel = 24 
        Case PixelFormat32bppARGB: bits_per_pixel = 32 
        Case PixelFormat32bppPARGB: bits_per_pixel = 32 
        Case PixelFormat32bppRGB: bits_per_pixel = 32 
        Case PixelFormat48bppRGB: bits_per_pixel = 48 
        Case PixelFormat64bppARGB: bits_per_pixel = 64 
        Case PixelFormat64bppPARGB: bits_per_pixel = 64 
        Default : bits_per_pixel = 32 
      EndSelect 
      
      If bits_per_pixel < 24 : bits_per_pixel = 24 : EndIf 
      imagenumber = CreateImage(#PB_Any, Width, Height, bits_per_pixel) 
      Retval = ImageID(imagenumber) 
      hDC = StartDrawing(ImageOutput(ImageNumber)) 
      CallFunction(lib, "GdipCreateFromHDC", hdc, @*gfx) 
      CallFunction(lib, "GdipDrawImageRectI", *gfx, *image, 0, 0, Width, Height) 
      StopDrawing()  
      Stream\stream\Release() 
      GlobalUnlock_(Stream\bits) 
      GlobalFree_(Stream\block) 
      CallFunction(lib, "GdipDeleteGraphics", *gfx)  
      CallFunction(lib, "GdipDisposeImage", *image) 
      CallFunction(lib, "GdiplusShutdown", *token) 
      CloseLibrary(0) 
      
      ProcedureReturn imagenumber
    Else 
      ProcedureReturn 0 
    EndIf 
  Else 
    ProcedureReturn 0 
  EndIf 
EndProcedure 

ProcedureDLL ImageFromFile(Filename$) 
  Protected lib 
  lib = OpenLibrary(#PB_Any, "gdiplus.dll") 
  If Not lib 
    ProcedureReturn 0 
  EndIf 
  
  input.GdiplusStartupInput 
  input\GdiPlusVersion = 1 
  
  CallFunction(lib, "GdiplusStartup", @*token, @input, #Null) 
  If *token 
    CallFunction(lib, "GdipCreateBitmapFromFile", StringToBStr(Filename$), @*image) 
    CallFunction(lib, "GdipGetImageWidth", *image, @Width.l) 
    CallFunction(lib, "GdipGetImageHeight", *image, @Height.l) 
    CallFunction(lib, "GdipGetImagePixelFormat", *image, @Format.l) 
    
    Select Format 
      Case PixelFormat1bppIndexed: bits_per_pixel = 1 
      Case PixelFormat4bppIndexed: bits_per_pixel = 4 
      Case PixelFormat8bppIndexed: bits_per_pixel = 8 
      Case PixelFormat16bppARGB1555: bits_per_pixel = 16 
      Case PixelFormat16bppGrayScale: bits_per_pixel = 16 
      Case PixelFormat16bppRGB555: bits_per_pixel = 16 
      Case PixelFormat16bppRGB565: bits_per_pixel = 16 
      Case PixelFormat24bppRGB: bits_per_pixel = 24 
      Case PixelFormat32bppARGB: bits_per_pixel = 32 
      Case PixelFormat32bppPARGB: bits_per_pixel = 32 
      Case PixelFormat32bppRGB: bits_per_pixel = 32 
      Case PixelFormat48bppRGB: bits_per_pixel = 48 
      Case PixelFormat64bppARGB: bits_per_pixel = 64 
      Case PixelFormat64bppPARGB: bits_per_pixel = 64 
      Default : bits_per_pixel = 32 
    EndSelect 
    
    If bits_per_pixel < 24 : bits_per_pixel = 24 : EndIf
    If Not width Or Not height : ProcedureReturn 0 : EndIf
    imagenumber = CreateImage(#PB_Any, Width, Height, bits_per_pixel) 
    Retval = ImageID(imagenumber) 
    hDC = StartDrawing(ImageOutput(ImageNumber)) 
    CallFunction(lib, "GdipCreateFromHDC", hdc, @*gfx) 
    CallFunction(lib, "GdipDrawImageRectI", *gfx, *image, 0, 0, Width, Height) 
    StopDrawing()  
    CallFunction(lib, "GdipDeleteGraphics", *gfx)  
    CallFunction(lib, "GdipDisposeImage", *image) 
    CallFunction(lib, "GdiplusShutdown", *token) 
    CloseLibrary(lib) 
    
    ProcedureReturn imagenumber 
  Else 
    ProcedureReturn 0 
  EndIf 
  
EndProcedure 
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 164
; FirstLine = 137
; Folding = -
; EnableXP