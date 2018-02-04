package timo.home.polyencode;

import java.util.ArrayList;
import com.google.maps.model.LatLng;
import com.google.maps.android.PolyUtil;
public class PolyEncode{
	public static String encode(double[] lat, double[] lon){
		ArrayList<LatLng> path = new ArrayList<LatLng>();
		for (int i = 0;i<lat.length;++i){
			path.add(new LatLng(lat[i],lon[i]));
		}		
		return PolyUtil.encode(path);
	}
}
