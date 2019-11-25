char real_time[26] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
char humidity[5] = {0,0,0,0,0};
char dust[7] = {0,0,0,0,0,0,0};
char zivert[5] = {0,0,0,0,0};
//char mas_gps[37] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//int i_gps = 0;
//boolean e_gps = 0;
boolean GPS_F = 0;
byte gps_i = 0;
#include <Wire.h> 
#include <BMP085.h> 
BMP085 dps = BMP085();    
long Temperature = 0, Pressure = 0;

#include <SoftwareSerial.h>
SoftwareSerial SoftSerial(8, 9); // RX, TX
byte gps_flag = 0;
byte gps_flag2 = 0;
byte fs = 0;  // $
byte fz = 0;  // ,
byte ft = 0;  // .
byte sp = 0;  // satellites - спутники

#include <SPI.h>
#include <SD.h>
File file;
char F;

uint32_t TIME = 0;

float temp = 0;
float dav = 0;

uint8_t i = 0;

void setup() {
  Serial.begin(9600);
  SoftSerial.begin(9600);
  i = 0;
  Wire.begin();
  dps.init(); 
  delay(100);
  while(!Serial){;}
}

void loop() {
  if (Serial.available() > 0) {
    F = Serial.read();
    if (F == '?') { delay(100); Serial.println("!"); }
    if (F == '@') {
      vvod();
      if (TIME + 10000 > millis()) {
        delay(100);
        zapros();
        zapisat();
      }
    }
    F = 0;
  }
  //test_bmp();
}

void zapisat() {
  // OPEN
  if(!SD.begin(10)){ Serial.println("E"); }
  else { 
    file = SD.open("DATA.txt", FILE_WRITE);
    if(file) { 
      // ZAPISAT
      file.println();
      file.println("==============================");
      file.print("Real time(GMT+3), ");
      i = 0; while (real_time[i] != 0) { file.print(real_time[i]); i++; } //file.println();
      GPS_F = 1; gps(); GPS_F = 0; file.println();
      bmp();
      file.print("temperature(C): ");
      file.print(temp);
      file.println(";");
      file.print("pressure(mmHg): ");
      file.print(dav);
      file.println(";");
      file.print("humidity(%): ");
      i = 0; while (humidity[i] != 0)  { file.print(humidity[i]); i++;  } file.println(";");
      file.print("dust: ");
      i = 0; while (dust[i] != 0)      { file.print(dust[i]); i++;      } file.println(";");
      file.print("sievert(@/42 sec): ");
      i = 0; while (zivert[i] != 0)    { file.print(zivert[i]); i++;    } file.println(";");
      file.println("==============================");
      // CLOSE
      if (file) { file.close(); }
      Serial.println("S"); 
    }
    else { Serial.println("E"); } 
  }
  
}

void vvod() {
  F = 0;
  i = 0;
  byte u = 0;
  for(u = 0; u < 26; u++) real_time[u] = 0;
  for(u = 0; u < 5;  u++) humidity[u] = 0;
  for(u = 0; u < 7;  u++) dust[u] = 0;
  for(u = 0; u < 5;  u++) zivert[u] = 0;
  u = 0;
  TIME = millis();
  while ((u <= 3) && (TIME + 10000 > millis())) {
    while (F != ';') {
      if (Serial.available() > 0) {
        F = Serial.read();
        if (F != ';') { 
          if (u == 0) real_time[i] = F;
          if (u == 1) humidity[i] = F;
          if (u == 2) dust[i] = F;
          if (u == 3) zivert[i] = F;
          i++;  
        }
      }
    }
    F = 0;
    u++;
    i = 0;   
  }
  /*i = 0; while (real_time[i] != 0) { Serial.print(real_time[i]); i++; } Serial.println();
  i = 0; while (humidity[i] != 0)  { Serial.print(humidity[i]); i++;  } Serial.println();
  i = 0; while (dust[i] != 0)      { Serial.print(dust[i]); i++;      } Serial.println();
  i = 0; while (zivert[i] != 0)    { Serial.print(zivert[i]); i++;    } Serial.println();*/
}

void zapros() {
  //Serial.print("@");
  gps();
  bmp();
  Serial.print(temp);  Serial.print(";"); 
  Serial.print(dav);   Serial.print(";");
  Serial.println();
}

/*
void test_bmp() {
  dps.getPressure(&Pressure); 
  dps.getTemperature(&Temperature);
  Serial.println(Temperature*0.1);  // Температуру по Цельсию
  Serial.println(Pressure/133.3);   // давление мм рт ст
}
*/

void bmp() {
  dps.getPressure(&Pressure); 
  dps.getTemperature(&Temperature);
  temp = Temperature*0.1;  // Температуру по Цельсию
  dav  = Pressure/133.3;   // давление мм рт ст
}

void gps() {
  //char F = 0;
  byte fl = 0;
  long int time_gps = millis();
  gps_flag = 1; //                      <=================================
  gps_flag2 = 1;
  fs = 0;  // $
  fz = 0;  // ,
  ft = 0;  // .
  sp = 0;  // спутники
  //vivodln("gps:");
  while ((fl < 2) && (time_gps + 2000 > millis())) {   // проверка на неполные первые входные данные
    if (SoftSerial.available() > 0) {
      F = SoftSerial.read();
      //Serial.print(F);
      time_gps = millis();
      fl = 1;
    }
    if ((millis() > time_gps + 100) && (fl == 1)) {
      //Serial.println();
      fl++;
      time_gps = millis();
    }
  }
  fl = 0;
  time_gps = millis();
  //i_gps = 0;
  gps_i = 0;
  //for(byte g = 0; g < 36; g++) mas_gps[g] = 0;
  while ((fl < 2) && (time_gps + 2000 > millis())) {
    if (SoftSerial.available() > 0) {
      F = SoftSerial.read();
      gps_mozg(F);  //                    <=================================
      //f[i] = F; i++;  // отладка 
      //Serial.print(F);
      //if(file){ file.print(F); }
      time_gps = millis();
      fl = 1;
    }
    if ((millis() > time_gps + 100) && (fl == 1)) {
      //Serial.println();
      fl++;
      time_gps = millis();
    }
  }
  //if (gps_flag == 1) { Serial.println("ERROR: gps"); }
  if ((gps_flag == 1) && (GPS_F == 0)) Serial.print("E;");
}

void gps_mozg(char c) {
  //if ((fs == 0)) { Serial.print("gps coordinates: "); }
  if (c == '$') { fs++; ft = 0; fz = 0; }
  else if (c == '.') { ft++; }
  else if (c == ',') { fz++; }
  else if (fs == 1) {  // определяем gps координаты  
    if ((fs == 1) && ((fz == 2) || (fz == 4))) {  // ((fz == 1) && (ft == 0)) || 
      //if (gps_flag != 9) { Serial.print(c); }
     write_gps(c); 
      if ((gps_flag == 2) || (gps_flag == 12)) { write_gps('.'); } 
      gps_flag++;
    }
    else if ((gps_flag == 9) || (gps_flag == 19)) { write_gps(';'); gps_flag++; }
  }
  else if (fs == 3 + sp) {
    if ((sp == 0) && (fz == 1)) {  // определяем кол-во спутников  && (gps_flag == 20)
      //gps_flag++;
      if (gps_flag != 20) {  // т.е. он не определил gps координаты
        //Serial.print("xxx; xxx; ");
        write_gps('x'); write_gps(';'); write_gps('x'); write_gps(';');
      }
      //Serial.println();
      //Serial.print("gps satellites: ");
      gps_flag = 21;
      write_gps(c);
      //Serial.println(";");
      if      (c == '1') { sp = 1; }
      else if (c == '2') { sp = 2; }
      else if (c == '3') { sp = 3; }
      else if (c == '4') { sp = 4; }
      else if (c == '5') { sp = 5; }
      else if (c == '6') { sp = 6; }
    }
    else if ((sp > 0) && (((fz == 1) && (ft == 0)) || (fz == 9))) {  // определяем время и дату
      write_gps(c);
      gps_flag++; 
    }
    if ((gps_flag == 21) || (gps_flag == 30) || (gps_flag == 39)) { //  || (gps_flag == 19) 
      //Serial.println("; ");
      write_gps(';');
      if (gps_flag == 21) {
        //Serial.print("gps time: ");
      }
      if (gps_flag == 30) {
        //Serial.print("gps date: ");
      }
      gps_flag++; 
    }
    else if ((gps_flag == 24) || (gps_flag == 27)) { write_gps(':'); gps_flag++; }
    else if ((gps_flag == 33) || (gps_flag == 36)) { write_gps('.'); gps_flag++; }
  }
}

void write_gps(char S) {
  if (GPS_F) {
    if (gps_i == 0) { file.println(); file.print("gps coordinates: "); gps_i++; }
    if (gps_i == 2) { file.print(" "); gps_i++; }
    if (gps_i == 4) { file.println(); file.print("gps satellites: "); gps_i++; }
    if (gps_i == 6) { file.println(); file.print("gps time: "); gps_i++; }
    if (gps_i == 8) { file.println(); file.print("gps date: "); gps_i++; }
    if (S == ';') { gps_i++; }
    file.print(S);
  }
  else {
    Serial.print(S);
  }
}
