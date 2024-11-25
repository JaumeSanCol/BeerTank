#include "bt_https.h"
#include "config.h"
#include <WiFiClientSecure.h>

void loginToCloud()
{
    WiFiClientSecure httpsclient;
    httpsclient.setInsecure(); // Use only for testing; secure certificates recommended for production
    if (!client.connect(server, httpsPort)) {
        Serial.println("Connection to server failed!");
        return;
    }

    // Build HTTP request
    String payload = ""; // Empty payload
    String request = String("POST /login HTTP/1.1\r\n") +
                    "Host: " + server + "\r\n" +
                    "special-key: arduinoUser\r\n" +
                    "Content-Type: application/json\r\n" +
                    "Content-Length: " + payload.length() + "\r\n" +
                    "Connection: close\r\n\r\n" +
                    payload;

    client.print(request);

    while (client.connected() || client.available())
    {
        if (client.available())
        {
            String line = client.readStringUntil('\n');
            Serial.println(line);
            
            // Interpret the response
            if (line.startsWith("HTTP/1.1 200"))
            {
                Serial.println("Login Complete");
            }
            else if (line.startsWith("HTTP/1.1 401"))
            {
                Serial.println("Invalid credentials");
            }
            else if (line.startsWith("HTTP/1.1 500"))
            {
                Serial.println("Login Error");
            }
        }
    }
}

void validateToken(int tokenId)
{

    // Send the token in the URL
    String url = String("/verify/token/") + tokenId;
    Serial.print("Requesting URL: ");
    Serial.println(url);
    client.print(String("POST ") + url + " HTTP/1.1\r\n" +
                 "Host: " + server + "\r\n" +
                 "Connection: close\r\n\r\n");
    while (client.connected() || client.available())
    {
        if (client.available())
        {
            String line = client.readStringUntil('\n');
            Serial.println(line);

            // Interpret the response
            if (line.startsWith("HTTP/1.1 200"))
            {
                Serial.println("Token is valid");
            }
            else if (line.startsWith("HTTP/1.1 404"))
            {
                Serial.println("Token invalid");
            }
            else if (line.startsWith("HTTP/1.1 500"))
            {
                Serial.println("Error verifying token");
            }
        }
    }
}