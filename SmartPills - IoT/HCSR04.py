
import gpio
import time
import timers

class HCSR04:

    def __init__(self, trigPin, echoPin, timeout=30):
        """
        Inizializza il dispositivo, prendendo in ingresso i seguenti parametri:
            • trigPin: pin di OUTPUT che invia gli impulsi
            • echoPin: pin di INPUT che rileva gli impulsi ricevuti
            • timeout: timeout in ms per ascoltare l'echoPin (di default è posto a 30)
        """
        
        self.trigPin = trigPin
        self.echoPin = echoPin
        self.timeout = timeout

        gpio.mode(self.trigPin, OUTPUT)
        gpio.mode(self.echoPin, INPUT)

        gpio.set(self.trigPin, LOW)
        sleep(2)

    def measure(self):
        """
        Ritorna la distanza misurata in cm.
        
        La distanza viene calcolata cronometrando un impulso dal sensore, indicando per quanto tempo il sensore ha inviato un 
        segnale ultrasonico e quando è tornato indietro ed è stato ricevuto. Se non viene ricevuto alcun segnale, verrà 
        generata un'eccezione RuntimeError. Ciò significa che il sensore si stava muovendo troppo velocemente per puntare nella 
        giusta direzione per captare il segnale ultrasonico quando è rimbalzato indietro, oppure l'oggetto da cui il segnale è 
        rimbalzato è troppo lontano per essere gestito dal sensore.
        """

        gpio.set(self.trigPin, HIGH)
        sleep(10, MICROS)
        gpio.set(self.trigPin, LOW)

        echoState = 0
        pulse_duration = None 
        myTimer = timers.Timer()

        myTimer.start()

        while(echoState == 0):
            if(myTimer.get() > self.timeout):
                myTimer.destroy()
                raise RuntimeError("Timed out")
            echoState = gpio.get(self.echoPin)
            pulse_start = time.time()

        myTimer.destroy()

        while(echoState == 1):
            echoState = gpio.get(self.echoPin)
            pulse_end = time.time()
 
        pulse_duration = pulse_end - pulse_start

        distance = pulse_duration*17150
        distance = round(distance, 2)

        if(distance < 2 or distance > 400):
            raise ValueError("Invalid value")

        return distance

