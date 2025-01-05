#include "bt_https.h"
#include "config.h"
#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>

int validateToken(WiFiClientSecure& client, int tokenId) {
  int code = 500;
  client.setInsecure();
  String urlToken = "/confirmations/request/" + String(tokenId);
  String urlReq = "/confirmations/request/status/";

  client.stop();
  if (client.connect(server, 443)) {
    //Serial.println(F("Connected to cloud successfully"));
    client.println("POST " + urlToken + " HTTP/1.1");
    client.println("Host: " + String(server));
    client.println("special-key: arduinoUser");
    client.println("Content-Type: application/json");
    client.println();

    //Serial.println(F("Headers sent to server successfully"));

    while (client.connected()) {
      String line = client.readStringUntil('\n');
      if (line == "\r") {
        break;
      }
    }
  
    Serial.println();
    String response = client.readString();
    Serial.println(response);

    int value3 = response.toInt();
    urlReq += String(value3);
    Serial.println(urlReq);
  } else {
    Serial.println(F("Connection to webserver was NOT successful"));
    client.stop();
    return code;
  }

  client.stop();

  unsigned long startTime = millis();
  int timeout = 30000; // 30 seconds

  while (millis() - startTime < timeout) {
    Serial.println("Checking response...");
    if (client.connect(server, 443)) {
      client.println("GET " + urlReq + " HTTP/1.1");
      client.println("Host: " + String(server));
      client.println("special-key: arduinoUser");
      client.println("Content-Type: application/json");
      client.println();


      while (client.connected()) {
        String line = client.readStringUntil('\n');
        if (line == "\r") {
          break;
        }
      }

      String response = client.readString();
      Serial.println(response);

      if (response.indexOf("\"status\":\"Approved\"") != -1) {
        Serial.println(F("Positive response received!"));
        code = 200;
        break;
      }
    } else {
      Serial.println(F("Connection to webserver was NOT successful"));
    }
    if (millis() - startTime > timeout) {
      Serial.println(F("Ran out of time for a response"));
    }

    client.stop();
    delay(30000);
  }

  return code;
}
