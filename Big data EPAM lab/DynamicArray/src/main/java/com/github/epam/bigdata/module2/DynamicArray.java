package com.github.epam.bigdata.module2;


/**
 * Created by dydus on 18/10/2016.
 * Allows to store any types of elements, is based on array. It increases the capacity of array automatically.
 */
public class DynamicArray<T> implements IDynamicArray<T> {
    public static final int DEFAULT_CAPACITY_VALUE = 10;
    public static final double CAPACITY_MULTIPLY_FACTOR = 1.5;

    private int capacity;
    private int size;
    private T[] array;

    /**
     * Add value to the end of the list
     * @param value
     */
    public void add(T value) {
        int newIndex = size + 1;
        if (newIndex < capacity) {
            array[newIndex] = value;
        } else {
            int newCapacity = (int)(((double)capacity) * DynamicArray.CAPACITY_MULTIPLY_FACTOR) + 1;
            allocate(newCapacity);
            array[newIndex] = value;
            capacity = newCapacity;
        }
        size = newIndex;
    }

    /**
     * Return contained value by input index. Throw exception whether index is not exist
     * @param index Index of element in the list since 0
     * @return Element
     */
    public T get(int index) {
        if (index < 0 || index >= size)
            throw new IndexOutOfBoundsException();
        return array[index+1];
    }

    /**
     * Remove element from list and return from the method. Throw exception whether index is not exist
     * @param index Index of element in the list since 0
     * @return Element
     */
    public T remove(int index) {
        T result = get(index);
        for (int i = index+1; i < size; i++) {
            array[i] = array[i+1];
        }
        size--;
        return result;
    }

    /**
     * Return actual size of array
     * @return
     */
    public int getCount() {
        return size;
    }

    /**
     * Return available amount of elements
     * @return
     */
    public int getCapacity() {
        return capacity;
    }

    public DynamicArray() {
        this(DynamicArray.DEFAULT_CAPACITY_VALUE);
    }

    public DynamicArray(int capacity) {
        this.array = (T[])new Object[capacity];
        this.size = 0;
        this.capacity = capacity;
    }

    private void allocate(int newCapacity) {
        T[] newArray = (T[])new Object[newCapacity];
        for (int i = 1; i <= size; i++) {
            newArray[i] = array[i];
        }
        array = newArray;
        capacity = newCapacity;
    }
}