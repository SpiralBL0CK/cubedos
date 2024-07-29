 -------------------------------------------------------------------------------
-- FILE   : control-messages.adb
-- SUBJECT: Body of a package that implements the controller message loop.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Ada.Real_Time;

with CubedOS.Log_Server.API;
with CubedOS.Time_Server.API;
use  CubedOS;
with CubedOS.Publish_Subscribe_Server.API; use CubedOS.Publish_Subscribe_Server.API;

with LED_Driver.API;
with LED_Driver; --use LED_Driver;
with Name_Resolver;

package body Control.Messages is
   use Message_Manager;

   -------------------
   -- Message Handling
   -------------------

   -- Counter for the pattern index. Make it a modular type so it wraps around automatically.
   type Pattern_Index_Type is mod 4;
   Pattern : constant array(Pattern_Index_Type) of LED_Driver.LED_Type :=
     [LED_Driver.Green, LED_Driver.Orange, LED_Driver.Red, LED_Driver.Blue];
   Current_LED : Pattern_Index_Type := Pattern_Index_Type'First;

   -- Counter for the button presses. Make it a modular type so it wraps around automatically.
   type Button_Counter_Type is mod 3;
   Button_Counter : Button_Counter_Type := 1; -- The program initializes to 10.0 seconds.


   procedure Handle_Subscribe_Result(Message : in Message_Record)
     with Pre => Publish_Subscribe_Server.API.Is_Publish_Result(Message)
   is
      Outgoing_Message: Message_Record;
   begin
      -- Notice that we don't bother to even look at the message contents!

      -- TODO: Factor out the common code from the branches below.

      -- Cancel the tick request, set tick timer to 10.0 seconds
      if Button_Counter = 0 then
         Outgoing_Message := Time_Server.API.Cancel_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);

         Outgoing_Message := Time_Server.API.Relative_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Tick_Interval => Ada.Real_Time.To_Time_Span(10.0),
            Request_Type  => Time_Server.API.Periodic,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);
         Button_Counter := @ + 1;

      -- Cancel the tick request, set tick timer to 3.0 seconds
      elsif Button_Counter = 1 then
         Outgoing_Message := Time_Server.API.Cancel_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);

         Outgoing_Message := Time_Server.API.Relative_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Tick_Interval => Ada.Real_Time.To_Time_Span(3.0),
            Request_Type  => Time_Server.API.Periodic,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);
         Button_Counter := @ + 1;

      -- Cancel the tick request, set tick timer to 1.0 seconds
      elsif Button_Counter = 2 then
         Outgoing_Message := Time_Server.API.Cancel_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);

         Outgoing_Message := Time_Server.API.Relative_Request_Encode
           (Sender_Address => Name_Resolver.Control,
            Request_ID    => 0,
            Tick_Interval => Ada.Real_Time.To_Time_Span(1.0),
            Request_Type  => Time_Server.API.Periodic,
            Series_ID     => 1);
         Route_Message(Outgoing_Message);
         Button_Counter := @ + 1;
      end if;
   end Handle_Subscribe_Result;


   procedure Handle_Tick_Reply(Message : in Message_Record)
     with Pre => Time_Server.API.Is_Tick_Reply(Message)
   is
      Outgoing_Message : Message_Record;
   begin
      Outgoing_Message := LED_Driver.API.Off_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID    => 0,
         LED           => Pattern(Current_LED));
      Route_Message(Outgoing_Message);

      Current_LED := @ + 1;

      Outgoing_Message := LED_Driver.API.On_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID    => 0,
         LED           => Pattern(Current_LED));
      Route_Message(Outgoing_Message);
   end Handle_Tick_Reply;

   -----------------------------------
   -- Message Decoding and Dispatching
   -----------------------------------

   -- This procedure processes exactly one message.
   procedure Process(Message : in Message_Record) is
   begin
      if Time_Server.API.Is_Tick_Reply(Message) then
         Handle_Tick_Reply(Message);

      elsif Publish_Subscribe_Server.API.Is_Publish_Result(Message) then
         Handle_Subscribe_Result(Message);

      elsif Publish_Subscribe_Server.API.Is_Subscribe_Reply(Message) then
         Log_Server.API.Log_Message
           (Name_Resolver.Control, Log_Server.API.Informational, "Received Subscription_Reply message");
      else
         Log_Server.API.Log_Message
           (Name_Resolver.Control, Log_Server.API.Warning, "Received unexpected message");
          null;
      end if;
   end Process;

   ---------------
   -- Message Loop
   ---------------

   task body Message_Loop is
      Incoming_Message : Message_Record;
      Outgoing_Message : Message_Record;
   begin
      -- Initialization...

      -- Make sure all the LEDs are off.
      Outgoing_Message := LED_Driver.API.All_Off_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID     => 0);
      Route_Message(Outgoing_Message);

      -- Turn first LED on for the initial state.
      Outgoing_Message := LED_Driver.API.On_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID    => 0,
         LED           => Pattern(Current_LED));
      Route_Message(Outgoing_Message);

      -- Request a periodic tick every 10.0 seconds.
      Outgoing_Message := Time_Server.API.Relative_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID    => 0,
         Tick_Interval => Ada.Real_Time.To_Time_Span(10.0),
         Request_Type  => Time_Server.API.Periodic,
         Series_ID     => 1);
         Route_Message(Outgoing_Message);

         -- Subscribe to channel 1.
      Outgoing_Message := Subscribe_Request_Encode
        (Sender_Address => Name_Resolver.Control,
         Request_ID    => 0,
         Channel       => 1);
      Route_Message(Outgoing_Message);

      loop
         Message_Manager.Fetch_Message(Name_Resolver.Control.Module_ID, Incoming_Message);
         Process(Incoming_Message);
      end loop;
   end Message_Loop;

end Control.Messages;
