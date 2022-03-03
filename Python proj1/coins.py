#assiignment question2
base8_chars='0,1,2,3,4,5,6,7'
base202_chars='0C2OMPIN'

def base10_to_202(amt_in_base10):
    '''
    (int)->(str)
    This function takes in intergers in base 10, convert it to base 202, and
    output the result as a string. Base 202 is base 8 with some digits replaced.
    >>>base10_to_202(202)
    '0c00000CC2'
    >>>base10_to_202(1234)
    '0c00002C22'
    >>>base10_to_202(0)
    '0c00000000'
    '''
    
    #first convert it into base 8
    base8=oct(amt_in_base10)
    base8_list=[]
    base8_list[:]=base8[2:]
    #replace the the characters
    for i in range(len(base8_list)):
        base8_list[i]=base202_chars[int(base8_list[i])] 
    base202_1=''
    for num in base8_list:
            base202_1 += str(num)
    base202_result='0c'+(8-len(base202_1))*'0'+base202_1
    return base202_result

#print(base10_to_202(202))

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
        if base202_list[i].upper() =='C':
            base202_list[i] ='1'
        if base202_list[i].upper() =='O':
            base202_list[i] ='3'
        if base202_list[i].upper() =='M':
            base202_list[i] ='4'
        if base202_list[i].upper() =='P':
            base202_list[i] ='5'
        if base202_list[i].upper() =='I':
            base202_list[i] ='6'
        if base202_list[i].upper() =='N':
            base202_list[i] ='7'
    base8=''
    #convert base8 into base10
    for num in base202_list:
        base8 += str(num)
    base10=int(base8,8)
    return base10
#print(base202_to_10('0c00000oc2')) testing

def is_base202(text):
    '''
    (str)->(bool)
    The function takes in a string of any length and returns True if the string
    is a valid comp202coin string, False if not.
    >>>is_base202('eisfs3010comp')
    False
    >>>is_base202('1ccomp20MP')
    False
    >>>is_base202('0cComp2020')
    True
    >>>is_base202('0cCoRp2020')
    False
    '''
    text=text.upper()
    if len(text) != 10:
        return False
    if text[:2] != '0C':
        return False
    for num in text[2:]:
        if num not in base202_chars:
            return False
    return True

def get_nth_base202_amount(text,n):
    '''
    (str,non_neg_int)->(str)
    The function takes in a string that can contain any characters of any length and
    a non-negative integre n. The function starts counting at n=0, and returns the n'th
    comp202 string in this text. If there is no comp202 string fot the given index n,
    the function returns an empty string.
    >>>get_nth_base202_amount(".0cCCMMPP22. sss ,,,, .... abcwed  0cOCOCOCOC.",1)
    '0cOCOCOCOC'
    >>>get_nth_base202_amount(".0cCCMMPP22. sss ,,,, .... abcwed  0cOCOCOCOC.",2)
    ''
    >>>get_nth_base202_amount(" ",0)
    ''
    '''
    list_of_base202=[]
    #obtain comp202 strings in a text and put them into a list
    for i in range(len(text)):
        #obtain the 10 character string that starts with 0c
        if text[i] == '0':
            if text[i+1] =='c':
                if (i+10)<=len(text):
                    base202=text[i:i+2].lower()+text[i+2:i+10].upper()
                    #check is the 10 characer string is a comp202 string
                    if is_base202(base202):
                        if base202 not in list_of_base202:
                            list_of_base202[i:i+1]=([base202])
    if n > len(list_of_base202)-1:
        return ''
    else:
        return list_of_base202[n]

#text=".0cCCMMPP22. sss ,,,, .... abcwed   0cOCOCOCOC  0coooocccc."
#print(get_nth_base202_amount(text,1)) testing

def nums_of_comp202(text):
    '''
    (str)->(int)
    returns the number of comp202 coin in the given text
    >>>nums_of_comp202('0ccomp0202 ..sfsfmbnv 0c00000002 .sfjse 0c0000mpin')
    3
    >>>nums_of_comp202('0ccomp0202 ..sfsfmbnv 0c00000002 .sfjse')
    2
    >>>nums_of_comp202('0ccomp02')
    0
    '''
    num_of_comp202=0
    while get_nth_base202_amount(text,num_of_comp202) != '':
        num_of_comp202 += 1
    return num_of_comp202


def get_total_dollar_amount(text):
    '''
    (str)->(int)
    This function takes in a string that could be of any length and can contain any characters,
    and returns the sum of dollar value (in base 10) of all comp202coin present in the text.
    >>>get_total_dollar_amount("BANKING TRANSACTIONS....PLANET ORION......FEBRUARY\
    #15, 3019.......0cCCMMPP22........FEBRUARY 16, 3019..........0cOCOCOCOC........\FEBRUARY 17, 3019..........0C24242412")
    9167275
    >>>get_total_dollar_amount('0ccomp2020 ......0cOCOCOCOC,,,,,0cCCMMPP22...0c0m0m0m0m')
    13268671
    >>>get_total_dollar_amount('0ccomwqwcz......0daasdass,,,,,0cCCMMdaadsas...0c0mads')
    0
    '''
    number_of_comp202=nums_of_comp202(text)
    list_base10=[]
    
    for i in range(number_of_comp202):
        #first obtain the nth comp202 string, then convert it to base10 and add it to list of base10
        list_base10.append(base202_to_10(get_nth_base202_amount(text,i)))
    total_dollar=sum(list_base10)
    return total_dollar

#print(get_total_dollar_amount("BANKING TRANSACTIONS....PLANET ORION......FEBRUARY\
#15, 3019.......0cCCMMPP22........FEBRUARY 16, 3019..........0cOCOCOCOC........\FEBRUARY 17, 3019..........0C24242412"))

    
def reduce_amounts(text,limit):
    '''
    (str,non_neg_num)->(str)
    This function takes in a string of any length and a non-negative numebr. The function first chekck if
    the total dollar value of comp202coin in the given string exceeds the given limit. If not, the function returns the
    original string; if it exceeds the limit, the function calcultaes the percent decrease, decrease each comp202
    in the text by the percentage, then return the modified string with everything else unchanged.
    >>>reduce_amounts("0cCCMMPP22 0cOCOCOCOC",9000000)
    '0cCCCCMCI0 0cC0NCPNCN'
    >>>reduce_amounts("0cCCMMPP22 0cOCOCOCOC",10000000)
    '0cCCMMPP22 0cOCOCOCOC'
    >>> reduce_amounts('0cCCMMPP22 0cOCOCOCOC',10)
    '0c00000002 0c0000000N'
    >>>reduce_amounts('0cCCMmpp22 0cOCOCoCoC',9000000)
    '0cCCCCMCI0 0cC0NCPNCN'
    '''
    num_of_comp202=nums_of_comp202(text)
    total_dollar=get_total_dollar_amount(text)
    #obtain the index of comp202 in the text
    if total_dollar<=limit:
        return text
    else:
        percent=(total_dollar-limit)/(total_dollar)
        new_comp202_list=[]
        for i in range(num_of_comp202):
            reduced_dollar=base202_to_10(get_nth_base202_amount(text,i))-base202_to_10(get_nth_base202_amount(text,i))*percent
            reduced_202=base10_to_202(int(reduced_dollar))
            new_comp202_list.append(reduced_202)
        #now replace the comp202 in old string with the reduced comp202
        text=text.lower()
        for i in range(num_of_comp202):
            text=text.replace(get_nth_base202_amount(text,i).lower(),new_comp202_list[i])
        return text

        
#print(reduce_amounts('0cCCMmpp22 0cOCOCoCoC',9000000))
    
    