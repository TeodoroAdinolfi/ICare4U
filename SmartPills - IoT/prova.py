import paho.mqtt.client as mqtt
import time


def on_connect(client,userdata,flags,rc):
    print("Connecting...")
    client.subscribe([("/connection", 1), ("/active", 1), ("/checkInit", 1)])
    return

def on_message(client , userdata , msg):
    print(msg.topic+" "+str(msg.payload))
    if(msg.topic == "/connection"):
        client.publish("/checkInit", "Active", 1)
    if(msg.topic == "/active" and str(msg.payload == "isAlive")):
        client.publish("/checkAlive", "Alive", 1)
    return

def on_subscribe(client, userdata, mid, granted_qos):
    print("\n on_subscribe:"+str(client._client_id))


try:
    client= mqtt.Client()
    client.on_connect=on_connect
    client.on_message=on_message
    client.on_subscribe= on_subscribe
    client.connect("test.mosquitto.org", 1883, 60)
    client.loop_start()

    while True:
        time.sleep(5)
        # print("Pubblico un messaggio...")
        # client.publish("/desktop/sample", "Ciao Fisciano", 1)


except Exception as e:
    print("Exception",e)
finally:
    client.loop_stop()
    client.unsubscribe("/init")
    client.disconnect()