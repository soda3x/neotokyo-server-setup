# Neotokyo Server Tool

Powershell script for setting up a Neotokyo dedicated server.

```txt
Usage: .\SetupNeotokyoServer.ps1 [OPTIONS]
Options:
  -Hostname        Specify the server hostname (default: 'My Neotokyo Server').
  -RconPassword    Set the RCON password for server administration (default: none, RCON disabled).
  -ServerPassword  Set a password for the server (default: none).
  -Port            Specify the server port (default: 27015).
  -Help            Display this help message.
```

* Downloads and manages SteamCMD and Neotokyo, keeping the dedicated server files up to date
* Generates a runnable batch script so you can easily start your server
* Provides options to be pre-filled in your `server.cfg` file to quickly get your server up and running
