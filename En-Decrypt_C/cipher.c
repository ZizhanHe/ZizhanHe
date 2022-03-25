#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void errorMsg(char *msg){
	printf("%s\n",msg);
	printf("Program syntax: ./cipher SWITCH KEY LENGTH < FILENAME\n");
	printf("Legal usage examples:\n./cipher -e 10 100 < filename.txt\n./cipher -d 10 200 < filename.e");
}


void encrypt(int key, int length) {
	char inputData[500];
	int lineToFill=0;
	char matrix[500][500];
	int size=0;
	for (int i=0; i<length; i++){
		inputData[size]=getc(stdin);
		size++;
	}

	int lastlined=0;
	int filled=1;
	int countsize=0;
	//printf("inputdata:%s\n",inputData);
	


	//printf("size:%d\n",size);
	//printf("here1");
	for( int i=0; filled ; i++){
		lineToFill++;
		int linefilled=0;
		for (int j=0; j<key && countsize<=size; j++){
			if (countsize==size){
                                matrix[i][j]=inputData[countsize];
                                lastlined=linefilled;
                                filled=0;
                                //printf("lastlined: %d\n",lastlined); 
			}else{
				matrix[i][j]=inputData[countsize];
				//printf("inputdata at size:%d is: %c\n",countsize,inputData[countsize]);
				countsize++;
				linefilled++;
				//printf("matrix element correspond[%d][%d]: %c\n",i,j,matrix[i][j]);
			}
		}
	}
	//printf("matrix[9][2]: %c\n",matrix[9][2]);
	//printf("linetoFill:%d\n",lineToFill);
	
	for (int i=0; i<key; i++){
		for(int j=0; j<lineToFill ;j++){
			if ( j==(lineToFill-1) && i>= lastlined){
				//printf("index of space- row: %d col:%d",j,i);
				putchar(' ');
			}else{
				putchar(matrix[j][i]);
				//printf("element at matrix[%d][%d] is put\n",j,i);
			}
		}	
	}

}


void decrypt(int key, int length){
	char inputData[500];
	int lineToFill=0;
	char matrix[500][500];
	int size=0;

	lineToFill=(length/key);
	if ((length%key) !=0 ){
		lineToFill++;
	}

	//printf("%d\n", lineToFill);
	for (int i=0; i<= (key*lineToFill);i++){
		//printf("%c\n", getc(stdin));
		inputData[size]=getc(stdin);
		//printf("%c\n",inputData[size]);
		size++;
		
	}

	//printf("%s\n",inputData);
	int countsize=0;
	for (int i=0; i<key; i++){
		for(int j =0; j< lineToFill; j++){
			matrix[j][i]=inputData[countsize];
			countsize++;
			//printf("%c\n",matrix[j][i]);
		}
	}

	int count=0;
	for (int j=0; j<lineToFill; j++){
		for( int i=0; i<key && count<=length; i++){
			putchar(matrix[j][i]);
			count++;
		}
	}
}


int main(int argc, char *argv[]){
	if (argc != 4){
		char *msg= "Incorrect number of arguments\n";
		errorMsg(msg);
		return 1;
	}
	if ((strcmp(argv[1],"-e") != 0) && (strcmp(argv[1], "-d")!=0)){
		char *msg= "Switch not supported\n";
       		errorMsg(msg);
	 	return 2;
	}
	int key = atoi(argv[2]);
        int length=atoi(argv[3]);
	
	if (length >= 500){
		char *msg= "LENGTH must be less than 500\n";
		errorMsg(msg);
		return 3;}
	if (length == 0){
		char *msg ="LENGTH cannot be zero\n";
		errorMsg(msg);
		return 5;}
	if (key >= length ){
		char *msg= "KEY must be less than LENGTH\n";
		errorMsg(msg);
		return 4;}	
	
	
	if (strcmp(argv[1],"-e") == 0){
		encrypt(key, length);
		//printf("here");
		printf("\n");
	}
	
	if (strcmp(argv[1], "-d")==0){
		decrypt(key, length);
		printf("\n");
	}

	return 0;
}

