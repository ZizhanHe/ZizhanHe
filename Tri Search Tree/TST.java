import java.lang.reflect.Array;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

public class TST<T extends Comparable<T>> implements Iterable<T>{
    TSTNode<T> root;


    public TST() {
        this.root = null;
    }


    public void insert(T element){
        if (this.root == null){
            TSTNode newNode=new TSTNode(element);
            root=newNode;
        }else{
            helper_insert(this.root,element);
        }
    }

    public void helper_insert(TSTNode root, T element){
        if (root.element.compareTo(element) ==0 ){
            if ( root.mid ==null){
                TSTNode newnode= new TSTNode(element);
                root.mid=newnode;
            }else{
                helper_insert(root.mid, element);
            }
        }else if (root.element.compareTo(element)<0){
            if (root.right == null){             //when element>root.element
                TSTNode newnode=new TSTNode(element);
                root.right=newnode;
            }else{
                helper_insert(root.right, element);
            }
        }else{
            if (root.left ==null){
                TSTNode newnode=new TSTNode(element);
                root.left=newnode;
            }else{
                helper_insert(root.left, element);
            }
        }
    }

    public void remove(T element){
        //if there's only the root
        if (this.root.height()==0){
            this.root=null;
        }else {
            helper_remove(this.root, element);
        }
    }
    public void helper_remove(TSTNode root, T element){
        //first find the node
        TSTNode targetNode=findNode(root, element);
        if (targetNode.mid != null ){
            //removes targetNode.mid
            targetNode.mid=targetNode.mid.mid;
        }else if (targetNode.left == null){
            //the case when root has only right subtree or no subtree
            //More work on this!
            if (targetNode.right != null){
                if (targetNode.element.equals(this.root.element)){
                    this.root=targetNode.right;
                }else{
                    TSTNode<T> interright= targetNode.right.right;
                    TSTNode<T> intermid = targetNode.right.mid;
                    TSTNode<T> interleft= targetNode.right.left;
                    targetNode.element=targetNode.right.element;
                    targetNode.right=interright;
                    targetNode.mid=intermid;
                    targetNode.left=interleft;
                }
            }else{
                //the case when removing the ending, we use a helper method that returns one
                //node prior to it
                TSTNode prevNode= returnPrevious(this.root,targetNode);
                if (prevNode.left != null && prevNode.left.element.equals(targetNode.element)){
                    prevNode.left=null;
                }else{
                    prevNode.right=null;
                }
            }
        }else{
            //the case we replace the root.element with largest from left
            TSTNode removingNode=targetNode.left.findMax();
            int countingMid=0;
            if (removingNode.mid != null){
                while (removingNode.mid != null){
                    //add mid to targetnode
                    targetNode.addMid(removingNode.element);
                    removingNode.mid=removingNode.mid.mid;
                }
            }
            targetNode.element=removingNode.element;
            helper_remove(targetNode.left , (T)removingNode.element);
        }
    }
    //takes in a root, and add mid where root.mid =null
    public TSTNode findNode(TSTNode root, T element) {
        if (root == null){
            return null;
        }else if (root.element.equals(element)){
            return root;
        }else if (root.element.compareTo(element) < 0 ){
            return findNode(root.right, element);
        }else{
            return findNode(root.left, element);
        }
    }

    //FIX mid problem! maybe fix this at the end, not using a function
    //as finding the max node from left subtree, check if the node has mid
    // if so, record the n  number of mid using while loop
    //while swaping the elements, add n number of mid to the targetNode. now remove the removingNode and all its mid
    //maybe add the third parameter k, representing the times of removal to repeat?
    //if we are not dealing with mid, then k=0. if we have n mid to remove, then we enter n.
    //add a for loop for when targetNode.mid != null to loop it n time
    //this is only the case when we're swaping the target node with removing node that has mid! normal removal of duplicate does
    //not applies
    //goes throught
    public void fixduplicate(TSTNode root){

    }

    public TSTNode returnPrevious(TSTNode root, TSTNode nodeToFind){
        if (((root.left!= null && root.left.element.equals(nodeToFind.element)) && ((root.left != null && root.left.left==null) && root.left.right==null)) || ((root.right != null && root.right.element.equals(nodeToFind.element))  &&  ((root.right != null && root.right.left==null) && root.right.right==null))){
            return root;
        }else{
            if (root.element.compareTo(nodeToFind.element)<0){
                return returnPrevious(root.right, nodeToFind);
            }else{
                return returnPrevious(root.left, nodeToFind);
            }
        }
    }

    public boolean contains(T element){
        if (this.root == null){
            return false;
        }else{
            return helper_contains(this.root, element);
        }
    }

    public boolean helper_contains(TSTNode root, T element){
        if(root==null){
            return false;
        }else if (root.element == element){
            return true;
        }else if (root.element.compareTo(element) < 0){
            return helper_contains(root.right,element);
        }else{
            return helper_contains(root.left, element);
        }
    }

    public void rebalance(){
        //first use inorder traversal to get arraylist
        ArrayList arraysorted = new ArrayList();
        inorderGetlist(arraysorted,this.root);
        TSTNode newroot=splitsort(arraysorted);
        this.root= newroot;
    }

    //helper method splitsort(list) that takes in an arraylist<T> (the elements)that represent
    //the result of in-order traversal in a tri-tree. And rebalance the tree and
    //returns the new root.
    public TSTNode<T> splitsort(ArrayList<T> orderedList){
        if (orderedList.size()==0){
            TSTNode newnode=null;
            return newnode;
        }

        if (orderedList.size()==1){
            T element=orderedList.get(0);
            TSTNode newnode= new TSTNode(element);
            return newnode;
        }else{
            T rtElement=orderedList.get(orderedList.size()/2);
            TSTNode root = new TSTNode(rtElement);
            //check if there's duplicates of rtElement
            ArrayList listOfDup=new ArrayList();
            for (int i=0; i<orderedList.size(); i++){
                if (orderedList.get(i).compareTo(rtElement) ==0){
                    listOfDup.add(orderedList.get(i));
                }
            }
            List<T> leftList1=  orderedList.subList(0, orderedList.size()/2);
            List<T> rightList1=  orderedList.subList((orderedList.size()/2)+1,orderedList.size());
            ArrayList<T> leftList= new ArrayList<T>();
            ArrayList<T> rightList= new ArrayList<T>();
            for (int i=0; i<leftList1.size(); i++){
                leftList.add(leftList1.get(i));
            }
            for (int j=0; j<rightList1.size();j++){
                rightList.add(rightList1.get(j));
            }

            //the case when we have root.mid
            if (listOfDup.size() > 1 ){
                //take the left list and right list, remove all dup from it
                boolean lfinished= false;
                boolean rfinished= false;
                while (! lfinished){
                    for (int i=0; i<leftList.size(); i++){
                        if (leftList.get(i).equals(rtElement)){
                            leftList.remove(i);
                            break;
                        }
                    }
                    lfinished=true;
                }
                while (! rfinished) {
                    for (int j = 0; j < rightList.size(); j++) {
                        if (rightList.get(j).equals(rtElement)) {
                            rightList.remove(j);
                            break;
                        }
                    }
                    rfinished = true;
                }
                //now we've modified leftlist and right list, splitsort()
                //then mid
                ArrayList<T> listofDup1 = new ArrayList<T>();
                for (int k=0; k< listOfDup.size()-1; k++){
                    listofDup1.add((T)listOfDup.get(k));
                }
                root.mid=splitsort(listofDup1);

            }
            root.left=splitsort((ArrayList<T>) leftList);
            root.right=splitsort((ArrayList<T>) rightList);
            return root;
        }
    }


    public void inorderGetlist(ArrayList<T> list1, TSTNode root) {
        if (root != null) {
            inorderGetlist(list1, root.left);
            list1.add((T) root.element);
            inorderGetlist(list1, root.mid);
            inorderGetlist(list1, root.right);
        }
    }


    /**
     * Caculate the height of the tree.
     * You need to implement the height() method in the TSTNode class.
     *
     * @return -1 if the tree is empty otherwise the height of the root node
     */
    public int height(){
        if (this.root == null)
            return -1;
        return this.root.height();
    }

    /**
     * Returns an iterator over elements of type {@code T}.
     *
     * @return an Iterator.
     */
    @Override
    public Iterator iterator() {

        return new TSTIterator(this);
    }

    // --------------------PROVIDED METHODS--------------------
    // The code below is provided to you as a simple way to visualize the tree
    // This string representation of the tree mimics the 'tree' command in unix
    // with the first child being the left child, the second being the middle child, and the last being the right child.
    // The left child is connect by ~~, the middle child by -- and the right child by __.
    // e.g. consider the following tree
    //               5
    //            /  |  \
    //         2     5    9
    //                   /
    //                  8
    // the tree will be printed as
    // 5
    // |~~ 2
    // |   |~~ null
    // |   |-- null
    // |   |__ null
    // |-- 5
    // |   |~~ null
    // |   |-- null
    // |   |__ null
    // |__ 9
    //     |~~ 8
    //     |   |~~ null
    //     |   |-- null
    //     |   |__ null
    //     |-- null
    //     |__ null
    @Override
    public String toString() {
        if (this.root == null)
            return "empty tree";
        // creates a buffer of 100 characters for the string representation
        StringBuilder buffer = new StringBuilder(100);
        // build the string
        stringfy(buffer, this.root,"", "");
        return buffer.toString();
    }

    /**
     * Build a string representation of the tertiary tree.
     * @param buffer String buffer
     * @param node Root node
     * @param nodePrefix The string prefix to add before the node's data (connection line from the parent)
     * @param childrenPrefix The string prefix for the children nodes (connection line to the children)
     */
    private void stringfy(StringBuilder buffer, TSTNode<T> node, String nodePrefix, String childrenPrefix) {
        buffer.append(nodePrefix);
        buffer.append(node.element);
        buffer.append('\n');
        if (node.left != null)
            stringfy(buffer, node.left,childrenPrefix + "|~~ ", childrenPrefix + "|   ");
        else
            buffer.append(childrenPrefix + "|~~ null\n");
        if (node.mid != null)
            stringfy(buffer, node.mid,childrenPrefix + "|-- ", childrenPrefix + "|   ");
        else
            buffer.append(childrenPrefix + "|-- null\n");
        if (node.right != null)
            stringfy(buffer, node.right,childrenPrefix + "|__ ", childrenPrefix + "    ");
        else
            buffer.append(childrenPrefix + "|__ null\n");
    }

    /**
     * Print out the tree as a list using an enhanced for loop.
     * Since the Iterator performs an inorder traversal, the printed list will also be inorder.
     */
    public void inorderPrintAsList(){
        String buffer = "[";
        for (T element: this) {
            buffer += element + ", ";
        }
        int len = buffer.length();
        if (len > 1)
            buffer = buffer.substring(0,len-2);
        buffer += "]";
        System.out.println(buffer);
    }
}
