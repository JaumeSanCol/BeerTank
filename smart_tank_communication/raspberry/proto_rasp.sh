sudo apt update
sudo apt upgrade
sudo apt install mosquitto mosquitto-clients
sudo systemctl enable mosquitto
sudo mosquitto_passwd -c /etc/mosquitto/passwd usuario
sudo nano /etc/mosquitto/mosquitto.conf
allow_anonymous false
password_file /etc/mosquitto/passwd
sudo systemctl restart mosquitto
mosquitto_sub -h localhost -t test/arduino