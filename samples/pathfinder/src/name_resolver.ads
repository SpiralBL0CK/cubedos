--------------------------------------------------------------------------------
-- FILE    : name_resolver.ads
-- SUBJECT : Specification of a package holding Domain IDs and Module IDs
-- AUTHOR  : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with Message_Manager; use Message_Manager;

package Name_Resolver is

   -- Core Modules.
   -- Declarations that are commented out are for currently unimplemented core modules.

   -- Note that the "Name_Resolver" module is reserved for a dynamic name resolver,
   -- which may never get implemented depending on how well this static system works!
   -- Network_Server is also has a reserved module ID (for now).

   Name_Resolver  : constant Module_ID_Type := 1;
   Network_Server : constant Module_ID_Type := 2;
   Log_Server     : constant Message_Address := (0, 3);

   -- Application-Specific Modules.
   -- Make up names as you see fit (typically the same as your module's top level package).
   -- Be sure there are no duplicate (Domain_ID, Module_ID) pairs.

   Random_Number_Generator : constant Message_Address := (0, 4);
   Read_Number             : constant Message_Address := (0, 5);
   System_Bus              : constant Message_Address := (0, 6);
   Telemetry               : constant Message_Address := (0, 7);

end Name_Resolver;
