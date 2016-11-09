package com.github.epam.bigdata.module2.com.github.epam.bigdata.module2;

import org.junit.Assert;
import org.junit.Test;

/**
 * Created by dydus on 19/10/2016.
 */
public class ShortestWordQueueTest {

    @Test
    public void queueEmptyTest() throws Exception {
        ShortestWordQueue queue = new ShortestWordQueue();
        Assert.assertEquals(null, queue.top());
        Assert.assertEquals(0, queue.getCount());
        Assert.assertEquals(null, queue.pop());
        Assert.assertEquals(0, queue.getCount());
    }

    @Test
    public void queueAddingAndRemovingTest() throws Exception {
        ShortestWordQueue queue = new ShortestWordQueue();
        queue.push("1");
        Assert.assertEquals("1", queue.top());
        Assert.assertEquals(1, queue.getCount());
        Assert.assertEquals("1", queue.pop());
        Assert.assertEquals(0, queue.getCount());
    }

    @Test
    public void queueSortingTest() throws Exception {
        ShortestWordQueue queue = new ShortestWordQueue();
        queue.push("123");
        queue.push("1");
        queue.push("12");
        queue.push("1234");
        Assert.assertEquals(4, queue.getCount());
        Assert.assertEquals("1", queue.top());
        Assert.assertEquals("1", queue.pop());
        Assert.assertEquals("12", queue.pop());
        Assert.assertEquals("123", queue.pop());
        Assert.assertEquals("1234", queue.pop());
        Assert.assertEquals(null, queue.pop());
    }

}