package epam.com.takephoto;

import android.content.Context;
import android.graphics.Bitmap;
import android.widget.ImageView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.Volley;

/**
 * Created by Anton Davydov on 2/20/15.
 */
public class ImageLoader {

    public static void setImageByUrl(Context context, String url, final ImageView imView) {
        RequestQueue queue = Volley.newRequestQueue(context);
        ImageRequest ir = new ImageRequest(url,
                new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap response) {
                        imView.setImageBitmap(response);
                    }
                }, 0, 0, null, null);
        queue.add(ir);
        queue.start();
    }
}
