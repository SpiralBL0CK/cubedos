--------------------------------------------------------------------------------
-- FILE   : fibonacci.adb
-- SUBJECT:
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------

package body Fibonacci is

   function Gen_Recursive(N : in Fib_Seed) return Natural is
      Return_Value : Natural;
   begin
      if N = 0 or N = 1 then
         Return_Value := Natural(N);
      else
         Return_Value := Gen_Recursive(N - 1) + Gen_Recursive(N - 2);
      end if;
      return Return_Value;
   end Gen_Recursive;


   function Gen_Dynamic(N : in Fib_Seed) return Natural is
      Fib : array (0 .. N + 1) of Natural;
   begin
      Fib(0) := 0;
      Fib(1) := 1;

      for I in 2 .. N loop
         Fib(I) := Fib(I - 1) + Fib(I - 2);
      end loop;

      return Fib(N);
   end Gen_Dynamic;


   function Gen_Slowest(N : in Fib_Seed) return Natural is
      Fib_Num      : Natural;
      Current_Seed : Fib_Seed;
   begin
      for I in 0 .. Natural(N) loop
         Current_Seed := Fib_Seed(I);
         Fib_Num := Gen_Recursive(Current_Seed);
      end loop;

      return Fib_Num;
   end Gen_Slowest;

end Fibonacci;
