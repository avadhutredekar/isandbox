package com.github.epam.bigdata.module2;

import org.junit.*;

/**
 * Created by dydus on 18/10/2016.
 */
public class DynamicArrayTest {

    @Test
    public void arrayCountTest() throws Exception {
        IDynamicArray<String> array = new DynamicArray<String>();
        Assert.assertEquals(0, array.getCount());
        array.add("first");
        array.add("second");
        Assert.assertEquals(2, array.getCount());
    }

    @Test
    public void arrayAddingAndRemovingTest() throws Exception {
        IDynamicArray<String> array = new DynamicArray<String>();
        array.add("first");
        array.add("second");
        Assert.assertEquals("first", array.get(0));
        Assert.assertEquals("second", array.get(1));
        String removedValue = array.remove(0);
        Assert.assertEquals("first", removedValue);
        Assert.assertEquals("second", array.get(0));
    }

    @Test
    public void arrayCapacityTest() throws Exception {
        DynamicArray<Integer> array = new DynamicArray<Integer>(4);
        Assert.assertEquals(4, array.getCapacity());
        array.add(0);
        array.add(1);
        array.add(2);
        array.add(3);
        Assert.assertEquals(7, array.getCapacity());
        Assert.assertEquals(4, array.getCount());
        array.remove(0);
        array.remove(0);
        Assert.assertEquals(7, array.getCapacity());
        Assert.assertEquals(2, array.getCount());
    }

    @Test(expected=IndexOutOfBoundsException.class)
    public void arrayIndexOfBoundsFirstPartTest() throws Exception {
        DynamicArray<Integer> array = new DynamicArray<Integer>(5);
        array.add(0);
        array.remove(-1);
    }

    @Test(expected=IndexOutOfBoundsException.class)
    public void arrayIndexOfBoundsSecondPartTest() throws Exception {
        DynamicArray<Integer> array = new DynamicArray<Integer>(5);
        array.add(0);
        array.get(2);
    }
}

















