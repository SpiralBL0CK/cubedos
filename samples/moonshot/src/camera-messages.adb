--------------------------------------------------------------------------------
-- FILE   : Camera-messages.adb
-- SUBJECT: Body of a package that implements the main part of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager;
with Name_Resolver;
with Camera.API;
with CubedOS.Log_Server.API;

package body Camera.Messages is
   use Message_Manager;

   procedure Handle_Take_Image_Request(Message : in Message_Record)
     with Pre => Camera.API.Is_Take_Image_Request(Message)
   is
      Image_Reply : Message_Record;
   begin
      if Message.Request_ID mod 2 = 0 then
         Image_Reply := Camera.API.Take_Image_Reply_Encode
          (Receiver_Address => Message.Sender_Address,
           Request_ID => 2,
           File_Name => "Image-Korolev.jpg");
      else
         Image_Reply := Camera.API.Take_Image_Reply_Encode
           (Receiver_Address => Message.Sender_Address,
            Request_ID => 1,
            File_Name => "Image-Copernicus.jpg");
      end if;
      Route_Message(Image_Reply);
   end Handle_Take_Image_Request;

   -----------------------------------
   -- Message Decoding and Dispatching
   -----------------------------------

   -- This procedure processes exactly one message at a time.
   procedure Process(Message : in Message_Record) is
   begin
      if Camera.API.Is_Take_Image_Request(Message) then
         Handle_Take_Image_Request(Message);
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Camera,
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
      loop
         Message_Manager.Fetch_Message(Name_Resolver.Camera.Module_ID, Incoming_Message);
         Process(Incoming_Message);
      end loop;
   end Message_Loop;

end Camera.Messages;
