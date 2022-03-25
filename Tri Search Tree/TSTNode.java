class TSTNode<T extends Comparable<T>>{
    T element;
    TSTNode<T> left;
    TSTNode<T> mid;
    TSTNode<T> right;

    public TSTNode(T element){
        this.element=element;
        this.left=null;
        this.right=null;
        this.mid=null;
    }

    public void addMid( T element){
        if (this.mid==null){
            TSTNode newnode=new TSTNode(element);
            this.mid=newnode;
        }else{
            this.mid.addMid(element);
        }
    }

    public int height(){
        if (this == null){
            return 0;
        } else{
            int heightL=0 , heightM=0, heightR=0;
            if (this.left==null){
                heightL=0;
            }else {
                heightL = 1 + this.left.height();}
            if (this.mid==null){
                heightM=0;
            }else {
                heightM = 1 + this.mid.height();}
            if (this.right==null){
                heightR=0;
            }else{
                heightR= 1 + this.right.height();
            }
            return Max(heightL,heightM,heightR);
        }
    }
    //returns the node with min value
    public TSTNode findMin() {
        if (this.left == null) {
            return this;
        } else {
            return this.left.findMin();
        }
    }
    //returns the node with max element
    public TSTNode findMax(){
        if (this.right == null){
            return this;
        }else{
            return this.right.findMax();
        }
    }


    //findMax returns the max of 3 integer input
    public int Max(int i, int j, int k) {
        if (i == j && j == k) {
            return i;           // 1 1 1
        } else if (i > j && i > k) {
            return i;            //3 2 1
        } else if (j > i && j > k) {
            return j;              //2 3 1
        } else if (k > i && k > j) {
            return k;             //1 2 3
        } else if (i > k && j > k && i == j) {
            return i;             // 3 3 2
        } else if (j > i && k > i && j == k) {
            return j;              //2 3 3
        } else if (i > j && k > j && i == k) {
            return i;              // 3 2 3
        }
        return 0;
    }
}
