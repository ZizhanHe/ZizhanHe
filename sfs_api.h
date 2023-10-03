#ifndef SFS_API_H
#define SFS_API_H

// You can add more into this file.

void mksfs(int); //(int fresh) creates the file system
                //-formats the virtual disk using disk_emu
                //-if fresh=1, then disk should be created from scrate (using disk_emu)
                //fresh=0, then load the current disk. Assume a valid fs already exists

int sfs_getnextfilename(char*); //(char *fname) get the name of the next file in directory
                //copies file name into *fname.
                //return 0 if reached end of directory. No more file
                //return non-zero else.

int sfs_getfilesize(const char*);//(const char* path) get the size of given file. 

int sfs_fopen(char*);//opens the given file
                //if file does not exists, creates a new file and set size o 0
                    //create a new directory entry, allocate i node
                    
                //if file exists, open the file in append mode
                //return index of file in FDT
                    //Aside: FDT represent active files

int sfs_fclose(int); //close the file with the given file ID
                //Search FDT for such file
                //Remove file entry from FDT. File should remain on disk
                //return 0 if success, negative else

int sfs_fwrite(int, const char*, int); //(int fileID,char *buf, int length)
                                        //Write buf characters into disk
                //return #bytes writtem

int sfs_fread(int, char*, int); //(int fileID,char *buf, int length)
                                //read into buffer

int sfs_fseek(int, int); //(int fileID, int location)
                //moves read/write pointer to the given location
                    //Aside: One file only has one pointer
                //returns 0 on success, native else

int sfs_remove(char*); //(cahr *file) - remvoes the file from filesystem
                //Removes file ffrom directory entry
                //Modify free space map to note data blocks as free
                //release i-node

#endif
