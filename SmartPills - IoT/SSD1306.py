
import i2c

# Constants
SSD1306_I2C_ADDRESS = 0x3C   
SSD1306_SETCONTRAST = 0x81
SSD1306_DISPLAYALLON_RESUME = 0xA4
SSD1306_DISPLAYALLON = 0xA5
SSD1306_NORMALDISPLAY = 0xA6
SSD1306_INVERTDISPLAY = 0xA7
SSD1306_DISPLAYOFF = 0xAE
SSD1306_DISPLAYON = 0xAF
SSD1306_SETDISPLAYOFFSET = 0xD3
SSD1306_SETCOMPINS = 0xDA
SSD1306_SETVCOMDETECT = 0xDB
SSD1306_SETDISPLAYCLOCKDIV = 0xD5
SSD1306_SETPRECHARGE = 0xD9
SSD1306_SETMULTIPLEX = 0xA8
SSD1306_SETLOWCOLUMN = 0x00
SSD1306_SETHIGHCOLUMN = 0x10
SSD1306_SETSTARTLINE = 0x40
SSD1306_MEMORYMODE = 0x20
SSD1306_COLUMNADDR = 0x21
SSD1306_PAGEADDR = 0x22
SSD1306_COMSCANINC = 0xC0
SSD1306_COMSCANDEC = 0xC8
SSD1306_SEGREMAP = 0xA0
SSD1306_CHARGEPUMP = 0x8D
SSD1306_EXTERNALVCC = 0x1
SSD1306_SWITCHCAPVCC = 0x2

# Scrolling constants
SSD1306_ACTIVATE_SCROLL = 0x2F
SSD1306_DEACTIVATE_SCROLL = 0x2E
SSD1306_SET_VERTICAL_SCROLL_AREA = 0xA3
SSD1306_RIGHT_HORIZONTAL_SCROLL = 0x26
SSD1306_LEFT_HORIZONTAL_SCROLL = 0x27
SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL = 0x29
SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL = 0x2A

# Font utilizzato per la visualizzazione dei caratteri, mediante il quale ogni singolo carattere è composto da 4 numeri.
FONT = (b'\x00\x00\x00\x00\x00^\x00\x00\x06\x00\x06\x00~$~\x00,~4\x00b\x18F'
        b'\x004Jt\x00\x00\x06\x00\x00<BB\x00BB<\x00*\x1c*\x00\x08\x1c\x08\x00'
        b'@0\x00\x00\x08\x08\x08\x00\x00@\x00\x00`\x18\x06\x00<"\x1e\x00\x04>'
        b'\x00\x00:*.\x00**>\x00\x0e\x08>\x00.*:\x00>*:\x00\x02\x02>\x00>*>'
        b'\x00.*>\x00\x00\x14\x00\x00@4\x00\x00\x08\x14"\x00\x14\x14\x14\x00"'
        b'\x14\x08\x00\x02Z\x0e\x00~Z^\x00>\n>\x00>*4\x00>"6\x00>"\x1c\x00>*"'
        b'\x00>\n\x02\x00>":\x00>\x08>\x00">"\x000 >\x00>\x086\x00>  \x00>\x04'
        b'>\x00>\x02>\x00>">\x00>\n\x0e\x00>"~\x00>\x1a.\x00.*:\x00\x02>\x02'
        b'\x00> >\x00\x1e0\x1e\x00>\x10>\x006\x086\x00\x0e8\x0e\x002*&\x00~BB'
        b'\x00\x06\x18`\x00BB~\x00\x0c\x06\x0c\x00@@@@\x00\x02\x04\x004,<\x00>'
        b'$<\x00<$$\x00<$>\x00<4,\x00\x08~\n\x00\\T|\x00>\x04<\x00\x08: \x00`H'
        b'z\x00>\x084\x00\x02> \x00<\x1c<\x00<\x04<\x00<$<\x00|$<\x00<$|\x00<'
        b'\x04\x0c\x00,,4\x00\x04>$\x00< <\x00\x1c \x1c\x00<0<\x004\x084\x00\\'
        b'P|\x004,$\x00\x08vB\x00\x00~\x00\x00Bv\x08\x00\x10*\x04\x00')

class SSD1306():

    def  __init__(self):
        """
        Istanzia un oggetto I2C per comunicare con il dispositivo i2c connesso sull'indirizzo 0x3C sul bus I2C0, usando 
           come frequenza del clock 1000000 Hz. Dopodichè, l'inizializzazione del modulo SSD1306 procede con la configurazione di tutti i parametri del display associati, indicati
           tramite le costanti sopra definite ed inviati tramite l'istruzione write come comandi attraverso il command register identificato dall'indirizzo 0x00. Essendo il display 128x64, la configurazione
           è stata effettuata basandosi su queste dimensioni.
        """

        self.port = i2c.I2c(SSD1306_I2C_ADDRESS)
        self.port.write(bytearray([0x00,SSD1306_DISPLAYOFF]))                    # 0xAE
        self.port.write(bytearray([0x00,SSD1306_SETDISPLAYCLOCKDIV]))            # 0xD5
        self.port.write(bytearray([0x00,0x80]))                                  # suggerito: 0x80
        self.port.write(bytearray([0x00,SSD1306_SETMULTIPLEX]))                  # 0xA8
        self.port.write(bytearray([0x00,0x3F]))
        self.port.write(bytearray([0x00,SSD1306_SETDISPLAYOFFSET]))              # 0xD3
        self.port.write(bytearray([0x00,0x00]))                                   # no offset
        self.port.write(bytearray([0x00,SSD1306_SETSTARTLINE | 0x0]))            # line #0
        self.port.write(bytearray([0x00,SSD1306_CHARGEPUMP]))                    # 0x8D
        self.port.write(bytearray([0x00,0x14]))
        self.port.write(bytearray([0x00,SSD1306_MEMORYMODE])) # 0x20
        self.port.write(bytearray([0x00,0x00])) 
        self.port.write(bytearray([0x00,SSD1306_SEGREMAP | 0x1]))
        self.port.write(bytearray([0x00,SSD1306_COMSCANDEC])) # 0x20
        self.port.write(bytearray([0x00,SSD1306_SETCOMPINS]))
        self.port.write(bytearray([0x00,0x12]))
        self.port.write(bytearray([0x00,SSD1306_SETCONTRAST]))# 0x81
        self.port.write(bytearray([0x00,0xCF]))
        self.port.write(bytearray([0x00,SSD1306_SETPRECHARGE]))                 # 0xd9
        self.port.write(bytearray([0x00,0xF1]))
        self.port.write(bytearray([0x00,SSD1306_SETVCOMDETECT]))                 # 0xDB
        self.port.write(bytearray([0x00,0x40]))
        self.port.write(bytearray([0x00,SSD1306_DISPLAYALLON_RESUME]))
        self.port.write(bytearray([0x00,SSD1306_NORMALDISPLAY]))
        self.port.write(bytearray([0x00,SSD1306_DISPLAYON]))
       

        self.port.write(bytearray([0x00,SSD1306_DEACTIVATE_SCROLL]))

        self.port.write(bytearray([0x00,SSD1306_COLUMNADDR]))
        self.port.write(bytearray([0x00,0])) # Indirizzo di partenza per le colonne (0 = reset)
        self.port.write(bytearray([0x00,63])) # Indirizzo finale per le colonne

        self.port.write(bytearray([0x00,SSD1306_PAGEADDR]))
        self.port.write(bytearray([0x00,0])) # Indirizzo di partenza per le pagine (0 = reset)
        self.port.write(bytearray([0x00,64//8 -1])) # Indirizzo finale per le pagine

        # Punto di partenza per la scrittura: riga 0 , colonna 0.
        self.row = 0
        self.col = 0
    
    def clear(self):
        """
        La funzione clear è adibita alla pulizia del buffer del display. Mediante un operazione di write, tramite il command 
        register (0x00), agli indirizzi 0xB- (con - compreso nel range 0-7), è possibile posizionarsi su una delle 8 pagine 
        (righe) che contraddistinguono il display. Dopodichè mediante 8 costrutti di iterazione, ognuno dei quali a sua volta 
        compie 1024 iterazioni (essendo la dimensione di ogni riga composta da 128*8 pixel), viene effettuata un operazione di 
        scrittura del valore 0 (mediante il data register contraddistinto dall'indirizzo 0x40), il quale porterà essendo lo 
        scorrimento del cursore sulla riga automatico, alla pulizia della riga specificata dall'indirizzo della pagina selezionata. 
        """

        self.port.write(bytearray([0x00,0xB0]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB1]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB2]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB3]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB4]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB5]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB6]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

        self.port.write(bytearray([0x00,0xB7]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

    def clearRow(self, row):
        """
        La funzione riceve in ingresso il parametro row indicante la riga su cui posizionasi ed è adibita alla pulizia del buffer
        relativo alla specifica riga passata. Il posizionamento avviene mediante un operazione di write all'indirizzo indirizzi
        0xB0 messo in or con il valore row (ottendo uno de valori compresi nel range 0xB0-0xB7) e successivamente viene effettuata
        un operazione di scrittura del valore 0 su tutti i 1024 pixel che contraddistinguono la riga selezionata. 
        """

        self.port.write(bytearray([0x00,0xB0 | row]))
        for i in range(1024):
            self.port.write(bytearray([0x40,0]))

    def move(self, x, y):
        """
        La funzione riceve in ingresso i parametri x ed y che indicano rispettivamente la riga e la colonna scelta ed è adibita 
        al posizionamento del cursore sulla specifica riga e alla specifica colonna selezionata. Le successive operazioni di 
        write effettuate sul buffer costruito sono finalizzate al posizionamento effettivo del cursore del display. 
        """

        x +=2
        buffer = bytearray(3)
        buffer[0] = 0xB0 | y
        buffer[1] = x & 0x0f
        buffer[2] = 0x10 | (x >> 4) & 0x0f
        for i in range(len(buffer)):
            self.port.write(bytearray([0x00,buffer[i]]))

    def letter(self,c):
        """
        La funzione riceve in ingresso un carattere e, essendo quest'ultimo composto da 4 numeri, genera l'indice indicante la 
        sua posizione nel buffer 'FONT' e preleva da quest'ultimo i primi 4 valori a partire dall'indice stesso generato. 
        Dopodichè, mediante un operazione di scrittura dati attraverso il data register, il carattere viene scritto sul display.
        """

        index = min(95, max(0, ord(c) - 32)) * 4
        buffer = FONT[index:index + 4]
        for i in range(len(buffer)):
            self.port.write(bytearray([0x40,buffer[i]]))

    def write(self, x, y, stringa):
        """ 
        La funzione riceve in ingresso tre parametri, i quali indicano rispettivamente la riga su cui posizionarsi, la colonna 
        su cui posizionarsi e la stringa da visualizzare a schermo. Dopodichè mediante un iterazione effettuata sulla string per 
        accedere ad ogni carattere, ognuno di quest'ultimo viene inviato alla funzione letter, e succesivamente viene incrementato 
        l'indice di colonna. Quando quest'ultimo supera il valore soglia, viene riportato a 0 e si passa alla riga (pagina 
        successiva) , richiamando la funzione move con i parametri aggiornati. 
        """

        self.move(x,y)
        for c in stringa:
            self.letter(c)
            x += 1
            if x >= 128:
                x = 0
                y += 1
                if y >= 7:
                    y = 0
                self.move(x, y)

    def invertDisplayColor(self):
        """
        La funzione è adibita all'inversione dei colori del display. 
        """

        self.port.write(bytearray([0x00,SSD1306_INVERTDISPLAY]))

    def activateScroll(self):
        """ 
        La funzione è adibita all'attivazione dello scorrimento del testo. 
        """

        self.port.write(bytearray([0x00,SSD1306_ACTIVATE_SCROLL]))

    def deactivateScroll(self):
        """
        La funzione è adibita alla disattivazione dello scorrimento del testo. 
        """

        self.port.write(bytearray([0x00,SSD1306_DEACTIVATE_SCROLL]))

    def displayOn(self):
        """
        La funzione è adibita all'attivazione del display. 
        """

        self.port.write(bytearray([0x00,SSD1306_DISPLAYON]))

    def displayOff(self):
        """
        La funzione è adibita alla disattivazione del display. 
        """

        self.port.write(bytearray([0x00,SSD1306_DISPLAYOFF]))
