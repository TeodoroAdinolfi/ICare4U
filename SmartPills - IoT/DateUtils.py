
class DateUtils():

    def isBefore(self, date1, date2):
        """
        Parametri in ingresso nel formato "gg/mm/aaaa" \n Restituisce true se date1 precede date2, altrimenti false
        """
        g1 = int(date1[0:2])
        m1 = int(date1[3:5])
        a1 = int(date1[6:10])
        g2 = int(date2[0:2])
        m2 = int(date2[3:5])
        a2 = int(date2[6:10])
        if(a1 < a2):
            return True
        elif(a1 == a2 and m1 < m2):
            return True
        elif(a1 == a2 and m1 == m2 and g1 < g2):
            return True
        return False
    
    def isAfter(self, date1, date2):
        """
        Parametri in ingresso nel formato "gg/mm/aaaa" \n Restituisce true se date1 succede date2, altrimenti false
        """
        g1 = int(date1[0:2])
        m1 = int(date1[3:5])
        a1 = int(date1[6:10])
        g2 = int(date2[0:2])
        m2 = int(date2[3:5])
        a2 = int(date2[6:10])
        if(a1 > a2):
            return True
        elif(a1 == a2 and m1 > m2):
            return True
        elif(a1 == a2 and m1 == m2 and g1 > g2):
            return True
        return False

    def isEqual(self, date1, date2):
        """
        Parametri in ingresso nel formato "gg/mm/aaaa" \n Restituisce true se date1 è uguale a date2, altrimenti false
        """
        return int(date1[6:10]) == int(date2[6:10]) and int(date1[3:5]) == int(date2[3:5]) and int(date1[0:2]) == int(date2[0:2])