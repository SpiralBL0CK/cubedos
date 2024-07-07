--------------------------------------------------------------------------------
--  FILE   : Read_Number-messages.adb
--  SUBJECT: Body of a package that implements the main part of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Ada.Text_IO;

with Name_Resolver;
with Message_Manager;
with System_Bus.API;

use Message_Manager;

package body Read_Number.Messages is

   procedure Initialize is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
   begin
      Outgoing_Message :=
        System_Bus.API.Random_Number_Request_Encode
          (Sender_Address => Name_Resolver.Read_Number,
           Request_ID     => R_ID,
           Priority       => Pri);
      Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

      while Outgoing_Status /= Accepted loop
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);
      end loop;
   end Initialize;


   procedure Handle_Read_Number_Reply(Message : in Message_Record)
     with Pre => System_Bus.API.Is_Random_Number_Reply(Message)
   is
      Outgoing_Message : Message_Record;
      Outgoing_Status  : Status_Type;
      Status           : Message_Status_Type;
      Value            : Positive;
      Call_Sign        : constant String := "High[" & Pri'Image & " ] -- Handle Reply: ";
   begin
      System_Bus.API.Random_Number_Reply_Decode(Message, Status, Value);

      if Status = Malformed then
         Ada.Text_IO.Put_Line(Call_Sign & "Error: Message status is Malformed!");
         Ada.Text_IO.New_Line;
      else

         Ada.Text_IO.Put(Call_Sign & "The random number recieved is");
         Ada.Text_IO.Put_Line(Value'Image);
         Ada.Text_IO.Put_Line(Call_Sign & "Thank you! I would like another...");
         Ada.Text_IO.New_Line;

         Outgoing_Message :=
           System_Bus.API.Random_Number_Request_Encode
             (Sender_Address => Name_Resolver.Read_Number,
              Request_ID     => R_ID,
              Priority       => Pri);
         Message_Manager.Route_Message(Outgoing_Message, Outgoing_Status);

         while Outgoing_Status /= Accepted loop
            Message_Manager.Route_Message (Outgoing_Message, Outgoing_Status);
         end loop;
      end if;
   end Handle_Read_Number_Reply;


   procedure Process(Message : in Message_Record) is
   begin
      if System_Bus.API.Is_Random_Number_Reply(Message) then
         Handle_Read_Number_Reply(Message);
      end if;
      -- TODO: Log unexpected messages.
   end Process;


   task body Message_Loop is
      Incoming_Message : Message_Manager.Message_Record;
      Fib_Number       : Natural;
      Call_Sign        : constant String := "High[" & Pri'Image & " ]: ";
   begin
      Initialize;
      loop
         Ada.Text_IO.Put_Line(Call_Sign & "Wasting time generating a Fibonacci number...");
         Fib_Number := Fibonacci.Gen_Slowest(Fibonacci_Seed);

         Ada.Text_IO.Put(Call_Sign & "Fibonacci(" & Fibonacci_Seed'Image & " ) is");
         Ada.Text_IO.Put_Line(Fib_Number'Image);
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put_Line(Call_Sign & "Getting next message to process...");
         Message_Manager.Fetch_Message(Name_Resolver.Read_Number.Module_ID, Incoming_Message);
         Process(Incoming_Message);

         Ada.Text_IO.Put_Line(Call_Sign & "Processed message.");
         Ada.Text_IO.New_Line;
      end loop;
   end Message_Loop;

end Read_Number.Messages;
