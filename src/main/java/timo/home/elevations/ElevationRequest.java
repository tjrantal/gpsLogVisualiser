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
	private static String apiKey;
	
	public ElevationRequest(String apiKey){
		this.apiKey = apiKey;
	}
	
	public double[] getElevations(){
		if (elevations !=null){
			return elevations[0];
		}else{
			return null;
		}
	}
	
	public double[] getLatitudes(){
		if (elevations !=null){
			return elevations[1];
		}else{
			return null;
		}
	}
	
	public double[] getLongitudes(){
		if (elevations !=null){
			return elevations[2];
		}else{
			return null;
		}
	}
	
	public double[] getResolution(){
		if (elevations !=null){
			return elevations[3];
		}else{
			return null;
		}
	}
	
	/**Encode and request elevations for lat, and lon from google elevations api*/
	public void encode(double[] lat, double[] lon){
		elevations = null;
		try{
			Coordinates a = new Coordinates(lat,lon);
			ArrayList<Elevation>	b = getJSON(a, apiKey);
			elevations = new double[4][b.size()];
			for (int i = 0; i<b.size(); ++i){
				elevations[0][i]=b.get(i).elevation;
				elevations[1][i]=b.get(i).lat;
				elevations[2][i]=b.get(i).lon;
				elevations[3][i]=b.get(i).resolution;
			}
		} catch (Exception e){
			System.out.println("Fetching elevations failed");
		}
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
