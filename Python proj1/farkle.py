import random
import farkle_utils
single_one=100
single_five=50
triplet_multiplier=100
straight=3000
three_pairs=1500

'''
This is a game implemented by me who just started leanrning coding. Some structures and algorithms might
be redundant, I'll improve this later.
'''

def compute_score(list1):
    '''
    (list)-> (int)
    This function takes in a list of integers between 1 and 6, and returns
    the highest possible score that can be obtained using those integers following
    the rules of Frakle.
    >>>compute_score([1, 1, 2, 2, 3, 3])
    1500
    >>>compute_score([1,2,3,4,5,6])
    3000
    >>>compute_score([1,2,4,4,5,6])
    0
    >>>compute_score([2,2,2])
    200
    >>>compute_score([5,5,5,1])
    600
    '''
    #score_3_pairs keeps track of the total score when there are 3 pairs
    score_3_pairs=0
    #when the length of the list is 6, first check if it's straight or contains 3 pairs
    if len(list1)==6:
        if farkle_utils.contains_all(list1):
            list_bool=[]
            for i in range(1,7):
                list_bool.append(i in list1)
            if False not in list_bool:
                score_straight =3000
                return score_straight
        if farkle_utils.count_num_of_pairs(list1) ==3:
            score_3_pairs += three_pairs
    #record the score when the list is viewd by three pairs (if it has 3 pairs)
    #then compute the score if not viewed as 3 pairs (if there is any)
    #considered list is used to keep track of the dice that already counted for scores
    considered=[]
    total_score=0
    list1_c=list1[:]
    #this following variable is used to record whether the player scores a 0 or not
    total_score_0=1
    for i in list1_c:
        #First consider wherether there are any threes
        #if there are threes, compute the total_score and then subtract them from list1
        if 6 >= (list1.count(i))>= 3:
            if i ==1:
                sub_score_threes= i*10*triplet_multiplier
                total_score +=sub_score_threes
            else:
                sub_score_threes=i*triplet_multiplier
                total_score += int(sub_score_threes)
            for j in range(3):
                considered.append(i)
            list1=farkle_utils.get_difference(list1_c,considered)
        #after all the threes (if there are any) are considered and removed, now consider individual scores for 1 and 5
        #if there are any single integer left other than 1 or 5, then the score will be 0.
        elif 0< list1.count(i) <3:
            if i==1:
                total_score += 100
                considered.append(i)
                list1=farkle_utils.get_difference(list1,[1])
            elif i==5:
                total_score += 50
                considered.append(i)
                list1=farkle_utils.get_difference(list1,[5])
            else:
                total_score_0=0
    #see which way of score calculation results in a higher score
    if score_3_pairs > total_score:
        return score_3_pairs
    elif score_3_pairs < total_score:
        if total_score_0 ==0:
            return total_score_0
        else:
            return total_score
    else:
        return total_score


    
def get_winners(list1,score):
    '''
    (list,int)->(list)
    This function takes in a list of positive int and a positive int representing the winning score
    and returns the index of the highest integers in the list that surpasses the score starting at index 1.
    If none of the integres surpasses the score, then an empty list is returned. If there are
    ties, then the function returns a list with all their index in an increasing order.
    >>> get_winners([500, 100, 5], 10000)
    []
    >>>get_winners([1000, 10000, 20],5000)
    [2]
    >>>get_winners([100,100,100,100],100)
    [1, 2, 3, 4]
    '''
    winner=[]
    highest=max(list1)
    for i in range(len(list1)):
        #obtain the highest scores in this list
        if list1[i] ==highest:
            #check if it passes the winning score
            if list1[i] >= score:
                winner.append(i+1)
    return winner
#get_winners([11,3,9,11],5)

def play_one_turn(index):
    '''
    (pos_int)->(int)
    This function takes in a positive integer representing a player and returns their score after
    their turn of Frakle ended. This function asks for the user input of whether to roll or not, rolls
    the dices, calculate the score on the selected dices, and repeat proccess if the user choses to continue.
    '''
    print('\nPlayer ',index,' it\'s yout turn!')
    score=0
    number_remain=6
    decision='roll'
    #the game will continue if the the player wants to keep rolling and have dices left
    while number_remain != 0 or decision == 'roll':
        player_decision=input('\nWould you like to roll or pass?: ')
        if player_decision.lower() != 'roll':
            return score
        #if the player is new to this round or had hot dice last round
        #the player can roll all 6 dices
        if number_remain==6:
            rolled_dice=farkle_utils.dice_rolls(6)
            ran_dice=[]
            for i in rolled_dice:
                ran_dice.append(str(i))
        #player rolls the remaining dices from last round
        else:
            rolled_dice=farkle_utils.dice_rolls(number_remain)
            ran_dice=[]
            for i in rolled_dice:
                ran_dice.append(str(i))
        print('Here\'s the result of rolling your dices: ',', '.join(ran_dice))
        re_enter=True
        player_select=input('Please enter a squence of the scoring dice to set aside (with spacing between): ')
        while re_enter==True:
            selected_list=[]
            #turn the string that the player enters into a list of integers
            for i in player_select.split():
                selected_list.append(int(i))
            #check if the integers entered are valid
            for i in selected_list:
                if i not in rolled_dice:
                    player_select=input('You don\'t have these dice. Select again: ')
                    re_enter=True
                    break
                else:
                    if selected_list.count(i) > rolled_dice.count(i):
                        player_select=input('You don\'t have these dice. Select again: ')
                        re_enter=True
                        break
                    else:
                        re_enter=False
        this_turn_score=compute_score(selected_list)
        #frakle
        if this_turn_score == 0:
            score=0
            print('FRAKLE! All the poinrs accumulated up to now are lost.')
            number_remain=len(rolled_dice)
        else:
            score += this_turn_score
            remain=farkle_utils.get_difference(rolled_dice,selected_list)
            number_remain=len(remain)
        print('Your current score in this round is: ',score)
        if number_remain==0:
            #hot dice
            if len(selected_list)==len(rolled_dice) and score != 0:
                number_remain=6
                decision='roll'
                print('HOT DICE! You are on a roll. You got six dice back')
                print( 'You have' ,number_remain,' dices to keep playing')
            #no more remaining dice
            else:
                return score
        else:
            decision='roll'
            print( 'You have' ,number_remain,' dices to keep playing')

def play_farkle():
    '''
    (None)->(None)
    This function takes no input and returns None. This function plays a full round of
    game of Frakle with the number of players and the winning score determined by the user. It prints
    welcome messages at the begining, and prints the score of each player at the end of each turn.
    At the end of each turn, the score of each player is added with the score of previous turns, and
    determine whether there is a winner. If there are more than one winner, then the winner is determined
    randomly.
    '''
    print('Welcome to a game of Farkle!!')
    number_player=0
    #asks for number of players
    while number_player<2 or number_player>8:
        number_player=int(input('How many players would like to play (2-8)? '))
    winning_score=0
    #asks for the winning score
    while winning_score <= 0 or type(winning_score) != int:
        winning_score=int(input('Enter the winning score: '))
    winner=[]
    acc_score=[]
    #creates a list with the length of the number of players that records the accumulateed scores.
    for i in range(number_player):
        acc_score.append(0)
    round_num=0
    #main loop that determines the list of winners
    while winner==[]:
        #list that record the scores for each round
        score_list=[]
        #for loop for a single round 
        for i in range(1,number_player+1):
            score_i=play_one_turn(i)
            score_list.append(score_i)
        #determines the accumulated scores
        for i in range(number_player):
            acc_score[i] += score_list[i]
        winner=get_winners(acc_score,winning_score)
        round_num += 1
        print('\nThis is the end of round',round_num)
        for i in range(1,number_player+1):
            print('Player',i,'now has',acc_score[i-1],'points')
    #if there are multipies winners, then the winner is determined randomly
    if len(winner)>1:
        rand_win=random.randint(len(winner))
        fin_winner=winner[rand.win]
    else:
        fin_winner=winner[0]
    print('\nThanks for Playing! The winner is player',fin_winner,'! Congratulation!')
        
#random.seed(123)
play_farkle()
