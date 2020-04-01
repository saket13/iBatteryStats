import os
import sys, time
from datetime import date, timedelta, datetime
import rumps, json
join = os.path.join

#Enter the absolute address of the file here and leave everything as it
log_file_path = '/Users/saket/Downloads/iBatteryStats/back.log'


class App(rumps.App):

    def __init__(self):                                 
        super(App, self).__init__("🔋")                    #Adding different menu items that will display different parameters of the battery
        self.menu.add(rumps.MenuItem(title='Charge'))
        self.menu.add(rumps.MenuItem(title='Cells'))
        self.menu.add(rumps.MenuItem(title='Time'))
        self.menu.add(rumps.MenuItem(title='Temperature'))
        self.menu.add(rumps.MenuItem(title='Cycles'))
        self.menu.add(rumps.MenuItem(title='Max_Capacity'))
        self.menu.add(rumps.MenuItem(title='Serial'))
        self.menu.add(rumps.MenuItem(title='Age'))
        self.menu.add(rumps.separator)                                      #Adds a separator in the menu  
        self.menu.add(rumps.MenuItem(title='Contact_Me'))
        #rumps.debug_mode(True)
    
    def refresh_status(self):
        """Refresh information on menu bar."""
        #Changing the title of the menu bar items to show the values rendered by the get_values() function 

        self.menu['Charge'].title, self.menu['Cells'].title, self.menu['Time'].title, self.menu['Temperature'].title, self.menu['Cycles'].title, self.menu['Max_Capacity'].title, self.menu['Serial'].title, self.menu['Age'].title = self.get_values()
        if (self.menu['Charge'].title == "Charge Left::  "+str(15)+ " %" or self.menu['Charge'].title == "Charge Left::  "+str(10)+ " %" and self.menu['Cells'].title[0] == "D"):
            rumps.notification("iBatteryStats", "Notification", " ⚡️ Charge Your Mac ⚡️")
        self.title= self.menu['Cells'].title[11:]


    def get_values(self):
        
        # Opens the file which contains the battery logs and making it in readabel status
        file1= open(log_file_path, 'r')
        d=[]
        for line in file1:
            d.append(line.strip('\n'))

        #Storing all the variables of the battery in a string format to return it to the refresh_status() function
            
        PERCENT, CELLS= d[0].split(' ')
        CHARGE= "Charge Left::  "+str(PERCENT)+ " %"
        CELLS = str(d[1])+ str(CELLS)
        TIME_INFO= "Time Left::  "+str(d[2])
        TEMPERATURE="Temperature::  "+ str(d[3])
        CYCLE_COUNT= "Cycles::  "+str(d[4])
        MAX_CAPACITY= "Max Capacity::  "+str(d[5])+ " mAh"
        SERIAL= "Serial:: "+str(d[6])
        AGE= "Age:: "+str(d[7])+ " months"

        
        return CHARGE, CELLS, TIME_INFO, TEMPERATURE, CYCLE_COUNT, MAX_CAPACITY, SERIAL, AGE

    @rumps.timer(60)                # Used to callback() function refresh_status()  every 60 seconds 
    def get_stats(self, sender):
        """ Timer """
        # sender = self.menu['Air!']  # if action no bind on clicked action

        def counter(t):
            self.refresh_status()

        # if bind on clicked action
        # set_timer = rumps.Timer(callback=counter, interval=60 )
        # set_timer.start()

        counter(None)        
        
    @rumps.clicked("Contact_Me")
    def Contact_Me(self, _):
        """ clicked contact me button." """
        
        show_window = rumps.Window(
            message='All area name',
            title='Area List',
            default_text='Fork This Project at : https://github.com/saket13/iBatteryStats' + '\n'+ 'Know more about me: www.saketsaumya.me',
            ok=None,
            dimensions=(300, 300)
        )

        show_window.run()    


if __name__ == '__main__':
    #output= get_values()
    #prRed('Calculating ::')
    #for key in output:
    #    prGreen ('{} :: {}'.format(key, output[key]))
    myapp = App()
    myapp.run()
