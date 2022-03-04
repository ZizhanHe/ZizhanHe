import coin_utils
import random
ALPHABET = 'qwertyuiopasdfghjklzxcvbnm1234567890äéèçæœ'
PUNCTUATION = '`~!@#$%^&*()-=_+[]\{}|;\':",./<>? \t\n\r'
ALL_CHARACTERS = ALPHABET + PUNCTUATION
MIN_BASE10_COIN = 0
MAX_BASE10_COIN = 16777215
LETTERS_IN_POPULARITY_ORDER = ' EOTARNLISMHDYFGCWPUBVXK.,\'"-;'
BASE8_CHARS   = '01234567'
BASE202_CHARS = '0C2OMPIN'

def get_crypt_dictionary(keys, value_generator):
    '''
    (list, function)->(dict)
    The function takes in a list of unique keys, and returns a dictionary with each key corresponding
    to the value value_generator generates.
    
    >>>random.seed(0)
    >>>x = get_crypt_dictionary(['a', 'b', 'c'], coin_utils.get_random_comp202coin)
    >>>x
    {'a': '0cCOMIN0MP', 'b': '0cONCPONIP', 'c': '0c22POPPOM'}
    
    >>>x = get_crypt_dictionary(['a', 'b', 'c'], coin_utils.get_random_character)
    >>>x
    {'a': ',', 'b': '6', 'c': ';'}
    
    >>>random.seed(1)
    >>>x = get_crypt_dictionary(['a', 'b', 'c'], coin_utils.get_random_character)
    >>>x
    {'a': 'k', 'b': '>', 'c': 'o'}
    
    >>>get_crypt_dictionary(['a', 'a', 'a'], coin_utils.get_random_character)
    Traceback (most recent call last)
    AssertionError: Values in keys should be unique
    
    >>>get_crypt_dictionary(('a', 'b', 'c'), coin_utils.get_random_character)
    Traceback (most recent call last):
    AssertionError: The first argument of the function should be a list
    
    '''
    #check conditions
    if type(keys) != list:
        raise AssertionError('The first argument of the function should be a list')
    for key in keys:
        if keys.count(key) >1:
            raise AssertionError('Values in keys should be unique')
    new_dict={}
    counted=[]
    for index, key in enumerate(keys):
        #generate values using value_generator
        value=value_generator(index)
        #regenerate value if the previous one already exists in dict
        while value in counted:
            value=value_generator(index)
        new_dict[key]=value
        counted.append(value)
    return new_dict


def encrypt_text(text):
    '''
    (str)-> (str, dict)
    This function takes in a string with characters from ALL_CHARACTERS, then it encrypt the string into comp202coin
    with dictionary generated with get_crypt_dictionary function, and returns the enctrypted string and the dictionary as tuple.
    
    >>>random.seed(9001)
    >>>s, d = encrypt_text('hello')
    >>>s
    '0c0MPNN0OC-0cMIMNIO0P-0cM0OCCIOI-0cM0OCCIOI-0cC0PIIMCP-'
    >>>d
    {'h': '0c0MPNN0OC', 'e': '0cMIMNIO0P', 'l': '0cM0OCCIOI', 'o': '0cC0PIIMCP'}
    
    >>>random.seed(0)
    >>>s, d = encrypt_text('he@wa')
    >>>s
    '0cIC2ONOON-0cIPIP2MP0-0c0PCOPCOI-0cMCCC02NM-0cNICMPI0O-'
    
    >>>random.seed(1)
    >>>s, d=encrypt_text('')
    >>>d
    {}
    
    >>>s,d=encrypt_text(['hello'])
    Traceback (most recent call last):
    AssertionError: This function takes in a string
    
    >>>s,d=encrypt_text('好')
    Traceback (most recent call last):
    AssertionError: All characters in text enetered must be in ALL_CHARACTER
    '''
    #encrypts chars in text into comp202coins
    #returns a string of comp202coin and a dictionary
    #check if characters are all in ALL_CHARACTERS
    if type(text) != str:
        raise AssertionError('This function takes in a string')
    lower_text=text.lower()
    for char in lower_text:
        if char not in ALL_CHARACTERS:
            raise AssertionError('All characters in text enetered must be in ALL_CHARACTER')
    #create keys for the dictionary
    unique_char_list=coin_utils.get_unique_elements(list(lower_text))
    #generate the dictionary
    encrypt_dict=get_crypt_dictionary(unique_char_list, coin_utils.get_random_comp202coin)
    new_str=''
    #encrypt the string using the dictionary
    for char in lower_text:
        new_str+=(str(encrypt_dict[char])+'-')
    return (new_str.strip('-'),encrypt_dict)




        
def encrypt_file(file_name):
    '''
    (str)->(file)
    This function reads a file, encrypt its content, and writes the encrypted content
    into a new file with name _encrypted added to its end and returns the dictionary used
    to encrypt.
    
    >>>random.seed(0)
    >>>encrypt_file('dubliners.txt')
    {'t': '0cM0022NNC', 'h': '0cPOCOOPCM', 'e': '0cNO2PMCIM', ' ': '0cIOMCN20P',
    'p': '0cCMMPICPP', 'r': '0c22CO0PMC', 'o': '0cPIONCOMI', 'j': '0cMP0P2PN2',
    'c': '0cP0P2MOIM', 'g': '0c0NM2C0MN', 'u': '0c2PIO0OII', 'n': '0cOMO0O2C0',
    'b': '0cNPCNICC0', 'k': '0c02OMMM0I', 'f': '0cNNIII0CP', 'd': '0cINOOIOII',
    'l': '0cMINPONPC', 'i': '0cC0CNO2PP', 's': '0cCNOPCCNI', ',': '0cM2PIPC2C',
    'y': '0cICNMOIOP', 'a': '0c2INMPOIC', 'm': '0cMNP2OCCC', '\n': '0cNPPIOCI2',
    'w': '0cCPM2PIC2', 'v': '0cIPPMOMM0', '.': '0c02I0CO2O', '-': '0cPMPMNICP',
    ':': '0cI0CCMO2C', '2': '0cMIINICNC', '0': '0cN2MCOM20', '1': '0cNI0CNO0O',
    '[': '0c0NOO220C', '#': '0cMOPCIPO2', '8': '0cMNOPPIMI', '4': '0cM0MIPPPC',
    ']': '0c0NOPCC0I', '9': '0cIPINONM0', '*': '0cNI0PPN2P', 'z': '0cPOCM0N0P',
    '(': '0cOI2CI2C0', ')': '0cCC2CN0PM', 'q': '0cNOM2MPMC', '"': '0c0PO0OPNC',
    "'": '0cPCICI0PP', 'x': '0cM020O0II', '!': '0cPP2MNNCM', ';': '0c020COOOC',
    '?': '0cOM0OMMMO', '_': '0c0NPPIP0C', '5': '0cPPIM2IM2', 'é': '0cNC2CCPOP',
    'è': '0cIPIC20IM', 'ç': '0cP0I02IOP', '&': '0c0IIP22OC', 'æ': '0cP2CIPOPP',
    '7': '0cPCNPP2NN', '6': '0cOO2N0CC0', 'œ': '0cONPNM2PM', '/': '0c22CCINNO',
    '3': '0cPPPO2O2N', '%': '0cCCPPPNPI', '@': '0cOO22C0IP', '$': '0c2P0NNNI0'}
    
    >>>fobj=open('dubliners_encrypted.txt', 'r', encoding='utf-8')
    >>>len(fobj.read())
    4282476
    
    >>>random.seed(1)
    >>>d=encrypt_file('dubliners.txt')
    >>>len(d)
    64
    
    >>>random.seed(42)
    >>>d=encrypt_file('dubliners.txt')
    >>>len(d)
    64
    
    '''
    
    fobj1=open(file_name,'r')
    s,d=encrypt_text(fobj1.read())
    fobj1.close()
    fobj2=open(file_name.strip('.txt')+'_encrypted'+'.txt','w')
    fobj2.write(s)
    return d

def decrypt_text(text, decryption_dict):
    '''
    (str,dict)->(str)
    This function takes in a encrypted string and a  dictionary, then it decrypt the string
    using the dictionary and returns the new string.
    
    >>>d={'0c0MPNN0OC': 'a', '0cMIMNIO0P': 'b', '0cM0OCCIOI': 'c'}
    >>>decrypt_text('0c0MPNN0OC-0cM0OCCIOI-0c0MPNN0OC',d)
    'aca'
    
    >>>d={'0c0MPNN0OC': 'h', '0cMIMNIO0P': 'e', '0cM0OCCIOI': 'l','0cIPIC20IM':'o'}
    >>>decrypt_text('0c0MPNN0OC-0cMIMNIO0P-0cM0OCCIOI-0cM0OCCIOI-0cIPIC20IM',d)
    'hello'
    
    >>>d={'0c0MPNN0OC': 'h', '0cMIMNIO0P': 'e', '0cM0OCCIOI': 'l','0cIPIC20IM':'o'}
    >>>decrypt_text('0c0MPNN0OC-0c0MPNN0OC-0c0MPNN0OC-0c0MPNN0OC',d)
    'hhhh'
    
    >>>d={'0c0MPNN0OC': 'h', '0cMIMNIO0P': 'e', '0cM0OCCIOI': 'l'}
    >>>decrypt_text(['0c0MPNN0OC','0c0MPNN0OC','0c0MPNN0OC'],d)
    Traceback (most recent call last):
    AssertionError: The first argument of this function should be a string
    
    >>>d=('0c0MPNN0OC', 'h')
    >>>decrypt_text('0c0MPNN0OC',d)
    Traceback (most recent call last):
    AssertionError: The second argument of this function should be a dict
    '''
    
    if type(text) != str:
        raise AssertionError('The first argument of this function should be a string')
    if type(decryption_dict) != dict:
        raise AssertionError('The second argument of this function should be a dict')
    text_list=coin_utils.get_all_coins(text)
    new_list=[]
    for comp in text_list:
    #iterate through every comp202coin inside the text
        try:
            #use the inputed dictionary to decrypt each word
            new_list.append(decryption_dict[comp])
        except KeyError:
            #if the dictionary does not cover all comp202coin, raise an error
            raise AssertionError('Dictionary inputed does not include every word in the text')
    new_str=''.join(new_list)
    return new_str



def decrypt_file(file_name, decryption_dict):
    '''
    This function takes in a string representing the file name and a dictionary.
    The function reads the content of the file, decrypts it using the given dictionary
    and writes the new content into a new file with `_decrypted' appended to its name.
    
    >>>decrypt_file('dubliners_encrypted.txt', coin_utils.reverse_dict(encrypt_file('dubliners.txt')))
    >>>fobj = open('dubliners.txt', 'r', encoding='utf-8')
    >>>fobj2 = open('dubliners_encrypted_decrypted.txt', 'r', encoding='utf-8')
    >>>fobj.read().lower() == fobj2.read()
    True
    >>>len(fobj.read())==len(fobj2.read()
    True
    >>>fobj.read(100).lower()==fobj2.read(100)
    True
    '''
    fobj1=open(file_name,'r')
    decrypted_str=decrypt_text(fobj1.read(),decryption_dict)
    fobj1.close()
    fobj2=open(file_name.strip('.txt')+'_decrypted'+'.txt','w')
    fobj2.write(decrypted_str)


def random_decrypt(encrypted_s, n, common_words_filename):
    '''
    (str, pos int, str)
    This function takes in a encrypted string, a positive integer n, and a file. It decrypts the string n
    times and returns the best possible decryption based on the percentage of characters in decrypted string
    that belongs to common words file. If multiple decryption have the same percentage, then returns the
    last string based on python string comparision.
    
    >>>random.seed(0)
    >>>encrypted_s = '0c0MPNN0OC-0cMIMNIO0P-0cMIMNIO0P'
    >>>random_decrypt(encrypted_s, 10**2, 'common_words.txt')
    '\\oo'
    
    >>>random_decrypt(encrypted_s, 10**3, 'common_words.txt')
    '}ff'
    
    >>>random.seed(1)
    >>>encrypted_s = '0c0MPNN0OC-0cMIMNIO0P-0cMIMNIO0P-0cMIMN0O0P'
    >>>random_decrypt(encrypted_s, 10**2, 'common_words.txt')
    '|ff^'
    
    >>>random_decrypt(encrypted_s, 10**2, 'common_words.txt')
    'y""s'
    
    >>>random.seed(2)
    >>>encrypted_s = '0coMPNN0oC-0cMIMNIO0P-0cMIMNIO0P-0cMIMN0O0P'
    >>>random_decrypt(encrypted_s, 10**2, 'common_words.txt')
    'r\\\\y'
    
    >>>random_decrypt(('d','d'), 10**2, 'common_words.txt')
    Traceback (most recent call last):
    AssertionError: First argument of the function must be a string
    
    >>>encrypted_s = '0coMPNN0oC-0cMIMNIO0P-0cMIMNIO0P-0cMIMN0O0P'
    >>>random_decrypt(encrypted_s, 0, 'common_words.txt')
    Traceback (most recent call last):
    AssertionError: Second argument of the function must be a positive intger
    
    '''
    #check conditions
    if type(encrypted_s) != str:
        raise AssertionError('First argument of the function must be a string')
    if type(n) != int or n<=0:
        raise AssertionError('Second argument of the function must be a positive intger')
    #obtain keys for the dictionary
    keys_comp=coin_utils.get_unique_elements(encrypted_s.split('-'))
    decrypt_n_dict={}
    #create a list that stores frequency of each decryption
    percent_list=[]
    all_coins=coin_utils.get_all_coins(encrypted_s)
    for i in range(n):
        #create a new list that will store the decrypted words
        new_list=[]
        decry_dict=get_crypt_dictionary(keys_comp, coin_utils.get_random_character)
        for comp in all_coins:
            new_list.append(decry_dict[comp])
        decrypted_str=''.join(new_list)
        #obtain the percentage for this iteration of decryption
        percent=coin_utils.get_pct_common_words(decrypted_str,common_words_filename)
        #append the frequency obtained in this iteration to the list
        percent_list.append(percent)
        #append the result string and its frequency to the dictionary
        decrypt_n_dict[decrypted_str]=percent
    #returns the decrypted string with max frequency
    decrypted_str_sorted=coin_utils.sort_keys_by_values(decrypt_n_dict)
    return decrypted_str_sorted[0]



def decrypt_with_user_input(encrypted_s):
    '''
    (str)->(none)
    This function takes a encrypted string as argument, and decrypt the string based on a dictionary
    that has its keys being comp202coin and values being a character from  LETTERS_IN_POPULARITY_ORDER. The index of
    the character is determined by its key's (comp202coin) frequency in the encrypted string. For example,
    if `0c0MPNN0OC' has the highest frequency, then it will have value  LETTERS_IN_POPULARITY_ORDER[0]. After printing
    the decrpted string, the function asks if the user want to swap letters, and keep swapping letters in
    the decrypted string until user is satisfied.
    
    >>>random.seed(0)
    >>>s,d= encrypt_text('Hello')
    >>decrypt_with_user_input(s)
    Decrypted string: TO  EA
    End decryption? n
    Enter first letter to swap:  
    Enter second letter to swap: E
    TOEE A
    End decryption? N
    Enter first letter to swap: T
    Enter second letter to swap: A
    AOEE T
    End decryption? Y
    
    >>>random.seed(1)
    >>>s,d= encrypt_text('Hello? HELLO ')
    >>decrypt_with_user_input(s)
    Decrypted string: AT  OREAT  OEN
    End decryption? N
    Enter first letter to swap: A
    Enter second letter to swap: T
    TA  ORETA  OEN
    End decryption? No
    Enter first letter to swap: AT
    Enter second letter to swap: Oe
    Traceback (most recent call last):
    AssertionError: Last two input should be strings of length 1
    
    >>>random.seed(1)
    >>>s,d= encrypt_text('1234 4321')
    >>decrypt_with_user_input(s)
    Decrypted string: TO EAE OTR
    End decryption? no
    Enter first letter to swap: O
    Enter second letter to swap: T
    OT EAE TOR
    End decryption? yes
    '''
    if type(encrypted_s) != str:
        raise AssertionError('This function takes in a string as arugument')
    #list of unique comp202coin
    keys_comp=coin_utils.get_unique_elements(coin_utils.get_all_coins(encrypted_s))
    #list of all comp202coin
    all_coins=coin_utils.get_all_coins(encrypted_s)
    #dict with keys being comp202coin and values being frequency
    dict_frequency=coin_utils.get_frequencies(all_coins)
    #create a list of comp202coin sorted by their frequency from big to smalll
    comp202_sorted=coin_utils.sort_keys_by_values(dict_frequency)
    decrypt_dict={}
    for key in keys_comp:
        #create a dicionary with key being the comp202coin, and value being the character in
        #LETTERS_IN_POPULARITY_ORDER with its index determined by the index of that comp202coin
        #in comp202_sorted
        decrypt_dict[key]=LETTERS_IN_POPULARITY_ORDER[comp202_sorted.index(key)]
    decrypt_str=decrypt_text(encrypted_s, decrypt_dict)
    print('Decrypted string: '+decrypt_str)
    satisfied=False
    #while loop that keeps asking for user to swap letters until they are satisfied
    while not satisfied:
        user_answer=input('End decryption? ')
        while user_answer not in ('y yes Y YES') and user_answer not in ('n no N NO'):
             user_answer=input('Please enter a valid answer Yes/No \nEnd decryption? ')
        if user_answer in ('y yes Y YES'):
            satisfied=True
        elif user_answer in ('n no N NO'):
            satisfied=False
            first_letter=input('Enter first letter to swap: ')
            second_letter=input('Enter second letter to swap: ')
            decrypt_str=coin_utils.swap_letters(decrypt_str,first_letter,second_letter)
            print('Decrypted string: '+decrypt_str)






            
        
            
            
    