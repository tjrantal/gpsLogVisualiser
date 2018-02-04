/*Class to hold elevations coming in from google elevations JSON*/
package timo.home.elevations;

public class Elevation{
	public double elevation;
	public double lat;
	public double lon;
	public double resolution;
	public Elevation(){}
	public Elevation(double a, double b, double c, double d){
		this.elevation = a;
		this.lat = b;
		this.lon = c;
		this.resolution = d;
	}
	 
}

