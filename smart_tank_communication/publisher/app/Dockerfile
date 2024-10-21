FROM python:3.9-slim

WORKDIR /app

# Install Paho MQTT client
RUN pip install paho-mqtt

# Copy the publisher script
COPY publisher.py /app/

# Run the publisher script
CMD ["python", "publisher.py"]

