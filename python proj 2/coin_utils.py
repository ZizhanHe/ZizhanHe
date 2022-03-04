import random
ALPHABET = 'qwertyuiopasdfghjklzxcvbnm1234567890äéèçæœ'
PUNCTUATION = '`~!@#$%^&*()-=_+[]\{}|;\':",./<>? \t\n\r'
ALL_CHARACTERS = ALPHABET + PUNCTUATION
MIN_BASE10_COIN = 0
MAX_BASE10_COIN = 16777215
LETTERS_IN_POPULARITY_ORDER = ' EOTARNLISMHDYFGCWPUBVXK.,\'"-;'
BASE8_CHARS   = '01234567'
BASE202_CHARS = '0C2OMPIN'


def base10_to_202(amt_in_base10):
    ''' (int) -> str
    >>> base10_to_202(202)
    '0c00000OC2'
    '''
    octal_s = oct(amt_in_base10)
    
    new_s = '0c'
    for i in range(8-len(octal_s)+2):
        new_s = new_s + '0'
    for c in octal_s[2:]:
        new_s = new_s + BASE202_CHARS[int(c)]
    return new_s

def is_base202(text):
    """ (str) -> bool
    10 character string
    
    >>> is_base202('1cCOMPCOIN')
    False
    >>> is_base202('0c0C2OMPIN')
    True
    """
    if (len(text) != 10) or (text[0:2].lower() != '0c'):
        return False
    for c in text[2:]:
        if c.upper() not in BASE202_CHARS:
            return False
    return True

def base202_to_10(amt_in_base202):
    '''
    (str)->(int)
    This function takes in a string in base 202, convert it to base 10, and output
    the result as integers.
    >>>base202_to_10('0c00000oc2')
    202
    >>>base202_to_10('0c00000000')
    0
    >>>base202_to_10('0c0020C0MP')
    66085
    '''
    base202=amt_in_base202[2:]
    base202_list=[]
    base202_list[:]=base202
    #replace comp202 characters into base8's
    for i in range(len(base202_list)):
        base202_list[i]=base202_chars.index(base202_list[i].upper())
    base8=''
    #convert base8 into base10
    for num in base202_list:
        base8 += str(num)
    base10=int(base8,8)
    return base10

def get_random_comp202coin(index):
    '''
    (all type)->(str)
    This function takes in an argument, but does not do anything with it. Then this
    function generates a random integer between MIN_BASE10_COIN and MAX_BASE10_COIN and
    convert it to base 202 and return it.
    >>>random.seed(0)
    
    >>> get_random_comp202coin(1)
    '0cIC2ONOON'
    >>> get_random_comp202coin(2)
    '0cIC2ONOON'
    >>> get_random_comp202coin(3)
    '0cIPIP2MP0'
    
    '''
    rand_int=random.randint(MIN_BASE10_COIN,MAX_BASE10_COIN)
    return base10_to_202(rand_int)



def get_random_character(index):
    '''
    (all type)->(str)
    This function takes in an argument, but does not do anything with it. Then the function
    generates a random index for ALL_CHARACTERS and returns the corresponding character.
    >>>random.seed(0)
    >>>get_random_character(1)
    '^'
    >>>get_random_character(2)
    ')'
    >>>get_random_character(3)
    'y'
    '''
    ran_index=random.randint(0,len(ALL_CHARACTERS)-1)
    return ALL_CHARACTERS[ran_index]

def get_letter_of_popularity_order(index):
    '''
    (non-neg int)->(str)
    This function takes in a non-negative integer index, and returns a character
    from LETTERS_IN_POPULARITY_ORDER that corresponds to that index. If the index goes beyond
    the bound, then the function returns the index as a string.
    >>>get_letter_of_popularity(0)
    ' '
    >>>get_letter_of_popularity(1231)
    '1231'
    
    >>>get_letter_of_popularity(23)
    'K'
    
    >>>get_letter_of_popularity('1')
    Traceback (most recent call last):
    AssertionError: Function takes in a non-negative integer
    
    >>>get_letter_of_popularity(-21)
    Traceback (most recent call last):
    AssertionError: Function takes in a non-negative integer
    
    '''
    if type(index) != int:
        raise AssertionError('Function takes in a non-negative integer')
    if index < 0:
        raise AssertionError('Function takes in a non-negative integer')
    if index> len(LETTERS_IN_POPULARITY_ORDER)-1:
        return str(index)
    return LETTERS_IN_POPULARITY_ORDER[index]

def get_unique_elements(my_list):
    '''
    (list)->(list)
    This function takes in a list and returns a list with only unique elements in it.
    The returned list should have elements in the same order as the input list.
    
    >>>get_unique_elements(['a','a','aa','b','c'])
    ['a', 'aa', 'b', 'c']
    
    >>>get_unique_elements([1,2,3,3,4,1,4])
    [1, 2, 3, 4]
    
    >>>get_unique_elements([1,1,1,1,1,1])
    [1]
    
    >>>get_unique_elements((1,2,31))
    Traceback (most recent call last):
    AssertionError: Function takes in a list
    
    '''
    if type(my_list) != list:
        raise AssertionError('Function takes in a list')
    new_list=[]
    #iterate through each element and append them to a new list if they are already in it
    for char in my_list:
        if char not in new_list:
            new_list.append(char)
    return new_list

def get_all_coins(text):
    '''
    (str)->(list)
    This function takes in a string, and returns a list of all comp202coin found inside
    the string.
    >>>get_all_coins('0c0M0NNMOC khkjhkj 0c0M0NNMOC 0c0M0NNMOC')
    ['0c0M0NNMOC', '0c0M0NNMOC', '0c0M0NNMOC']
    
    >>>get_all_coins('0c0M0NNsMOCada')
    []
    
    >>>get_all_coins('')
    []
    
    >>>get_all_coins(['0c0M0NNMOC','qdaasd','0c0M0NPMOC'])
    Traceback (most recent call last):
    AssertionError: Function takes in a string
    
    '''
    list_of_base202=[]
    #obtain comp202 strings in a text and put them into a list
    for i in range(len(text)):
        #obtain the 10 character string that starts with 0c
        if (text[i] == '0' )and (text[i+1] =='c') and ((i+10)<=len(text)):
            base202=text[i:i+2].lower()+text[i+2:i+10].upper()
            #check is the 10 characer string a comp202 string
            if (is_base202(base202)) and (base202 not in list_of_base202):
                list_of_base202[i:i+1]=([base202])
    return list_of_base202

def reverse_dict(my_dict):
    
    #check if immutable
    for keys in my_dict:
        try:
            my_dict[keys][0]='try to assign'
            raise AssertionError('Input dictionary should have immutable values')
        except TypeError:
            None
    #check if unique values
    list_of_values=[]
    for keys in my_dict:
        list_of_values.append(my_dict[keys])
    for value in list_of_values:
        if list_of_values.count(value) >1:
            raise AssertionError('Input dictionary must have unique values')
    #reverse dict
    new_dict={}
    for key,value in list(my_dict.items()):
        new_dict[value]=key
    return new_dict

#x = reverse_dict({'a': 1, 'b': 3,'c':3, 'd': 7})
#print(x)

def get_frequencies(my_list):
    '''
    (list)->(dict)
    This function takes in a list as argument and calculates the percentage of the times
    the element appears in this list, and returns a dictionary with the element mapping to its frequency.
    
    >>>get_frequencies([1,1,1,1])
    {1: 1.0}
    
    >>>get_frequencies(['a','b','c','d','e'])
    {'a': 0.2, 'b': 0.2, 'c': 0.2, 'd': 0.2, 'e': 0.2}
    
    >>>get_frequencies([(1,2,3),(2,3,4),(1,2,3)])
    {(1, 2, 3): 0.6666666666666666, (2, 3, 4): 0.3333333333333333}
    
    >>>>get_frequencies((1,2))
    Traceback (most recent call last):
    AssertionError: This function takes in a list
    
    '''
    #check condition
    if type(my_list) != list:
        raise AssertionError('This function takes in a list')
    #make a copy of the list
    my_list_cp=my_list[:]
    new_dict={}
    counted=[]
    for element in my_list_cp:
        if element not in counted:
            #calculate the % of each unique element
            new_dict[element]=my_list_cp.count(element)/len(my_list_cp)
            counted.append(element)
    return new_dict


def swap_letters(s,let1,let2):
    '''
    (str, str , str) ->(str)
    This function takes in three strings, with the first string being a segment of text,
    let1 and let2 being one character only. Then the function replaces all let 1 in the text with
    let2, and all let2 with let1, and returns the new string. Note that the function is
    case sensitive.
    
    >>>swap_letters('123456','1','6')
    '623451'
    
    >>>swap_letters('ABCefg','e','A')
    'eBCAfg'
    
    >>>swap_letters('Hello, how are you?','h','?')
    'Hello, ?ow are youh'
    
    >>>swap_letters([1,2,3,4,5],5,1)
    Traceback (most recent call last):
    AssertionError: This function takes in 3 strings
    
    >>>swap_letters('abcdef','abc','def')
    Traceback (most recent call last):
    AssertionError: Last two input should be strings of length 1
    
    '''
    #check conditions
    if type(s) != str or type(let1) != str or type(let2) != str:
        raise AssertionError('This function takes in 3 strings')
    if len(let1) != 1 or len(let2) != 1:
        raise AssertionError('Last two input should be strings of length 1')
    new_s=''
    #iterate through s, and replace let1 with let2, let2 with let1
    for char in s:
        if char == let1:
            new_s += let2
        elif char == let2:
            new_s += let1
        else:
            new_s += char
    return new_s

def get_pct_common_words(text,common_words_filename):
    '''
    (str, str)-(float)
    This function takes in a text string and a string representing a file name. This function
    finds the common words between the text and the file and returns the percentage of
    characters that forms common words in that text string. Note that this function is not case
    sensitive. A word with punctuation should be considered as two words divided by the punctuation.

    
    >>>get_pct_common_words("The quick brown fox jumps over the lazy dog.", 'common_words.txt')
    0.22727272727272727
    
    >>>get_pct_common_words('The','common_words.txt')
    1.0
    
    >>>get_pct_common_words('T\'s@d;d','common_words.txt')
    0.5714285714285714
    
    >>>get_pct_common_words(['The','Quick','Brown'],'common_words.txt')
    Traceback (most recent call last):
    AssertionError: THe first argument of this fucntion should be a string
    '''
    #check conditions
    if type(text) != str:
        raise AssertionError('THe first argument of this fucntion should be a string')
    if type(common_words_filename)!= str:
        raise AssertionError('THe second argument of this fucntion should be a string')
    #first split the text by space
    text_list_space=text.lower().split(' ')
    #iterate through each element that are split by space, and strip the punctuation off from each element
    for i in range(len(text_list_space)):
        text_list_space[i:i+1]=[text_list_space[i].strip(PUNCTUATION)]
    puns=''
    #find which characters in PUNCTUATIION are presented inside the text
    for punc in PUNCTUATION:
        if punc in text:
            puns+=punc
    #puns contain all the puncuations in text
    #now iterate through each character in puns
    for pun in puns:
        #for each pun, iterate through each word in text_list_space
        for i in range(len(text_list_space)):
            if pun in text_list_space[i]:
                #if pun is found inside a word, then split the word by the pun
                text_list_space[i:i+1]=text_list_space[i].split(pun)
    list_text=text_list_space
    #list_text now contains all words from the input string split by puns
    word_list=[]
    #now iterate through all words and check if they are in the file
    fobj=open(common_words_filename,'r')
    for word in list_text:
        if word in fobj.read():
            word_list.append(word)
    fobj.close()
    length=0
    for word in word_list:
        length += len(word)
    return length/len(text)


def sort_keys_by_values(my_dict):
    #check the input is a dictionary
    if type(my_dict) != dict:
        raise AssertionError('This function takes in a dictionary')
    #check that all values are numbers
    for key in my_dict:
        if type(my_dict[key]) != int and type(my_dict[key]) != float:
            raise AssertionError('Values of the input dictionary must be numbers')
    #obtain 2d list of a tuple key values pair
    list_key_value=list(my_dict.items())
    #obtain a list of values
    values=[]
    for key, value in list_key_value:
        values.append(value)
    values.sort()
    #sort the values from large to small
    values_rev=values[::-1]
    key_sorted=[]
    counted=[]
    #iterate through the values from large to small
    for i in range(len(values_rev)):
        #then iterate through keys and values in the dictionary, and check if the value matches
        for key, value1 in list_key_value:
            if (values_rev[i] not in counted) and (value1 == values_rev[i]):
                #find the key when Value1==values_rev[i]
                #check if there are multiple keys refering to the same value
                if values_rev.count(values_rev[i])==1:
                    key_sorted.append(key)
                #when there are multiple keys refering to the same value
                else:
                    key_rep=[]
                    counted.append(values_rev[i])
                    #get all keys that refers to this value
                    for key1,value2 in list_key_value:
                        if value2==values_rev[i]:
                            key_rep.append(key1)
                    key_rep.sort()
                    #sort those keys and append them to key_sorted
                    key_rev=key_rep[::-1]
                    key_sorted += key_rev
    return key_sorted

        
                            
         
                
        
        
