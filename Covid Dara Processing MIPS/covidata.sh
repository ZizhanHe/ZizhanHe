#!/bin/bash
#Name: Herbie He
#ID:260943211



errorMsg(){
	scriptSyn='./covidata.sh -r procedure id range inputFile outputFile compareFile'
	echo -e "Error:\n\t$1"
	echo -e "Script syntax:\n\t$scriptSyn"
	echo -e "Legal usage examples:\n\t./covidata.sh get 35 data.csv result.csv\n\t./covidata.sh -r get 35 2020-01 2020-03 data.csv result.csv\n\t./covidata.sh compare 10 data.csv result2.csv result.csv\n\t./covidata.sh -r compare 10 2020-01 2020-03 data.csv result2.csv result.csv"
}

#check if procedure is provided (either get or compare)
if [[ !($* = *[cC]ompare* || $* = *[gG]et*) ]]
then
	errorMsg 'Procedure not provided / Wrong procedure name'
fi

#check if correct number of elements is provided, #between 4 and 8
if [[ $# -lt 4 || $# -gt 8 ]]
then
	if [[ $* != *[gG]et* && $* != *[cC]ompare* ]]
	then
		errorMsg 'Wrong number of arguments'
	fi
fi


Get(){
	id=$2
	input=$3
	output=$4
	error=error.txt
	echo -n '' > $output
	##copy the row with id $2 to $4 file from $3 file
	awk -v lid="$id" -v output="$output" -v error="$error" '
	BEGIN { FS="," ; totRows=0; totNumConf=0; totNumDeaths=0; totNumTests=0 }
	{ if ($1 == lid )
		{ totRows++ ;
		 	totNumConf+=$6 ;
		       	totNumDeaths+=$8 ;
		       	totNumTests+=$11; 
			print $0 >> output } }
			END { 
			{if (totRows ==  0)
				{print "1" >> error }
			else
			{avgNumConf= totNumConf/totRows; avgNumDeaths=totNumDeaths/totRows; avgNumTests=totNumTests/totRows; OFS="," ; print "rowcount,avgconf,avgdeaths,avgtests" >> output; print totRows,avgNumConf, avgNumDeaths, avgNumTests >> output}} }' < $input
#check is the output file exists or not, if it does not exists, then the id does not exists
	if [[ -f $error ]]
	then
		rm $error
		errorMsg 'Wrong ID'
	fi
}

#compare
#check conditions by first checking which if the keyword (get compare) it match, then check if it has appropariate components

#one awk to cpoy rows to output file, and calculate data and store it in a another file
#a awk for adding rows from comp file to output file, and adding data to the other file
#a owk for the other file, which contains 4 lines of info and ata, use awk to obtain the data needed (determined by line numbet 1 3, calculate diference, then add all of then ot the output file.

Compare(){
	id=$2
        input=$3
        output=$4
	comp=$5
	inter=inter.txt
	error=error.txt
	echo -n '' > $output
        ##copy the row with id $2 to $4 file from $3 file
        awk -v lid="$id" -v output="$output" -v inter="$inter" -v error="$error" '
        BEGIN { FS="," ; totRows=0; totNumConf=0; totNumDeaths=0; totNumTests=0 }
        { if ($1 == lid )
                { totRows++ ;
                        totNumConf+=$6 ;
                        totNumDeaths+=$8 ;
                        totNumTests+=$11; 
                        print $0 >> output } }
			END {
		       	{if (totRows ==  0)
                                {print "1" >> error } 
			else
			{ avgNumConf= totNumConf/totRows; avgNumDeaths=totNumDeaths/totRows; avgNumTests=totNumTests/totRows; OFS="," ; print "rowcount,avgconf,avgdeaths,avgtests" >> inter; print totRows,avgNumConf, avgNumDeaths, avgNumTests >> inter }} }' < $input
	if [[ -f $error ]]
        then
	 	rm $error      
		errorMsg 'Wrong ID'
        fi
	#stop here! change inter.txt to a variable!
	#append rows to output
	cat $comp | wc -l > lineNum
	read compTotLine < lineNum
	rm lineNum
	awk -v output="$output" -v totLine="$compTotLine" -v inter="$inter" '
	BEGIN {FS=","}
	{ if ( NR <= (totLine-2))
		{print $0 >> output}
	else
		{print $0 >> inter}
	} ' < $comp

	awk -v output="$output" '
	BEGIN {FS=","; totrow1=0; avgconf1=0; avgdeaths1=0; avgtests1=0; totrow2=0; avgconf2=0; avgdeaths2=0; avgtests2=0; diffrow=0; diffavgconf=0; diffavgdeath=0; diffavgtests=0}
	{ if ($0 ~ /rowcount/ )
		{print $0 >>output}
	else
		{ if (NR == 2)
			{ totrow1=$1;avgconf1=$2; avgdeaths1=$3; avgtests1=$4; print $0 >> output}
		else
			{ totrow2=$1;avgconf2=$2; avgdeaths2=$3; avgtests2=$4; print $0 >>output}
		}
	}
	END {diffrow=totrow1-totrow2; diffavgconf=avgconf1-avgconf2; diffavgdeath=avgdeaths1-avgdeaths2; diffavgtests=avgtests1-avgtests2; print "diffcount,diffavgconf,diffavgdeath,diffavgtests" >> output; OFS="," ; print diffrow,diffavgconf,diffavgdeath,diffavgtests >>output}' < $inter 
	rm inter.txt

}


#first obtain a file with rows of those months
#use a for loop from the begin moenth to end month, for (5-2) may-to-jan
#for each loop, use awk to loop through the rows, if the rows's month matches, then check its date. i#f date 1<=d<=15, add to the first 15days data, if date 16<=d<=31, add to the second 15 days data. In# the end, calculate the two set of data, append to output file the two lines.store the difff data for the first 15days and last15 days for each loop in a intremediate file, if is 'compare' then we can access that file, if not, then it will be deleted.
#keep looping for the next month

#Compare $1 $2 $3 $4 $5

switchR(){
	operation=$2
	id=$3
	input=$6
	output=$7
	start=$4
	end=$5
	echo -n '' > $output
	if [[ $operation = compare ]]
	then
		compfile=$8
	fi
	startYear=${start:0:4}
	endYear=${end:0:4}
	startMonth=${start:5:2}
	endMonth=${end:5:2}
	diffYear=$( expr $endYear - $startYear )
	interfile=inter.csv
	if [[ diffYear -ne 0 ]]
	then
		s1=$( echo "12 - $startMonth" | bc )
		s2=$( echo "($diffYear - 1 ) * 12" | bc )
		s3=$( echo "$s2 + $endMonth" | bc )
		diffMonth=$(echo " $s1 + $s3" | bc )
	else
		diffMonth=$( expr $endMonth - $startMonth )
	fi
#get output file with all rows within the year and months
	awk -v lid="$id" -v output="$output" -v inter="$interfile" '
        BEGIN { FS=","  }
        { if ($1 == lid )
		{ print $0 >> inter}
	}'	< $input	
        if [[ -f $interfile ]]
        then
                garbage=0
        else
                errorMsg 'Wrong ID'
        fi

	
	i=0       #counter of month
	listofdates=()
	startMonth=$(expr $startMonth + 0 )
	while [[ $i -le $diffMonth ]]
	do
		if [[ $startMonth -le 12 ]]
		then
			if [[ $startMonth -lt 10 ]]
                        then
				startMonth=0${startMonth}
                        fi
			listofdates+=(${startYear}-${startMonth})
			startMonth=$(expr $startMonth + 1 )
			i=$(expr $i + 1)	
		else
			startMonth=1
			startYear=$(expr $startYear + 1)
		fi
	done
	k=0
	while [[ $k -lt ${#listofdates[@]} ]]
	do
		grep ${listofdates[$k]} $interfile >> $output
		k=$(expr $k + 1)
	done	
	
	intercomparedate=intercomp.csv
	if [[ $operation = compare ]]
	then
		awk -v output="$output" -v inter="$intercomparedate" '
		BEGIN {FS=","; seprownum=999999}
		{if (NR >= seprownum)
			{ print $0 >> inter }
		else
			{{if ($0 ~ /rowcount/)
				{seprownum=NR+1}
				else
				{print $0 >> output }}}}' < $compfile
	fi

	echo 'rowcount,avgconf,avgdeath,avgtests' >> $output
	for dates in ${listofdates[@]}
	do
		matchpattern1="$dates-[0][1-9]"
		matchpattern2="$dates-[1][0-5]"
		awk -v dates="$dates" -v match1="$matchpattern1" -v match2="$matchpattern2" -v output="$output" -v inter="$intercomparedate" '
		BEGIN {FS="," ; firsttotrows=0 ; firsttotconf=0 ; firsttotdeath=0 ; firsttottest=0 ; secondtotrows=0 ; secondtotconf=0; secondtotdeaths=0; secondtottest=0 }
		{if ($5 ~ dates)
			{ if ( $5 ~ match1 || $5 ~ match2)
				{ firsttotrows+=1 ; firsttotconf+=$6; firsttotdeath+=$8 ; firsttottest+=$11 }
			else
				{  secondtotrows+=1 ; secondtotconf+=$6; secondtotdeath+=$8; secondtottest+=$11}
		}}
		END { {if (firsttotrows == 0) 
			{avgfirstconf=0 ; avgfirstdeath=0; avgfirsttest=0}
		else
			{avgfirstconf=firsttotconf/firsttotrows ; avgfirstdeath=firsttotdeath/firsttotrows ; avgfirsttest=firsttottest/firsttotrows}
		  	};
			OFS="," ; print firsttotrows,avgfirstconf,avgfirstdeath,avgfirsttest >> output ; 
			{ if (secondtotrows == 0)
				{avgsecondconf=0; avgseconddeath=0; avgsecondtest=0}
			else
				{avgsecondconf=secondtotconf/secondtotrows; avgseconddeath=secondtotdeaths/secondtotrows; avgsecondtest=secondtottest/secondtotrows}
			}; print secondtotrows,avgsecondconf,avgseconddeath,avgsecondtest >> output; print firsttotrows,avgfirstconf,avgfirstdeath,avgfirsttest >> inter; print secondtotrows,avgsecondconf,avgseconddeath,avgsecondtest >> inter }' <$output
	done
	
	if [[ $operation = compare ]]
	then
		cat $intercomparedate | wc -l > lineNum1
        	read interlinenum  < lineNum1
        	rm lineNum1
		awk -v totinterlinnum="$interlinenum" -v output="$output" '
		BEGIN {FS=","; compfileline=totinterlinnum/2; print "rowcount,avgconf,avgdeath,avgtests" >> output}
		{ if (NR <= compfileline)
			{ print $0 >> output }}
		' < $intercomparedate
		
		echo "diffcount,diffavgconf,diffavgdeath,diffavgtests" >> $output
		halfinternum=$(expr $interlinenum / 2 )
		counter=1
		while [[ $counter -le $halfinternum ]]
		do
			awk -v output="$output" -v operationline="$counter" -v halfinternum="$halfinternum" '
			BEGIN {FS="," ; firstrowcount=0; firstavgconf=0; firstavgdeath=0; firstavgtests=0; secondrowcount=0; secondavgconf=0; secondavgdeath=0; secondavgtests=0}
			{ {if (NR == operationline)
				{firstrowcount=$1; firstavgconf=$2; firstavgdeath=$3; firstavgtests=$4 }};
			
			{if (NR == operationline+halfinternum)
				{secondrowcount=$1; secondavgconf=$2; secondavgdeath=$3; secondavgtests=$4 }}
			}
			END {diffrowcount=secondrowcount-firstrowcount; diffavgconf=secondavgconf-firstavgconf; diffavgdeath=secondavgdeath-firstavgdeath;  diffavgtests=secondavgtests-firstavgtests; OFS=","; print diffrowcount,diffavgconf,diffavgdeath,diffavgtests >> output }' < $intercomparedate
			counter=$(expr $counter + 1 )
		done	
	fi
	rm $interfile
	rm $intercomparedate	

	
}



#first obtain a file with rows of those months
#use a for loop from the begin moenth to end month, for (5-2) may-to-jan
#for each loop, use awk to loop through the rows, if the rows's month matches, then check its date. i#f date 1<=d<=15, add to the first 15days data, if date 16<=d<=31, add to the second 15 days data. In# the end, calculate the two set of data, append to output file the two lines.store the difff data for the first 15days and last15 days for each loop in a intremediate file, if is 'compare' then we can access that file, if not, then it will be deleted.
#keep looping for the next month

#intermediate file should contain all data for data fiel and comp file in order!


#calculate the line number of intercomparedate, and loop line#/2 times, each time use awk to compare line number (NR=i) and line number (NR=i+ (line#/2)) where i is a counter starting from 1. If range is 2020-01 2020-03, 2020-03 2020-05 then there will be 4 rows for data file and comp file (8 in total). First loop, compare NR=1 and NR=1+4  ... until NR=4 , NR=4+4

#first obtain a intermediate file containing the rows with the id
#obtain a list contiang the year-month that need to be extracted x=(2020-01, 2021-03, 2022-01)
#loop through x, and grep all the content matching to the output file
#switchR $1 $2 $3 $4 $5 $6 $7 $8
#end of line

#invoke get
if [[ $* = *[gG]et* && $* != *-[rR]*  ]]
then
#check for num of arguments
	if [[ $# -ne 4 ]]
        then
                errorMsg 'Wrong number of arguments for get'
        else
                Get $1 $2 $3 $4
        fi
fi

#invoke compare
if [[ $* = *[cC]ompare* && $* != *-[rR]* ]]
then
	if [[ $# -ne 5 ]]
        then
                errorMsg 'Wrong number of arguments for compare'
        else
                Compare $1 $2 $3 $4 $5
        fi
fi

#invoke switch R get
if [[ $* = *[gG]et* && $* = *-[rR]* ]]
then
	if [[ $# -ne 7 ]]
        then
                errorMsg 'Wrong number of arguments for using get -r'
        else
                switchR $1 $2 $3 $4 $5 $6 $7
        fi
fi

#invoke switch R compare
if [[ $* = *[cC]ompare* && $* = *-[rR]* ]]
then
        if [[ $# -ne 8 ]]
        then
                errorMsg 'Wrong number of arguments compare -r'
        else
                switchR $1 $2 $3 $4 $5 $6 $7 $8
        fi
fi


