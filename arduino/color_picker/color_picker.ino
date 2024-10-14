#include <SoftwareSerial.h>

int red = 11;
int green = 10;
int blue = 9;

String color = "";

SoftwareSerial BT (3, 4); // RX, TX

void setup()
{
	pinMode(13, OUTPUT);
    Serial.begin(9600);
    BT.begin(9600);
}

void loop()
{
    if(Serial.available()){
        color = Serial.readString();
        processColor(color);
    }

    if(BT.available()){
        Serial.println("BT available");
        color = strip(BT.readString());
        if(color.length() == 1){
            if(color == "1"){
                analogWrite(red, 100);
            }else if(color == "0"){
                analogWrite(red, 0);
            }
        }else{
            processColor(color);
        }        
    }
}

int hexToDec(String hexString){
    int decValue = strtol(hexString.c_str(), NULL, 16);
    return decValue;
}

void createColor(int r, int g, int b){
    Serial.println(b);
    analogWrite(red, r);
    analogWrite(green, g);
    analogWrite(blue, b);
}

void processColor(String color){
    int r = hexToDec(color.substring(0, 2));
    int g = hexToDec(color.substring(2, 4));
    int b = hexToDec(color.substring(4, 6));
    createColor(r, g, b);
}

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