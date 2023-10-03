#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <unistd.h>
#include <time.h>
#include "disk_emu.h"
#include "disk_emu.c"
#include "sfs_api.h"


//Index: 0 (SB),1-9 (INODE TBL), DBs, 2045-2047 (FBM)
#define DISK_SIZE 2048  //disk contains 2048 blocks
#define BLOCK_SIZE 1024
#define DIR_SIZE 5 //5 blocks is allocated for directories
                    // can hold (5*1024)/64 = 80 files
#define INODE_TBL_SIZE 8 //8 blocks is allocated for i nodes
                // can hold 128 i-node entries. Inode>Directory because files can occupy more than 1 inode


typedef struct _block_t_{
    char data[BLOCK_SIZE];
} block_t;

typedef struct _FDT_entry_t{
    char *fileName;
    int FD_num; //the index of this file in FDT
                //initialized to -1 to indicate invalid, then its set to its current index
    int inode_pointer; //indicating the inode for to this file
                    //initialized to -1 to indicate invalid
    int rw_pointer; //initialized to -1 to indicate invalid
}FDT_entry_t;

typedef struct _dir_entry_t_{
    char filename[64-sizeof(int)];
    int inode; 
} dir_entry_t;

typedef struct _dirblock_t_{
    dir_entry_t directories[16]; //Each directory block contains 16 direcotry entries
}dirblock_t; 

typedef struct _inode_entry_t_{
    int mode;  //initialized to -1 to indicate invalid. Set to 1 if its used for some file
    int link_cnt; 
    int size; 
    int pointers[12]; //pointers to data blocks containing the file
    int ind_pointer; //points to the next inode if the file is too large to be contained in 12 data blocks
}inode_entry_t;

typedef struct _inode_block_t_{
    inode_entry_t inodes[16];
}inode_block_t;

//Special block type for superblock
typedef struct _sp_block_t_{
    int magic_num;
    int block_size;
    int filesys_size; //disk size
    int inode_tbl_size;
    int rt_dir_inode; //0th inode
}sp_block_t;


//in memory component
dirblock_t dircache[DIR_SIZE]; //contains all 5 blocks of directory
inode_block_t inodetbl[INODE_TBL_SIZE]; //contains all blocks of INode table
block_t freebit_map[2]; //2 blocks for FBM
sp_block_t super_block; //keep a copy of super block in memory
FDT_entry_t fd_table[16*DIR_SIZE]; //File descriptor table


//Different block type buffers
block_t cache;
sp_block_t spcache;
dirblock_t dir_block_cache;
inode_block_t inode_block_cache;

//Some Constants
int MAX_INODE=16*INODE_TBL_SIZE;
int MAX_FILE_NO=16*DIR_SIZE;
int FDT_SIZE=16*DIR_SIZE;
int INODE_STARTS_AT=1;
int FBM_BLOCK_NO=2045;
int FBM_SIZE=2;
int DIRECTORY_POINTER=0;
int MAX_INODE_NO=128;
                   

//Helper function - Write in-memory component to disk
void synchronize(){
    write_blocks(INODE_STARTS_AT,INODE_TBL_SIZE,inodetbl);
    write_blocks(inodetbl[0].inodes[DIRECTORY_POINTER].pointers[0],DIR_SIZE,dircache);
    write_blocks(FBM_BLOCK_NO,FBM_SIZE,freebit_map);
}

//Helper function
void setfree_datablock(int db_no){
    freebit_map[db_no/BLOCK_SIZE].data[db_no%BLOCK_SIZE]=1;
}

//Helper function - returns the index of the next available inode,
//change its mode to 1 to indicate the inode is now valid
int find_available_inodeslot(){
    for(int i=0;i<MAX_INODE_NO;i++){
        if(inodetbl[i/16].inodes[i%16].mode<0){
            inodetbl[i/16].inodes[i%16].mode=1;
            return i;
        }
    }
    return -1; //no free inode
}

//Helper function - Initialize free bit map
void init_FBM(){
    char one=1;
    for(int i=0; i<2; i++ ){
        for(int j=0;j<BLOCK_SIZE;j++){
            memcpy(freebit_map[i].data+(j*sizeof(char)),&one,sizeof(char));
        }
    }
    //first 9 blocks are SB and Inode table, mark them as occucpied
    for(int k=0;k<9;k++){
        freebit_map[0].data[k]=0;
    }
    write_blocks(FBM_BLOCK_NO,2,(void *) freebit_map);
}

//Helper function - Initialize file descriptor table
void init_FDT(){
        for(int i=0; i<FDT_SIZE; i++){
            fd_table[i].fileName="-";
            fd_table[i].FD_num=-1;
            fd_table[i].inode_pointer=-1;
            fd_table[i].rw_pointer=-1;
        }
}

//Helper function - Return the next available slot in FDT
int get_available_FDT(){
    for(int i=0;i<FDT_SIZE;i++){
        if(fd_table[i].FD_num<0){
            return i;
        }
    }
    return -1;
}

//Helper function - Return the next available data block
int get_next_available_dblock(){
    int counter=0;
    for(int i=0; i<2; i++ ){
        block_t c=freebit_map[i];
        for(int j=0;j<BLOCK_SIZE;j++){
            if(c.data[j]==1){
                return counter;
            }
            counter++;
        }
    }
}

//Helper function - Mark block_no in the disk as occupied (0) in the free bit map
void mark_as_occupied(int block_no){
    //printf("\n DB occupied %d", block_no);
    if(block_no<1024){
        freebit_map[0].data[block_no]=0;
    }else{
        freebit_map[1].data[block_no-1024]=0;
    }
    write_blocks(FBM_BLOCK_NO,2,(void *) freebit_map);
}

void mksfs(int fresh){
    if(fresh==0){
        init_disk("myDisk",BLOCK_SIZE,DISK_SIZE);
        //load component into memory
        //load superblocl
        read_blocks(0,1,&super_block);
        //load inode table
        read_blocks(1,INODE_TBL_SIZE,&inodetbl);
        //load directory into cache
        read_blocks(inodetbl[0].inodes[0].pointers[0] ,DIR_SIZE,&dircache);
        //load free bit map
        read_blocks(FBM_BLOCK_NO,2,&freebit_map);
        //initialize fdt
        init_FDT();
        //initialize directory pointer
        DIRECTORY_POINTER=0;
    }else{
        int error=init_fresh_disk("myDisk",BLOCK_SIZE,DISK_SIZE);
        if(error<0){return;}
        //initialize disk
        //init super block, write into disk
        super_block.magic_num=0;
        super_block.block_size=BLOCK_SIZE;
        super_block.filesys_size=DISK_SIZE;
        super_block.inode_tbl_size=INODE_TBL_SIZE; 
        super_block.rt_dir_inode=0; 
        //write super block into 0th block in disk
        write_blocks(0,1,&super_block);

        //init freebit map
        init_FBM();

        //init inode & inode table
        for(int i=0; i<INODE_TBL_SIZE; i++){
            //Add 16 i node entry to each inode block
            for (int j=0; j<16; j++){
                inode_entry_t entry;
                entry.mode=-1; //inidcate invalid
                entry.link_cnt=0; //unused
                entry.size=0; //no file
                for(int k=0;k<12;k++){
                    //init 12 poitners to 0
                    entry.pointers[k]=0;
                }
                entry.ind_pointer=0;
                //put entry into block
                inodetbl[i].inodes[j]=entry;
            }
        }
        //make 0th inode entry point to RT directory
        inodetbl[0].inodes[0].link_cnt=1;
        inodetbl[0].inodes[0].mode=1; 
        //change rt dir pointer 1-5 to available data blocks
        for(int h=0;h<DIR_SIZE;h++){
            int data_block_no=get_next_available_dblock();
            mark_as_occupied(data_block_no);
            inodetbl[0].inodes[0].pointers[h]=data_block_no;
        }
        write_blocks(1,INODE_TBL_SIZE,inodetbl);

        //crete directory
        for(int i=0; i<DIR_SIZE; i++){
            for(int j=0; j<16; j++){
                dir_entry_t entry;
                memcpy(entry.filename,"-",64-sizeof(int));
                entry.inode=-1; //indicates not used
                dircache[i].directories[j]=entry;
            }
        }
        write_blocks(inodetbl->inodes[0].pointers[0],DIR_SIZE,dircache);    
        DIRECTORY_POINTER=0;

        //initialize FDT
        init_FDT();
        } 
 }


 int sfs_getnextfilename(char* buf){
    //Return the file at current DIRECTORY_POINTER if file is valid
    if (DIRECTORY_POINTER>=MAX_FILE_NO){
        return 0;
    }else if(dircache[DIRECTORY_POINTER/16].directories[DIRECTORY_POINTER%16].inode<0){
        //if inode<0, then file not valid. Reached to end
        return 0;
    }else{
        strncpy(buf, dircache[DIRECTORY_POINTER/16].directories[DIRECTORY_POINTER%16].filename,64-sizeof(int));
        DIRECTORY_POINTER++;
    }
 }


 int sfs_getfilesize(const char* name){
    //Loop through directory to find file
    for(int i=0;i<MAX_FILE_NO;i++){
        if(strcmp(name,dircache[i/16].directories[i%16].filename)==0){
            int inode_index=dircache[i/16].directories[i%16].inode;
            if(inode_index<0){
                //printf("\nFile has not been initialized\n");
                return -1;
            }
            return inodetbl[inode_index/16].inodes[inode_index%16].size;
        }
    }
    return -1;
 }
 
 int sfs_fopen(char* name){
    //Check if file name exceeds max length. Need to modify sfs_test1.c, sfs_test2.c MAX_FNAME_SIZE to 32
    if(strlen(name)>32){
        //name too long!
        return -1;
    }

    //scan fdt to check if the file is already opened
    for(int p=0;p<FDT_SIZE;p++){
        if(strcmp(fd_table[p].fileName,name)==0){
            return -1;
        }
    }

    int inode_ind=-1;
    //search directory to see if the file exists
    for (int k=0; k<MAX_FILE_NO; k++){
        if(strcmp(name,dircache[k/16].directories[k%16].filename)==0){
            inode_ind=dircache[k/16].directories[k%16].inode;
        }
    }
    if(inode_ind<0){
        //File don't exists, create a new file

        // 1) find a free spot in the directory and add this file
        for(int i=0; i<MAX_FILE_NO; i++){
            if(dircache[i/16].directories[i%16].inode<0){
                strncpy(dircache[i/16].directories[i%16].filename,name,64-sizeof(int));
                
                //2) Find a available inode
                inode_ind=find_available_inodeslot();
                //if(inode_ind<0){printf("\n INODE CRISES! "); return -1;}
                dircache[i/16].directories[i%16].inode=inode_ind;
                
                //flush dircache into disk
                write_blocks(inodetbl[0].inodes[0].pointers[0],DIR_SIZE,&dircache);
                
                //3) now with inode_ind, set up the inode, and flush inodetbl into memory
                inodetbl[inode_ind/16].inodes[inode_ind%16].link_cnt=1;
                inodetbl[inode_ind/16].inodes[inode_ind%16].size=0;
                int db=get_next_available_dblock();
                mark_as_occupied(db);
                inodetbl[inode_ind/16].inodes[inode_ind%16].pointers[0]=db;
                inodetbl[inode_ind/16].inodes[inode_ind%16].ind_pointer=0;

                //flush inodetbl into disk
                write_blocks(INODE_STARTS_AT,INODE_TBL_SIZE,&inodetbl);

                //4) Allocate FDT
                int fdt_index=get_available_FDT();
                //if(fdt_index<0){printf("\n FDT full!"); return -1;}
                fd_table[fdt_index].fileName=name;
                fd_table[fdt_index].FD_num=fdt_index;
                fd_table[fdt_index].inode_pointer=inode_ind;
                fd_table[fdt_index].rw_pointer=0; 

                synchronize();
                return fdt_index;
            }
        }
    }else{
        //File already exists

        //1) Allocate new slot in FDT
        int fdt_index=get_available_FDT();
        if(fdt_index<0){
            //printf("\n FDT full");
            return -1;
        }
        //2) Open in append mode
        //set rw_pointer to size
        fd_table[fdt_index].fileName=name;
        fd_table[fdt_index].FD_num=fdt_index;
        fd_table[fdt_index].inode_pointer=inode_ind;
        fd_table[fdt_index].rw_pointer=inodetbl[inode_ind/16].inodes[inode_ind%16].size;
        synchronize();
        return fdt_index;
    }
 }

 int sfs_fwrite(int fd_num,const char* buffer,int bytes_written){
    int bytes_written_cp=bytes_written;
    if(fd_table[fd_num].FD_num<0){
       //printf("\n Invalid File Table number! "); 
        return -1;
    }
    //Determine if the size of file should change
    //if rw_pointer + bytes_written < file current size. Do nothing
    //if rw_pointer + bytes_written > file current size, update file size
    int rw_ptr=fd_table[fd_num].rw_pointer;
    int ind=fd_table[fd_num].inode_pointer;
    int sizef=inodetbl[ind/16].inodes[ind%16].size;
    if(rw_ptr+bytes_written>sizef){
        inodetbl[(fd_table[fd_num].inode_pointer)/16].inodes[(fd_table[fd_num].inode_pointer)%16].size=rw_ptr+bytes_written;
    }
    
    //determine overflow
    if((BLOCK_SIZE-(rw_ptr%BLOCK_SIZE)) > bytes_written){
        //no overflow

        //get the datablock, need to determine which inode is holding the db. 
        //If file is large, then we need multiple inodes
        int bptr_no=rw_ptr/BLOCK_SIZE;
        int linkct=bptr_no/12; 
        for(int i=0;i<linkct;i++){ 
            ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
        }
        int bloc_no=inodetbl[ind/16].inodes[ind%16].pointers[bptr_no%12];

        //load the datablock into cache
        read_blocks(bloc_no,1,&cache);
        //write data into cache
        int rw_specif=rw_ptr%BLOCK_SIZE;
        memcpy((cache.data)+rw_specif,buffer,bytes_written);
        //flush cache back into memory
        write_blocks(bloc_no,1,&cache);
        
        //advances pointer
        fd_table[fd_num].rw_pointer+=bytes_written;
        //write inode table into disk
        write_blocks(INODE_STARTS_AT,INODE_TBL_SIZE,inodetbl);

        synchronize();
        return bytes_written;
    }else{
        //overflow
        //determine the number of extra data blocks needed
        int overflow_blocks_no=(bytes_written-(BLOCK_SIZE-(rw_ptr%BLOCK_SIZE)))/BLOCK_SIZE;
        overflow_blocks_no++; //
        //increment link count in inode
        inodetbl[ind/16].inodes[ind%16].link_cnt+=overflow_blocks_no;

        //first write to un-overflowed block
        int bptr_no=rw_ptr/BLOCK_SIZE;
        int linkct=bptr_no/12;
        for(int i=0;i<linkct;i++){
            ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
        }
        int db_pointer=bptr_no%12;
        int bloc_no=inodetbl[ind/16].inodes[ind%16].pointers[db_pointer];
        //load the datablock into cache
        read_blocks(bloc_no,1,&cache);
        //write data into cache
        int rw_specif=rw_ptr%BLOCK_SIZE;
        int bytes_left=BLOCK_SIZE-(rw_ptr%BLOCK_SIZE);
        memcpy((cache.data)+rw_specif,buffer,bytes_left);
        write_blocks(bloc_no,1,&cache);
        buffer+=bytes_left; //increment content address by the bytes we wrote
        rw_ptr+=bytes_left; //
        bytes_written-=bytes_left; //decrement bytes that needs to be written
        db_pointer++;

        //check if a new inode is needed. If file overflowed from 12 data blocks to 13 data blocks, then need new inode
        if(db_pointer>=12){
            //allocate new inode, mark as occupeid
            int new_inode=find_available_inodeslot();
            //link current inode to new inode
            inodetbl[ind/16].inodes[ind%16].ind_pointer=new_inode;
            //refer to new inode
            ind=new_inode;
            //dp_pointer now points to the 0th db pointer in new inode
            db_pointer=0;
        }

        //first allocate new block
        int ava_block=get_next_available_dblock();
        mark_as_occupied(ava_block);
        inodetbl[ind/16].inodes[ind%16].pointers[db_pointer]=ava_block;
        
        //now write to overflowed blocks
        for(int c=0;c<overflow_blocks_no;c++){
            //if theres still bytes to be writeen
            if(bytes_written>0){
            //allocate a new data block
            //load this block from disk
            read_blocks(ava_block,1,&cache);
            if(bytes_written>=BLOCK_SIZE){
                //wrtie entre block
                memcpy(cache.data, buffer, BLOCK_SIZE);
                buffer+=BLOCK_SIZE;
                rw_ptr+=BLOCK_SIZE;
                bytes_written-=BLOCK_SIZE;
                db_pointer++;
                write_blocks(ava_block,1,&cache);
                //Allocate new data block
                ava_block=get_next_available_dblock();
                mark_as_occupied(ava_block); 
                if(db_pointer>=12){
                    //create new inode
                    int new_inode=find_available_inodeslot();
                    //link current inode to new inode
                    inodetbl[ind/16].inodes[ind%16].ind_pointer=new_inode;
                    //refer to new inode
                    ind=new_inode;
                    //dp_pointer now points to the 0th db pointer in new inode
                    db_pointer=0;
                }
                inodetbl[ind/16].inodes[ind%16].pointers[db_pointer]=ava_block;
            }else{
                memcpy(cache.data,buffer,bytes_written);
                rw_ptr+=bytes_written;
                bytes_written-=bytes_written;
                write_blocks(ava_block,1,&cache);
            }
        }
        }

        //update rw pointer in fd table
        fd_table[fd_num].rw_pointer=rw_ptr;
        //write inode into disk
        write_blocks(INODE_STARTS_AT,INODE_TBL_SIZE,&inodetbl);
        synchronize();
        return bytes_written_cp;
    }


 }

 int sfs_fread(int fd_num, char* buffer, int size_to_read){
    int size2r_cp=size_to_read;
    char* buffer_cp=buffer;

    if(fd_table[fd_num].FD_num<0){
        //printf("\n Invalid File Table number! "); 
        return -1;
    }
    
    int ind=fd_table[fd_num].inode_pointer;
    int rw_ptr=fd_table[fd_num].rw_pointer;
    int sizef=inodetbl[ind/16].inodes[ind%16].size;

    //determine overflow
    if((BLOCK_SIZE-(rw_ptr%BLOCK_SIZE))>= size_to_read){
        //no overflow
        //get data block
        int db_idx=rw_ptr/BLOCK_SIZE;
        int inod_ct=db_idx/12;
        for(int i=0; i< inod_ct;i++){
            ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
        }
        int db_pointer=db_idx%12;
        int db=inodetbl[ind/16].inodes[ind%16].pointers[db_pointer];
        read_blocks(db,1,&cache);
        memcpy(buffer,cache.data+(rw_ptr%BLOCK_SIZE),size_to_read);
        synchronize();
        
        //check if reader reads more than the size of file
        if(rw_ptr+size_to_read>sizef){
            //user reads over the file size
            //rw_ptr sets to end of file
            fd_table[fd_num].rw_pointer=sizef;
            return (sizef-rw_ptr);
        }else{
            //increment pointer
            fd_table[fd_num].rw_pointer+=size_to_read;
            return size2r_cp;
        }
    }else{
        //read the unoverflowed portion, similar to sfs_write
        int db_idx=rw_ptr/BLOCK_SIZE;
        int inode_ct=db_idx/12;
        for(int i=0; i<inode_ct;i++){
            ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
        }
        int db_pointer=db_idx%12;
        int db=inodetbl[ind/16].inodes[ind%16].pointers[db_pointer];

        int bytes_left=BLOCK_SIZE-(rw_ptr%BLOCK_SIZE);
        read_blocks(db,1,&cache);
        memcpy(buffer_cp,cache.data+(rw_ptr%BLOCK_SIZE),bytes_left);
        rw_ptr+=bytes_left;
        size_to_read-=bytes_left;
        int offset=bytes_left;
        db_pointer++;

        if(db_pointer>=12){
            ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
            db_pointer=0;
        }

        int oveflwed=size_to_read/BLOCK_SIZE;
        oveflwed++;

        //read overflowed portion
        for(int i=0;i<oveflwed;i++){
            if(size_to_read>0){
            //load data block
            int dbx=inodetbl[ind/16].inodes[ind%16].pointers[db_pointer];
            read_blocks(dbx,1,&cache);
            if(size_to_read>=BLOCK_SIZE){
                //read entire blcok
                memcpy(buffer_cp+offset,cache.data,BLOCK_SIZE);
                size_to_read-=BLOCK_SIZE;
                rw_ptr+=BLOCK_SIZE;
                offset+=BLOCK_SIZE;
                db_pointer++;
                if(db_pointer>=12){
                    ind=inodetbl[ind/16].inodes[ind%16].ind_pointer;
                    db_pointer=0;
                }
            }else{
                memcpy(buffer_cp+offset,cache.data,size_to_read);
                rw_ptr+=size_to_read;
                offset+=size_to_read;
                size_to_read-=size_to_read;           
            }
        }
        }
        fd_table[fd_num].rw_pointer=rw_ptr;
        synchronize();
        return size2r_cp;
    }
 }

 int sfs_fseek(int fd_num, int location){
    if(fd_table[fd_num].FD_num<0){
        //printf("\n Invalid FD no!");
        return -1;
    }
    fd_table[fd_num].rw_pointer=location;
    return 0;
 }
 int sfs_fclose(int fd_num){
    if(fd_table[fd_num].FD_num<0){
        //printf("\n Invalid FD no for close!");
        return -1;
    }
    write_blocks(INODE_STARTS_AT,INODE_TBL_SIZE,inodetbl);
    //clean up fdt entry
    fd_table[fd_num].fileName="-";
    fd_table[fd_num].FD_num=-1;
    fd_table[fd_num].inode_pointer=-1;
    fd_table[fd_num].rw_pointer=-1;
    synchronize();
    return 0;
 }

 int sfs_remove(char* fname){
    int inode=-1;
    for(int i=0; i<DIR_SIZE;i++){
        if(strcmp(dircache[i/16].directories[i%16].filename,fname)==0){
            inode=dircache[i/16].directories[i%16].inode;
            //removes file from directory
            dircache[i/16].directories[i%16].inode=-1;
            memcpy(dircache[i/16].directories[i%16].filename,"-",sizeof(char));
        }
    }
    if(inode<0){
        //printf("\n Trying to remove invalid file");
        return -1;
    }
    //iteratively delete inode and datablocks
    int mode=inodetbl[inode/16].inodes[inode%16].mode;
    while(inode>0 && mode>0){
        //delete this inode
        int i_cp=inodetbl[inode/16].inodes[inode%16].ind_pointer;
        inodetbl[inode/16].inodes[inode%16].mode=-1;
        inodetbl[inode/16].inodes[inode%16].link_cnt=0;
        inodetbl[inode/16].inodes[inode%16].size=0;
        for(int i=0;i<12;i++){
            setfree_datablock(inodetbl[inode/16].inodes[inode%16].pointers[i]);
            inodetbl[inode/16].inodes[inode%16].pointers[i]=0;
        }
        inodetbl[inode/16].inodes[inode%16].ind_pointer=0;
        //delete next inode
        inode=i_cp;
        mode=inodetbl[inode/16].inodes[inode%16].mode;
    }
    synchronize();
    return 1;
 }


