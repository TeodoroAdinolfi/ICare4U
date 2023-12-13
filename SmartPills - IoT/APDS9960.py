
import i2c

# APDS-9960 register addresses #
APDS9960_ENABLE         = 0x80
APDS9960_PDATA          = 0x9C

ADDRESS = 0X39

class APDS9960():

    def __init__(self):
        """
        Istanzia un oggetto I2C per comunicare con il dispositivo i2c connesso sull'indirizzo 0x39 sul bus I2C0, usando 
           come frequenza del clock 1000000 Hz.
        """
        self.port = i2c.I2c(ADDRESS)
        print("Device APDS9960 available on address " + hex(ADDRESS))
    
    def start(self):
        """
        Inizializza e abilita il dispositivo in modalità "PROXIMITY".
        """
        self.port.write(bytearray([APDS9960_ENABLE, 0x05])) 

    def readProximity(self):
        """
        Legge e ritorna dal registro APDS9960_PDATA il valore di prossimità misurato.
        """
        return self.port.write_read(bytearray([APDS9960_PDATA]), 1)[0]

    def stop(self):
        """
        Disabilita il dispositivo, portandolo in low energy state.
        """
        self.port.write(bytearray([APDS9960_ENABLE, 0x00])) 