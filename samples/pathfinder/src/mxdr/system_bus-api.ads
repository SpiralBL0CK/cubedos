--------------------------------------------------------------------------------
-- FILE   : system_bus-api.ads
-- SUBJECT: Specification of a package that simplifies use of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Name_Resolver;
with Message_Manager; use Message_Manager;
with System;

package System_Bus.API is

   type Status_Type  is (Success, Failure);
   type Message_Type is (Random_Number_Request, Random_Number_Reply, Telemetry);

   -----------------
   -- Random Number
   -----------------
   function Random_Number_Request_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
     with
      Global => null;

   function Random_Number_Reply_Encode
     (Receiver_Address : in Message_Address;
      Request_ID       : in Request_ID_Type;
      Status           : in Status_Type := Success;
      Priority         : in System.Priority := Pri) return Message_Record
     with
      Global => null;

   function Is_Random_Number_Request(Message : in Message_Record) return Boolean is
     (Message.Receiver_Address = Name_Resolver.System_Bus and
        Message.Message_ID = Message_Type'Pos(Random_Number_Request));

   function Is_Random_Number_Reply(Message : in Message_Record) return Boolean is
     (Message.Sender_Address = Name_Resolver.System_Bus and
        Message.Message_ID = Message_Type'Pos(Random_Number_Reply));

   procedure Random_Number_Reply_Decode
     (Message       : in  Message_Record;
      Decode_Status : out Message_Status_Type;
      Value         : out Positive)
     with
      Global  => null,
      Pre     => Is_Random_Number_Reply (Message),
      Depends => (Decode_Status => Message, Value => Message);

   -------------
   -- Telemetry
   -------------
   -- Why are these here and not in the Telemetry module's API?

   function Telemetry_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
     with
      Global => null;

   function Is_Telemetry(Message : in Message_Record) return Boolean is
     (Message.Receiver_Address = Name_Resolver.System_Bus and
        Message.Message_ID = Message_Type'Pos (Telemetry));

end System_Bus.API;
