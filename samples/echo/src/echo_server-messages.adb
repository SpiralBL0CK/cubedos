--------------------------------------------------------------------------------
-- FILE   : echo_server-messages.adb
-- SUBJECT: Body of a package that implements the main part of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--------------------------------------------------------------------------------
with Echo_Server.API;
with Name_Resolver;
with CubedOS.Log_Server.API;

package body Echo_Server.Messages is
   use Message_Manager;

   -------------------
   -- Message Handling
   -------------------

   procedure Handle_Ping_Request(Message : in Message_Record)
     with
       Pre => Echo_Server.API.Is_Ping_Request(Message)
   is
      Outgoing_Message : Message_Record;
   begin
      Outgoing_Message :=
        Echo_Server.API.Ping_Reply_Encode
          (Receiver_Address => Message.Sender_Address,
           Request_ID      => Message.Request_ID,
           Status          => Echo_Server.API.Success);  -- Ping is always successful.
      Message_Manager.Route_Message(Outgoing_Message);
   end Handle_Ping_Request;

   -----------------------------------
   -- Message Decoding and Dispatching
   -----------------------------------

   -- This procedure processes exactly one message.
   procedure Process(Message : in Message_Record) is
   begin
      if Echo_Server.API.Is_Ping_Request(Message) then
         Handle_Ping_Request(Message);
      else
         CubedOS.Log_Server.API.Log_Message(Name_Resolver.Echo_Client,
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
         Message_Manager.Fetch_Message(Name_Resolver.Echo_Server.Module_ID, Incoming_Message);
         Process(Incoming_Message);
      end loop;
   end Message_Loop;

end Echo_Server.Messages;
