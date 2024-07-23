--------------------------------------------------------------------------------
-- FILE   : Camera.ads
-- SUBJECT: Top level package of a CubedOS Camera Module.
-- AUTHOR : (C) Copyright 2024 by Vermont State University
--
-- This module is a skeleton, with comments, showing how to set up a standard CubedOS module.
-- CubedOS modules do not need to follow this structure exactly, but it is recommended to at
-- least start here. Note that many of the comments should be edited/erased in a real
-- application.
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

package Camera is
   pragma Pure;

   -- Every module has a domain ID number and a module ID number. However, those numbers are
   -- assigned by the application programming in a package Name_Resolver. Modules are not
   -- directly aware of their own ID numbers but instead look them up from the Name_Resolver
   -- just as clients must.
end Camera;
