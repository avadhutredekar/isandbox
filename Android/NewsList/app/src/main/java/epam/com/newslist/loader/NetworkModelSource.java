package epam.com.newslist.loader;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.util.Log;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.RequestFuture;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Date;

import epam.com.newslist.News;

/**
 * Created by Anton Davydov on 2/26/15.
 * Gets data from apiary.io
 */
public class NetworkModelSource extends LocaleJSONModelSource implements Response.Listener<JSONObject>, Response.ErrorListener {

    private static final String NEWS_URL = "http://private-5360b-newslist.apiary-mock.com/news";
    private ModelSourceDelegate mDelegate;
    private RequestQueue mQueue;
    private AsyncTask mAsyncTask;

    public NetworkModelSource(Context context) {
        super(context);

        mQueue = Volley.newRequestQueue(context);
    }

    @Override
    public void startLoadNews(ModelSourceDelegate delegate) {
        mDelegate = delegate;
        mNewsModel.clear();

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.GET, NEWS_URL, null, this, this);

        mQueue.add(request);
        mQueue.start();
    }

    @Override
    public void onErrorResponse(VolleyError error) {
        if (mDelegate != null) {
            mDelegate.finishLoadNews(this, mNewsModel);
        }
    }

    @Override
    public void onResponse(final JSONObject response) {
        mAsyncTask = new AsyncTask() {

            @Override
            protected Object doInBackground(Object[] params) {
                parseResponse(response);
                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                if (mDelegate != null) {
                    mDelegate.finishLoadNews(NetworkModelSource.this, mNewsModel);
                }
            }
        };

        mAsyncTask.execute();
    }

    private void parseResponse(JSONObject response) {
        try {
            JSONArray array = response.getJSONArray(JSON_TAG_NEWS);

            for (int i = 0; i < array.length(); i++) {
                JSONObject item = array.getJSONObject(i);

                Date date = format.parse(item.getString(JSON_TAG_TIME));
                String url = item.getString(JSON_TAG_BITMAP);

                RequestFuture<Bitmap> future = RequestFuture.newFuture();
                ImageRequest request = new ImageRequest(url,future, 0, 0, null,future);
                mQueue.add(request);
                Bitmap bitmap = null;
                try {
                    bitmap = future.get();
                } catch (Exception e) {
                }

                mNewsModel.add(new News(
                        date,
                        String.valueOf(i + 1) + ". " + item.getString(JSON_TAG_DESCRIPTION),
                        bitmap
                ));

            }
        } catch (Exception e) {
            Log.e("Error", e.toString());
            mNewsModel.clear();
        }
    }
}
