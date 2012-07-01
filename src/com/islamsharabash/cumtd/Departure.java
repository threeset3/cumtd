package com.islamsharabash.cumtd;

import android.graphics.Color;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class Departure {
  private String route;
  private int minutes;
  private int color;
  private float  LIGHT_OFFSET= .2f;
  private float SAT_OFFSET = -.12f;

  public Departure(String route, int minutes, String color) {
    this.route = route;
    this.minutes = minutes;
    this.color = brightenColor("#" + color);
  }

  public int getColor() {
    return this.color;
  }

  public String getRoute() {
    return this.route;
  }

  public String getTime() {
    if (this.minutes == 0) {
      return "DUE";
    }

    /*TODO I used h (12 hour) instead of H (24 hour). I had difficulty trying to get access to the user's preference.
      If someone puts in a toggle for this, they should ask if they want 12 or 24 hour time, and change this to
      "H:mm" if the user prefers 24 hour time.*/ 
    SimpleDateFormat timingFormat = new SimpleDateFormat("h:mm");
    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.MINUTE, this.minutes);

    return Integer.toString(this.minutes) + "m " + timingFormat.format(cal.getTime());
  }

  public int getTimeColor() {
    if (this.minutes == 0) {
      return Color.RED;
    }
    return Color.WHITE;
  }

  private int brightenColor(String str_color) {
    int color = Color.parseColor(str_color);
    float[] hsv = new float[3];
    Color.colorToHSV(color, hsv);

    hsv[2] = hsv[2] + LIGHT_OFFSET;
    hsv[1] = hsv[1] + SAT_OFFSET;

    return Color.HSVToColor(hsv);
  }
}
