
class TimeUtils():

    def isBefore(self, time1, time2):
        """
        Parametri in ingresso nel formato "hh:mm" \n Restituisce true se time1 precede time2, altrimenti false
        """
        h1 = int(time1[0:2])
        m1 = int(time1[3:5])
        h2 = int(time2[0:2])
        m2 = int(time2[3:5])
        if(h1 < h2):
            return True
        elif(h1 == h2 and m1 <= m2):
            return True
        return False
    
    def isAfter(self, time1, time2):
        """
        Parametri in ingresso nel formato "hh:mm" \n Restituisce true se time1 succede time2, altrimenti false
        """
        h1 = int(time1[0:2])
        m1 = int(time1[3:5])
        h2 = int(time2[0:2])
        m2 = int(time2[3:5])
        if(h1 > h2):
            return True
        elif(h1 == h2 and m1 > m2):
            return True
        return False
    
    def isEqual(self, time1, time2):
        """
        Parametri in ingresso nel formato "hh:mm" \n Restituisce true se time1 è uguale a time2, altrimenti false
        """
        return int(time1[0:2]) == int(time2[0:2]) and int(time1[3:5]) == int(time2[3:5])
