package timo.jyu;

import org.knowm.xchart.XYChartBuilder;
import org.knowm.xchart.style.Styler.ChartTheme;
import org.knowm.xchart.XYChart;
import org.knowm.xchart.QuickChart;
import org.knowm.xchart.XYSeries;
import org.knowm.xchart.style.markers.SeriesMarkers;

//import org.knowm.xchart.SwingWrapper;
import org.knowm.xchart.BitmapEncoder;
import org.knowm.xchart.BitmapEncoder.BitmapFormat;



//Appending charts
import java.awt.image.BufferedImage;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class PlotXChart{
	XYChart chart;
	public PlotXChart(String chartTitle, String xTitle, String yTitle, int width, int height){
		chart = new XYChartBuilder().width(width).height(height).theme(ChartTheme.Matlab).title(chartTitle).xAxisTitle(xTitle).yAxisTitle(yTitle).build();
		chart.getStyler().setPlotGridLinesVisible(false);
		chart.getStyler().setXAxisTickMarkSpacingHint(100);
		chart.getStyler().setLegendVisible(false);
	}
	
	public void addSeries(String seriesName, double[] xData, double[] yData){
		XYSeries series = chart.addSeries(seriesName,xData,yData);
		series.setMarker(SeriesMarkers.NONE);
	}
	
	public void savePNG(String saveName){
		savePNG(saveName,300);
	}
	
	public void savePNG(String saveName, int dpi){
		try{
			BitmapEncoder.saveBitmapWithDPI(chart, saveName, BitmapFormat.PNG, dpi);
		}catch (Exception e){
			System.out.println("Could not save image "+saveName+" "+e.toString());
		}
	}
	
	public BufferedImage getBI(){
		return BitmapEncoder.getBufferedImage(chart);
	}
	
	public BufferedImage appendBI(BufferedImage bottomImage){
		return appendBI(bottomImage, false);
	}
	
	public BufferedImage appendBI(BufferedImage bottomImage, boolean flipOrder){
		BufferedImage topImage;
		if (flipOrder){
			//This image on the bottom
			topImage = bottomImage;
		 	bottomImage = getBI();
		}else{
			//This image on top
			topImage = getBI();
		}
		int offset  = 0;
        int width = topImage.getWidth() > bottomImage.getWidth() ? topImage.getWidth() : bottomImage.getWidth();
        int height = topImage.getHeight() + bottomImage.getHeight();
        //create a new buffer and draw two image into the new image
        BufferedImage combined = new BufferedImage(width,height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2 = combined.createGraphics();
        Color oldColor = g2.getColor();
        //fill background
        g2.setPaint(Color.WHITE);
        g2.fillRect(0, 0, width, height);
        //draw image
        g2.setColor(oldColor);
        g2.drawImage(topImage, null, 0, 0);
        g2.drawImage(bottomImage, null, 0, topImage.getHeight());
        g2.dispose();
		return combined;		
	}
	
	public void appendAndSavePNG(String saveName,BufferedImage bottomImage){
		appendAndSavePNG(saveName,bottomImage,false);
	}
	
	public void appendAndSavePNG(String saveName,BufferedImage bottomImage, boolean flipOrder){
		BufferedImage combined = appendBI(bottomImage,flipOrder);
		//Write the image to a PNG file
		try{
			ImageIO.write(combined, "png", new File(saveName));
		}catch (Exception e){
			System.out.println("Could not save image "+saveName+" "+e.toString());
		}
	}
	
	
	public static void main(String[] a){
		double[][] xVals = new double[][]{{0,1,2,3,4},{8,9,10,11,12}};
		double[][] test = new double[][]{{0,1,0,-1,0},{1,0,-1,0,1}};
		PlotXChart pc = new PlotXChart("Sample plot","X","Y",1600,600);
		pc.addSeries("1st",xVals[0],test[0]);
		pc.addSeries("2nd",xVals[1],test[1]);
		PlotXChart pc2 = new PlotXChart("Sample plot2","X","Y",1600,600);
		pc2.addSeries("1st",xVals[0],test[0]);
		pc.appendAndSavePNG("TestSave.png",pc2.getBI());
		
		// Show it
		//new SwingWrapper(chart).displayChart();
	}
}
