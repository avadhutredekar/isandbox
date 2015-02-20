package epam.com.takephoto;

import android.os.AsyncTask;

/**
 * Created by Anton Davydov on 2/20/15.
 */
public class Provider {

    public static void startLoadData(final ProviderDelegate delegate) {
        (new AsyncTask() {
            @Override
            protected Object doInBackground(Object[] params) {
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                if (delegate != null)
                    delegate.finishLoad(true);
            }

            @Override
            protected void onCancelled(Object o) {
                super.onCancelled(o);
                if (delegate != null)
                    delegate.finishLoad(false);
            }
        }).execute();
    }
}


interface ProviderDelegate {
    void finishLoad(boolean result);
}