------------------------------------------------------------------------------
--  FILE   : telemetry-api.ads
--  SUBJECT: Specification of a package that simplifies use of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager; use Message_Manager;
with Name_Resolver;
with System;

package Telemetry.API is

   type Status_Type  is (Success, Failure);
   type Message_Type is (Telemetry_Request);

   function Telemetry_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
     with
      Global => null;

   function Is_Telemetry_Request(Message : in Message_Record) return Boolean is
     (Message.Receiver_Address = Name_Resolver.Telemetry and
        Message.Message_ID = Message_Type'Pos(Telemetry_Request));

   -- No decoder is necessary for Telemetry_Request. The existence of the message itself is all that is needed.

end Telemetry.API;
