package com.github.epam.bigdata.module2.com.github.epam.bigdata.module2;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by dydus on 19/10/2016.
 * Allows to store sorted queue. Shorted strings are located on the top of the queue.
 */
public class ShortestWordQueue {
    private List<String> queue = new ArrayList<String>();

    /**
     * Add new value to the queue. Position depends on length of input value.
     * @param value
     */
    public void push(String value) {
        int size = queue.size();
        int len = value.length();
        for (int i = 0; i < size; i++) {
            if (len <= queue.get(i).length()) {
                queue.add(i, value);
                return;
            }
        }
        queue.add(value);
    }

    /**
     * Allow to get element from the top of the queue without removing. Return null in case when queue is empty.
     * @return
     */
    public String top() {
        return queue.size() == 0 ? null : queue.get(0);
    }

    /**
     * Remove top element and return it. Return null in case when queue is empty.
     * @return
     */
    public String pop() {
        if (queue.size() == 0) {
            return null;
        }

        String result = top();
        queue.remove(0);
        return result;
    }

    /**
     * Get amount of available elements in the queue.
     * @return
     */
    public int getCount() {
        return queue.size();
    }
}
