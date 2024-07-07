--------------------------------------------------------------------------------
-- FILE    : SAMPLE_MODULE-api.adb
-- SUBJECT : Body of a package that simplifies use of the module.
-- AUTHOR  : (C) Copyright 2024 by State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Random_Number_Generator.API;

package body System_Bus.API is

   -----------------
   -- Random Number
   -----------------
   function Random_Number_Request_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
   is
      Message : constant Message_Record :=
        Make_Empty_Message
          (Sender_Address   => Sender_Address,
           Receiver_Address => Name_Resolver.System_Bus,
           Request_ID => Request_ID,
           Message_ID => Message_Type'Pos(Random_Number_Request),
           Priority   => Priority);
   begin
      return Message;
   end Random_Number_Request_Encode;


   function Random_Number_Reply_Encode
     (Receiver_Address : in Message_Address;
      Request_ID       : in Request_ID_Type;
      Status           : in Status_Type := Success;
      Priority         : in System.Priority := Pri) return Message_Record
   is
      pragma Unreferenced (Status);

      Message : constant Message_Record :=
        Make_Empty_Message
          (Sender_Address   => Name_Resolver.System_Bus,
           Receiver_Address => Receiver_Address,
           Request_ID => Request_ID,
           Message_ID => Message_Type'Pos(Random_Number_Reply),
           Priority   => Priority);
   begin
      return Message;
   end Random_Number_Reply_Encode;


   procedure Random_Number_Reply_Decode
     (Message       : in  Message_Record;
      Decode_Status : out Message_Status_Type;
      Value         : out Positive)
   is
   begin
      Random_Number_Generator.API.Generate_Number_Reply_Decode(Message, Decode_Status, Value);
   end Random_Number_Reply_Decode;

   -------------
   -- Telemetry
   -------------
   function Telemetry_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
   is
      Message : constant Message_Record :=
        Make_Empty_Message
          (Sender_Address => Sender_Address,
           Receiver_Address => Name_Resolver.System_Bus,
           Request_ID => Request_ID,
           Message_ID => Message_Type'Pos(Telemetry),
           Priority   => Priority);
   begin
      return Message;
   end Telemetry_Encode;

end System_Bus.API;
