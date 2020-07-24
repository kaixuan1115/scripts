Const Title = "Udp2Raw", errorLog = "udp2raw.log", Host = "202.181.104.225"

Class Application
	Private WS
	Private SF
	Private SA
	Private Cimv2
	Private CommandLine
	Private RetryCount
	
	Private Sub Class_Initialize
	Set WS = CreateObject("WScript.Shell")
	Set SF = CreateObject("Scripting.FileSystemObject")
	Set SA = CreateObject("Shell.Application")
	Set Cimv2 = GetObject("winmgmts:\\.\root\cimv2")
	CommandLine = "udp2raw_mp_nolibnet.exe -c -r"& Host &":8855 -l0.0.0.0:22345 --raw-mode faketcp -kpasswd --log-level 3 --sock-buf 4096"
	RetryCount = 15
	End Sub
	
	Private Sub Class_Terminate
	Set WS = NoThing
	Set SF = NoThing
	Set SA = NoThing
	Set Cimv2 = NoThing
	End Sub
	
	Public Sub HideExecute
	If LCase(Right(WScript.FullName, 11)) = "wscript.exe" Then
		SA.ShellExecute "cscript.exe", """"& WScript.ScriptFullName &"""", Null, "runas", 0
		WScript.Quit
	End If
	End Sub
	
	Public Sub AddFirewall
	WS.Run "netsh advfirewall firewall delete rule name=udp2raw", 0, True
	WS.Run "netsh advfirewall firewall add rule name=udp2raw protocol=TCP dir=in remoteip="& Host &"/32 remoteport=8855 action=block", 0, True
	WS.Run "netsh advfirewall firewall add rule name=udp2raw protocol=TCP dir=out remoteip="& Host &"/32 remoteport=8855 action=block", 0, True
	End Sub
	
	Public Sub CheckRunning
	Set Processes = Cimv2.ExecQuery("Select ProcessId From Win32_Process Where CommandLine="""& CommandLine &"""")
	Result = Confirm(Processes.Count > 0)
	If Result = vbNo Then
		WScript.Quit
	Elseif Processes.Count > 0 Then
		For Each Process in Processes: Process.Terminate 0: Next
		WScript.Quit
	End If
	End Sub
	
	Public Sub RunCommand
	Set oExec = WS.Exec(CommandLine)
	If Len(errorLog) <= 0 Then
		WScript.Quit
	End If
	strLine = ""
	Set fsm = SF.OpenTextFile(".\\" & errorLog, 2, true)
	Do While Not oExec.StdOut.AtEndOfStream
		strLine = oExec.StdOut.ReadLine()
		fsm.WriteLine strLine
		WScript.Sleep 200
	Loop
	fsm.Close
	If InStr(UCase(strLine), "FATAL") > 0 And RetryCount > 0 Then
		RetryCount = RetryCount - 1
		WScript.Sleep 3000: RunCommand
	End If
	End Sub
	
	Private Function Confirm(isRunning)
	If isRunning Then
		Confirm = MsgBox(Title &" is running, do you want to stop it ?", vbYesNo or vbExclamation, "Question")
	Else
		Confirm = MsgBox(Title &" is not running, do you want to start it ?", vbYesNo or vbQuestion, "Question")
	End If
	End Function
End Class

Set App = new Application
App.HideExecute
App.CheckRunning
App.AddFirewall
App.RunCommand

