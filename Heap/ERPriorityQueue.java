import java.util.ArrayList;
import java.util.HashMap;
public class ERPriorityQueue {
        public ArrayList<Patient>  patients;
        public HashMap<String,Integer>  nameToIndex;

        public ERPriorityQueue(){

            //  use a dummy node so that indexing starts at 1, not 0

            patients = new ArrayList<Patient>();
            patients.add( new Patient("dummy", 0.0) );

            nameToIndex  = new HashMap<String,Integer>();
        }

        private int parent(int i){
            return i/2;
        }

        private int leftChild(int i){
            return 2*i;
        }

        private int rightChild(int i){
            return 2*i+1;
        }

    /*
    TODO: OPTIONAL
    TODO: Additional helper methods such as isLeaf(int i), isEmpty(), swap(int i, int j) could be useful for this assignment
     */

        public void upHeap(int i){
            int parentIndex=parent(i);
            if (parentIndex > 0 && patients.get(i).getPriority() < patients.get(parentIndex).getPriority()) {
                swap(parentIndex, i);
                upHeap(parentIndex);
            }else {
                //update hash map
                nameToIndex.put(patients.get(i).getName(),i);
            }
        }

        //swap takes in two index, swap these two patients in patients
        public void swap(int indexi, int indexj){
            if (indexi != indexj) {
                Patient patient1 = patients.get(indexi);
                Patient patient2 = patients.get(indexj);
                //change hash map
                nameToIndex.put(patient1.getName(),indexj);
                nameToIndex.put(patient2.getName(),indexi);
                //now create a temporary Patient obj, and will have values of patient 1
                Patient temp = new Patient(patient1);
                patients.remove(indexi);
                patients.add(indexi, patient2);
                patients.remove(indexj);
                patients.add(indexj, temp);
            }
        }

        public void downHeap(int i){
            if (leftChild(i) < patients.size() || rightChild(i) < patients.size()){
                //determent which is the smaller child
                int smallerChildIndex = leftChild(i);
                Patient smallerChild=patients.get(smallerChildIndex);
                if (rightChild(i) < patients.size()){
                    Patient rightChild=patients.get(rightChild(i));
                    if (rightChild.getPriority() < smallerChild.getPriority() ){
                        smallerChildIndex=rightChild(i);
                        smallerChild=patients.get(smallerChildIndex);
                    }
                }
                Patient parent=patients.get(i);
                //swap if needed
                if (parent.getPriority() > smallerChild.getPriority()){
                    swap(i,smallerChildIndex);
                    downHeap(smallerChildIndex);
                }else{
                    nameToIndex.put(parent.getName(),i);
                }
            }else{
                nameToIndex.put(patients.get(i).getName(),i);
            }
        }


        public boolean contains(String name){
            Integer index=nameToIndex.get(name);
            if (index != null){
                return true;
            }
            return false;
        }

        public double getPriority(String name){
            Integer index=nameToIndex.get(name);
            if (index == null){
                return -1;
            }else{
                return patients.get(index).getPriority();
            }
        }

        public double getMinPriority(){
            if (patients.size()==1){
                return -1;
            }else{
                return patients.get(1).getPriority();
            }
        }

        public String removeMin(){
            if (patients.size()==1){
                //empty queue
                return null;
            }else{
                Patient minToRemove=patients.get(1);
                //swap
                swap(1,patients.size()-1);
                patients.remove(patients.size()-1);
                //remove from hashmap
                nameToIndex.remove(minToRemove.getName());
                if (patients.size() > 1) {
                    downHeap(1);
                }
                //consider this more
                return minToRemove.getName();
            }

        }

        public String peekMin(){
            if (patients.size()==1){
                return null;
            }else{
                return patients.get(1).getName();
            }
        }

        /*
         * There are two add methods.  The first assumes a specific priority.
         * The second gives a default priority of Double.POSITIVE_INFINITY
         *
         * If the name is already there, then return false.
         */

        public boolean  add(String name, double priority){
            if (contains(name)){
                return false;
            }else{
                Patient newPatient= new Patient(name, priority);
                //add new patient at last
                patients.add(newPatient);
                //upheap the last patient (new patient) log2n
                upHeap(patients.size()-1);
                //find the index of new patient just added (log2n)
                //int findIndex=patients.size()-1;
                //while (patients.get(findIndex).name != name){
                    //half findIndex each loop, so log2n
                   // findIndex =findIndex/2;
                //}
                //nameToIndex.put(name,findIndex);
                return true;
            }
        }

        public boolean  add(String name) {
            if (contains(name)) {
                return false;
            } else{
                Double priority = Double.POSITIVE_INFINITY;
                Patient newPatient=new Patient(name,priority);
                patients.add(newPatient);
                nameToIndex.put(name,patients.size()-1);
                return true;
            }
        }

        public boolean remove(String name){
            if (!contains(name)){
                return false;
            }else{
                //O(1)
                int indexToRemove=nameToIndex.get(name);
                //now swap with the last element O(1)
                swap(indexToRemove,patients.size()-1);
                nameToIndex.remove(patients.get(patients.size()-1).getName());
                //removes the last element
                patients.remove(patients.size()-1);
                //down heap
                if (patients.size()>1 && indexToRemove<patients.size()) {
                    downHeap(indexToRemove);
                }
                return true;
            }
        }

        /*
         *   If new priority is different from the current priority then change the priority
         *   (and possibly modify the heap).
         *   If the name is not there, return false
         */

        public boolean changePriority(String name, double priority){
            if (!contains(name)){
                return false;
            }
            int smallerChild=0;
            int patientIndex= nameToIndex.get(name);
            Patient patient=patients.get(patientIndex);
            if (leftChild(patientIndex)<patients.size()-1) {
                smallerChild=leftChild(patientIndex);
            }
            if (rightChild(patientIndex)<patients.size()-1) {
                Patient rightChild = patients.get(rightChild(patientIndex));
                if (rightChild.priority<patients.get(smallerChild).getPriority()){
                    smallerChild=rightChild(patientIndex);
                }
            }
            //only when smllerChild != 0, we can downheap

            //first consider when patient.pri < parent.pri
            patient.setPriority(priority);
            if(parent(patientIndex)>0 && patient.getPriority() < patients.get(parent(patientIndex)).getPriority()){
                upHeap(patientIndex);
                return true;
            //then consider patient.pri > smaller child.pri
            }else if(smallerChild != 0 && patient.getPriority()>patients.get(smallerChild).getPriority()){
                downHeap(patientIndex);
                return true;
            }else{
                return true;
            }
        }

        public ArrayList<Patient> removeUrgentPatients(double threshold){
            //traversl patients, remove patients with priority<=threshold
            ArrayList<Patient> urgentPatients=new ArrayList<Patient>();
            int patientSize=patients.size();
            ArrayList<String> names=new ArrayList<String>();
            for (int j=0; j<patients.size();j++){
                names.add(patients.get(j).name);
            }
            for (int i=1; i<patientSize; i++){ //O(n)
                String name = names.get(i);
                int index=nameToIndex.get(name);
                Patient urgent=patients.get(index);
                if (urgent.priority <= threshold){
                    remove(urgent.getName());             //O(log2n)
                    urgentPatients.add(urgent);
                }
            }
            return urgentPatients;
        }

        public ArrayList<Patient> removeNonUrgentPatients(double threshold){
            ArrayList<Patient> nonurgentPatients=new ArrayList<Patient>();
            int patientSize=patients.size();
            ArrayList<String> names=new ArrayList<String>();
            for (int j=0; j<patients.size();j++){
                names.add(patients.get(j).name);
            }
            for (int i=1; i<patientSize; i++){ //O(n)
                String name = names.get(i);
                int index=nameToIndex.get(name);
                Patient nonurgent=patients.get(index);
                if (nonurgent.priority >= threshold){
                    remove(nonurgent.getName());             //O(log2n)
                    nonurgentPatients.add(nonurgent);
                }
            }
            return nonurgentPatients;
        }



        static class Patient{
            private String name;
            private double priority;

            Patient(String name,  double priority){
                this.name = name;
                this.priority = priority;
            }

            Patient(Patient otherPatient){
                this.name = otherPatient.name;
                this.priority = otherPatient.priority;
            }

            double getPriority() {
                return this.priority;
            }

            void setPriority(double priority) {
                this.priority = priority;
            }

            String getName() {
                return this.name;
            }

            @Override
            public String toString(){
                return this.name + " - " + this.priority;
            }

            public boolean equals(Object obj){
                if (!(obj instanceof  ERPriorityQueue.Patient)) return false;
                Patient otherPatient = (Patient) obj;
                return this.name.equals(otherPatient.name) && this.priority == otherPatient.priority;
            }

        }
    }


