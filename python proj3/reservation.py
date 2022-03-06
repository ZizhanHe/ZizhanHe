#name: Herbie He
#ID: 260943211
import datetime
import random
from room import *

class Reservation:
    #instance: booking_num(int), name(str), room_reserved(Room),
    #checkin date(date), checkout date(date)
    booking_numbers=[]
    def __init__(self,name, room_reserved, check_in, check_out,booking_num=None):
        #reserves the room for the dates
        if not room_reserved.is_available(check_in, check_out):
            raise AssertionError('The room is not available at the specified dates')
    #check that booking num is qualified
    #if not then generate new bk num
        if booking_num != None:
            if booking_num in self.booking_numbers:
                raise AssertionError('Inputed booking number has been already used')
            if len(booking_num) != 13:
                raise AssertionError('Booking number must be 13 digit long')
            if str(booking_num)[0] ==0:
                raise AssertionError('Booking number cannot start with 0')
        while (booking_num==None) or (str(booking_num)[0]==0) or (booking_num in self.booking_numbers):
            booking_num=random.randint(1000000000000,9999999999999)
        #initialize
        self.name=str(name)
        self.room_reserved=room_reserved
        self.check_in=check_in
        self.check_out=check_out
        self.booking_number=int(booking_num)
        #update class atributes
        self.booking_numbers.append([booking_num])
        #use a for loop to reserve_room for every night
        date_obj=check_in
        diff=check_out-check_in
        #does not need to reserve room for check_out day
        for i in range(diff.days):
            self.room_reserved.reserve_room(date_obj)
            try:
                day1=date_obj.day
                day1 += 1
                date_obj=datetime.date(date_obj.year,date_obj.month,day1)
            #date is out of range
            except ValueError:
                try:
                    month1=date_obj.month
                    month1 +=1
                    day1=date_obj.day
                    day1=1
                    date_obj=datetime.date(date_obj.year,month1,day1)
                #Month is out of range
                except ValueError:
                    year1=date_obj.year
                    year1 +=1
                    month1=date_obj.month
                    month1 =1
                    date_obj=datetime.date(year1 ,month1, 1)

    def __str__(self):
        list_of_info=[]
        #bk num
        list_of_info.append('Booking number: '+str(self.booking_number))
        #name
        list_of_info.append('Name: '+self.name)
        #room
        list_of_info.append('Room reserved: '+str(self.room_reserved))
        #checkin
        list_of_info.append('Check-in date: ' + str(self.check_in))
        #checkout
        list_of_info.append('Check-out date: ' + str(self.check_out))
        return '\n'.join(list_of_info)
    
    def to_short_string(self):
        return(str(self.booking_number)+'--'+self.name)
    
    @classmethod
    def from_short_string(cls, string1, checkin_date, checkout_date,room1):
        #creates reservation objects from short string
        booking_number,name=string1.split('--')
        return cls(name,room1,checkin_date, checkout_date, booking_number)
    
    @staticmethod
    def get_reservations_from_row(room, tuples_info):
        #takes in a room and list of tuples (year, mon, day, 'str_info'), returns a dict mapping
        #bk num to reservations
        #make reservation for a room
        #create a dictionary where key is booking number and value is the [string_info, checkin, checkout
        #returns a diction mappting bk num -> reserv object
        #there can be multiple bookings in a month for the same room
        dict_booking_date={}
        for year, month, day, string_info in tuples_info:
            date=datetime.date(int(year),int(MONTHS.index(month)+1),int(day))
            if string_info != '':
                booking_number,name=string_info.split('--')
                if booking_number not in dict_booking_date.keys():
                    dict_booking_date[booking_number]=[string_info,date]
                else:
                    dict_booking_date[booking_number].append(date)
        dict_bk_reser={}
        for key in dict_booking_date:
            #determine the max and min
            last_day=max(dict_booking_date[key][1:])
            try:
                checkout=datetime.date(last_day.year, last_day.month, (last_day.day+1))
            except ValueError:
                try:
                    checkout=datetime.date(last_day.year, (last_day.month+1), 1)
                except ValueError:
                    checkout=datetime.date((last_day.year+1),1,1)
            checkin=min(dict_booking_date[key][1:])
            dict_bk_reser[int(key)]=Reservation.from_short_string(dict_booking_date[key][0], checkin, checkout, room)
        return dict_bk_reser
    

#random.seed(987)
#Reservation.booking_numbers = []
#r1 = Room("Queen", 105, 80.0)
#r1.set_up_room_availability(MONTHS, 2021)
#rsv_strs = [(2021, 'May', 3, '1953400675629--Jack'), (2021, 'May', 4, '1953400675629--Jack')]
#rsv_dict = Reservation.get_reservations_from_row(r1, rsv_strs)
#print(rsv_dict[1953400675629])


