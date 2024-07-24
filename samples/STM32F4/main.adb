--------------------------------------------------------------------------------
-- FILE   : main.adb
-- SUBJECT: Main program of the STM32F4 demonstration.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with System;

-- Bring in the necessary modules, both from CubedOS and from this application.
with CubedOS.Log_Server.Messages;
with CubedOS.Publish_Subscribe_Server.Messages;
with CubedOS.Time_Server.Messages;

with LED_Driver.Messages;
with Button_Driver.Messages;
with Control.Messages;

pragma Unreferenced(CubedOS.Log_Server.Messages);
pragma Unreferenced(CubedOS.Publish_Subscribe_Server.Messages);
pragma Unreferenced(CubedOS.Time_Server.Messages);

pragma Unreferenced(LED_Driver.Messages);
pragma Unreferenced(Button_Driver.Messages);
pragma Unreferenced(Control.Messages);


procedure Main is
   pragma Priority(System.Priority'First);
begin
   null;
end Main;
