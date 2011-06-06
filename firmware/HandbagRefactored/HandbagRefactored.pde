#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>

// Requires Serial to have been initialised.
#define LOG_DEBUG(x) Serial.println(x)

AndroidAccessory acc("rancidbacon.com",
		     "Handbag",
		     "Handbag (Arduino Board)",
		     "0.1",
		     "http://rancidbacon.com",
		     "0000000000000001");

#define CALLBACK(varname) void (*varname)()


#define UI_WIDGET_TYPE_BUTTON 0x00
#define UI_WIDGET_TYPE_LABEL 0x01

#define COMMAND_GOT_EVENT 0x80

#define EVENT_BUTTON_CLICK 0x01

#define WIDGET_TYPE unsigned int

class Widget {
  private:
    CALLBACK(callback);
    unsigned int id;
    unsigned int type;
    
    friend class HandbagApp;
};

#define MAX_WIDGETS 20

#define MESSAGE_CONFIGURE 0x10

class HandbagApp {

private:
  AndroidAccessory& accessory;
  
  // TODO: Dynamically allocate this?
  Widget widgets[MAX_WIDGETS];
  
  unsigned int widgetCount;

// TODO: Dynamically allocate this?  
#define MSG_BUFFER_SIZE 50

  void sendWidgetConfiguration(byte widgetType, byte widgetId, const char *labelText) {
    /*
     */
    // TODO: Do something stream based instead.
    byte msg[MSG_BUFFER_SIZE];
    byte offset = 0;
    
    byte lengthToCopy = 0;
    
    msg[offset++] = MESSAGE_CONFIGURE;
    msg[offset++] = widgetType;
    
    msg[offset++] = widgetId;
    
    lengthToCopy = MSG_BUFFER_SIZE - (offset + 1);
    
    if (strlen(labelText) < lengthToCopy) {
      lengthToCopy = strlen(labelText);
    }
    
    msg[offset++] = lengthToCopy;
    
    memcpy(msg+offset, labelText, lengthToCopy);
    
    offset += lengthToCopy;
    
    accessory.write(msg, offset);
  }  
  
  
public:
  HandbagApp(AndroidAccessory& accessory) : accessory(accessory) {
    /*
     */
     widgetCount = 0;
  }

  int begin() {
    /*
     */
    accessory.powerOn();
    
    while (!accessory.isConnected()) {
      // Wait for connection
      // TODO: Do time out?
    }

    // TODO: Do protocol version handshake.
    // TODO: Return result status.
        
  }

  // TODO: Make private
  // TODO: Set type-specific things like "label text" differently?
  int addWidget(WIDGET_TYPE widgetType, CALLBACK(callback), const char *labelText) {
    /*
     */

    if (widgetCount == MAX_WIDGETS) {
      return -1;
    }

    Widget& theWidget = widgets[widgetCount];

    theWidget.id = widgetCount;
    widgetCount++;
    
    theWidget.type = widgetType;
    theWidget.callback = callback; 
    
    // TODO: Wait for confirmation?
    sendWidgetConfiguration(theWidget.type, theWidget.id, labelText);
    
    return theWidget.id;
  }
  
  int addLabel(const char *labelText) {
    /*
     */
    return addWidget(UI_WIDGET_TYPE_LABEL, NULL, labelText);
  }
  
  int addButton(const char *labelText, CALLBACK(callback)) {
    /*
     */
    return addWidget(UI_WIDGET_TYPE_BUTTON, callback, labelText);
  }

  void triggerButtonCallback(int widgetId) {
    /*
     */
    if (widgetId < widgetCount) {
      // TODO: Actually search to match the ID?
      Widget& theWidget = widgets[widgetId];
      
      if ((theWidget.type == UI_WIDGET_TYPE_BUTTON) && (theWidget.callback != NULL)) {
        theWidget.callback();
      }
    }
  }

  void refresh() {
    /*
     */
    byte msg[3];

    // TODO: Ensure we're not called too often? (Original had 'delay(10)'.)

    if (accessory.isConnected()) {
      // TODO: Change this to all be stream based.
      int len = acc.read(msg, sizeof(msg), 1);
      
      if (len > 0) {
        // Requires only one command per "packet".
        // TODO: Check actual length received?
        // Currently bytes are: (command_type, arg1, arg2)
        // For command type event occured: arg 1 = event type, arg2 = widget id 
        switch (msg[0]) {
          case COMMAND_GOT_EVENT:
            switch (msg[1]) {
              case EVENT_BUTTON_CLICK:
                triggerButtonCallback(msg[2]);
                break;
                
              default:
                break;
            }
            break;
          
          default:
            break;
        }
      }
    } else {
      // TODO: Handle disconnection.
      // TODO: Move widget configuration to happen when connected? (Or also via a callback?)
    }
    
  }

};


HandbagApp Handbag(acc);


void callMe() {
  /*
   */
  Serial.println("Callback called."); 
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  
  Serial.println("Starting...");

  Handbag.begin();

  Serial.println("Started.");
  
  Serial.print("Widget id: ");
  Serial.println(Handbag.addLabel("Hello"));
  
  Serial.print("Widget id: ");
  Serial.println(Handbag.addButton("There", callMe));

  Serial.println("Finished.");  
}

void loop() {
  // put your main code here, to run repeatedly: 
  Handbag.refresh();  
}


