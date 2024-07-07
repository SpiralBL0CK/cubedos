--------------------------------------------------------------------------------
-- FILE   : Read_Number.ads
-- SUBJECT: Top level package of a CubedOS Random Number Generator.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager;
with System;
with System.Multiprocessors;
with Fibonacci;
with System_Bus;

package Read_Number is
   use type Fibonacci.Fib_Seed;

   R_ID           : constant Message_Manager.Request_ID_Type  := 103;
   Fibonacci_Seed : constant Fibonacci.Fib_Seed               := System_Bus.Fibonacci_Seed + 1;
   Pri            : constant System.Priority                  := 30;
   CPU_Number     : constant System.Multiprocessors.CPU_Range := System.Multiprocessors.CPU'First;

end Read_Number;
