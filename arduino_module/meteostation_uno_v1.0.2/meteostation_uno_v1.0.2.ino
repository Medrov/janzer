#define TIME_geiger 42000 // ms for geiger
#include <iarduino_RTC.h>
iarduino_RTC time(RTC_DS3231);
//int D, M, Y, h, m, s, W;
/*    time.gettime("d-m-Y, H:i:s, D")
     *****
      time.gettime();                                                   // Считываем текущее время из модуля.
      D = time.day;                                                     // Получаем текущий день месяца 1-31.
      M = time.month;                                                   // Получаем текущий месяц       1-12.
      Y = time.year;                                                    // Получаем текущий год         0-99.
      h = time.Hours;                                                   // Получаем текущие часы        0-23.
      m = time.minutes;                                                 // Получаем текущие минуты      0-59.
      s = time.seconds;                                                 // Получаем текущие секунды     0-59.
      W = time.weekday;                                                 // Получаем текущий день недели 0-6. Sun Mon Tue Wed Thu Fri Sat*/
int geiger = 0;
int Geiger = 0;
long int time_geiger = 0;
int i = 0;
boolean file = 0;
boolean nano = 0;
#include <SoftwareSerial.h>
SoftwareSerial SoftSerial(8, 9); // RX, TX
#include "DHT.h"
#define DHTPIN 4
DHT dht(DHTPIN, DHT11);
int vlaga = 0;
int schethcik = 0;
char F;
#define DUST_ILED 7
#define DUST_PIN 0
#define NO_DUST_VOLT 0//.9
long int dust = 0;
uint32_t TIME = 0;
#define TEST 1 // отправка данных в: 0 - Serial, 1 - SoftSerial
boolean SD = 0;

char gps1[15];
char gps2[15];
char satellites;
char gps_time[10];
char gps_date[10];
char temp[10];
char dav[10];

byte i_gps1;
byte i_gps2;
byte i_gps_time;
byte i_gps_date;
byte i_temp;
byte i_dav;

void setup() {
  Serial.begin(9600); 
  SoftSerial.begin(9600);
  pinMode(7, OUTPUT);
  digitalWrite(7, LOW);
  dht.begin();
  delay(100);
  time.begin();
  attachInterrupt(0, s_geiger, RISING);
}

void loop() {
  START();
}

void START() {
  if (time_geiger + TIME_geiger < millis()) {
    nano = proverka();
    // vivod data
    dat();
    if (nano) {
      if (TEST == 0) {
        Serial.print("@");
        Serial.print(time.gettime("d-m-Y; H:i:s; D"));
        Serial.print(";");
        Serial.print(vlaga);
        Serial.print(";");
        Serial.print(dust);
        Serial.print(";");
        Serial.print(Geiger);
        Serial.print(";");
      }
      else {
        SoftSerial.print("@");
        SoftSerial.print(time.gettime("d-m-Y, H:i:s, D"));
        SoftSerial.print(";");
        SoftSerial.print(vlaga);
        SoftSerial.print(";");
        SoftSerial.print(dust);
        SoftSerial.print(";");
        SoftSerial.print(Geiger);
        SoftSerial.print(";");
      }  
    }
    
    // vvod data
    byte ii = 0;
    for (ii = 0; ii < 15; ii++) gps1[ii] = 0;
    for (ii = 0; ii < 15; ii++) gps2[ii] = 0;
    for (ii = 0; ii < 10; ii++) gps_time[ii] = 0;
    for (ii = 0; ii < 10; ii++) gps_date[ii] = 0;
    for (ii = 0; ii < 10; ii++) temp[ii] = 0;
    for (ii = 0; ii < 10; ii++) dav[ii] = 0;
    satellites = 0;
    i_gps1 = 0;
    i_gps2 = 0;
    i_gps_time = 0;
    i_gps_date = 0;
    i_temp = 0;
    i_dav = 0;
    ii = 0;
    TIME = millis();
    while ((ii < 8) && (nano) && (TIME + 10000 > millis())) {
      if (SoftSerial.available() > 0) {
        F = SoftSerial.read();
        if ((ii == 0) && (F == 'E')) { ii = 4; gps1[i_gps1] = F; }
        else if (F == ';') ii++;
        else if (ii == 0) { gps1[i_gps1] = F; i_gps1++; }
        else if (ii == 1) { gps2[i_gps2] = F; i_gps2++; }
        else if (ii == 2) { satellites = F; }
        else if (ii == 3) { gps_time[i_gps_time] = F; i_gps_time++; }
        else if (ii == 4) { gps_date[i_gps_date] = F; i_gps_date++; }
        else if (ii == 5) { temp[i_temp] = F; i_temp++; }
        else if (ii == 6) { dav[i_dav] = F; i_dav++; }
        else if ((ii == 7) && ((F == 'S') || (F == 'E'))) {
          if (F == 'S') SD = 1;
          else SD = 0;
          ii++;
        }
      }
    }
    if (TIME + 10000 <= millis()) nano = 0;
    // vivod 2
    Serial.println();
    Serial.println("=========================");
    Serial.print("Real time(GMT+3), "); Serial.println(time.gettime("d-m-Y, H:i:s, D"));
    //nano = proverka();
    if (nano) Serial.println("successfull: ARDUINO NANO;");
    else Serial.println("ERROR: ARDUINO NANO;");
    if (nano) {
      if (SD) Serial.println("successfull: SD-card;");
      else Serial.println("ERROR: SD-card;");
    }
    if ((gps1[2] != 'E') && (nano)) {
      Serial.print("gps coordinates: ");
      i = 2; while (gps1[i] != 0)  { Serial.print(gps1[i]); i++; }
      Serial.print("; ");
      i = 0; while (gps2[i] != 0)  { Serial.print(gps2[i]); i++; }
      Serial.println(";");
      Serial.print("gps satellites: ");
      Serial.print(satellites);
      Serial.println(";");
      Serial.print("gps time: ");
      i = 0; while (gps_time[i] != 0)  { Serial.print(gps_time[i]); i++; }
      Serial.println(";");
      Serial.print("gps date: ");
      i = 0; while (gps_date[i] != 0)  { Serial.print(gps_date[i]); i++; }
      Serial.println(";");
    }
    else if ((gps1[2] == 'E') && (nano)) {
      Serial.println("ERROR: gps;");
    }
    if (nano) {
      Serial.print("temperature(C): ");
      i = 0; while (temp[i] != 0)  { Serial.print(temp[i]); i++; }
      Serial.println(";");
      Serial.print("pressure(mmHg): ");
      i = 0; while (dav[i] != 0)  { Serial.print(dav[i]); i++; }
      Serial.println(";");
    }
    Serial.print("humidity(%): ");
    Serial.print(vlaga);
    Serial.println(";");
    Serial.print("dust: ");
    Serial.print(dust);
    Serial.println(";");
    Serial.print("sievert(@/42 sec): ");
    Serial.print(Geiger);
    Serial.println(";");
    Serial.println("=========================");
    delay(1);
    time_geiger = millis();
    geiger = 0;
  }
}

boolean proverka() {
  if (TEST == 0) Serial.println("?"); 
  else SoftSerial.println("?");
  boolean flag = 1;
  TIME = millis();
  while ((flag) && (TIME + 5000 > millis())) {
    if ((TEST == 0) && (Serial.available() > 0)) {
      F = Serial.read();
      if (F == '!') { flag = 0; }
    }
    if ((TEST == 1) && (SoftSerial.available() > 0)) {
      F = SoftSerial.read();
      if (F == '!') { flag = 0; }
    }
  }
  //Serial.println(flag);
  if (flag) flag = 0;
  else flag = 1;
  //Serial.println(flag);
  return flag;
}

void dat() {
  Geiger = geiger;
  vlaga = dht.readHumidity(); //Измеряем влажность
  //temp  = temp  + int(dht.readTemperature());
  //vlaga = vlaga + int(dht.readHumidity());
  digitalWrite(7, HIGH);
  delayMicroseconds(280);
  dust = ((analogRead(DUST_PIN)) * 5.0 / 1024.0 - NO_DUST_VOLT)*100;
  digitalWrite(7, LOW);
  //schethcik++;
}

void s_geiger() {
  geiger++;
}
