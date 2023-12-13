
import i2c
import serial

serial.serial()

def bcdToInt(bcd):
    """
    Decodifica un 2x4bit BCD in un intero.
    """
    out = 0
    for d in (bcd >> 4, bcd):
        for p in (1, 2, 4 ,8):
            if d & 1:
                out += p
            d >>= 1
        out *= 10
    return out / 10

def intToBcd(n):
    """
    Codifica un numero composto da una o due cifre in BCD.
    """
    bcd = 0
    for i in (n // 10, n % 10):
        for p in (8, 4, 2, 1):
            if i >= p:
                bcd += 1
                i -= p
            bcd <<= 1
    return bcd >> 1

class DS1307():

    ADDRESS = 0x68

    _REG_SECONDS = 0x00
    _REG_MINUTES = 0x01
    _REG_HOURS = 0x02
    _REG_DAY = 0x03
    _REG_DATE = 0x04
    _REG_MONTH = 0x05
    _REG_YEAR = 0x06
    _REG_CONTROL = 0x07

    def __init__(self):
        """
        Istanzia un oggetto I2C per comunicare con il dispositivo i2c connesso sull'indirizzo 0x68 sul bus I2C0, usando 
           come frequenza del clock 1000000 Hz. Inoltre, abilita l'oscillatore scrivendo 0x00 nel _REG_SECONDS.
        """
        self.port = i2c.I2c(self.ADDRESS)
        self.port.write(bytearray([self._REG_SECONDS, 0x00]))
        print("Device DS1307 available on address " + hex(self.ADDRESS))
         
    def writeAll(self, seconds = None, minutes = None, hours = None, day = None, date = None, month = None, year = None):
        """
        Ottiene in ingresso i valori di inizializzazione e configura il dispositivo.
        """
        if seconds is not None:
            if seconds < 0 or seconds > 59:
                raise ValueError('Seconds is out of range [0,59].')
            self.port.write(bytearray([self._REG_SECONDS, intToBcd(seconds)]))

        if minutes is not None:
            if minutes < 0 or minutes > 59:
                raise ValueError('Minutes is out of range [0,59].')
            self.port.write(bytearray([self._REG_MINUTES, intToBcd(minutes)]))

        if hours is not None:
            if hours < 0 or hours > 23:
                raise ValueError('Hours is out of range [0,23].')
            self.port.write(bytearray([self._REG_HOURS, intToBcd(hours)]))  

        if year is not None:
            if year < 0 or year > 99:
                raise ValueError('Years is out of range [0,99].')
            self.port.write(bytearray([self._REG_YEAR, intToBcd(year)]))

        if month is not None:
            if month < 1 or month > 12:
                raise ValueError('Month is out of range [1,12].')
            self.port.write(bytearray([self._REG_MONTH, intToBcd(month)]))

        if date is not None:
            if date < 1 or date > 31:
                raise ValueError('Date is out of range [1,31].')
            self.port.write(bytearray([self._REG_DATE, intToBcd(date)]))

        if day is not None:
            if day < 1 or day > 7:
                raise ValueError('Day is out of range [1,7].')
            self.port.write(bytearray([self._REG_DAY, intToBcd(day)]))

    def readSeconds(self):
        """
        Legge i secondi dal registro _REG_SECONDS
        """
        s = int(bcdToInt(self.port.write_read(bytearray([self._REG_SECONDS]), 1)[0]))
        return "0"+str(s) if (s >= 0 and s <=9) else str(s)

    def readMinutes(self):
        """
        Legge i minuti dal registro _REG_MINUTES
        """
        m = int(bcdToInt(self.port.write_read(bytearray([self._REG_MINUTES]), 1)[0]))
        return "0"+str(m) if (m >= 0 and m <=9) else str(m)

    def readHours(self):
        """
        Legge le ore dal registro _REG_HOURS
        """
        h = int(bcdToInt(self.port.write_read(bytearray([self._REG_HOURS]), 1)[0] & 0x3F))
        return "0"+str(h) if (h >= 0 and h <=9) else str(h)

    def readTime(self):
        """
        Restituisce l'ora attuale nel formato HH:mm:ss
        """
        return self.readHours() + ":" + self.readMinutes() + ":" + self.readSeconds()

    def readDate(self):
        """
        Legge il giorno dal registro _REG_DATE
        """
        d = int(bcdToInt(self.port.write_read(bytearray([self._REG_DATE]), 1)[0]))
        return "0"+str(d) if (d >= 0 and d <=9) else str(d)
    
    def readMonth(self):
        """
        Legge il mese dal registro _REG_MONTH
        """
        m = int(bcdToInt(self.port.write_read(bytearray([self._REG_MONTH]), 1)[0]))
        return "0"+str(m) if (m >= 0 and m <=9) else str(m)

    def readYear(self):
        """
        Legge l'anno dal registro _REG_YEAR
        """
        y = int(bcdToInt(self.port.write_read(bytearray([self._REG_YEAR]), 1)[0]))
        return "200"+str(y) if (y >= 0 and y <=9) else "20"+str(y)
    
    def readData(self):
        """
        Restituisce la data attuale nel formato dd/MM/yyyy
        """
        return self.readDate() + "/" + self.readMonth() + "/" + self.readYear()
    
    