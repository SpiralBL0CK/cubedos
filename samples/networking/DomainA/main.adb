--------------------------------------------------------------------------------
-- FILE   : main.adb
-- SUBJECT: Main program of the echo client/server CubedOS demonstration program.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with System;

-- Bring in the necessary modules, both from CubedOS and from this application.
with DomainA_Client.Messages;
with CubedOS.Transport_UDP.Messages;
with CubedOS.Log_Server.Messages;

pragma Unreferenced(CubedOS.Log_Server.Messages);
pragma Unreferenced(CubedOS.Transport_UDP.Messages);
pragma Unreferenced(DomainA_Client.Messages);

procedure Main is
   pragma Priority(System.Priority'First);
begin
   return;
end Main;
