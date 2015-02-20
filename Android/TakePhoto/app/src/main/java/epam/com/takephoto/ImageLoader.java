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

    private Context context;
    private RequestQueue queue;

    public ImageLoader(Context context) {
        this.context = context;
    }

    public void loadImageByUrl(String url, final ImageLoaderDelegate delegate) {
        RequestQueue queue = Volley.newRequestQueue(context);
        ImageRequest request = new ImageRequest(url,
                new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap response) {
                        if (delegate != null)
                            delegate.finishLoad(response);
                    }
                }, 0, 0, null, null);
        request.setTag(this);
        queue.add(request);
        queue.start();
    }

    public void cancel() {
        if (queue != null)
            queue.cancelAll(this);
    }
}

interface ImageLoaderDelegate {
    void finishLoad(Bitmap result);
}