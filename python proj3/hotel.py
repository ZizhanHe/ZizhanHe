#Name: Herbie He
#ID:260943211
import datetime
import random
import copy
import os
from room import *
from reservation import *

class Hotel:
    #Instances: Name(str), rooms( list of room),
    #reservations( dict mapping bking numvers to reservation objects
    def __init__(self, name, list_rooms=[], dict_bknum_res={}):
        self.name=name
        #r1 and self.rooms[0] refers to two different room object!
        self.rooms=copy.deepcopy(list_rooms)
        self.reservations=copy.deepcopy(dict_bknum_res)
    def make_reservation(self, name_p, desired_room, checkin, checkout):
        #takes desired room type and make reservation, return bk num, and update self.reservations
        match=Room.find_available_room(self.rooms, str(desired_room), checkin, checkout)
        if match != None:
            reserve=Reservation(str(name_p), match, checkin, checkout)
            self.reservations[reserve.booking_number]=reserve
            return reserve.booking_number
        else:
            raise AssertionError('No room for this type is available')
    
    def get_receipt(self, list_bknum):
        #takes in a list of bk num, and returns the total sum of the price
        #first create a list of reservations
        resers=[]
        for booking_num in list_bknum:
            try:
                resers.append(self.reservations[booking_num])
            except KeyError:
                continue
        #for loop through resers and calculate price
        if len(resers)==0:
            return 0.0
        price=0
        for reservation in resers:
            room1=reservation.room_reserved
            price_room=room1.price
            checkin=reservation.check_in
            checkout=reservation.check_out
            diff=checkout-checkin
            total_price=diff.days * price_room
            price += total_price
        return price
    
    def get_reservation_for_booking_number(self, booking_num):
        return self.reservations[booking_num]

    def cancel_reservation(self, booking_num):
        #make self.rooms[0/1..] available, and cancel self.reservations[bk num]
        #first find the reservation
        try:
            reserv=self.reservations[booking_num]
        except KeyError:
            return None
        #make the room available
        checkin=reserv.check_in
        checkout=reserv.check_out
        date_obj=checkin
        diff=checkout-checkin
        for i in range(diff.days):
            reserv.room_reserved.make_available(date_obj)
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
        #cancel self.reservation
        self.reservations.pop(booking_num)
    
    def get_available_room_types(self):
        #returns a list of room types in the hotel
        #get list_of_rooms
        list_of_rooms=self.rooms
        #create a list of room types
        room_types=[]
        for room in list_of_rooms:
            if room.room_type not in room_types:
                room_types.append(room.room_type)
        return room_types
    
    @staticmethod
    def load_hotel_info_file(file_path):
        #loads a file of hotel info, returns a tuple of hotel name and a list
        #of room objects
        fobj=open(file_path,'r')
        list_rooms=[]
        for line in fobj:
            #identify the hotel name
            if 'Hotel' in line:
                hotel_name=str(line.strip(' \t\n'))
                continue
            room_num_1,room_type,room_price=line.split(',')
            room_number=int(room_num_1.split(' ')[1])
            room_price=float(room_price)
            list_rooms.append(Room(room_type,room_number,room_price))
        #now have hotel_name and list_rooms
        fobj.close()
        return (hotel_name, list_rooms)
        
    def save_hotel_info_file(self):
        #saves the hotel name, and rooms into a file in a file named by hotel and in 'hotel' file
        hotel_name=self.name
        #list
        hotel_rooms=self.rooms
        #save two info into one list. [0] is hotel name, all other are rooms
        hotel_info_list=[hotel_name]+hotel_rooms
        file_name='hotels/'+'_'.join(hotel_name.split(' ')).lower()+'/'+'hotel_info.txt'
        fobj=open(file_name,'w')
        for info in hotel_info_list:
            fobj.write(str(info)+'\n')
        fobj.close()
    
    @staticmethod
    def load_reservation_strings_for_month(hotel_folder,month, year):
        #takes in hotel folder name, month(str), year(int), returns a dict mapping room numver-> list of tuples
        #each tuple represent each day of that month, and contain(year, month, day, 'booking num--name')
        #name of csv: 1975_Dec.csv
        #dicrectory: hotels/hotel_folder_name/1975_Dec.csv
        #first find the file name
        csv_file_name=str(year)+'_'+month+'.csv'
        file_name='hotels/'+hotel_folder+'/'+csv_file_name
        dict_roomnum_tup={}
        fobj=open(file_name,'r')
        for room in fobj:
            #create a list of info for each room, where index of this list
            #refers to the date
            #[1,'num1--xxx','num2--xxx..]
            info=room.split(',')
            #this list of tuples stores tupel info for each day
            list_of_tuples=[]
            for i in range(DAYS_PER_MONTH[MONTHS.index(month)]+1):
                #first element is room_number
                if i ==0:
                    room_number=int(info[i])
                    continue
                date=i
                string_info=info[i].strip('\n')
                list_of_tuples.append((year,month,date,string_info))
            dict_roomnum_tup[room_number]=list_of_tuples
        fobj.close()
        return dict_roomnum_tup

    def save_reservations_for_month(self, month, year):
        #(string, int)
        #Resrevation.to_short_string(self):
        #first create csv file
        csv_name=str(year)+'_'+month+'.csv'
        hotel_folder_name='_'.join(self.name.split(' ')).lower()
        file_name='hotels/'+hotel_folder_name+'/'+csv_name
        #obtain a list of room numbers
        list_room_num=[]
        for room in self.rooms:
            list_room_num.append(room.room_num)
        #for loop list_room_num, rows
        #obtain all reservation objects for this month
        reservation_month=[]
        for booking_num in self.reservations:
            check_in=self.reservations[booking_num].check_in
            check_out=self.reservations[booking_num].check_out
            #if one of the check in/out date is in this month, then append the reservation to the list
            if check_in.month == MONTHS.index(month)+1 or check_out.month == MONTHS.index(month)+1 or check_in.month < MONTHS.index(month)+1 < check_out.month:
                reservation_month.append(self.reservations[booking_num])
            
        #create a new csv object
        fobj=open(file_name,'w')
        #loop through each room
        for i in range(len(list_room_num)):
        #create a list of len(month) that stores info per row
            list_row_info=[]
            for j in range(DAYS_PER_MONTH[MONTHS.index(month)]+1):
                list_row_info.append('')
            list_row_info[0]=str(list_room_num[i])
            for reservation in reservation_month:
                #check if the reservation is for this room
                if reservation.room_reserved.room_num==list_room_num[i]:
                    #if check_in and check_out is in the same month
                    if reservation.check_in.month == MONTHS.index(month)+1 and reservation.check_out.month == MONTHS.index(month)+1:
                        diff=reservation.check_out-reservation.check_in
                        days_diff=diff.days
                        for i in range(reservation.check_in.day,reservation.check_in.day+days_diff):
                            list_row_info[i]=reservation.to_short_string()
                       #if one of check in/out day is not in this month
                    elif reservation.check_in.month == MONTHS.index(month)+1 or reservation.check_out.month == MONTHS.index(month)+1:
                        #if check in is in this month
                        if reservation.check_in.month == MONTHS.index(month)+1:
                            for i in range(reservation.check_in.day,len(list_row_info)):
                                list_row_info[i]=reservation.to_short_string()
                        else: #check out is in this month
                            for i in range(1,reservation.check_out.day):
                                list_row_info[i]=reservation.to_short_string()
                        #if this month is inbetween the check_in and check_out
                    else:
                        for i in range(1,len(list_row_info)):
                            list_row_info[i]=reservation.to_short_string()
            fobj.write(','.join(list_row_info)+'\n')
        fobj.close()
                        
    def save_hotel(self):
        path_str='hotels/'+'_'.join(self.name.split(' ')).lower()
        if not os.path.exists(path_str):
            os.makedirs(path_str)
        self.save_hotel_info_file()
        #obtain the year and month (list of tuple)each room is available
        list_month_year=[]
        for room in self.rooms:
            for year, month in room.availability.keys():
                month=MONTHS[month-1]
                list_month_year.append((month, year))
        for month1, year1 in list_month_year:
            self.save_reservations_for_month(month1, year1)
        
    @classmethod
    def load_hotel(cls,folder_name):
        #room, tuples_info) to create reserv
        #where year, month given by the name of the file, day given by index of col
        open_path='hotels/'+folder_name+'/'
        #open hotel_info
        list_of_file=os.listdir(open_path)
        #list_of_file contain strings of file name
        for file in list_of_file:
            if 'info' in file:
                list_of_file.remove(file)
            if '.DS' in file:
                list_of_file.remove(file)
        hotel_name, list_rooms=cls.load_hotel_info_file(open_path+'hotel_info.txt')
        #create a dictionary mapping from room number to room objects
        dict_roomnum_room={}
        for room in list_rooms:
            dict_roomnum_room[room.room_num]=room
        #load_reservation_strings_for_month(hotel_folder,month, year)
        #loop through each month file, use load_reservation_strings_for_month(hotel_folder,month, year) to
        #obtain dict mapping from(room num ->tuple_info)
        #use room and tuple_info and get_reservations_from_row(room, tuples_info)to obtain a dict mapping (bk num->reserv)
        #use (booknum->reserv) and hotel_name, list_rooms to breate hotel
        dict_bknum_reserv={}
        #this maps room_number to tuple info of all months
        #set up room availability
        for room in list_rooms:
            list_yearmonday=[]
            for file in list_of_file:
                year,month=file[:8].split('_')
                year=int(year)
                room.set_up_room_availability([month],year)
                list_yearmonday.append((year, MONTHS.index(month)+1,1))
            list_datetime=[]
            for year,month,day in list_yearmonday:
                list_datetime.append(datetime.date(year,month,day))
            last_month=max(list_datetime).month
            last_year=max(list_datetime).year
            if last_month<12:
                room.set_up_room_availability([MONTHS[last_month]],year)
            elif last_month==12:
                room.set_up_room_availability(['Jan'],last_year+1)
        
        dict_roomnum_tuple_info={}
        for file in list_of_file:
            year,month=file[:8].split('_')
            #set availability for each room for this month using for loop
            #for room in list_rooms:
                #room.set_up_room_availability([month],int(year))  
            dict_roomnum_tuple=cls.load_reservation_strings_for_month(folder_name,month, year)
            for room_number in dict_roomnum_tuple:
                if room_number not in dict_roomnum_tuple_info.keys():
                    dict_roomnum_tuple_info[room_number]=dict_roomnum_tuple[room_number]
                else:
                    dict_roomnum_tuple_info[room_number] += dict_roomnum_tuple[room_number]
        #loop through dict_roomnum_tuple_info anc create a dictionary mapping form
        #booking number to reservation object for each room, each month    
        for roomnum in dict_roomnum_tuple_info:
            dict_bknum_reserv_per_room=Reservation.get_reservations_from_row(dict_roomnum_room[roomnum], dict_roomnum_tuple_info[roomnum])
            #now append keys and element in this dict to the global dict
            for booking_number in dict_bknum_reserv_per_room:
                dict_bknum_reserv[booking_number]=dict_bknum_reserv_per_room[booking_number]
        return cls(hotel_name, list_rooms, dict_bknum_reserv)

#name, rooms = Hotel.load_hotel_info_file('hotels/overlook_hotel/hotel_info.txt')
#h = Hotel(name, rooms, {})
#rsvs = h.load_reservation_strings_for_month('overlook_hotel', 'Oct', 1975)
#print(rsvs[237])

    



