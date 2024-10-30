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
with CubedOS.Lib.Space_Packets;
use CubedOS.File_Server.API;
with Ada.Exceptions;

package body Controller.Messages is
   use Message_Manager;

   -- Start the periodic ticks every minute.
   -- This will prompt images from the camera.
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

   -- when a tick is received, a Take_Image_Request is sent to the camera
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
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Tink has been handled. Image request has been sent to camera...");
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "Tick message has decoded inccorectly!");
      end if;
   end Handle_Tick_Reply;

   -- When an image reply is received from the camera,
   -- an open request is sent to the File Server to open it.
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
            Name => File_Name(1 .. Name_Size));
         Message_Manager.Route_Message(Open_Request);
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Image reply has been handled, sent open request for "
                                            & File_Name(1 .. Name_Size));
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Error,
                                            "Image reply message has decoded inccorectly!");
      end if;
   end Handle_Image_Reply;

   -- When an open reply is received from the File Server, we start reading the file
   procedure Handle_Open_Reply(Message : in Message_Record)
     with Pre => CubedOS.File_Server.API.Is_Open_Reply(Message)
   is
      Status : Message_Status_Type;
      Handle : CubedOS.File_Server.API.File_Handle_Type;
      Read_Request : Message_Record;
      Incomming_Message : Message_Record;
      Amount_Read : Read_Result_Size_Type;
      Data : CubedOS.Lib.Octet_Array(0 .. 255);   -- the data decoded from the image
      Space_Packet : CubedOS.Lib.Space_Packets.Space_Packet(511);
      Space_Data : CubedOS.Lib.Octet_Array(0 .. 512); -- the full data to send in the space packet
      Position : CubedOS.Lib.Octet_Array_Index := 0;  -- the index to which Space_Data has been filled
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
                                            "Image file failed to open");
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Image file has been opened. Sending a read request...");
         -- encode a space packet of 512 octets
         Space_Packet.Header := CubedOS.Lib.Space_Packets.Format_Primary_Header
           (APID => 42,
            Packet_Type => CubedOS.Lib.Space_Packets.Telemetry,
            Sequence_Count => 0,
            Data_Length => 512);
         -- encode a read request of 256 octets
         Read_Request := CubedOS.File_Server.API.Read_Request_Encode
           (Sender_Address => Name_Resolver.Controller,
            Request_ID => 0,
            Handle => Handle,
            Amount => 256);
         -- route the read request message
         Message_Manager.Route_Message(Read_Request);

         -- loop through until image is finished being read.
         loop
            Message_Manager.Fetch_Message(Name_Resolver.Controller.Module_ID, Incomming_Message);
            if CubedOS.File_Server.API.Is_Read_Reply(Incomming_Message) then
               CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                  CubedOS.Log_Server.API.Informational,
                                                  "Received a read reply " & integer'image(data'Length));
               Read_Reply_Decode(Incomming_Message, Handle, Amount_Read, Data, Status);
               if Status = Malformed then
                  CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                     CubedOS.Log_Server.API.Error,
                                                     "Read reply is malformed! Closing image...");
                  Message_Manager.Route_Message
                    (CubedOS.File_Server.API.Close_Request_Encode
                       (Name_Resolver.Controller, 0, Handle));
               else
                  CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                     CubedOS.Log_Server.API.Informational,
                                                     "sucessfully read " & Read_Result_Size_Type'Image(Amount_Read) & " octets. position = "
                                                     & CubedOS.Lib.Octet_Array_Index'Image(Position) & " Space_Data'Last = " &
                                                    CubedOS.Lib.Octet_Array_Count'Image(Space_Data'Last));
                  if Amount_Read = 0 then
                     CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                        CubedOS.Log_Server.API.Informational,
                                                        "Finished reading image, closing file...");
                     Message_Manager.Route_Message
                       (CubedOS.File_Server.API.Close_Request_Encode
                          (Name_Resolver.Controller, 0, Handle));
                     if Position > 0 then
                        Space_Packet := CubedOS.Lib.Space_Packets.From_Raw_Array(Space_Data(Space_Data'First .. Position + Space_Data'First));
                        -- TODO: send last space packet
                     end if;
                  elsif Position + Amount_Read > Space_Data'Last then
                     Space_Data(Position + Space_Data'First .. Space_Data'Last)
                       := Data(Data'First .. Space_Data'Last - Position + Data'First);
                     Space_Packet := CubedOS.Lib.Space_Packets.From_Raw_Array(Space_Data);
                     -- TODO: send space packet
                     Space_Data(Space_Data'First ..  Data'Last - (Space_Data'Last - Position + Data'First))
                       := Data(Space_Data'Last - Position + Data'First .. Data'Last);
                     Position := Data'Last - (Space_Data'Last - Position) + 1;
                     Message_Manager.Route_Message
                       (CubedOS.File_Server.API.Read_Request_Encode(Name_Resolver.Controller, 0, Handle, 256));
                  else
                     -- loop through and set data to space data.
                     Space_Data(Position .. Position + Amount_Read) := Data;
                     Position := Position + Amount_Read + 1;
                     CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                        CubedOS.Log_Server.API.Informational,
                                                        "Loading space packet");
                     Message_Manager.Route_Message
                       (CubedOS.File_Server.API.Read_Request_Encode(Name_Resolver.Controller, 0, Handle, 256));
                  end if;
               end if;
            else
               CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                                  CubedOS.Log_Server.API.Error,
                                                  "Recieved message that was not a read reply!");
            end if;
         end loop;
      end if;
   end Handle_Open_Reply;

   -----------------------------------
   -- Message Decoding and Dispatching
   -----------------------------------

   -- This procedure processes exactly one message at a time.
   procedure Process(Message : in Message_Record) is
   begin
      if CubedOS.Time_Server.API.Is_Tick_Reply(Message) then
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Tick reply has been received, handling it...");
         Handle_Tick_Reply(Message);
      elsif Camera.API.Is_Take_Image_Reply(Message) then
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Image reply has been received, handling it...");
         Handle_Image_Reply(Message);
      elsif CubedOS.File_Server.API.Is_Open_Reply(Message) then
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Informational,
                                            "Open reply has been received, handling it...");
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
      CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                         CubedOS.Log_Server.API.Informational,
                                         "Initialization is done. Ticks are starting...");
      loop
         Message_Manager.Fetch_Message(Name_Resolver.Controller.Module_ID, Incoming_Message);
         Process(Incoming_Message);
      end loop;
   exception
      when E : others =>
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Controller,
                                            CubedOS.Log_Server.API.Critical,
                                            Ada.Exceptions.Exception_Message(E));
   end Message_Loop;

end Controller.Messages;
