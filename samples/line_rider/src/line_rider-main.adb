--------------------------------------------------------------------------------
-- FILE   : line_rider-main.adb
-- SUBJECT: Main program of the Line Rider application.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with System;

-- The "last chance handler" is the user-defined routine that is called when an exception tries
-- to propagate. We need it in the executable, therefore it must be somewhere in the closure of
-- the context clauses.
--
with Last_Chance_Handler;  pragma Unreferenced(Last_Chance_Handler);
with Line_Rider.States;    pragma Unreferenced(Line_Rider.States);
with Sensor_Driver.API;    pragma Unreferenced(Sensor_Driver.API);

procedure Line_Rider.Main is
   pragma Priority(System.Priority'First);
begin
   null;
end Line_Rider.Main;
