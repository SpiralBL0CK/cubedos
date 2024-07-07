--------------------------------------------------------------------------------
-- FILE   : pnumbers.ads
-- SUBJECT:
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------

package PNumbers is

   type Random_Range is range 1 .. 100;

   function Get_Random_Number return Positive;

end PNumbers;
