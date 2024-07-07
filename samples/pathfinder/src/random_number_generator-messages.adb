--------------------------------------------------------------------------------
--  FILE   : random_number_generator-messages.adb
--  SUBJECT: Body of a package that implements the main part of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Ada.Text_IO; use Ada.Text_IO;

with Name_Resolver;
with Message_Manager;
with Fibonacci;
with Random_Number_Generator.API;

use Message_Manager;

package body Random_Number_Generator.Messages is

   procedure Handle_Generate_Number_Request(Message : in Message_Record)
     with Pre => Random_Number_Generator.API.Is_Generate_Number_Request(Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
      Call_Sign        : constant String :=
        "Low[" & Pri'Image & " ] -- Handle Request: ";
   begin
      Outgoing_Message :=
        Random_Number_Generator.API.Generate_Number_Reply_Encode
          (Receiver_Address => Message.Sender_Address,
           Request_ID       => Message.Request_ID,
           Priority         => Pri);

      Ada.Text_IO.Put_Line(Call_Sign & "Sending Reply...");
      Ada.Text_IO.New_Line;

      Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

      while Outgoing_Status /= Accepted loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;

   end Handle_Generate_Number_Request;


   procedure Process(Message : in Message_Record) is
   begin
      if Random_Number_Generator.API.Is_Generate_Number_Request(Message) then
         Handle_Generate_Number_Request(Message);
      end if;
      -- TODO: Log unexpected messages.
   end Process;


   task body Message_Loop is
      Incoming_Message : Message_Manager.Message_Record;
      Fib_Number       : Natural;
      Call_Sign        : constant String := "Low[" & Pri'Image & " ]: ";
   begin
      loop
         Ada.Text_IO.Put_Line(Call_Sign & "Wasting time generating a Fibonacci number...");
         Fib_Number := Fibonacci.Gen_Slowest(Fibonacci_Seed);
         Ada.Text_IO.Put(Call_Sign & "Fibonacci(" & Fibonacci_Seed'Image & " ) is");
         Ada.Text_IO.Put_Line(Fib_Number'Image);
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put_Line(Call_Sign & "Getting next message to process...");

         Message_Manager.Fetch_Message(Name_Resolver.Random_Number_Generator.Module_ID, Incoming_Message);
         Process(Incoming_Message);

         Ada.Text_IO.Put_Line(Call_Sign & "Processed message.");
         Ada.Text_IO.New_Line;
      end loop;
   end Message_Loop;

end Random_Number_Generator.Messages;
