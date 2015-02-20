package epam.com.takephoto;

import android.os.AsyncTask;
import android.util.Log;

/**
 * Created by Anton Davydov on 2/20/15.
 */
public class AsyncLoader {
    private AsyncTask task;
    public static final String EXCEPTION_TAG = AsyncLoader.class.getCanonicalName();

    public void startLoad(final AsyncLoaderDelegate delegate) {
        task = new AsyncTask() {
            @Override
            protected Object doInBackground(Object[] params) {
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e) {
                    Log.e(EXCEPTION_TAG, e.toString());
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                if (delegate != null)
                    delegate.finishLoad(o);
            }

            @Override
            protected void onCancelled(Object o) {
                super.onCancelled(o);
                if (delegate != null)
                    delegate.finishLoad(o);
            }
        };
        task.execute();
    }

    public void cancel() {
        if (task != null)
            task.cancel(true);
    }

    public boolean isRunning() {
        return (task != null && task.getStatus() == AsyncTask.Status.RUNNING);
    }
}


interface AsyncLoaderDelegate {
    void finishLoad(Object o);
}