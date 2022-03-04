
def is_valid_universe(two_d_list):
    '''
    (list)->(bool)
    This function takes in a two D list and check if the list satsifies the
    condition for a valid universe. A valid universe is when the length of each list
    in the 2D list is the same and when all elements are 1s or 0s.
    
    >>>beehives=[[2,2,1],[3,1,1],[4,1,1]]
    >>>is_valid_universe(beehives)
    False
    
    >>>beehives1=[[1,0,0],[1,1,1],[1,0]]
    >>>is_valid_universe(beehives1)
    False
    
    >>>beehives2=[[1,0,0],[0,0,0],[0,0,0]]
    >>>is_valid_universe(beehives2)
    True
    
    '''
    if two_d_list==[]:
        return False
    #check if all sub-lists are the same length
    length=len(two_d_list[0])
    for list1 in two_d_list:
        if len(list1) != length:
            return False
    #check all elements are 0 or 1
    for list1 in two_d_list:
        for element in list1:
            if (not element==1) and (not element==0):
                return False
    return True

def universe_to_str(two_d_list):
    '''
    (list)->(str)
    This function takes in two-d list that is a valid universe and returns
    a string representing its graphic.
    >>>block= [[0, 0, 0, 0], [0, 1, 1, 0], [0, 1, 1, 0], [0, 0, 0, 0]]
    >>>print(universe_to_str(block))
    +----+
    |    |
    | ** |
    | ** |
    |    |
    +----+
    >>>block1=[[1, 0, 0, 1], [0, 0, 0, 0], [0, 1, 1, 0], [0, 1, 1, 0]]
    >>>print(universe_to_str(block1))
    +----+
    |*  *|
    |    |
    | ** |
    | ** |
    +----+
    
    >>>block2=[[1, 0, 0, 1], [0, 0, 1, 0], [0, 0, 1, 0], [0, 1, 0, 0],
               [1, 0, 0, 1], [0, 1, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0]]
    >>>print(universe_to_str(block2))
    +----+
    |*  *|
    |  * |
    |  * |
    | *  |
    |*  *|
    | *  |
    | *  |
    |  * |
    +----+
    '''
    output_string='+'+len(two_d_list[0])*'-'+'+'+'\n'
    #iterate through each row and change each 1, 0 into strings
    for row in two_d_list:
        output_string += '|'
        for col in row:
            if col == 0:
                output_string +=' '
            elif col == 1:
                output_string +='*'
        output_string +='|'+'\n'
    output_string+='+'+len(two_d_list[0])*'-'+'+'
    return output_string

def count_live_neighbors(beehives, x, y):
    '''
    (list,int,int)->(int)
    This function takes in a two D list that is a valid universe and two
    integer representing the location of a cell (where x is rows and y is cols).
    Then the function counts and returns the number of live cells around it.
     
    >>>beehive =  [[0, 0, 0, 0, 0, 0], 
                   [0, 0, 1, 1, 0, 0], 
                   [0, 1, 0, 0, 1, 0], 
                   [0, 0, 1, 1, 0, 0], 
                   [0, 0, 0, 1, 0, 0]]
    >>>count_live_neighbors(beehive,1,3)
    2
    >>>count_live_neighbors(beehive,0,0)
    0
    >>>count_live_neighbors(beehive,0,3)
    2
    
    '''
    #representing x row and y col
    count=0
    #check for every single slot around it
    if((x-1>=0)and(y-1>=0)) and beehives[x-1][y-1]==1:
        count+=1
    if(x-1>=0) and beehives[x-1][y]==1:
        count+=1
    if((x-1>=0)and(y+1<len(beehives))) and beehives[x-1][y+1]==1:
        count+=1
    if(y-1>=0) and beehives[x][y-1]==1:
        count+=1
    if(y+1<len(beehives)) and beehives[x][y+1]==1:
        count+=1
    if((x+1<len(beehives))and (y-1>=0)) and beehives[x+1][y-1]:
        count+=1
    if(x+1<len(beehives)) and beehives[x+1][y]:
        count+=1
    if(x+1<len(beehives))and(y+1<len(beehives))and beehives[x+1][y+1]==1:
        count+=1
    return count



def get_next_gen_cell(beehives,x,y):
    '''
    (list,int,int)->(int)
    This function takes in a 2-d list that is a valid universe and two
    integers representing the location of a cell, and returns an integer
    indicating whether the cell is alive or dead in the next generation
    (1 is alive, 0 is dead)
    
    >>> toad = [[0, 0, 0, 0, 0, 0],
                [0, 0, 1, 1, 1, 0], 
                [0, 1, 1, 1, 0, 0],
                [0, 0, 0, 0, 0, 0]]
    >>>get_next_gen_cell(toad, 0, 3)
    1
    >>>get_next_gen_cell(toad, 0, 0)
    0
    >>>get_next_gen_cell(toad, 2, 2)
    0
    
    >>>block = [[0, 0, 1, 1, 1, 0],
                [0, 0, 1, 0, 1, 0], 
                [0, 0, 1, 1, 1, 0],
                [0, 0, 0, 0, 0, 0]]
    >>>get_next_gen_cell(block, 1, 3)
    0
    
    '''
    #returns 1 if the cell is alive and 0 if it will die in the next generation
    #count live cells
    num_live_cell=count_live_neighbors(beehives, x, y)
    #check conditions
    if beehives[x][y]==1: 
        if num_live_cell<2:
            return 0
        elif 2 <= num_live_cell <= 3:
            return 1
        else num_live_cell>3:
            return 0
    else:
        if num_live_cell==3:
            return 1
        else:
            return 0


def get_next_gen_universe(beehives):
    '''
    (lst)->(lst)
    This function takes in a list that is a valid universe, and returns
    a new list representing the universe in the next generation
    
    >>>toad =  [[0, 0, 0, 0, 0, 0],
                [0, 0, 1, 1, 1, 0],
                [0, 1, 1, 1, 0, 0],
                [0, 0, 0, 0, 0, 0]]
    >>>gen1=get_next_gen_universe(toad)
    >>>print(gen1)
    [[0, 0, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0],
     [0, 1, 0, 0, 1, 0], [0, 0, 1, 0, 0, 0]]
    >>>gen2=get_next_gen_universe(gen1)
    >>>print(gen2)
    [[0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 1, 0],
     [0, 1, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0]]
     
    >>>block=[[0,0,0,0],[0,1,1,1],[0,0,0,0],[1,0,0,1]]
    >>>print(get_next_gen_universe(block))
    [[0, 0, 1, 0], [0, 0, 1, 0], [0, 1, 0, 1], [0, 0, 0, 0]]
    
    '''
    #iterate through each element in the 2D list
    new_beehives=[]
    for i in range(len(beehives)):
        row=[]
        for j in range(len(beehives[i])):
            #get next generation cell
            next_result=get_next_gen_cell(beehives,i,j)
            row.append(next_result)
        new_beehives.append(row)
    return new_beehives

def get_n_generations(beehives,n):
    '''
    (list,int)->(list)
    This function takes in a two-d list that is a valid universe, and an integer
    representing how many generations to find. Then this function returns a list of strings
    representing the graphics of these generations. Note that if the universe repeat itself,
    the output list will only contain the portion of universe that does not repeat itself. In
    other words, the output list won't contain repeating strings. The functions will first
    check if all inputs satisfies the conditions
    >>>block=[[1,2,0],[2,3,1],[4,1,2]]
    >>>get_n_generations(block, 5)
    Traceback(most recent call last):
    ValueError: 2D list entered is not a valid universe
    
    >>>block1=[[1,0,0],[1,0,1],[1,1,0]]
    >>>get_n_generations(block1, -1)
    Traceback(most recent call last):
    ValueError: Second integer is not a positive integer
    
    >>>block2=[['1',0,0],[0,'0',0],[1,1,1]]
    >>>get_n_generations(block2, 3)
    Traceback (most recent call last):
    TypeError: First argument of this function should be a 2D list of integers
    
    >>>block3=[(1,1,0),(1,0,0),(0,0,0)]
    >>>get_n_generations(block3, 3)
    Traceback (most recent call last):
    TypeError: First argument of this function should be a 2D list of integers
    
    >>>toad = [[0, 0, 0, 0, 0, 0],
               [0, 0, 1, 1, 1, 0], 
               [0, 1, 1, 1, 0, 0],
               [0, 0, 0, 0, 0, 0]]
        
    >>>lst_of_gens=get_n_generations(toad, 3)
    >>>print(lst_of_gens[0])
    +------+
    |      |
    |  *** |
    | ***  |
    |      |
    +------+
    >>>print(lst_of_gens[1])
    +------+
    |   *  |
    | *  * |
    | *  * |
    |  *   |
    +------+
    
    >>>random_block=[[1,1,1,1,1],[0,0,0,0,0],[1,1,1,1,1],[0,0,0,0,0]]
    >>>gens=get_n_generations(random_block, 3)
    >>>print(gens[1])
    +-----+
    | *** |
    |     |
    | *** |
    | *** |
    +-----+
    '''
    #check TypeError
    #first check if beehive is a 2d list of integers
    if type(beehives) != list:
        raise TypeError('First argument of this function should be a 2D list of integers')
    for row in beehives:
        if type(row) != list:
            raise TypeError('First argument of this function should be a 2D list of integers')
        for col in row:
            if type(col) != int:
                raise TypeError('First argument of this function should be a 2D list of integers')
    if type(n) != int:
        raise TypeError('Second argument of this function should be an integer')
    #ValueError
    #check if it is a valid universe
    #check if n is a positive int
    if not is_valid_universe(beehives):
        raise ValueError('2D list entered is not a valid universe')
    if n <= 0:
        raise ValueError('Second integer is not a positive integer')
    
    k=1
    #deep copy of beehives
    new_gen=[]
    for list1 in beehives:
        row=[]
        for j in list1:
            row.append(j)
        new_gen.append(row)
    new_lst=[universe_to_str(new_gen)]
    #repeat finding the next generation universe n times
    while k < n:
        new_gen=get_next_gen_universe(new_gen)
        new_str=universe_to_str(new_gen)
        if new_str not in new_lst:
            new_lst.append(new_str)
        #Check if the universe repeats on itself
        else:
            break
        k+=1
    return new_lst


 