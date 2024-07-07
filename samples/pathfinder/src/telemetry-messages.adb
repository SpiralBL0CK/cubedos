--------------------------------------------------------------------------------
--  FILE   : telemetry-messages.adb
--  SUBJECT: Body of a package that implements the main part of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Ada.Text_IO;

with Name_Resolver;
with Message_Manager;
with CubedOS.Log_Server.API;
with Fibonacci;
with System_Bus.API;
with Telemetry.API;

use CubedOS;
use Message_Manager;

package body Telemetry.Messages is

   procedure Handle_Telemetry (Message : in Message_Record)
     with Pre => Telemetry.API.Is_Telemetry_Request (Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
      Call_Sign : constant String := "Med[" & Pri'Image & " ] -- Telemetry: ";
   begin
      Ada.Text_IO.Put_Line(Call_Sign & "Processed message, sending reply to SysBus");
      Ada.Text_IO.New_Line;

      -- Creating request to cause loop.
      Outgoing_Message :=
        System_Bus.API.Telemetry_Encode
          (Sender_Address => Name_Resolver.Telemetry,
           Request_ID     => R_ID,
           Priority       => Pri);

      for I in 1 .. 4 loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;
   end Handle_Telemetry;


   procedure Process(Message : in Message_Record) is
   begin
      if Telemetry.API.Is_Telemetry_Request(Message) then
         Handle_Telemetry(Message);
      else
         Log_Server.API.Log_Message
           (Name_Resolver.Telemetry, Log_Server.API.Warning, "Unexpected message received");
      end if;
   end Process;


   task body Message_Loop is
      Incoming_Message : Message_Manager.Message_Record;
      Fib_Number       : Natural;
      Call_Sign        : constant String := "Med[" & Pri'Image & " ]: ";
   begin
      loop
         Ada.Text_IO.Put_Line(Call_Sign & "Wasting time generating a Fibonacci number...");
         Fib_Number := Fibonacci.Gen_Slowest(Fibonacci_Seed);

         Ada.Text_IO.Put(Call_Sign & "Fibonacci(" & Fibonacci_Seed'Image & " ) is");
         Ada.Text_IO.Put_Line(Fib_Number'Image);
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put_Line(Call_Sign & "Getting next message to process...");
         Message_Manager.Fetch_Message(Name_Resolver.Telemetry.Module_ID, Incoming_Message);
         Process(Incoming_Message);

         Ada.Text_IO.Put_Line(Call_Sign & "Processed message.");
         Ada.Text_IO.New_Line;
      end loop;
   end Message_Loop;

end Telemetry.Messages;
