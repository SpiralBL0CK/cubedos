--------------------------------------------------------------------------------
-- FILE   : system_bus-messages.adb
-- SUBJECT: Body of a package that implements the main part of the module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Ada.Text_IO;

with Name_Resolver;
with Message_Manager;
with Random_Number_Generator.API;
with Read_Number;
with System_Bus.API;
with Telemetry.API;

use Message_Manager;

package body System_Bus.Messages is

   Count : Positive := 1;

   procedure Initialize is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
   begin
      Outgoing_Message :=
        System_Bus.API.Telemetry_Encode
          (Sender_Address => Name_Resolver.System_Bus,
           Request_ID     => R_ID,
           Priority       => Telemetry.Pri);

      for I in 1 .. 4 loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;
   end Initialize;


   -----------------
   -- Random Number
   -----------------
   procedure Handle_Random_Number_Request(Message : in Message_Record)
     with Pre => System_Bus.API.Is_Random_Number_Request(Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
   begin
      Outgoing_Message :=
        Random_Number_Generator.API.Generate_Number_Request_Encode
          (Sender_Address => Name_Resolver.System_Bus,
           Request_ID     => R_ID,
           Priority       => Message.Priority);

      Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

      while Outgoing_Status /= Accepted loop
         Message_Manager.Route_Message (Outgoing_Message, Outgoing_Status);
      end loop;
   end Handle_Random_Number_Request;


   procedure Handle_Random_Number_Reply(Message : in Message_Record)
     with Pre => Random_Number_Generator.API.Is_Generate_Number_Reply(Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
   begin
      -- Reply to read
      Outgoing_Message :=
        System_Bus.API.Random_Number_Reply_Encode
          (Receiver_Address => Name_Resolver.Read_Number,
           Request_ID       => Read_Number.R_ID,
           Priority         => Message.Priority);
      Outgoing_Message.Payload := Message.Payload;

      Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

      while Outgoing_Status /= Accepted loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;
   end Handle_Random_Number_Reply;

   -------------
   -- Telemetry
   -------------
   procedure Handle_Telemetry(Message : in Message_Record)
     with Pre => System_Bus.API.Is_Telemetry(Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
      Call_Sign        : constant String := "SysBus[" & Pri'Image & " ]: ";
   begin

      Ada.Text_IO.Put_Line(Call_Sign & "Received Telemetry, Priority:" & Message.Priority'Image);
      Ada.Text_IO.New_Line;

      Outgoing_Message :=
        Telemetry.API.Telemetry_Encode
          (Sender_Address => Name_Resolver.System_Bus,
           Request_ID     => R_ID,
           Priority       => Message.Priority);

      Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

      while Outgoing_Status /= Accepted loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;
   end Handle_Telemetry;


   procedure Process(Message : in Message_Record) is
   begin
      if System_Bus.API.Is_Random_Number_Request(Message) then
         Handle_Random_Number_Request(Message);
      elsif System_Bus.API.Is_Telemetry(Message) then
         Handle_Telemetry(Message);
      elsif Random_Number_Generator.API.Is_Generate_Number_Reply(Message) then
         Handle_Random_Number_Reply(Message);
      end if;
      -- TODO: Log unexpected messages.
   end Process;


   task body Message_Loop is
      Incoming_Message : Message_Manager.Message_Record;
      Fib_Number       : Natural;
      Call_Sign        : constant String := "SysBus[" & Pri'Image & " ]: ";
   begin
      Initialize;
      loop
         Ada.Text_IO.Put_Line(Call_Sign & "Wasting time generating a Fibonacci number...");
         Fib_Number := Fibonacci.Gen_Slowest(Fibonacci_Seed);

         Ada.Text_IO.Put(Call_Sign & "Fibonacci(" & Fibonacci_Seed'Image & " ) is");
         Ada.Text_IO.Put_Line(Fib_Number'Image);
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put_Line(Call_Sign & "Getting next message to process...");
         Message_Manager.Fetch_Message(Name_Resolver.System_Bus.Module_ID, Incoming_Message);
         Process(Incoming_Message);

         Ada.Text_IO.Put_Line(Call_Sign & "Processed message.");
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put_Line(Call_Sign & "Loop #" & Count'Image);
         Count := Count + 1;
      end loop;
   end Message_Loop;

end System_Bus.Messages;
