--------------------------------------------------------------------------------
-- FILE   : main.adb
-- SUBJECT: Main program of the echo client/server CubedOS demonstration program.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with System;

-- Bring in the necessary modules, both from CubedOS and from this application.

with Echo_Client.Messages;
with Echo_Server.Messages;
with CubedOS.Log_Server.Messages;

pragma Unreferenced(Echo_Client.Messages);
pragma Unreferenced(Echo_Server.Messages);
pragma Unreferenced(CubedOS.Log_Server.Messages);

procedure Main is
   pragma Priority(System.Priority'First);
begin
   return;
end Main;
