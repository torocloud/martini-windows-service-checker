# Martini Runtime Windows Service Checker

## Overview
When hosting Martini Runtme on your own server you’ll want to setup a separate service that monitors Martini Runtime and triggers an auto-recovery script should it not be responding.

This document provides a couple of simple options to monitor and restart Martini Runtime in a Windows Server environment.

## Setting up Windows Service Manager recovery option
Windows provides an option to recover any service that is no longer responding within Windows Service Manager.

Note that this monitors at the application level. It does not monitor individual services that Martini may be running. That is, it can restart Martini Runtime if it detects that the application has crashed but it won’t take any action if one of the REST APIs that Martini Runtime is hosting is not responding.

To monitor Martini Runtime at the service level see the PowerShell script option below.

To configure Windows Service Manager recovery option: 
<pre>
1.) Open the Control Panel.
2.) Double-click the Administrative Tools icon.
3.) Double-click the Services icon in the Administrative Tools dialog box.
4.) The Services dialog box appears.
5.) Right-click the “Martini Runtime” service.
6.) Select Properties.
7.) The Service Properties dialog box appears.
8.) Select the Recovery tab.
9.) Select the recovery actions you want in the First attempt failure, Second attempt failure and Subsequent attempts failure fields.
</pre>

## Monitoring Martini Runtime at the service level using PowerShell
This repo contains a PowerShell script that can be used to monitor any service exposed via HTTP on Martini Runtime. The script will make a web request to the http endpoint specified and check the response code. If the response code is 200, that is the service “OK”, then the script will not take any action. However, if the response code is anything other than 200 then the script will initiate a restart of the service.

### Line 2: Defining your http endpoint to monitor
By default the script makes a request to the HelloYou REST API from the Examples package. This will only work if the Examples package is installed and started on your Martini Runtime instance. 

You can manually test the path to this API by entering the following URL in your brower or HTTP client:

http://{MartiniRuntimeServerURL}:{port}/api/sample/hello/Martini

This will return the following response with Status code = 200:
<pre>
{
	"message": "Hello Martini"
}
</pre>
It is recommended that you change this URL to the http endpoint of the service you would like to monitor.

### Line 10: Check the status code
Note that the script does not inspect the body of the response. On line 10 of the script it only inspects the status code of the response. If the status code = 200 then it is assumed the service is OK. In line 15 if the status code is anything other than 200 then the service will be restarted.

### Running the script
To emulate the action the script will take if the Martini Runtime service being monitored is running:
<pre>
1.) Ensure the Martini Package containing your service is started.
2.) Manually test the service by entering the URL of the service in a browser or HTTP client.
3.) Start PowerShell
4.) Copy and paste the script into PowerShell

Click Run
</pre>
The PowerShell console should display a message “Martini is OK!”

To emulate the action the script will take if the Martini Runtime service being monitored is not running or is returning a response code other than 200:
<pre>
1.) Stop the Martini Package containing your service.
2.) Start PowerShell
3.) Copy and paste the script into PowerShell

Click Run
</pre>

The PowerShell console should display a message “Martini not responding, restarting service...”.

Note that restarting the Martini Runtime instance can take up to a few minutes depending on the number of CPUs on the machine, the type and number of dependencies such as message queues and databases, and the number and size of Packages to be started.

After Martini Runtime has restarted you should be able to manually test the service by entering the URL of the service in a browser or HTTP client.

## Configuring the Martini Runtime PowerShell monitoring script to run on a schedule
Now that we have confirmed that the script is running as expected we will want to set it up so that it runs automatically on a schedule. To do this we will use Windows Task Scheduler.


### Configuring Task Scheduler to run the PowerShell monitoring script:
<br> 1.) Click “Create a task” and enter a name and description for the new task. In our example, we’ll assign a service account to run the task, and run it regardless of whether the user is logged on. ![image](https://user-images.githubusercontent.com/99488555/178425394-71392a47-a8ae-40d0-9ed2-4956a5f16097.png)
</br>
<br> 2.) Switch Trigger Tab and click the “New…” button. Here you can specify the conditions that trigger the task to be executed. For example, you can have it executed on schedule, at logon, on idle, at startup or whenever a particular event occurs. We want our task to run every 5 minutes to check whether our packages or api are running or not. So we choose "On a schedule" from the drop down and set it to daily. Under Advanced Settings, we set to Repeat the Task every 5 minutes for the duration of 1 day. ![image](https://user-images.githubusercontent.com/99488555/178425620-c371facf-b2b8-434a-8b69-66849b8ef7f0.png)
</br>
<br> 3.) Navigate to the “Actions” tab, and click “New…”. Here you can specify the actions that will be executed whenever the trigger conditions are met. In our case, we want to monitor our Martini service, so we will use the powershell script inside this repository.

To schedule the PowerShell script, specify the following parameters:
<pre>
Action: Start a program
Program\script: powershell
Add arguments (optional): -File [Specify the file path to the script here]
Click “OK” to save your changes.
</pre> 
![image](https://user-images.githubusercontent.com/99488555/178425703-a17752d3-6c60-4289-ad12-a4e0a0504c2e.png)

4.) The “Conditions” tab enables you to specify the conditions that, along with the trigger, determine whether the task should be run. In our case, we set it with the following settings:
<pre>
- [x] Start the task only if the computer is on AC power
- [x] Stop if the computer switches to battery power
</pre>
![image](https://user-images.githubusercontent.com/99488555/178425871-7f8d6944-9613-48d5-86ae-fd984ae5fdf8.png)

5.) You can also set up additional parameters for your scheduled task on the “Settings” tab. In our case, we set it with the following settings:
<pre>
- [x] Allow task to be run on demand
- [x] If the running task does not end when requested, force it to stop

The rest are unchecked.
</pre>
![image](https://user-images.githubusercontent.com/99488555/178425956-8817153b-2b7b-43dc-b174-dfc5dc78b132.png)

