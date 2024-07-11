--------------------------------------------------------------------------------
-- FILE    : name_resolver.ads
-- SUBJECT : Specification holding Domain IDs and Module IDs
-- AUTHOR  : (C) Copyright 2024 by Vermont State University
--
--------------------------------------------------------------------------------
with Message_Manager; use Message_Manager;

package Name_Resolver is

   -- Core Modules
   Log_Server            : constant Message_Address := (0,5);
   Time_Server           : constant Message_Address := (0,6);
   File_Server           : constant Message_Address := (0,7);
   Pub_Sub_Server        : constant Message_Manager := (0,8);

   -- Application-Specific Modules
   Camera            : constant Message_Address := (0,1);
   Radio             : constant Message_Address := (0,2);
   Thruster          : constant Message_Address := (0,3);
   Controller        : constant Message_Manager := (0,4);

end Name_Resolver;
