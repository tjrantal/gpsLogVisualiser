package timo.home.seriesreducer;
/**
	Uses https://github.com/LukaszWiktor/series-reducer Ramer–Douglas–Peucker algorithm implementation
	to simplify a polygon, this class is used to retain Point index
*/
import pl.luwi.series.reducer.Point;
public class RDPPoint implements Point{
	public double x;	//x-coordinate
	public double y;	//y-coordinate
	public int i;	//index of the point
	
	public RDPPoint(double x, double y, int i){
		this.x = x;
		this.y = y;
		this.i = i;
	}
	
	//Implement the Point interface
	public double getX(){
		return x;
	}
    
   public double getY(){
   	return y;
   }

}
