#include "bt_https.h"
#include "config.h"
#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>


int validateToken(WiFiClientSecure& client, int tokenId) {

  int code = 500;

  client.setInsecure();
  String url = "/verify/token/" + String(tokenId);

  //Serial.print("Requesting URL: ");
  //Serial.println(url)
  ;
  client.stop();
  if (client.connect(server, 443)) {
    // Serial.println(F("Connected to server successfully"));
    client.println("POST " + url + " HTTP/1.1");
    client.println("Host: " + String(server));
    client.println("special-key: arduinoUser");
    client.println("Content-Type: application/json");
    client.println();

    // Serial.println(F("Headers sent to server successfully"));

    while (client.connected()) {
      String line = client.readStringUntil('\n');
      if (line == "\r") {
        break;
      }
    }

    String response = client.readString();
    int start = response.indexOf(':');
    int end = response.indexOf(',');

    if (start != -1 && end != -1 && end > start) {
      String result = response.substring(start + 1, end);
      if (result == "true") code = 200;
      else if (result == "false") code = 404;
      else Serial.println("Unexpected response");

    } else Serial.println("Unexpected response");
  } else {
    Serial.println(F("Connection to webserver was NOT successful"));
  }

  client.stop();
  return code;
}