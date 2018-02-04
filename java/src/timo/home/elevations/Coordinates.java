package timo.home.elevations;

/**Helper class to contain coordinates*/
public class Coordinates{
	public double[] latitude;
	public double[] longitude;
	public Coordinates(double[] lat, double[] lon){
		latitude = new double[lat.length];
		longitude = new double[lon.length];
		for (int i = 0; i<lat.length; ++i){
			latitude[i] = lat[i];
			longitude[i] = lon[i];
		}
	}
}
