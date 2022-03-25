//Herbie He
//ID: 260943211
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
FILE *state;
FILE *trans;

struct ACCOUNT {
	int accountNumber;
	double startingBalance;
	double endingBalance;
	struct ACCOUNT *next;
};

struct LINKEDLIST {
	struct ACCOUNT *head;
	struct ACCOUNT *tail;
	int size;
};

void displayMsg(){
	printf("Program syntax:\n");
	printf("\tTransactionVerification.c");
	printf("legal usage examples:\n");
	printf("\t./tv state.csv transaction.csv\n\t./tv ../state.csv /data/log/transaction.csv");
}

//read state.csv, this function takes in the file state.csv
//returns a linked list with accoutns filled.

struct LINKEDLIST read(FILE *state){
	struct LINKEDLIST bank;
        bank.head=NULL;
        bank.tail=NULL;
        bank.size=0;
        //read the state.csv
        while (!feof(state)){
                char line[120];
                int accNum;
                double start;
                double end;
                struct ACCOUNT *node;
		//get a line
                fgets(line,120,state);
                //skip the first line, and obtain the data
                if (line[0] !='a'){
                        char accNumstr[7];
                        char startstr[20];
                        char endstr[20];
                        //get the first6 int
                        for (int i=0; i<6; i++){
                                accNumstr[i]=line[i];
                        }
                        accNumstr[6]='\0';
                        accNum=atoi(accNumstr);
                        //printf("accNumstr: %s accNum: %d\n",accNumstr,accNum);
			//get start
			int j;
			int i;
			for(j=7, i=0; line[j]!= ','; i++, j++){
				startstr[i]=line[j];
			}
			//i++;
			startstr[i]='\0';
			start=atof(startstr);
			//get end
			//j should stop at-,- so increment j
			j++;
			int k;
			for (k=0;line[j] !='\0'; k++, j++){
				endstr[k]=line[j];
			}
			endstr[k+1]='\0';
			end=atof(endstr);
			//printf("endstr: %s\n",endstr);
			//printf("end: %f\n", end);
		
			//create a new node and add to local linked list
			node=(struct ACCOUNT *) malloc(sizeof(struct ACCOUNT));
			node->accountNumber=accNum;
			node->startingBalance=start;
			node->endingBalance=end;
			//printf("acc: %d start: %f end: %f\n",node->accountNumber,node->startingBalance,node->endingBalance);
			//ensure acc num is 6 digits
			if (node->accountNumber < 100000){
				continue;
			}
			//if linked list bank is empty, then construct a head
			//if node.acNum < bank.head.acNum, then the node will be the new head
			//if no these two special cases, then we iter through the linked list
			if (bank.size==0){
				node->next=NULL;
				bank.head=node;
				bank.size++;
				//printf("size increamen, acc num: %d\n",node->accountNumber);
			}else if(node->accountNumber < bank.head->accountNumber){
				node->next=bank.head;
				bank.head=node;
				bank.size++;
				//printf("size increamen, acc num: %d\n",node->accountNumber);
			}else{
				//iterate through linked list
				//three possible case
				//1.iter.next=NULL, then add node at the end
				//2.iter.acNum=node.acNum, then error
				//3.iter.acNum<node.acNum && node.acNum<iter.next.acNum, insert node between them
				int NotAdded=1;
				struct ACCOUNT *iter=bank.head;
				while (NotAdded){
					if (iter->accountNumber==node->accountNumber){
						printf("Duplicate account number [account, start, end]: %d %f %f\n",node->accountNumber,node->startingBalance,node->endingBalance);
                                                NotAdded=0;	
					}else if ( iter->next==NULL){
						node->next=NULL;
                                                iter->next=node;
                                                bank.size++;
                                                //printf("size increamen, acc num: %d\n",node->accountNumber);
                                                NotAdded=0;
					}else if(iter->accountNumber < node->accountNumber && node->accountNumber < iter->next->accountNumber){
						node->next=iter->next;
						iter->next=node;
						NotAdded=0;
						bank.size++;
						//printf("size increamen, acc num: %d\n",node->accountNumber);
					}
					iter=iter->next;	
			}
			//now the node has been added to the linked list
		}	
	
		}
	}
	return bank;

}

void printLinkedList(struct ACCOUNT *head){
	struct ACCOUNT *iter;
	iter=head;
	while (iter != NULL){
		printf("acc: %d ",iter->accountNumber);
		printf("start: %f ",iter->startingBalance);
		printf("end: %f\n",iter->endingBalance);
		iter=iter->next;
	}
}

void check(struct LINKEDLIST bank){
	struct ACCOUNT *iter = bank.head;
	while (iter!=NULL){
		//check start and end
		if (iter->startingBalance != iter->endingBalance){
			printf("End of day balances do not agree (account, starting, ending): %d %f %F\n",iter->accountNumber,iter->startingBalance,iter->endingBalance);
		}
		iter=iter->next;
	}
}

void freeNode(struct ACCOUNT *head){
	if (head->next != NULL){
		freeNode(head->next);
	}
	free(head);
}


int main(int argc, char *argv[]){
	//check arguments
	if (argc != 3){
		printf("Wrong number of arguments.\n");
		displayMsg();
		return 1;
	}
	//check if file is readable
	state =fopen(argv[1],"rt");
	if (state == NULL){
		printf("Unable to open filename %s, state.csv file cannot be opened\n.",argv[1]);
		displayMsg();
		return 2;
	}
	trans =fopen(argv[2],"rt");
        if (trans == NULL){
                printf("Unable to open filename %s, transactions.csv file cannot be opened\n",argv[2]);
                displayMsg();
                return 2;
        }
	//construct a linked list this will sotres all accounts
	
	//check if state is empty or/and transactions is empty
	//first chek state
	int state_empty=1;  //assume is empty
	while ( !feof(state) ){
		char c=fgetc(state);
		if ( isdigit(c)){
			state_empty=0; 
			break; 		//if there's digits then state is not empty
		}
	}
	fclose(state);
	//check transactions
	int trans_empty=1; //assume is empty
	while (!feof(trans)){
		char c=fgetc(trans);
		if ( isdigit(c)){
			trans_empty=0;
		    	break;		//if digit then not empty
		}
	}
	fclose(trans);
	if (state_empty && !trans_empty){
		printf("File state.csv is empty. Unable to validate transactions.csv\n");
		return 3;
	}
	state=fopen(argv[1],"rt");
	
	struct LINKEDLIST bank;
	bank.head=NULL;
	bank.tail=NULL;
	bank.size=0;
	if (! state_empty){
		bank=read(state);
	}
	//bank is now a linked list with all accounts from state
	//print bank for testing
	//printLinkedList(bank.head);
	//printf("Size: %d\n", bank.size);
	fclose(state);
	//finished reading state
	//now read transactions
	//trans =fopen(argv[2],"rt");
        //if (trans == NULL){
                //printf("Unable to open filename %s\n.",argv[2]);
                //displayMsg();
               // return 2;
        //}
	
	trans=fopen(argv[2],"rt");

	while (!feof(trans)){
		//read line by line, obtain the following info
		char line[120];
		int accNum;
		char mode;
		double absVal;
		fgets(line,120,trans);
		//skip the first line
		if (line[0] != 'a'){
			char accNumstr[7];
			char absValstr[20];
			//read account number
			int i;
			for (i=0; i<6;i++){
				accNumstr[i]=line[i];
			}
			accNumstr[i+1]='\0';
			accNum=atoi(accNumstr);
			//read mode
			mode=line[7];
			//read absval
			int j;
			int k;
			for (j=9,k=0; line[j]!='\0';j++,k++){
			       absValstr[k]=line[j];
			}
	 		absValstr[k+1]='\0';
			absVal=atof(absValstr);	
		
		//now iter through the linked list
		int notAdded=1;
		struct ACCOUNT *iter=bank.head;
		while(iter !=NULL && notAdded){
			if (iter->accountNumber==accNum){
				if (mode=='d'){
					iter->startingBalance+=absVal;
				}else if (mode=='w'){
					double balance;
					balance=iter->startingBalance;
					iter->startingBalance-=absVal;
					if(iter->startingBalance <0){
						iter->startingBalance=0;
						printf("Balance below zero error (account, moed, transaction, startingBalance before): %d %c %f %f\n",iter->accountNumber,mode,absVal,balance);
					}
				}
				notAdded=0;
			}
			iter=iter->next;
		}
		//now the one account (if there's a match) in linked list is modified
		//if there's no match
		if (notAdded & accNum>=100000){
			printf("Account not found (account, mode, amount): %d %c %f\n",accNum,mode,absVal);
		}
		
		}
		//return to proccess next line
	}
	fclose(trans);
	//printLinkedList(bank.head);	
	//now the start and end in each account should agreee
	//loop through the linked list
	//the function check takes in a linked list and start from list.head
	//loop through the entire list, check stats
	check(bank);	

	//free(bank.head->next);
	if (bank.head != NULL){
		freeNode(bank.head);
	}
	//now free all nodes
	//struct ACCOUNT *iter= bank.head;
	//struct ACCOUNT *free;
	//for(int i=0; i<bank.size;i++){
		//free=iter;
		//iter=iter->next;
		//free(free);
	//}
	return 0;


}	

