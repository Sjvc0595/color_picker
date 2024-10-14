#include <SoftwareSerial.h>

// Ports for RGB LED
int red = 11;
int green = 10;
int blue = 9;

// String to store color
String color = "";

SoftwareSerial BT (3, 4); // RX, TX

void setup()
{
	pinMode(13, OUTPUT); // onboard LED
    Serial.begin(9600); // Serial monitor
    BT.begin(9600); // Bluetooth
}

void loop()
{
    // Blink onboard LED
    if(Serial.available()){
        color = Serial.readString();
        processColor(color);
    }

    // Check if BT is available
    if(BT.available()){
        Serial.println("BT available");
        color = strip(BT.readString()); // Read color from BT
        if(color.length() == 1){ // Check if color is a single digit
            if(color == "1"){ // Check if color is 1
                analogWrite(red, 100); // Set red to 100
            }else if(color == "0"){ // Check if color is 0
                analogWrite(red, 0); // Set red to 0
            }
        }else{ // If color is not a single digit
            processColor(color);
        }        
    }
}

// Function to convert hex to decimal
int hexToDec(String hexString){
    int decValue = strtol(hexString.c_str(), NULL, 16);
    return decValue;
}

// Function to create color
void createColor(int r, int g, int b){
    Serial.println(b);
    analogWrite(red, r);
    analogWrite(green, g);
    analogWrite(blue, b);
}

// Function to process color
void processColor(String color){
    int r = hexToDec(color.substring(0, 2));
    int g = hexToDec(color.substring(2, 4));
    int b = hexToDec(color.substring(4, 6));
    createColor(r, g, b);
}

// Function to strip non-ASCII characters
String strip(String str) {
    String newStr = "";
    for (int i = 0; i < str.length(); i++) {
        char c = str.charAt(i);
        if (c >= 32 && c <= 126) {
            newStr += c;
        }
    }
    return newStr;
}