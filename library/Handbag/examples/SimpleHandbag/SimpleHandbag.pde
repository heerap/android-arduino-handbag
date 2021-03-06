/*

   SimpleHandbag -- A simple demo for the Handbag App for Android.
   
   This sketch demonstrates a simple Arduino-based accessory for Android.
   
   Requirements:
   
     * Arduino Uno or similar
     
     * USB Host shield and associated library
     
     * Handbag library (this example is part of it)
     
     * Handbag App for Android installed on your phone/tablet from <http://rancidbacon.com/files/Handbag001/Handbag.apk>
     
     * AndroidAccessory library from <http://developer.android.com/guide/topics/usb/adk.html#installing>

     * (Optional) LED connected to digital pin 4.
     
     
   The general requirements of a Handbag compatible sketch are demonstrated
   in this example:
   
     * Creating the Android accessory instance.
     
     * Creating the Handbag instance.
     
     * Writing the functions activated by button presses ("callbacks").
     
     * Writing a function to describe the User Interface (UI).
     
     * Starting the Handbag and giving it the function used to describe the UI.
     
     * Repeatedly refreshing the Handbag so it responds to user actions on the phone.
     
     
   If you have the Arduino connected to a serial port when running this example
   then pressing the button labelled "There" on your Android device will print a message
   to the serial port.
  
   If you have an LED connected to digital pin 4 on your Arduino when running this
   example it will toggle when you press the button labelled "World" on your Android
   device. 
   
   See also:
   
      <http://www.labradoc.com/i/follower/p/android-arduino-handbag>
      
 */

#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>

#include "Handbag.h"


AndroidAccessory acc("rancidbacon.com",
		     "Handbag",
		     "Handbag (Arduino Board)",
		     "0.1",
		     "http://rancidbacon.com",
		     "0000000000000001");

HandbagApp Handbag(acc);


void callMe() {
  /*
   */
  Serial.println("Callback called."); 
}


void lightUp() {
  /*
   */
  const int ledPin = 4;
  
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, !digitalRead(ledPin));
}


void setupUI() {
  /*
   */
  Handbag.addLabel("Hello");
  Handbag.addButton("There", callMe);
  Handbag.addButton("World", lightUp);  
}


void setup() {
  Serial.begin(9600);
  
  Handbag.begin(setupUI);
}


void loop() {
  Handbag.refresh();  
}


