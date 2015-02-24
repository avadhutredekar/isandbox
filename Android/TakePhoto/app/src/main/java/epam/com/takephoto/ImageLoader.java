package epam.com.takephoto;

import android.content.Context;
import android.graphics.Bitmap;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.Volley;

/**
 * Created by Anton Davydov on 2/20/15.
 */
public class ImageLoader {

    private final Context mContext;
    private RequestQueue mQueue;

    /**
     *
     * @param context Activity context
     */
    public ImageLoader(Context context) {
        this.mContext = context;
    }


    /**
     * Concurrent receiving Bitmap by url
     * @param url Image url
     * @param delegate Callback when loading will be finished
     */
    public void loadImageByUrl(String url, final ImageLoaderDelegate delegate) {
        mQueue = Volley.newRequestQueue(mContext);
        ImageRequest request = new ImageRequest(url,
                new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap response) {
                        if (delegate != null) {
                            delegate.finishLoad(response);
                        }
                    }
                }, 0, 0, null, null);
        request.setTag(this);
        mQueue.add(request);
        mQueue.start();
    }


    /**
     * Cancelling of loading
     */
    public void cancel() {
        if (mQueue != null) {
            mQueue.cancelAll(this);
        }
    }
}


/**
 * Notification about finish of load
 */
interface ImageLoaderDelegate {
    void finishLoad(Bitmap result);
}