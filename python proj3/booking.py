#this is main
#Call menu() to execute

import datetime
import random
import os
from hotel import *
import matplotlib

class Booking:
    def __init__(self, list_hotels):
        self.hotels=list_hotels
    
    @classmethod
    def load_system(cls):
        list_of_hotel_file=os.listdir('hotels')
        for file in list_of_hotel_file:
            if '.D' in file:
                list_of_hotel_file.remove(file)
        list_hotels=[]
        for file_name in list_of_hotel_file:
            hotel=Hotel.load_hotel(file_name)
            list_hotels.append(hotel)
        return cls(list_hotels)
    #load_hotel(cls,folder_name)
    def menu(self):
        print('Welcome to Booking System')
        print('What would you like to do?')
        user_input=input('1 \tMake a reservation\n2 \tCancel a reservation\n3 \tLook up a reservation\n')
        if user_input== 'xyzzy':
            self.delete_reservations_at_random()
        elif int(user_input)==1:
            self.create_reservation()
        elif int(user_input)==2:
            self.cancel_reservation()
        elif int(user_input)==3:
            self.lookup_reservation()
        for hotel in self.hotels:
            hotel.save_hotel_info_file()
            
    def create_reservation(self):
        #
        user_name=input('Please enter you name: ')
        print('Hi '+user_name+'! Which hotel would you like to book?')
        list_hotel_option=[]
        for i in range(len(self.hotels)):
            list_hotel_option.append(str(i+1)+'\t'+self.hotels[i].name+'\n')
        print(''.join(list_hotel_option))
        user_input=int(input(''))
        #
        hotel_chose=self.hotels[user_input-1]
        print('Which type of room would you like?')
        #
        user_room=int(input('1 \tDouble\n2 \tTwin\n3 \tKing\n4 \tQueen\n'))
        if user_room==1:
            room_chose='Double'
        elif user_room==2:
            room_chose='Twin'
        elif user_room==3:
            room_chose='King'
        elif user_room==4:
            room_chose='Queen'
        user_checkin=input('Enter check-in date (YYYY-MM-DD): ')
        yeari,monthi,dayi=user_checkin.split('-')
        if int(monthi) < 10:
            monthi=int(monthi[1:])
        if int(dayi) < 10:
            dayi=int(dayi[1:])
        #
        checkin=datetime.date(int(yeari),int(monthi), int(dayi))
        user_checkout=input('Enter check-out date (YYYY-MM-DD): ')
        yearo,montho,dayo=user_checkout.split('-')
        if int(montho) < 10:
            montho=int(montho[1:])
        if int(dayo) < 10:
            dayo=int(dayo[1:])
        #
        checkout=datetime.date(int(yearo),int(montho), int(dayo))
        reservation_num=hotel_chose.make_reservation(user_name, room_chose, checkin, checkout)
        money_due=hotel_chose.get_receipt([reservation_num])
        print('Ok. Making your reservation for a '+room_chose+' room.')
        print('Your reservation number is: '+str(reservation_num))
        print('Your total amount due is: $'+str(round(money_due,2)))
        print('Thank you!')
    
    def cancel_reservation(self):
        bk_num=int(input('Please enter your booking number: '))
        #list of bool
        count=0
        for hotel in self.hotels:
            if bk_num not in hotel.reservations.keys():
                count += 1
            else:
                hotel.cancel_reservation(bk_num)
        if count == len(self.hotels):
            print('Could not find a reservation with that booking number.')
        else:
            print('Cancelled successfully')
            
    def lookup_reservation(self):
        have_bknum=input('Do you have your booking number(s)? ')
        if have_bknum.lower() in 'y yes yeah':
            list_user_input=[]
            booking_num='1'
            while booking_num != 'end':
                booking_num=input("Please enter a booking number (or 'end'): ")
                list_user_input.append(booking_num)
            booking_number=int(list_user_input[-2])
            for hotel in self.hotels:
                try:
                    reservation=hotel.reservations[booking_number]
                    print(reservation)
                    print('Total amount due: $'+ str(hotel.get_receipt([booking_number])))
                except KeyError:
                    continue
        elif have_bknum.lower() in 'no nah n':
            name1=input('Please enter yout name: ')
            hotel1=input('Please enter the hotel you are booked at: ')
            room_num1=int(input('Enter the reserved room number: '))
            user_checkin=input('Enter the check-in date (YYYY-MM-DD): ')
            yeari,monthi,dayi=user_checkin.split('-')
            if int(monthi) < 10:
                monthi=int(monthi[1:])
            if int(dayi) < 10:
                dayi=int(dayi[1:])
            checkin=datetime.date(int(yeari),int(monthi), int(dayi))
            user_checkout=input('Enter the check-out date (YYYY-MM-DD): ')
            yearo,montho,dayo=user_checkout.split('-')
            if int(montho) < 10:
                montho=int(montho[1:])
            if int(dayo) < 10:
                dayo=int(dayo[1:])
            #
            checkout=datetime.date(int(yearo),int(montho), int(dayo))
            found=False
            for hotel in self.hotels:
                if hotel.name.lower().strip('\n') == hotel1.lower():
                    for booking_number in hotel.reservations:
                        if hotel.reservations[booking_number].name.lower() == name1.lower() and hotel.reservations[booking_number].room_reserved.room_num == room_num:             
                            if hotel.reservations[booking_number].check_in == checkin and hotel.reservations[booking_number].check_out==checkout :                       
                                booking_num1=booking_number
                                found=True
                                print('Reservation found under booking number: '+ str(booking_num1))
                                print('Here are the details:')
                                print(hotel.reservations[booking_num1])
                                print('Total amount due: $'+ str(round(hotel.get_receipt([booking_num1]),2)))
                                break
            if found==False:
                print('Sorry, the reservation cannot be found')
    def delete_reservations_at_random(self):
        print('You said the magic word!')
        magic_index=random.randint(0,len(self.hotels)-1)
        magic_hotel=self.hotels[magic_index]
        list_bk_num=[]
        for booking_number in magic_hotel.reservations:
            list_bk_num.append(booking_number)
        for book_num in list_bk_num:
            magic_hotel.cancel_reservation(book_num)
    
#random.seed(137)
#booking = Booking.load_system()
#booking.menu()





                    


