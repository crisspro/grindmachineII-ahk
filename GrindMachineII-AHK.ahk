;nombre: GrindMachineII-AHK
;Autor: crisspro
;Año: 2020
;Licencia: GPL-3.0

#Include JSON.ahk


ScriptNombre:= "GrindMachineII-AHK"
ScriptVersion:= "v1.0"
ScriptApi:= "https://api.github.com/repos/crisspro/grindmachineii-ahk/releases/latest"
VSTNombre:= "Grind Machine II"
VSTControl:= "IPlug"

xg:= 0
yg:= 0
VSTControlDetectado:= False
VSTNombreDetectado:= False

;funciones

;mensajes
;carga NVDA
nvdaSpeak(text)
{
Return DllCall("nvdaControllerClient" A_PtrSize*8 ".dll\nvdaController_speakText", "wstr", text)
}

;verbaliza mensajes por medio del lector de pantalla
hablar(es,en)
{
Lector:= "otro"
process, Exist, nvda.exe
if ErrorLevel != 0
{
Lector:= "nvda"
if (InStr(A_language,"0a") = "3")
nvdaSpeak(es)
else
nvdaSpeak(en)
}
process, Exist, jfw.exe
if ErrorLevel != 0
{
Lector:= "jaws"
Jaws := ComObjCreate("FreedomSci.JawsApi")
if (InStr(A_language,"0a") = "3")
Jaws.SayString(es)
else
Jaws.SayString(en)
}
If global Lector = "otro"
{
Sapi := ComObjCreate("SAPI.SpVoice")
Sapi.Rate := 5
Sapi.Volume :=90
if (InStr(A_language,"0a") = "3")
Sapi.Speak(es)
else
Sapi.Speak(en)
}
}

;Chequea si hay nueva versión del script
descargar(ScriptApi, ScriptVersion)
{
try
{
enlace:= ComObjCreate("WinHttp.WinHttpRequest.5.1")
enlace.Open("GET", ScriptApi, true)
enlace.Send()
enlace.WaitForResponse()
base := enlace.ResponseText
texto:= JSON.Load(base)
for i, obj in texto
if i = tag_name
{
If obj != %ScriptVersion%
{ 
if (InStr(A_language,"0a") = "3")
{
SoundPlay,sounds\version.wav
MsgBox, 4, , Hay una nueva versión de este script. ¿Quieres descargarlo ahora?
IfMsgBox Yes
resp:= True
}
else
{
MsgBox, 4, , There is a new version of this script abailable, do you want to download it?
IfMsgBox Yes
resp:= True
}
}
}
If (resp = True)
{
for i, obj in texto
if i = assets
for j, k in obj
for l, m in k
If l = browser_download_url 
Run %m%
}
}
}

SetTitleMatchMode,2

;inicio
SoundPlay,sounds/start.wav, 1
hablar(ScriptNombre " activado",ScriptNombre " ready")
descargar(ScriptApi, ScriptVersion)

;detecta el plugin
loop
{
WinGet, VentanaID,Id,A
winget, controles, ControlList, A
IfWinActive,%VSTNombre%
{
VSTNombreDetectado:= True
loop, parse, controles, `n
{
if A_LoopField contains %VSTControl%
{
VSTControlDetectado:= True
ControlGetPos, x,y,a,b,%A_loopField%, ahk_id %VentanaID% 
xg:= x
yg:= y
break
}
else
VSTControlDetectado:= False
}
}
else
VSTNombreDetectado:= False
}


;atajos
#If VSTControlDetectado= True and VSTNombreDetectado= True

;despliega el menú.
m:: MouseClick,LEFT, xg+391, yg+143,1

;cambia al preset anterior.
a::
MouseClick,LEFT, xg+190, yg+152,1
hablar("anterior", "back")
return

;cambia al siguiente preset.
s::
MouseClick,LEFT, xg+561, yg+155,1
hablar("siguiente", "next")
return
 

;abre la ayuda.
f1::
if (InStr(A_language,"0a") = "3")
Run Documentation\es.html
else
Run Documentation\en.html
return

;sale del script.
^q:: 
SoundPlay,sounds/exit.wav,1
hablar(ScriptNombre " cerrado",ScriptNombre " closed")
ExitApp
return