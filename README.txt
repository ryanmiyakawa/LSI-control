SUBJ : Met5Instruments.jar
AUTH : Carl Cork

REV DATE        DESCRIPTION
--- ----------  ------------------------------------------------------------
 00 2017-09-15  Initial

This folder contains the Met5Instruments 'mega-jar', it's input configuration
file, key interface source files, and the javadoc html documentation.

You should only need to include the Met5Instruments.jar in your classpath.
The Instruments.ini configuration file should either be placed in the
calling programs working directory, or else in a location that is passed
in the full constructor to cxro.met5.Instruments(String appDir).

The following command was used to generate javadocs for included source:

  javadoc -d javadoc -sourcepath src -subpackages cxro
