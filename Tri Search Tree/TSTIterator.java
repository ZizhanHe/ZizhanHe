import java.util.Iterator;
import java.util.ArrayList;
// add your imports here

class TSTIterator<T extends Comparable<T>> implements Iterator<T> {
    ArrayList<T> elements;
    int pointer;

    public TSTIterator(TST tree){
        ArrayList<T> interelement = new ArrayList<>();
        tree.inorderGetlist(interelement, tree.root);
        this.elements=interelement;
        pointer=0;
    }
    /**
     * Returns {@code true} if the iteration has more elements. (In other words, returns {@code true} if {@link #next}
     * would return an element rather than throwing an exception.)
     *
     * @return {@code true} if the iteration has more elements
     */
    @Override
    public boolean hasNext() {
        if (this.pointer < this.elements.size()){
            return true;
        }else{
            return false;
        }

    }

    /**
     * Returns the next element in the iteration.
     *
     * @return the next element in the iteration
     *
    //* @throws NoSuchElementException
     *         if the iteration has no more elements
     */
    @Override
    public T next() {
        T returningE = this.elements.get(this.pointer);
        this.pointer ++;
        return returningE;
    }
}
