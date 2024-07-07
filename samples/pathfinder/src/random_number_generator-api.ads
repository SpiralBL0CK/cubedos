------------------------------------------------------------------------------
--  FILE   : random_number_generator-api.ads
--  SUBJECT: Specification of a package that simplifies use of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager; use Message_Manager;
with Name_Resolver;
with System;

package Random_Number_Generator.API is

   type Status_Type is (Success, Failure);
   type Message_Type is (Generate_Number_Request, Generate_Number_Reply);

   ----------
   -- Request
   ----------
   function Generate_Number_Request_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
     with Global => null;

   function Is_Generate_Number_Request(Message : in Message_Record) return Boolean is
     (Message.Receiver_Address = Name_Resolver.Random_Number_Generator and
      Message.Message_ID = Message_Type'Pos(Generate_Number_Request));

   --------
   -- Reply
   --------
   function Generate_Number_Reply_Encode
     (Receiver_Address : in Message_Address;
      Request_ID       : in Request_ID_Type;
      Priority         : in System.Priority := Pri) return Message_Record with
     Global => null;

   function Is_Generate_Number_Reply(Message : in Message_Record) return Boolean is
     (Message.Sender_Address = Name_Resolver.Random_Number_Generator and
      Message.Message_ID = Message_Type'Pos(Generate_Number_Reply));

   procedure Generate_Number_Reply_Decode
     (Message       : in     Message_Record;
      Decode_Status :    out Message_Status_Type;
      Value         :    out Positive)
     with Global  => null,
      -- Pre     => Is_Generate_Number_Reply(Message),
      Depends => (Decode_Status => Message, Value => Message);

end Random_Number_Generator.API;
