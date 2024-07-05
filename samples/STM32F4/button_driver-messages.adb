--------------------------------------------------------------------------------
-- FILE   : SAMPLE_MODULE-messages.adb
-- SUBJECT: Body of a package that implements the main part of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Button; use Button;
with Name_Resolver;

with CubedOS.Lib; use CubedOS.Lib;
with CubedOS.Publish_Subscribe_Server.API; use CubedOS.Publish_Subscribe_Server.API;

package body Button_Driver.Messages is
   use Message_Manager;

   procedure Button_Pressed_Message is
      Outgoing_Message : Message_Record;
      Message_Data : CubedOS.Lib.Octet_Array(1 .. 2);
   begin
       -- Create the message data. This data is ignored by the receiver.
       Message_Data := [0, 0];

       -- Craft a publish request message
       Outgoing_Message := Publish_Request_Encode
        (Sender_Address => Name_Resolver.Button_Driver,
         Request_ID    => 0,
         Channel       => 1,
         Message_Data  => Message_Data);
       Route_Message(Outgoing_Message);

   end Button_Pressed_Message;


   procedure Process_Press(State_Test : in Button_State_Type)
     with
       Global => null,
       Pre => State_Test = Pressed
   is
   begin
      if State_Test = Pressed then
         Button_Pressed_Message;
     end if;
   end Process_Press;


   task body Message_Loop is
      State_Test : Button_State_Type;
   begin
      loop
         -- The only "message" that arrives is if the button has been pressed. This module never tries to
         -- fetch messages from its mailbox. Note that Button.Button_Pressed will block until the User button
         -- is pressed.
         State_Test := Button.Button_Pressed;
         Process_Press(State_Test);
     end loop;
   end Message_Loop;

end Button_Driver.Messages;
