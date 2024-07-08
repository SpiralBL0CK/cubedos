--------------------------------------------------------------------------------
--  FILE   : Read_Number-messages.ads
--  SUBJECT: Specification of a package that implements the main part of the module.
--  AUTHOR : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

package Read_Number.Messages is

   task Message_Loop with
      Priority => Pri,
      CPU      => CPU_Number
   is
   --pragma Storage_Size (4 * 1_024);
   end Message_Loop;

end Read_Number.Messages;
