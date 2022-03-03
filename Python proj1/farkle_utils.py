import random

def single_dice_roll():
    '''
    (none)->(int)
    returns a random integer from 1-6
    random.seed(1)
    >>> single_dice_roll()
    2 
    >>> single_dice_roll()
    5
    >>> single_dice_roll()
    1
    '''
    rand_int=random.randint(1,6)
    return rand_int

def dice_rolls(n):
    '''
    (none)->(list)
    returns a list of n randomly chosen integer between 1-6
    random.seed(3)
    >>> dice_rolls(6)
    [2, 5, 5, 2, 3, 5]
    >>> dice_rolls(6)
    [4, 6, 5, 1, 5, 1]
    >>> dice_rolls(6)
    [4, 3, 5, 2, 2, 6]
    
    random.seed(6)
    >>> dice_rolls(3)
    [5, 1, 4]
    >>> dice_rolls(3)
    [3, 1, 1]
    >>> dice_rolls(3)
    [2, 6, 5]
    '''
    list_of_dices=[]
    for i in range(n):
        list_of_dices.append(single_dice_roll())
    return list_of_dices

def contains_repetitions(list1,n,m):
    '''
    (list,int,pos_int) -> (bool)
    This function takes in a list of integers, and integer, and a positive integer.
    Then it checks if the integer n presents in the list for m times and returns True
    if it does, returns False if not
    >>> contains_repetitions([1,2,3,4,4,5],4,1)
    False
    >>> contains_repetitions([1,2,3,4,4,5],4,2)
    True
    >>> contains_repetitions([1,2,3,5],4,0)
    True
    >>> contains_repetitions([],4,1)
    False
    '''
    counts=0
    for i in range(len(list1)):
        if list1[i]==n:
            counts+=1

    if counts == m:
        return True
    else:
        return False
#contains_repetitions([1,2,3,4,4,5],4,1)
    
def pick_random_element(list1):
    '''
    (list)->(str/float/int/none)
    This function takes in a list, and returns a random element from this list
    random.seed(1)
    >>> pick_random_element([1,2,3,4,5,6])
    2
    >>> pick_random_element([1,2,3,4,5,6])
    5
    >>> pick_random_element([1,2,3,4,5,6])
    1
    '''
    if len(list1) == 0:
        return None
    randindex=random.randint(0,len(list1)-1)
    return list1[randindex]
#pick_random_element([1,2,3,4,5,6])

def contains_all(list1):
    '''
    (list) -> (bool)
    Takes in a list of integers and returns True if the list contains all unique
    consecutive positive integers starting from 1; returns False if not.
    >>> contains_all([3, 2])
    False
    >>> contains_all([3,2,4,8,1,7,6,5])
    True
    >>> contains_all([])
    False
    >>> contains_all([1,1,2,2,3,3])
    False
    '''
    if (len(list1)==0) or (1 not in list1):
        return False
    #sort the list
    list1.sort()
    for i in range(len(list1)-1):
        if (list1[i+1]!=list1[i]+1): #check for consecutive.
            return False
    return True
    

#print(contains_all([1,2,3]))

def count_num_of_pairs(list1):
    '''
    (list1)->(int)
    The function takes in a list and returns an integer representing the number
    of pairs inside this list
    >>> count_num_of_pairs([1, 1, 1, 2, 2, 1, 1])
    3
    >>> count_num_of_pairs([1, 2, 1, 1, 2, 2])
    2
    >>> count_num_of_pairs([])
    0
    '''
    count=0
    while (len(list1)>1):
        if(list1[0]==list1[1]):   #loop through the list, check if each elements forms a pair with the next element
            count+=1              #Time complex=N
            list1.pop(0)
            list1.pop(0)
        else:
            list1.pop(0)
    return count
    
#print(count_num_of_pairs([1, 2, 1, 1, 2, 2]))

def is_included(list1,list2):
    '''
    (list,list)->(bool)
    This function takes in two list, list1 and list2, then returns True if list2 is a subset
    of list1, False if not. The order of elements does not matter, as long as all elements
    inside list2 is contained in list1, then it is considered as a subset. This function does not
    changes the original lists.
    >>> is_included([6, 4, 4, 2, 6, 3], [4, 4, 6, 6])
    True
    >>> is_included([6, 4, 4, 2, 6, 3], [])
    True
    >>> is_included([], [1,2,3])
    False
    >>> is_included([], [])
    True
    '''
    list1_copy = list1[:]    #Time complexity= N
    list2_copy = list2[:]
    for i in list2_copy:
        if i not in list1_copy:
            return False
        elif list2_copy.count(i) > list1_copy.count(i):
            return False
    return True
                
#n = [1, 2, 4, 5, 5, 5]
#m1 = [1,1]
#print(is_included(n, m1))

def get_difference(list1,list2):
    '''
    (list,list)->(list)
    The function takes in two list, list1 and list2. If list2 is not a subset of list1
    , it will return a empty list. If list2 is a subset of list1, it returns the difference between
    two list, where the resulting list contains all the elements list2 required to be identical to
    list 1
    >>> get_difference([1, 2, 3, 4, 5], [2, 4])
    [1, 3, 5]
    >>> get_difference([0, 2, 1], [2, 4])
    []
    >>> get_difference([1, 2, 1], [])
    [1, 2, 1]
    '''
    list1_c=list1[:]
    list2_c=list2[:]
    if not is_included(list1,list2):
        return []
    for i in list2_c:
        list1_c.remove(i)
    return list1_c

#print(get_difference([1,2,2,3,4,5,6],[2,2]))

                
                
            
    
