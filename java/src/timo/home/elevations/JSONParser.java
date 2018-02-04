/**Class to parse JSON returned from google elevations api*/
package timo.home.elevations;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import android.util.JsonReader;
import android.util.JsonToken;
import java.util.ArrayList;

public final class JSONParser{
	public static ArrayList<Elevation>  parse(String toParse) throws IOException {
		return parse(new ByteArrayInputStream(toParse.getBytes("UTF_8")));
	}
	
	public static ArrayList<Elevation> parse(InputStream toParse) throws IOException {
		JsonReader reader = null;
		ArrayList<Elevation> elevations = null;
		try{
			reader = new JsonReader(new InputStreamReader(toParse, "UTF-8"));
		}catch(UnsupportedEncodingException e){
			return elevations;
		}
		if (reader != null){
			try{
				reader.beginObject();	//Consume opening curly bracket
				String name = reader.nextName();
				 reader.beginArray();	//Consume array opening square bracker
				 elevations = new ArrayList<Elevation>();
				 while (reader.hasNext()){
				 	//Read the coordinates and elevations objects
				 	elevations.add(readElevationResult(reader));
				 }
				 reader.endArray();
				name = reader.nextName();
			 	String value = reader.nextString();
			 	reader.endObject();	//Consume the final closing curly bracket
		  }catch(IOException e){
		  }
		}
     return elevations;
   }
	
	//Interpret elevation object from JSON stream
	private static Elevation readElevationResult(JsonReader reader) throws IOException{
		Elevation returnVal = new Elevation();
		reader.beginObject();	//Consume opening curly bracket
		reader.nextName();	//Elevation
		returnVal.elevation = reader.nextDouble();
		reader.nextName();	//Location
		reader.beginObject();	//Consume opening curly bracket
		reader.nextName();	//Lat
		returnVal.lat = reader.nextDouble();
		reader.nextName();	//Lon
		returnVal.lon = reader.nextDouble();
	 	reader.endObject();	//Consume closig curly bracket
	 	reader.nextName();	//Resolution
	 	returnVal.resolution = reader.nextDouble();
	 	reader.endObject();	//Consume closig curly bracket
	 	return returnVal;
	}
}
