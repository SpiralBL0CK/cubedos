--------------------------------------------------------------------------------
-- FILE   : main.adb
-- SUBJECT: Main program of the Moonshot CubedOS tutorial application.
-- AUTHOR : (C) Copyright 2024 by Vermont State University.
--
--------------------------------------------------------------------------------

-- Bring in the necessary modules, both from CubedOS and from this application.
with CubedOS.Log_Server.Messages;
with CubedOS.Time_Server.Messages;
with CubedOS.File_Server.Messages;
with CubedOS.Publish_Subscribe_Server.Messages;
with Controller.Messages;
with Camera.Messages;

pragma Unreferenced(CubedOS.Log_Server.Messages);
pragma Unreferenced(CubedOS.Time_Server.Messages);
pragma Unreferenced(CubedOS.File_Server.Messages);
pragma Unreferenced(CubedOS.Publish_Subscribe_Server.Messages);
pragma Unreferenced(Controller.Messages);
pragma Unreferenced(Camera.Messages);

procedure Main is
begin
   return;
end Main;
