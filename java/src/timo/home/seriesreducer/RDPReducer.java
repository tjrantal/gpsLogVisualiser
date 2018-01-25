package timo.home.seriesreducer;
/**
	Uses https://github.com/LukaszWiktor/series-reducer Ramer–Douglas–Peucker algorithm implementation
	to simplify a polygon
*/

import java.util.List;
import java.util.ArrayList;
import pl.luwi.series.reducer.Point;
import pl.luwi.series.reducer.SeriesReducer;
public class RDPReducer{
	private List<RDPPoint> reduced;	//the simplified polygon
	/**
		@param x x-coordinates of the polygon to simplify
		@param y y-coordinates of the polygon to simplify
		@param tolerance tolerance for the Ramer-Douglas-Peucker algorithm
	*/
	public RDPReducer(double[] x, double[] y,double tolerance){
		ArrayList<RDPPoint> toReduce = new ArrayList<RDPPoint>();
		for (int i = 0;i<x.length;++i){
			toReduce.add(new RDPPoint(x[i],y[i],i));
		}
		reduced = SeriesReducer.reduce(toReduce, tolerance);
	}
	
	/**@returns the indices of the reduced vertices in the original data*/
	public int[] getIndices(){
		int[] indices = new int[reduced.size()];
		for (int i = 0; i<reduced.size();++i){
			indices[i] = reduced.get(i).i;
		}
		return indices;
	}
	
	/**@returns the x-coordinates of the simplified polygon*/
	public double[] getX(){
		double[] x = new double[reduced.size()];
		for (int i = 0; i<reduced.size();++i){
			x[i] = reduced.get(i).x;
		}
		return x;
	}
	
	/**@returns the y-coordinates of the simplified polygon*/
	public double[] getY(){
		double[] y = new double[reduced.size()];
		for (int i = 0; i<reduced.size();++i){
			y[i] = reduced.get(i).y;
		}
		return y;
	}

}
