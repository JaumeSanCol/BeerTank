#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// Credenciales de Wi-Fi
const char* ssid = "nombre_red_wifi";
const char* password = "contraseña_red_wifi";

// Dirección IP del Broker MQTT (Raspberry Pi)
const char* mqtt_server = "IP_Raspberry_Pi";

// Variables para la conexión MQTT
WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);
  
  // Conectar a la red Wi-Fi
  setup_wifi();
  
  // Configurar servidor MQTT
  client.setServer(mqtt_server, 1883);
  
  // Intentar conectarse al servidor MQTT
  while (!client.connected()) {
    Serial.print("Conectando al broker MQTT...");
    if (client.connect("ArduinoClient")) {
      Serial.println("conectado!");
    } else {
      Serial.print("fallo con estado ");
      Serial.print(client.state());
      delay(2000);
    }
  }
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Conectando a ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  
  // Esperar hasta conectarse al Wi-Fi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("Conectado a Wi-Fi");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Asegurar conexión con el broker MQTT
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Ejemplo: publicar un mensaje en el tópico "test/arduino"
  String mensaje = "Hola desde Arduino!";
  client.publish("test/arduino", mensaje.c_str());
  
  delay(5000); // Publicar mensaje cada 5 segundos
}

void reconnect() {
  // Intentar reconectar al broker MQTT
  while (!client.connected()) {
    Serial.print("Intentando reconectar...");
    if (client.connect("ArduinoClient")) {
      Serial.println("conectado!");
    } else {
      Serial.print("fallo, rc=");
      Serial.print(client.state());
      Serial.println(" intentamos en 5 segundos");
      delay(5000);
    }
  }
}
