#command = "⌘"

ImportC "/System/Library/Frameworks/Accelerate.framework/Accelerate"
  vImageUnpremultiplyData_RGBA8888 (*src, *dest, flags) 
EndImport

Macro ImageFromFile
  LoadImageEx
EndMacro

; code by wilbert (http://www.purebasic.fr/english/viewtopic.php?p=392073#p392073)
Procedure LoadImageEx(Filename.s,Image = #PB_Any)
  Protected.i Result, Rep, vImg.vImage_Buffer
  Protected Size.NSSize, Point.NSPoint
  CocoaMessage(@Rep, 0, "NSImageRep imageRepWithContentsOfFile:$", @Filename)
  If Rep
    Size\width = CocoaMessage(0, Rep, "pixelsWide")
    Size\height = CocoaMessage(0, Rep, "pixelsHigh")
    If Size\width And Size\height
      CocoaMessage(0, Rep, "setSize:@", @Size)
    Else
      CocoaMessage(@Size, Rep, "size")
    EndIf
    If Size\width And Size\height
      Result = CreateImage(Image, Size\width, Size\height, 32, #PB_Image_Transparent)
      If Result
        If Image = #PB_Any : Image = Result : EndIf
        StartDrawing(ImageOutput(Image))
        CocoaMessage(0, Rep, "drawAtPoint:@", @Point)
        If CocoaMessage(0, Rep, "hasAlpha")
          vImg\data = DrawingBuffer()
          vImg\width = OutputWidth()
          vImg\height = OutputHeight()
          vImg\rowBytes = DrawingBufferPitch()
          vImageUnPremultiplyData_RGBA8888(@vImg, @vImg, 0)
        EndIf
        StopDrawing()
      EndIf
    EndIf
  EndIf  
  ProcedureReturn Result
EndProcedure

Procedure CatchImageEx(Image, *MemoryAddress, MemorySize)
  Protected.i Result, DataObj, Class, Rep, vImg.vImage_Buffer
  Protected Size.NSSize, Point.NSPoint
  CocoaMessage(@DataObj, 0, "NSData dataWithBytesNoCopy:", *MemoryAddress, "length:", MemorySize, "freeWhenDone:", #NO)
  CocoaMessage(@Class, 0, "NSImageRep imageRepClassForData:", DataObj)
  If Class
    CocoaMessage(@Rep, Class, "imageRepWithData:", DataObj)
    If Rep
      Size\width = CocoaMessage(0, Rep, "pixelsWide")
      Size\height = CocoaMessage(0, Rep, "pixelsHigh")
      If Size\width And Size\height
        CocoaMessage(0, Rep, "setSize:@", @Size)
      Else
        CocoaMessage(@Size, Rep, "size")
      EndIf    
      If Size\width And Size\height
        Result = CreateImage(Image, Size\width, Size\height, 32, #PB_Image_Transparent)
        If Result
          If Image = #PB_Any : Image = Result : EndIf
          StartDrawing(ImageOutput(Image))
          CocoaMessage(0, Rep, "drawAtPoint:@", @Point)
          If CocoaMessage(0, Rep, "hasAlpha")
            vImg\data = DrawingBuffer()
            vImg\width = OutputWidth()
            vImg\height = OutputHeight()
            vImg\rowBytes = DrawingBufferPitch()
            vImageUnPremultiplyData_RGBA8888(@vImg, @vImg, 0)
          EndIf
          StopDrawing()
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure
; IDE Options = PureBasic 5.44 Beta 3 LTS (MacOS X - x64)
; Folding = -
; EnableUnicode
; EnableXP