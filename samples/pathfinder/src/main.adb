--------------------------------------------------------------------------------
-- FILE   : main.adb
-- SUBJECT: Main program of the Priority Inversion/Inhertiance demonstration program.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with System;

-- Bring in the necessary modules, both from CubedOS and from this application.
with CubedOS.Log_Server.Messages;
with Random_Number_Generator.Messages;
with Read_Number.Messages;
with System_Bus.Messages;
with Telemetry.Messages;

pragma Unreferenced(CubedOS.Log_Server.Messages);
pragma Unreferenced(Random_Number_Generator.Messages);
pragma Unreferenced(Read_Number.Messages);
pragma Unreferenced(System_Bus.Messages);
pragma Unreferenced(Telemetry.Messages);

procedure Main with
   Priority => System.Priority'First
is
begin
   null;
end Main;
