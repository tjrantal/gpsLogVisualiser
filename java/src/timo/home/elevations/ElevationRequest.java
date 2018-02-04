/**Class to request elevations from google elevations API*/
package timo.home.elevations;

import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.util.ArrayList;

import java.net.URL;
import java.net.HttpURLConnection;

//Internationalisation
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

public class ElevationRequest{
	private static final String ELEVATION_API_URL =  "https://maps.googleapis.com/maps/api/elevation/json";
	private static final int batchSize = 250;
	private double[][] elevations;
	
	public ElevationRequest(double[] lat, double[] lon, String apiKey){
		elevations = encode(lat,lon,apiKey);
	}
	
	public double[] getElevations(){
		return elevations[0];
	}
	
	public double[] getLatitudes(){
		return elevations[1];
	}
	
	public double[] getLongitudes(){
		return elevations[2];
	}
	
	public double[] getResolution(){
		return elevations[3];
	}
	
	/**Encode and request elevations for lat, and lon from google elevations api*/
	public static double[][] encode(double[] lat, double[] lon, String apiKey){
		double[][] ret = null;
		try{
			Coordinates a = new Coordinates(lat,lon);
			ArrayList<Elevation>	b = getJSON(a, apiKey);
			ret = new double[4][b.size()];
			for (int i = 0; i<b.size(); ++i){
				ret[0][i]=b.get(i).elevation;
				ret[1][i]=b.get(i).lat;
				ret[2][i]=b.get(i).lon;
				ret[3][i]=b.get(i).resolution;
			}
		} catch (Exception e){
			System.out.println("Fetching elevations failes");
		}
		return ret;
	}

	/*Send data to elevations API in batches, and decode the return JSONs*/
	public static ArrayList<Elevation> getJSON(Coordinates coordinates, String apiKey) throws IOException{
		ArrayList<Elevation> elevations = new ArrayList<Elevation>();
    	DecimalFormat df = new DecimalFormat("#.##############");
	   DecimalFormatSymbols dfs = df.getDecimalFormatSymbols();
		dfs.setDecimalSeparator('.');
    	df.setDecimalFormatSymbols(dfs);
		//Do coordinates in batchSize coordinate batches
		for (int i =0;i<coordinates.latitude.length;i+=batchSize){
			String coordinateString = getString(coordinates,i,min(i+batchSize,coordinates.latitude.length),df);
			URL url = new URL(ELEVATION_API_URL+ "?locations=" + coordinateString +"&key="+apiKey);
			HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
			try {
			  urlConnection.setDoOutput(true);
			  urlConnection.setChunkedStreamingMode(0);

			  OutputStream out = new BufferedOutputStream(urlConnection.getOutputStream());
			  out.flush();	//Write the outputstream
			  ArrayList<Elevation> temp = JSONParser.parse(new BufferedInputStream(urlConnection.getInputStream()));
			  elevations.addAll(temp);
		  		
			} finally {
			  urlConnection.disconnect();
			}
			//Sleep 50 ms between loop rounds to not go over the api request rate
			try{Thread.sleep(50l);}catch(Exception e){}
		}
		return elevations;
	}
	
	/*Parse latitudes and longitudes into URL string to be sent to google elevations*/
	public static String getString(Coordinates coordinates,int first, int last, DecimalFormat df){
	
		String ret = df.format(coordinates.latitude[first])+","+df.format(coordinates.longitude[first]);
		for (int i = first+1;i<last;++i){
			ret+="|"+df.format(coordinates.latitude[i])+","+df.format(coordinates.longitude[i]);
		}
		return ret;
	}
	
	public static int min(int a, int b){return a<b? a:b;}

}
