#include "bt_https.h"
#include "config.h"
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>




void validateToken(WiFiClientSecure& client, int tokenId) {

  String url = String("/verify/token/") + tokenId;
  Serial.print("Requesting URL: ");
  Serial.println(url);

  if (client.connect(server, 443)) {
      Serial.println(F("Connected to server successfully"));
      client.println("POST " + url + " HTTP/1.0");
      client.println("Host: " + (String)server);
      client.println(F("Connection: close"));
      client.println(F("special-key: arduinoUser/json;"));
      client.println(F("Content-Type: application/json;"));
      Serial.println(F("Datas were sent to server successfully"));
      while (client.connected()) {
        String line = client.readStringUntil('\n');
        if (line == "\r") {
          break;
        }
      }
      String line = client.readStringUntil('\n');
    } else {
      Serial.println(F("Connection to webserver was NOT successful"));
    }
  

  // // Construct HTTP request headers
  // String httpRequest = String("POST ") + url + " HTTP/1.1\r\n" + "Host: " + server + "\r\n" + "Connection: close\r\n" + "Content-Type: application/json\r\n" + "special-key: arduinoUser\r\n" + "\r\n";  // End of headers

  // // Send the HTTP request
  // httpsclient.print(httpRequest);
  // // Serial.println("Request: "+httpRequest);
  // // Wait for and process the response
  // while (httpsclient.connected() || httpsclient.available()) {
  //   if (httpsclient.available()) {
  //     String line = httpsclient.readStringUntil('\n');
  //     Serial.println(line);

  //     // Interpret the response
  //     if (line.startsWith("HTTP/1.1 200")) {
  //       Serial.println("Token is valid");
  //     } else if (line.startsWith("HTTP/1.1 404")) {
  //       Serial.println("Token invalid");
  //     } else if (line.startsWith("HTTP/1.1 500")) {
  //       Serial.println("Error verifying token");
  //     }
  //   }
  // }
}
