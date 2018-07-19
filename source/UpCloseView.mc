using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class UpCloseView extends WatchUi.WatchFace {

	// global variables
	var aCx 			= 0.0; 			// absolute center x coordinate
	var aCy 			= 0.0;			// absolute center y coordinate
	var r1  			= 0.0; 			// absolute circle radius
	var rCx 			= 0.0; 			// relative center x coordinate
	var rCy 			= 0.0; 			// relative center y coordinate
	var r2  			= 0.0; 			// relative circle radius
	var lCx 			= 0.0;			// opposite point to rCx
	var lCy 			= 0.0; 			// opposite point to rCy 
	var bCx 			= 0.0;			// bottom point of minute arc x
	var bCy				= 0.0;			// bottom point of minute arc y 
	var tCx 			= 0.0;			// top point of minute arc x
	var tCy 			= 0.0; 			// top point of minute arc y
	var hrR				= 0.0;			// radius of circle to draw hours from
	var hfR				= 0.0; 			// radius of circle to draw 30 min ticks from
	var htR 			= 0.0;			// radius of circle to draw 15 min ticks from
	var hsR				= 0.0; 			// radius of circle to draw 5 min ticks from
	var numeralFont 	= null;			// font to use on the numbers
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        numeralFont = loadResource(Rez.Fonts.roboto48);
        
        // setup absolute circle (watch face)
        aCx = dc.getWidth() / 2; 
        aCy = dc.getHeight() / 2;
    	r1 = dc.getWidth() / 2;
    	
    	rCx = aCx + (r1 * Math.cos((7 * Math.PI) / 4));
    	rCy = aCy + (r1 * Math.sin((7 * Math.PI) / 4));
    	
    	lCx = aCx + (r1 * Math.cos((3 * Math.PI) / 4)); 
    	lCy = aCy + (r1 * Math.sin((3 * Math.PI) / 4)); 
    	
    	bCx = aCx + (r1 * Math.cos(Math.PI / 4)); 
    	bCy = aCy + (r1 * Math.sin(Math.PI / 4)); 
    	
    	// might not need this one...
    	tCx = aCx + (r1 * Math.cos((5 * Math.PI) / 4)); 
    	tCy = aCy + (r1 * Math.sin((5 * Math.PI) / 4)); 
    	
    	//System.println("Relative center: (" + rCx + ", " + rCy + ")");
    	//System.println("Bottom center: 	 (" + bCx + ", " + bCy + ")");
    	
    	r2 = bCy - rCy; 
    	hrR = 0.75 * r2;
    	hfR = 0.80 * r2;
    	htR = 0.85 * r2;
    	hsR = 0.93 * r2;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		dc.setPenWidth(3);
		// draw background 
		dc.fillCircle(aCx, aCy, r1);
		// draw arc for time
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
		dc.drawArc(rCx, rCy, r2, 0, 180, 270);
		
		// draw tick marks
		var time = Gregorian.info(Time.now(), 0);
		var hours = time.hour;
		var minutes = time.min;
		System.println("Time: " + hours + ":" + minutes);
		
		var count = 0.0; // going to 120, counting minutes 
		var radian = 0.0;
		var Dx = 0.0; // draw x
		var Dy = 0.0; // draw y
		var Dx2 = 0.0;
		var Dy2 = 0.0;
		var Mx = 0.0; // change in x
		var My = 0.0; // change in y
		var d = 0.0; // distance between D and D2
		hours = hours - 1;
		if (hours < 0) {
			hours = 12;
		} 
		var drawHours = hours;
		dc.setPenWidth(1);
		// System.println("Earlier Time: " + hours + ":" + minutes);
		while (count < 120) {
			switch(minutes) {
				case 0:
					// System.println("Draw hour at: " + hours + ":" + minutes);
					radian = (Math.PI / 2) + ((Math.PI / 2) * (count / 120));
					// System.println("Degree to draw: " + Math.toDegrees(radian));
					Dx = rCx + (r2 * Math.cos(radian));
					Dy = rCy + (r2 * Math.sin(radian));
					Dx2 = rCx + (hrR * Math.cos(radian));
					Dy2 = rCy + (hrR * Math.sin(radian));
					dc.drawLine(Dx, Dy, Dx2, Dy2);
					System.println("D = (" + Dx + ", " + Dy + ")");
					System.println("D2 = (" + Dx2 + ", " + Dy2 + ")");
					Mx = (Dx - Dx2).abs();
					My = (Dy - Dy2).abs(); 
					System.println("Mx = " + Mx + ", My = " + My);
					d = Math.sqrt(Math.pow(Mx, 2) + Math.pow(My, 2));
					Dx = Dx2 + (0.5 * Mx);
					Dy = Dy2 - (0.5 * My) - 24; // extra offset for font size
					System.println("Adjusted D = (" + Dx + ", " + Dy + ")");
					dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
					drawHours = hours % 12;
					if (drawHours == 0) {
						drawHours = 12;
					}
					dc.drawText(Dx, Dy, numeralFont, drawHours, Graphics.TEXT_JUSTIFY_CENTER);
					dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
					break;
				case 15:
				case 45:
					// System.println("Draw 15 tick at: " + hours + ":" + minutes);
					radian = (Math.PI / 2) + ((Math.PI / 2) * (count / 120));
					Dx = rCx + (r2 * Math.cos(radian));
					Dy = rCy + (r2 * Math.sin(radian));
					Dx2 = rCx + (htR * Math.cos(radian));
					Dy2 = rCy + (htR * Math.sin(radian));
					dc.drawLine(Dx, Dy, Dx2, Dy2);
					break;
				case 30:
					// System.println("Draw 30 tick at: " + hours + ":" + minutes);
					radian = (Math.PI / 2) + ((Math.PI / 2) * (count / 120));
					Dx = rCx + (r2 * Math.cos(radian));
					Dy = rCy + (r2 * Math.sin(radian));
					Dx2 = rCx + (hfR * Math.cos(radian));
					Dy2 = rCy + (hfR * Math.sin(radian));
					dc.drawLine(Dx, Dy, Dx2, Dy2);
					break;
				case 5:
				case 10:
				case 20:
				case 25:
				case 35:
				case 40:
				case 50:
				case 55:
					radian = (Math.PI / 2) + ((Math.PI / 2) * (count / 120));
					Dx = rCx + (r2 * Math.cos(radian));
					Dy = rCy + (r2 * Math.sin(radian));
					Dx2 = rCx + (hsR * Math.cos(radian));
					Dy2 = rCy + (hsR * Math.sin(radian));
					dc.drawLine(Dx, Dy, Dx2, Dy2);
					break;
				default:
					// do nuttin
					break;
			}
			count = count + 1;
			minutes = minutes + 1;
			if (minutes >= 60) {
				minutes = 0;
				hours = hours + 1;
				if (hours >= 24) {
					hours = 0;
				}
			}
		}
		//System.println("Later Time: " + hours + ":" + minutes);
		
		// draw line for minute hand, this should be drawn last
		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
		dc.drawLine(lCx, lCy, rCx, rCy);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
