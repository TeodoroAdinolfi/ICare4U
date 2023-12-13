
import gpio

class StepperMotor():

    def __init__(self, in1, in2, in3, in4):
        """
        Inizializza il dispositivo, prendendo in ingresso i seguenti parametri:
            • in1: pin di OUTPUT MotorDriver
            • in2: pin di OUTPUT MotorDriver
            • in3: pin di OUTPUT MotorDriver
            • in4: pin di OUTPUT MotorDriver
        """
        self.in1 = in1
        self.in2 = in2
        self.in3 = in3
        self.in4 = in4
        gpio.mode(self.in1, OUTPUT)
        gpio.mode(self.in2, OUTPUT)
        gpio.mode(self.in3, OUTPUT)
        gpio.mode(self.in4, OUTPUT)

    def rotate(self, degree):
        """
        Permette allo stepper motor di ruotare del numero di gradi specificato. La velocità di rotazione è fissata.
        """
        temp = (512*degree)/360
        for i in range(int(temp)):
            gpio.set(self.in1, HIGH)
            gpio.set(self.in2, HIGH)
            gpio.set(self.in3, LOW)
            gpio.set(self.in4, LOW)
            sleep(5)
            gpio.set(self.in1, LOW)
            gpio.set(self.in2, HIGH)
            gpio.set(self.in3, HIGH)
            gpio.set(self.in4, LOW)
            sleep(5)
            gpio.set(self.in1, LOW)
            gpio.set(self.in2, LOW)
            gpio.set(self.in3, HIGH)
            gpio.set(self.in4, HIGH)
            sleep(5)
            gpio.set(self.in1, HIGH)
            gpio.set(self.in2, LOW)
            gpio.set(self.in3, LOW)
            gpio.set(self.in4, HIGH)
            sleep(5)
        gpio.set(self.in1, LOW)
        gpio.set(self.in2, LOW)
        gpio.set(self.in3, LOW)
        gpio.set(self.in4, LOW)
        sleep(5)
        return True
    

