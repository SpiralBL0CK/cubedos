--------------------------------------------------------------------------------
-- FILE   : fibonacci.ads
-- SUBJECT:
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------

package Fibonacci is

   type Fib_Seed is range 0 .. 46;

   function Gen_Recursive(N : in Fib_Seed) return Natural;
   function Gen_Dynamic  (N : in Fib_Seed) return Natural;
   function Gen_Slowest  (N : in Fib_Seed) return Natural;

end Fibonacci;
