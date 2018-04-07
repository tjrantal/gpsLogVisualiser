package timo.home.utils;

public class Utils{
	//Create google maps HEX string colours
	public static int[] getColourSlide(int start, int finish, int colourNo){
		int[] temp = new int[colourNo];
		double[] startC = new double[]{(double) ((start & 0X00FF0000)>>16),(double) ((start & 0X0000FF00)>>8),(double) ((start & 0X000000FF))};
		double[] finishC = new double[]{(double) ((finish & 0X00FF0000)>>16),(double) ((finish & 0X0000FF00)>>8),(double) ((finish & 0X000000FF))};
		double[] range = new double[]{finishC[0]-startC[0],finishC[1]-startC[1],finishC[2]-startC[2]};
		for (int i = 0; i < colourNo; ++i){
			double scale = ((double) i)/((double) (colourNo-1));
			//int tempColour = 0XFF000000;
			int tempColour = 0X00000000;
			for (int c = 0; c<3; ++c){
			 		tempColour = tempColour | ((0XFF & ((int) (startC[c]+range[c]*scale))) << ((2-c)*8));
			 }
			//temp[i] = String.format("%h",tempColour);
			temp[i] = tempColour;
		}
		return temp;
	}	
		
}
