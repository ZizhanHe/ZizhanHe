#Name:Herbie He
#ID: 260943211
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
DAYS_PER_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
import datetime

class Room:
    #instance attributes:
    #roome_type (str), room_num(int), price (flt) avaliability (dict)
    @classmethod
    def TYPES_OF_ROOMS_AVAILABLE(cls):
        return ['twin','double','queen','king']
    
    def __init__(self, room_type, room_num, room_price, ava={}):
        #input validation
        if (type(room_type) != str) or (type(room_num) != int) or (type(room_price) != float) or (type(ava) != dict):
            raise AssertionError('Input values must be the correct type (room_type - str, room_num- int, room_price - float, ava - dict)')
        room_ava=['twin','double','queen','king']
        if room_type.lower() not in room_ava:
            raise AssertionError('room type must be one of \'twin, double, queen, king\'')
        if  room_num <= 0:
            raise AssertionError('room number must be a postive integer')
        if room_price <0:
            raise AssertionError('room price cannot be negative')
        self.room_type=str(room_type)
        self.room_num=int(room_num)
        self.price=float(room_price)
        self.availability={}
        for key in ava:
            self.availability[key]=ava[key][:]

    def __str__ (self):
        #'room num, room type, price
        list_info=['Room '+str(self.room_num),self.room_type,str(self.price)]
        return ','.join(list_info)

    def set_up_room_availability(self,months,year):
        new_dict={}
        list_of_tup=[]
        for month in months:
            list_of_tup.append((year, MONTHS.index(month)+1))
        is_leap= False
        if year%4==0:
            is_leap=True
            if year%100 ==0 and year%400 != 0:
                is_leap=False
        for key in list_of_tup:
            days=DAYS_PER_MONTH[key[1]-1]
            list_bool_days=[None]
            if key[1] == 2 and is_leap:
                for i in range(29):
                    list_bool_days.append(True)
            else:    
                for i in range(days):
                    list_bool_days.append(True)
            new_dict[key]=list_bool_days
        for key in new_dict:
            self.availability[key]=new_dict[key]
    
    def reserve_room(self, date_obj):
        day=date_obj.day
        month=date_obj.month
        year=date_obj.year
        key=(year,month)
        #if data for this month and year is not availabile
        if key not in self.availability.keys():
            raise AssertionError('The room is not available at given date')
        #if the room is already reserved
        if self.availability[key][day] == False:
            raise AssertionError('The room is not avaliable at given date')
        self.availability[key][day]=False
        
    def make_available(self, date_obj):
        day=date_obj.day
        month=date_obj.month
        year=date_obj.year
        key=(year,month)
        self.availability[key][day]=True

    ###
    def is_available(self, checkIn, checkOut):
         #check the first date is eariler than the other
        if checkIn >= checkOut:
            raise AssertionError('The first date should be earlier than the second date')
        key_checkin=(checkIn.year,checkIn.month)
        key_checkout=(checkOut.year,checkOut.month)
        #find month difference
        if checkOut.year>checkIn.year:
            month_diff=(12-checkIn.month)+(checkOut.year-(checkIn.year+1))*12+checkOut.month-1
        else:
            month_diff=(checkOut.month-checkIn.month)-1
        #create a list of keys with (year, month)
        list_keys_between=[key_checkin]
        month_key=checkIn.month
        year_key=checkIn.year
        for i in range(month_diff):
            if month_key<12:
                month_key +=1
                new_key=(year_key,month_key)
            else:
                year_key +=1
                month_key=1
                new_key=(year_key,month_key)
            list_keys_between.append(new_key)
        list_keys_between.append(key_checkout)
        #check availability
        for key in list_keys_between:
            if key not in self.availability.keys():
                return False
        #new list that record the availability of all nights
        new_list_days=[]
        for key in list_keys_between:
            #check in day
            if list_keys_between.index(key)==0:
                days=self.availability[key][checkIn.day:][:]
            #check out day
            elif key ==list_keys_between[-1]:
                days=self.availability[key][ : checkOut.day][:]
            else:
                days=self.availability[key][:]
            new_list_days.append(days)
        for days in new_list_days:
            for day in days:
                if day == False:
                    return False
        return True

    @staticmethod
    def find_available_room(list_room,room_type, date1, date2):
        #find room in list_room that are the requested room_type and ava, and returns the first match
        if date2 <= date1:
            raise AssertionError('Check in date must be eailer than check out date')
        room_ava=[]
        for room in list_room:
            if room.room_type==room_type and room.is_available(date1,date2):
                return room
        return None

