--------------------------------------------------------------------------------
-- FILE   : pnumbers.adb
-- SUBJECT:
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with Ada.Numerics.Discrete_Random;

package body PNumbers is

   package Random_Integer is new Ada.Numerics.Discrete_Random(Random_Range);

   Number_Generator : Random_Integer.Generator;

   function Get_Random_Number return Positive is
      Value : Random_Range;
   begin
      Value := Random_Integer.Random(Number_Generator);
      return Positive(Value);
   end Get_Random_Number;

begin  -- PNumbers
   Random_Integer.Reset(Number_Generator);
end PNumbers;
