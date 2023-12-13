
from bsp import board
from networking import wifi
from protocols import mqtt

# Inizializzazione board
board.init()

# Driver sviluppati
import DS1307
import HCSR04
import StepperMotor
import SSD1306
import APDS9960

# Librerie di utilità
import DateUtils
import TimeUtils

# Librerie Zerynth SDK
import serial
import pwm
import gpio
import time
import threading

cvInit = threading.Condition()
cvAvvioErogazione = threading.Condition()

lockLista = threading.Lock()
lockStorico = threading.Lock()
lockDaErogare = threading.Lock()
lockRTC = threading.Lock()

serial.serial()

# Inizializzazione wifi
ssid = "iPhone di Antonio"
passwd = "m3phvmoo3czj9"
# ssid = "iPhone di Teodoro Adinolfi"
# passwd = "12345678"
# ssid = "iPhone di Emilio"
# passwd = "emiama00"
try:
    print("Configuring...")
    wifi.configure(ssid=ssid, password=passwd)
    print("Connecting...")
    wifi.start()
    print("Connected!")
    print(wifi.info()) # DHCP, IP address, netmask, gateway, DNS, MAC address
except WifiBadPassword:
    print("Bad Password")
except WifiBadSSID:
    print("Bad SSID")
except WifiException:
    print("Generic Wifi Exception")
except Exception as e:
    raise e

# Inizializzazione mqtt
host = "mqtt.eclipseprojects.io" 
#host = "test.mosquitto.org"
client_id = "smartPills"

def run():
    """Loops waiting for messages receiving and calls the relevant registered callback."""
    try:
        print("Starting loop")
        client.loop()
    except Exception as e:
        print("Run thread exec", e)
        sleep(6000)

# Inizializzazione dispositivo
data = ""
ora = ""
listaDispenser1 = [] # contiene le pillole del dispenser 1
listaDispenser2 = [] # contiene le pillole del dispenser 1
lista = [] # contiene tutte le pillole
daErogare = [] # contiene le pillole da erogare
storico = [] # contiene le pillole erogate o non che devono essere comunicate all'applicazione
changed = True # flag per l'aggiornamento del display
avvioErogazione = False # flag per l'avvio del processo di erogazione
erogazioneAcquaRemota = "auto" # flag per l'erogazione dell'acqua in caso di prelievo manuale

# Inizializzazione XKC-Y25-NPN
sensorLevelPin = D15
gpio.mode(sensorLevelPin, INPUT_PULLUP)

dateUtil = DateUtils.DateUtils() # Funzioni di utilità su date
timeUtil = TimeUtils.TimeUtils() # Funzioni di utilità su time

# Funzioni per l'ordinamento

def year_month_day(str_data):
	lst = str_data.split('/')
	return lst[2] + lst[1] + lst[0]

def sortTupleArray(tup, type, index):
     
    # getting length of list of tuples
    lst = len(tup)
    for i in range(0, lst):
         
        for j in range(0, lst-i-1):
            if(type == "date"):
                if (year_month_day(tup[j][index]) > year_month_day(tup[j + 1][index])):
                    temp = tup[j]
                    tup[j]= tup[j + 1]
                    tup[j + 1]= temp
            elif(type == "time"):
                if (tup[j][index] > tup[j + 1][index]):
                    temp = tup[j]
                    tup[j]= tup[j + 1]
                    tup[j + 1]= temp

    return tup

def updateStorico(item, check):
    """
    Funzione che riceve in ingresso un item del tipo farmaco;data;ora e concatena a tale stringa "true" se la pillola è stata 
       erogata con successo (check == true), altrimenti "false", e la aggiunge alla lista "storico".
    """
    print(item)
    global storico
    #messaggio = []
    messaggio = item[0] + ";" + item[1] + ";" + item[2] + ";"
    if check:
        messaggio = messaggio + "true"
    else:
        messaggio = messaggio + "false"
    lockStorico.acquire()
    storico.append(messaggio)
    print(storico)
    lockStorico.release()

# Funzioni di callback
def callbackAggiornamento(client, topic, message):
    """
    Funzione di callback che, alla ricezione del messaggio "ack" sul topic "/historical", pubblica sul topic 
       "/checkHistorical", se lo storico non è vuoto, il contenuto di questo. Inoltre, invia sul topic "/smartPills/acqua" 
       la stringa "true" se questa è presente, "false" altrimenti.
    """
    print("Received",message,"on",topic)
    if(message == "ack"):
        global storico
        lockStorico.acquire()
        while(len(storico) != 0):
            item = storico.pop(0)
            lockStorico.release()
            try:
                client.publish("/checkHistorical", item, qos=2)
                print("publishing", item)
            except Exception as e:
                print(e)
            lockStorico.acquire()
        lockStorico.release()
        try:
            client.publish("/checkHistorical", "fine", qos=2)
        except Exception as e:
            print(e)

def callbackNewPill(client, topic, message):
    """
    Funzione di callback che riceve una nuova assunzione:
        • se la data e l'ora di questa precede la data e l'ora attuale, l'assunzione viene inserita nello storico con esito negativo
        • altrimenti, l'assunzione viene inserita nella "lista" ordinata per data e ora
       Inoltre, viene forzato l'aggiornamento del display nel caso in cui si inserisca la prima pillola.
    """
    print("Received",message,"on",topic)
    cura = message.split("&")
    for i in range(len(cura) - 1):
        tmp = cura[i].split(";")
        lockRTC.acquire()
        lockLista.acquire()
        if(dateUtil.isBefore(tmp[1], rtc.readData()) or (dateUtil.isEqual(tmp[1], rtc.readData()) and timeUtil.isBefore(tmp[2], rtc.readTime()))):
            lockRTC.release()
            updateStorico(tmp, False)
            lockLista.release()
        else:
            lockRTC.release()
            if(tmp[3] == "0"):
                listaDispenser1.append(tmp)
            else:
                listaDispenser2.append(tmp)
            lista.append(tmp)
            lista = sortTupleArray(lista, "time", 2)
            lista = sortTupleArray(lista, "date", 1)
            lockLista.release()
    
    lockLista.release()
    global changed
    changed = True
    updateDisplay()
    lockLista.acquire()
    print(lista)
    lockLista.release()

def callbackRemove(client, topic, message):
    print("Received",message,"on",topic)
    tmp = message.split(";")
    lockLista.acquire()
    if(tmp in lista):
        lista.remove(tmp)
    lockLista.release()
    try:
        listaDispenser1.remove(tmp)
        listaDispenser2.remove(tmp)
    except ValueError:
        pass
    global changed
    changed = True
    updateDisplay()

checkInizializzazione = False

def checkRvdPillInStorico(assunzione):
    """
    Funzione che verifica se un'assunzione inviata dall'app ha già avuto luogo.
    """
    lockStorico.acquire()
    for item in storico:
        item = item.split(";")
        if(assunzione[0] == item[0] and assunzione[1] == item[1] and assunzione[2] == item[2]):
            lockStorico.release()
            return True
    lockStorico.release()
    return False

def callbackInizializzazione(client, topic, message):
    """
    Funzione di callback che riceve una stringa formattata nel seguente modo "dataCorrente, oraCorrente, other", dove
        • other = "void" se non ci sono pillole programmate 
        • other = "farmaco1;data1;ora1;dispenser&farmaco2;data2;ora2;dispenser&..." se ci sono pillole programmate
       e aggiorna le variabili globali per l'inizializzazione del dispositivo. 
       In particolare, se other != "void" e l'assunzione ricevuta presenta data e ora precedenti quella attuale, quest'ultima 
       viene inserita nello storico con esito negativo, altrimenti viene aggiunta alla lista delle prossime assunzioni.
       Inoltre, se lo storico non è vuoto, viene comunicato all'app, sul topic "/checkHistorical", il suo contenuto. 
       Infine, viene inviato sul topic "/smartPills/acqua" la stringa "true" se questa è presente, "false" altrimenti e 
       aggiornato il flag "checkInizializzazione" per avviare completamente il dispositivo.
    """
    print("Received",message,"on",topic)
    initString =  message.split(", ")
    global data
    data = initString[0].split("/")
    global ora
    ora = initString[1].split(":")
    global checkInizializzazione
    if(not(checkInizializzazione)):
        other = initString[2]
        if(not(other == "void")):
            global lista 
            cura = other.split("&")
            for i in range(len(cura) - 1):
                tmp = cura[i].split(";")
                if(not(checkRvdPillInStorico(tmp)) and (dateUtil.isBefore(tmp[1], initString[0]) or (dateUtil.isEqual(tmp[1], initString[0]) and timeUtil.isBefore(tmp[2], initString[1])))):
                    updateStorico(tmp, False)
                elif(not(checkRvdPillInStorico(tmp)) and not(dateUtil.isBefore(tmp[1], initString[0]) or (dateUtil.isEqual(tmp[1], initString[0]) and timeUtil.isBefore(tmp[2], initString[1])))):
                    lockLista.acquire()
                    if(tmp[3] == "0"):
                        listaDispenser1.append(tmp)
                    else:
                        listaDispenser2.append(tmp)
                    lista.append(tmp)
                    lista = sortTupleArray(lista, "time", 2)
                    lista = sortTupleArray(lista, "date", 1)
                    lockLista.release()
            print(lista)

    lockStorico.acquire()
    while(len(storico) != 0):
        item = storico.pop(0)
        try:
            client.publish("/checkHistorical", item, qos=2)
            print("publishing", item)
        except Exception as e:
            print(e)
    lockStorico.release()

    try:
        client.publish("/checkInit", "active", qos=0)
    except Exception as e:
        print(e)
    
    global checkInizializzazione
    cvInit.acquire()
    checkInizializzazione = True
    cvInit.notify()
    cvInit.release()

def callbackEroga(client, topic, message):
    """
    Funzione di callback che anticipa l'erogazione della prossima pillola quando riceve sul topic "/smartPills/eroga" il 
       messaggio "eroga".
    """
    print("Received",message,"on",topic)
    if(message == "eroga" or message == "erogaConAcqua"):
        if(message == "eroga"):
            global erogazioneAcquaRemota
            erogazioneAcquaRemota = "none"
        else:
            erogazioneAcquaRemota = "auto"
        lockLista.acquire()
        if(len(lista) != 0):
            global avvioErogazione
            cvAvvioErogazione.acquire()
            lockDaErogare.acquire()
            daErogare.append(lista.pop(0))
            lockDaErogare.release()
            avvioErogazione = True
            cvAvvioErogazione.notify()
            cvAvvioErogazione.release()
        lockLista.release()

def callbackEmpty(client, topic, message):
    print("Received",message,"on",topic)
    if(message == "dispenser1"):
        for item in listaDispenser1:
            lockLista.acquire()
            try:
                lista.remove(item)
            except:
                pass
            lockLista.release()
        stepper1.rotate(360)
    elif(message == "dispenser2"):
        for item in listaDispenser2:
            lockLista.acquire()
            try:
                lista.remove(item)
            except:
                pass
            lockLista.release()
        stepper2.rotate(360)
    global changed
    changed = True
    updateDisplay()

def callbackWater(client, topic, message):
    print("Received",message,"on",topic)
    try:
        client.publish("/checkWater", "false" if(gpio.get(sensorLevelPin)) else "true", qos=2)
    except Exception as e:
        print(e)

# Topic list
subs = [                  
    "/connection",
    "/newPill",
    "/preleva",
    "/historical",
    "/removePill",
    "/empty",
    "/water"
]

client = mqtt.MQTT(host, client_id, keepalive = 1800, reconnect_after=5000)
print("Suscribe to", subs[0], client.on(subs[0], callbackInizializzazione, 0))
print("Suscribe to", subs[1], client.on(subs[1], callbackNewPill, 1))
print("Suscribe to", subs[2], client.on(subs[2], callbackEroga, 1))
print("Suscribe to", subs[3], client.on(subs[3], callbackAggiornamento, 1))

print("Suscribe to", subs[4], client.on(subs[4], callbackRemove, 1))
print("Suscribe to", subs[5], client.on(subs[5], callbackEmpty, 1))
print("Suscribe to", subs[6], client.on(subs[6], callbackWater, 1))

client.connect()
thread(run)

# Inizializzazione SSD1306
display = SSD1306.SSD1306()
display.clear()
display.write(0, 3, "Attendo inizializzazione...")

# Si attende che il dispositivo riceva la stringa di inizializzazione dall'app 
cvInit.acquire()
while(checkInizializzazione == False):
    cvInit.wait()
print("pass")
cvInit.release()

display.clearRow(3)
display.write(0, 3, "Inizializzazione completata!")
sleep(1000)

# Inizializzazione buzzer
buzzerPin = D5
gpio.mode(buzzerPin, OUTPUT)

# Inizializzazione led
ledPin = D27 
gpio.mode(ledPin, OUTPUT)

# Inizializzazione relay
relayPin = D13
gpio.mode(relayPin, OUTPUT)

# Inizializzazione RTC
rtc = DS1307.DS1307()
rtc.writeAll(seconds=int(ora[2]), minutes=int(ora[1]), hours=int(ora[0]), date=int(data[0]), month=int(data[1]), year=int(data[2][2:4]))

# Inizializzazione HCSR04
trigPin = D25
echoPin = D26
hcsr04 = HCSR04.HCSR04(trigPin, echoPin)

# Inizializzazione StepperMotor
in1d1 = D18
in2d1 = D19
in3d1 = D21  
in4d1 = D22
stepper1 = StepperMotor.StepperMotor(in1d1, in2d1, in3d1, in4d1)

in1d2 = D4
in2d2 = D0
in3d2 = D2
in4d2 = D23
stepper2 = StepperMotor.StepperMotor(in1d2, in2d2, in3d2, in4d2)

# Inizializzazione APDS9960
proximity = APDS9960.APDS9960()

def updateDisplay():
    """
    Funzione di aggiornamento del display
    """
    global changed
    if(changed):
        lockLista.acquire()
        lockDaErogare.acquire()
        if(len(lista) == 0 and len(daErogare) == 0): # se vero non sono programmate pillole
            lockDaErogare.release()
            lockLista.release()
            display.clear()
            display.write(10, 3, "Nessuna pillola programmata")
        elif(len(daErogare) != 0):  # se vero ci sono pillole in coda da erogare
            display.clear()
            display.write(28, 3, "Prossima pillola")
            display.write(0, 4, "FARMACO: " + str(daErogare[0][0]))
            display.write(0, 5, "DATA: " + str(daErogare[0][1]))
            display.write(0, 6, "ORA: " + str(daErogare[0][2]))
            display.write(0, 7, "DISPENSER: " + str(int(daErogare[0][3])+1))
            lockDaErogare.release()
            lockLista.release()
        else: # se vero non ci sono pillole da erogare nell'immediato, mostra la prossima pillola
            lockDaErogare.release()
            display.clear()
            display.write(28, 3, "Prossima pillola")
            display.write(0, 4, "FARMACO: " + str(lista[0][0]))
            display.write(0, 5, "DATA: " + str(lista[0][1]))
            display.write(0, 6, "ORA: " + str(lista[0][2]))
            display.write(0, 7, "DISPENSER: " + str(int(lista[0][3])+1))
            lockLista.release()
    changed = False

def addMinutes(min):
    """
    Aggiunge "min" minuti all'ora corrente.\nRestituisce la tupla (hour, minutes)
    """
    lockRTC.acquire()
    hour = int(rtc.readHours())
    minutes = int(rtc.readMinutes())
    lockRTC.release()
    tot = minutes + min
    hour = hour + (minutes + min)//60
    minutes = minutes + (min - (60 * (min//60)))
    return hour, minutes - 60*(minutes//60) 

def checkHand(trigPin, echoPin):
    """
    Funzione per il controllo della presenza dalla mano per l'effettiva erogazione della pillola\nRestituisce "true" 
       se la mano è stata rilevata, "false" se sono trascorsi 60 secondi dall'attivazione. Per evitare situazioni di falso 
       rilevamento, si è deciso di effettuare la media di 10 letture consecutive.
    """
    hour, minutes = addMinutes(1)
    lockRTC.acquire()
    seconds = int(rtc.readSeconds())
    while (int(rtc.readHours()) != hour or int(rtc.readMinutes()) != minutes or int(rtc.readSeconds()) != seconds):
        lockRTC.release()
        distance = 0
        for i in range(10):
            try:
                distance = distance + hcsr04.measure()
            except RuntimeError as e:
                pass
            except ValueError as e:
                pass
        print("Distance: " + str(distance/10) + " cm")
        if((distance/10) < 5.7):
            return True
        sleep(200)
        lockRTC.acquire()
    lockRTC.release()
    return False

def checkOra():
    """
    Thread per il controllo della prossima pillola da erogare, aggiungendola alla lista 'daErogare'
    """
    while True:
        lockLista.acquire()
        if(len(lista) != 0): # se c'è una pillola per cui controllare l'ora
            lockRTC.acquire()
            while(len(lista) != 0 and (rtc.readHours() !=  lista[0][2][0:2] or rtc.readMinutes() != lista[0][2][3:5]) or (rtc.readDate() != lista[0][1][0:2] or rtc.readMonth() != lista[0][1][3:5] or rtc.readYear() != lista[0][1][6:10])):
                print(rtc.readTime()) 
                lockRTC.release()
                lockLista.release()
                sleep(1000)
                lockLista.acquire()
                if(len(lista) == 0):
                    break
                lockRTC.acquire()
            lockRTC.release()
            if(len(lista) != 0):
                lockLista.release()
                global avvioErogazione
                cvAvvioErogazione.acquire()
                lockDaErogare.acquire()
                lockLista.acquire()
                daErogare.append(lista.pop(0))
                lockDaErogare.release()
                avvioErogazione = True
                cvAvvioErogazione.notify()
                cvAvvioErogazione.release()
        lockLista.release()
        sleep(1000)

thread(checkOra)

def erogazione(dispenser):
    """
    Funzione che attiva lo StepperMotor in base al numero del dispenser passato come parametro.\nRestituisce 'true'
       ad erogazione effettuata
    """
    return stepper1.rotate(45) if dispenser == 0 else stepper2.rotate(45)

def attendoBicchiere():
    """
    Funzione che attende il posizionamento del bicchiere.\nRestituisce 'true' se presente
    """
    display.clearRow(1)
    display.write(0, 1, "Posizionare il bicchiere...")
    proximity.start()
    while (not(proximity.readProximity() >=  240 and proximity.readProximity() <= 255)):
        print(proximity.readProximity())
        sleep(250)
    proximity.stop()
    return True

# Inizio
updateDisplay() 
while True:
    cvAvvioErogazione.acquire()
    while(avvioErogazione == False):
        cvAvvioErogazione.wait()
    display.write(0, 1, "Pillola pronta per l'erogazione")
    pwm.write(buzzerPin, 1319, 1000, MICROS)
    gpio.set(ledPin, HIGH)
    if(checkHand(trigPin, echoPin)):
        display.clearRow(1)
        display.write(0, 1, "Erogo pillola...")
        lockDaErogare.acquire()
        if(erogazione(int(daErogare[0][3]))):
            lockDaErogare.release()
            pwm.write(buzzerPin, 0, 0, MICROS)
            gpio.set(ledPin, LOW)
            display.clearRow(1)
            display.write(0, 1, "Pillola erogata")
            sleep(2000)
            if(erogazioneAcquaRemota == "auto" and gpio.get(sensorLevelPin)):
                if(attendoBicchiere()):
                    display.clearRow(1)
                    display.write(0, 1, "Erogazione acqua...")
                    gpio.set(relayPin, HIGH)
                    sleep(4000)
                    gpio.set(relayPin, LOW)
                    display.clearRow(1)
                    display.write(0, 1, "Erogazione effettuata")
                    sleep(2000)
            else:
                display.clearRow(1)
                if(not(gpio.get(sensorLevelPin))):
                    display.write(0, 1, "Acqua terminata!")
                else:
                    display.write(0, 1, "Acqua non richiesta!")

                sleep(2000)
            lockDaErogare.acquire()
            item = daErogare.pop(0)
            lockDaErogare.release()
            print(item)
            updateStorico(item, True)
        else:
            lockDaErogare.release()
    else:
        pwm.write(buzzerPin, 0, 0, MICROS)
        gpio.set(ledPin, LOW)
        lockDaErogare.acquire()
        item = daErogare.pop(0)
        lockDaErogare.release()
        print(item)
        updateStorico(item, False)
    global changed
    changed = True
    updateDisplay()
    avvioErogazione = False
    cvAvvioErogazione.release()
    sleep(1000)