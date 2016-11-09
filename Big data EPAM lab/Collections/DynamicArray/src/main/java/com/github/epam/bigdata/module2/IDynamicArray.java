package com.github.epam.bigdata.module2;

/**
 * Created by dydus on 18/10/2016.
 * Describes available methods of dynamic array
 */
public interface IDynamicArray<T> {
    void add(T value);
    T get(int index);
    T remove(int index) ;
    int getCount();
    int getCapacity();
}
