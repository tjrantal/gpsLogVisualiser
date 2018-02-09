An Octave/Matlab + java script to visualise a GPS logged track on a Google map using the [Google Static Maps api](https://developers.google.com/maps/documentation/static-maps). I use it to visualise the logs I've recorded with my [Exercise Pacer](https://play.google.com/store/apps/details?id=timo.home.exercisepacer) and [GPS Logger](https://play.google.com/store/apps/details?id=timo.home.gpsLog) android apps.

To use 

Obtain a google static maps api key, and save it to a file named 'mapsKey.txt' in the root folder of the project (i.e. the folder with visualiseGPS.m). Just follow the procedure outlined on the google static maps webpage to obtain one.
Obtain a google elevations api key, and save it to a file named 'elevationsKey.txt' in the root folder of the project (i.e. the folder with visualiseGPS.m). Just follow the procedure outlined on the google elevations api webpage to obtain one.

Compile the java classes. Requires [java SDK](http://www.oracle.com/technetwork/java/javase/)
	1) Uses a gradle build -> install [gradle](https://gradle.org/)
	2) open command prompt cd into the folder with this README and type gradle jar on the command line  (+ hit enter)
		 should create build/libs/runAnalyserHelper-1.0.jar

Add some GPS log files into sampleData/gpsLog folder. I have included a sample file, which should show a route in the Melbourne Metropolitan area from Blackburn to Burwood. Will create a folder 'elevationFigs' and save corresponding Google Static Maps as .png files.

Uses [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0) code I downloaded from google Github (polyencode for encoding GPS coordinates into Google Maps-compatible format, and Json parsing) and Lukasz Wiktor's [series-reducer library](https://github.com/LukaszWiktor/series-reducer), which is licensed with Apache 2.0 license for Ramer–Douglas–Peucker series reduction of the GPS coordinates. Those licensing terms apply to this derivative work, and any code I have added is released to the public domain unless otherwise mandated by the other licensing.
