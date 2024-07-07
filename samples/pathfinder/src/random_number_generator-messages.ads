--------------------------------------------------------------------------------
--  FILE   : random_number_generator-messages.ads
--  SUBJECT: Specification of a package that implements the main part of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

package Random_Number_Generator.Messages is

   task Message_Loop with
      Priority => Pri,
      CPU      => CPU_Number
   is
      -- pragma Storage_Size (4 * 1_024);
   end Message_Loop;

end Random_Number_Generator.Messages;
