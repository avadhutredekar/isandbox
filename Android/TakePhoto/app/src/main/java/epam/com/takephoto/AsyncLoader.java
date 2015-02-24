package epam.com.takephoto;

import android.os.AsyncTask;
import android.util.Log;

/**
 * Created by Anton Davydov on 2/20/15.
 */
public class AsyncLoader {
    private AsyncTask mTask;
    private static final Integer WAITING_TIME = 3000;

    /**
     * Tag for log error when loading was interrupted
     */
    public static final String EXCEPTION_TAG = AsyncLoader.class.getCanonicalName();


    /**
     * Concurrent execution of task
     * @param delegate Notification about finishing of load
     */
    public void startLoad(final AsyncLoaderDelegate delegate) {
        mTask = new AsyncTask() {
            @Override
            protected Object doInBackground(Object[] params) {
                try {
                    Thread.sleep(WAITING_TIME);
                } catch (InterruptedException e) {
                    Log.e(EXCEPTION_TAG, e.toString());
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                if (delegate != null) {
                    delegate.finishLoad(o);
                }
            }

            @Override
            protected void onCancelled(Object o) {
                super.onCancelled(o);
                if (delegate != null) {
                    delegate.finishLoad(o);
                }
            }
        };
        mTask.execute();
    }


    /**
     * Cancel task
     */
    public void cancel() {
        if (mTask != null) {
            mTask.cancel(true);
        }
    }

    /**
     * Checking of task state
      * @return state of task
     */
    public boolean isRunning() {
        return (mTask != null && mTask.getStatus() == AsyncTask.Status.RUNNING);
    }
}


/**
 * Notification about finish of execution of task
 */
interface AsyncLoaderDelegate {
    void finishLoad(Object o);
}