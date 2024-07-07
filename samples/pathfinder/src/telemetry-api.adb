--------------------------------------------------------------------------------
--  FILE   : telemetry-api.adb
--  SUBJECT: Body of a package that simplifies use of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

package body Telemetry.API is

   function Telemetry_Encode
     (Sender_Address : in Message_Address;
      Request_ID     : in Request_ID_Type;
      Priority       : in System.Priority := Pri) return Message_Record
   is
      Message : constant Message_Record :=
        Make_Empty_Message
          (Sender_Address,
           Name_Resolver.Telemetry,
           Request_ID,
           Message_Type'Pos(Telemetry_Request),
           Priority);
   begin
      return Message;
   end Telemetry_Encode;

end Telemetry.API;
