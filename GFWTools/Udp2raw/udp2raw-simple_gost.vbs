Set SA = CreateObject("Shell.Application")
If WScript.Arguments.Count <= 0 Then
	SA.ShellExecute "cscript.exe", """"& WScript.ScriptFullName &""" 1", Null, "runas", 0
	WScript.Quit
End If

Set WS = CreateObject("WScript.Shell")
Set SF = CreateObject("Scripting.FileSystemObject")
Set Cimv2 = GetObject("winmgmts:\\.\root\cimv2")

Class App_udp2raw
	Private Title
	Private Host
	Private errorLog
	Private CommandLine
	Private RetryCount
	Public Running
	
	Private Sub Class_Initialize
	Title = "Udp2Raw"
	Host = "202.181.104.225"
	errorLog = "udp2raw-simple.log"
	CommandLine = "udp2raw_mp.exe -c -r"& Host &":8856 -l127.0.0.1:22345 --raw-mode faketcp -kpasswd --log-level 3 --sock-buf 4096 --cipher-mode xor --auth-mode simple"
	RetryCount = 10
	Running = False
	End Sub
	
	Public Sub AddFirewall
		WS.Run "netsh advfirewall firewall delete rule name=udp2raw-simple", 0, True
		WS.Run "netsh advfirewall firewall add rule name=udp2raw-simple protocol=TCP dir=in remoteip="& Host &"/32 remoteport=8856 action=block", 0, True
		WS.Run "netsh advfirewall firewall add rule name=udp2raw-simple protocol=TCP dir=out remoteip="& Host &"/32 remoteport=8856 action=block", 0, True
	End Sub
	
	Public Function CheckRunning
	Set Processes = Cimv2.ExecQuery("Select ProcessId From Win32_Process Where CommandLine="""& CommandLine &"""")
	Result = Confirm(Processes.Count > 0)
	CheckRunning = True
	If Result = vbNo Then
		CheckRunning =  False
	Elseif Processes.Count > 0 Then
		Running = True
		For Each Process in Processes: Process.Terminate 0: Next
	End If
	End Function
	
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

Class App_gost
	Private Title
	Private errorLog
	Private CommandLine
	
	Private Sub Class_Initialize
	Title = "Gost"
	errorLog = "gost.log"
	CommandLine = "gost.exe -L=:1080 -F=ss+kcp://chacha20:ss123456@127.0.0.1:22345?c=kcp.json"
	End Sub
	
	Public Sub CheckRunning
	Set Processes = Cimv2.ExecQuery("Select ProcessId From Win32_Process Where CommandLine=""" & CommandLine & """")
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
	Set fsm = SF.OpenTextFile(".\\" & errorLog, 2, true)
	Do While Not oExec.StdErr.AtEndOfStream
		fsm.WriteLine oExec.StdErr.ReadLine
		WScript.Sleep 200
	Loop
	fsm.Close
	End Sub
	
	Private Function Confirm(isRunning)
	If isRunning Then
		Confirm = MsgBox(Title & " is running, do you want to stop it ?", vbYesNo or vbExclamation, "Question")
	Else
		Confirm = MsgBox(Title & " is not running, do you want to start it ?", vbYesNo or vbQuestion, "Question")
	End If
	End Function
End Class


If WScript.Arguments(0) = "1" Then
	Set App = new App_udp2raw
	Result = App.CheckRunning
	SA.ShellExecute "cscript.exe", """"& WScript.ScriptFullName &""" 2", Null, "runas", 0
	If Not Result Or App.Running Then WScript.Quit: End If
	App.AddFirewall
	App.RunCommand
Elseif WScript.Arguments(0) = "2" Then
	Set App = new App_gost
	App.CheckRunning
	App.RunCommand
End If

