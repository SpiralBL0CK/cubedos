#!/bin/bash

# This script is necessary because gnatcheck will return a failure status code if even one
# rule is violated (apparently), and there doesn't seem to be a way to change that behavior.
# This causes Jenkins to fail the build unless the style is *perfect*, which is unreasonable.
# This script runs gnatcheck but always returns a success status code.

echo -e "\nCubedOS Core"
echo      "------------"
codepeer-gnatcheck -P src/cubedos.gpr src/library/*.ads src/library/*.adb
codepeer-gnatcheck -P src/cubedos.gpr src/modules/*.ads src/modules/*.adb
codepeer-gnatcheck -P src/cubedos.gpr src/check/*.ads src/check/*.adb

# Now the samples...

echo -e "\nEcho"
echo      "----"
codepeer-gnatcheck -P samples/echo/echo.gpr samples/echo/*.ads samples/echo/*.adb

echo -e "\nMulti-Domain"
echo      "------------"
codepeer-gnatcheck -P samples/networking/networking.gpr -XBUILD=DomainA samples/networking/DomainA/*.ads samples/networking/DomainA/*.adb
codepeer-gnatcheck -P samples/networking/networking.gpr -XBUILD=DomainB samples/networking/DomainB/*.ads samples/networking/DomainB/*.adb

echo -e "\nPub/Sub Server"
echo      "--------------"
codepeer-gnatcheck -P samples/pubsub/pubsub.gpr samples/pubsub/*.ads samples/pubsub/*.adb

# The AdaCore-provided packages make heavy use of names with non-standardard casing. As a
# result, analyzing the style of this sample produces a lot of warnings in packages we did not
# write. I'm not sure how to best handle this. For now, let's skip the style analysis of this
# sample. (pchapin)
#
# NOTE: Perhaps there is a command line option to disable an individual rule that will override
# the enabling of that rule in the global rules file.
#
#echo -e "\nSTM32F4"
#echo      "-------"
#codepeer-gnatcheck -P samples/STM32F4/stmdemo.gpr samples/STM32F4/*.ads samples/pubsub/*.adb


exit 0  # Success!
