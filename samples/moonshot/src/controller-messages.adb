--------------------------------------------------------------------------------
-- FILE   : controller-messages.adb
-- SUBJECT: Body of a package that implements the main part of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager;
with Name_Resolver;
with CubedOS.Log_Server.API;
with CubedOS.File_Server.API;
with Ada.Real_Time;
with CubedOS.Time_Server.API;
with Camera.API;
with Ada.Text_IO;
use CubedOS.File_Server.API;

package body Controller.Messages is
   use Message_Manager;

   procedure Initialize is
      Periodic_Message : Message_Record;
   begin
      Periodic_Message := CubedOS.Time_Server.API.Relative_Request_Encode
        (Sender_Address => Name_Resolver.Controller,
         Request_ID => 1,
         Tick_Interval => Ada.Real_Time.Seconds(10),
         Request_Type => CubedOS.Time_Server.API.Periodic,
         Series_ID => 1);
      Message_Manager.Route_Message
        (Message => Periodic_Message);
   end Initialize;

   -------------------
   -- Message Handling
   -------------------

   procedure Handle_Tick_Reply(Message : in Message_Record)
     with Pre => CubedOS.Time_Server.API.Is_Tick_Reply(Message)
   is
      Series_ID : CubedOS.Time_Server.API.Series_ID_Type;
      Status : Message_Status_Type;
      Count : Natural;
      Image_Request : Message_Record;
   begin
      CubedOS.Time_Server.API.Tick_Reply_Decode
        (Message => Message,
         Series_ID => Series_ID,
         Count => Count,
         Decode_Status => Status);
      if Status = Message_Manager.Success then
         Image_Request := Camera.API.Take_Image_Request_Encode
           (Sender_Address => Name_Resolver.Controller,
            Request_ID => Request_ID_Type(Count));
         Message_Manager.Route_Message(Image_Request);
         Ada.Text_IO.Put_Line("Ping has been handled. Image request has been sent to camera...");
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "Tick message has decoded inccorectly!");
      end if;
   end Handle_Tick_Reply;

   procedure Handle_Image_Reply(Message : in Message_Record)
     with Pre => Camera.API.Is_Take_Image_Reply(Message)
   is
      Status : Message_Status_Type;
      Name_Size : Natural := 0;
      File_Name : String(1 .. 128);
      Open_Request : Message_Record;
   begin
      Camera.API.Take_Image_Reply_Decode
         (Message => Message,
          File_Name => File_Name,
          File_Name_Size => Name_Size,
          Decode_Status => Status);
      if Status = Message_Manager.Success then
         Open_Request := CubedOS.File_Server.API.Open_Request_Encode
           (Sender_Address => Name_Resolver.Controller,
            Request_ID => 1,
            Mode => CubedOS.File_Server.API.Read,
            Name => File_Name);
         Message_Manager.Route_Message(Open_Request);
         Ada.Text_IO.Put_Line("Image reply has been handled, open request for " & File_Name);
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "Image reply message has decoded inccorectly!");
      end if;
   end Handle_Image_Reply;

   procedure Handle_Open_Reply(Message : in Message_Record)
     with Pre => CubedOS.File_Server.API.Is_Open_Reply(Message)
   is
      Status : Message_Status_Type;
      Handle : CubedOS.File_Server.API.File_Handle_Type;
   begin
      CubedOS.File_Server.API.Open_Reply_Decode
        (Message => Message,
         Handle => Handle,
         Decode_Status => Status);
      if Status /= Message_Manager.Success then
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "Open reply message has decoded inccorectly!");
      elsif Handle = CubedOS.File_Server.API.Invalid_Handle then
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "File failed to open");
      else
         Ada.Text_IO.Put_Line("File has been opened...");
      end if;
   end Handle_Open_Reply;

   -----------------------------------
   -- Message Decoding and Dispatching
   -----------------------------------

   -- This procedure processes exactly one message at a time.
   procedure Process(Message : in Message_Record) is
   begin
      if CubedOS.Time_Server.API.Is_Tick_Reply(Message) then
         Ada.Text_IO.Put_Line("Tick reply has been received");
         Handle_Tick_Reply(Message);
      elsif Camera.API.Is_Take_Image_Reply(Message) then
         Ada.Text_IO.Put_Line("Image Reply has been received");
         Handle_Image_Reply(Message);
      elsif CubedOS.File_Server.API.Is_Open_Reply(Message) then
         Ada.Text_IO.Put_Line("Open Reply has been received");
         Handle_Open_Reply(Message);
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "An unknown message type has been received!");
      end if;
   end Process;

   ---------------
   -- Message Loop
   ---------------

   task body Message_Loop is
      Incoming_Message : Message_Manager.Message_Record;
   begin
      Initialize;
      Ada.Text_IO.Put_Line("Initialization is done. Ticks are starting...");
      loop
         Message_Manager.Fetch_Message(Name_Resolver.Controller.Module_ID, Incoming_Message);
         Process(Incoming_Message);
      end loop;
   end Message_Loop;

end Controller.Messages;
