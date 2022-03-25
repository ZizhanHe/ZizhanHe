import java.util.ArrayList;

public class test {
    public static void changeArr(ArrayList<Integer> arr){
        arr.add(0,1);
    }
    public static void main(String[] args){
        ArrayList<Integer> arr=new ArrayList<Integer>(2);
        arr.add(0,12);
        arr.add(1,2);
        //changeArr(arr);
        System.out.println(arr.size());

    }
}
