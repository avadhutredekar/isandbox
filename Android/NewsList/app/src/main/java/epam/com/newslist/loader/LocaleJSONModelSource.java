package epam.com.newslist.loader;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.IOException;
import java.io.InputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import epam.com.newslist.News;

/**
 * Created by Anton Davydov on 2/26/15.
 * Creates the news from local json-file
 */
public class LocaleJSONModelSource extends ModelSource {
    protected static final String JSON_FILE_NAME = "news.json";
    protected static final String JSON_TAG_NEWS = "news";
    protected static final String JSON_TAG_DESCRIPTION = "description";
    protected static final String JSON_TAG_TIME = "time";
    protected static final String JSON_TAG_BITMAP = "bitmap";
    protected static final DateFormat format = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
    private AsyncTask mAsyncTask;
    private ModelSourceDelegate mDelegate;

    public LocaleJSONModelSource(Context context) {
        super(context);
    }

    @Override
    public void startLoadNews(ModelSourceDelegate delegate)  {
        mDelegate = delegate;
        mAsyncTask = new AsyncTask() {

            @Override
            protected Object doInBackground(Object[] params) {
                parseJSON(loadJSONFromAsset());
                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                if (mDelegate != null) {
                    mDelegate.finishLoadNews(LocaleJSONModelSource.this, mNewsModel);
                }
            }
        };

        mAsyncTask.execute();
    }

    private void parseJSON(String json) {
        mNewsModel.clear();

        try {
            JSONObject root = new JSONObject(json);
            JSONArray array = root.getJSONArray(JSON_TAG_NEWS);
            for (int i = 0; i < array.length(); i++) {
                JSONObject item = array.getJSONObject(i);

                Date date = format.parse(item.getString(JSON_TAG_TIME));
                InputStream ims = context.getAssets().open(item.getString(JSON_TAG_BITMAP));

                mNewsModel.add(new News(
                        date,
                        String.valueOf(i + 1) + ". " + item.getString(JSON_TAG_DESCRIPTION),
                        BitmapFactory.decodeStream(ims)
                ));

            }
        } catch (Exception e) {
            Log.e("Error", e.toString());
            mNewsModel.clear();
        }
    }

    private String loadJSONFromAsset() {
        String json = null;
        try {
            InputStream is = context.getAssets().open(JSON_FILE_NAME);
            int size = is.available();
            byte[] buffer = new byte[size];
            is.read(buffer);
            is.close();
            json = new String(buffer, "UTF-8");

        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
        return json;
    }

}
