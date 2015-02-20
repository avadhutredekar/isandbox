package epam.com.takephoto;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.Volley;
import static android.view.ViewGroup.*;


public class TakePhoto extends ActionBarActivity implements OnClickListener {
    public static final String EXTRA_KEY = "TakePhoto:key";
    public static final String folder = "/sdcard/TakePhoto/";
    private static final String imageUrl = "http://zdorovnavek.ru/wp-content/uploads/2011/11/gates1.jpg";
    private static final Integer requestCameraCode = 101;

    private ImageView preview;
    private TextView takePhotoText;
    private Button buttonTake;
    private Button buttonRetake;
    private Button buttonUse;
    private Button buttonBack;
    private Button buttonUseVolley;
    private RelativeLayout relLayout;
    private LinearLayout linLayout;
    private ProgressBar progressBar;
    private RelativeLayout relativeProgress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_take_photo);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        preview = (ImageView)findViewById(R.id.preview);
        takePhotoText = (TextView) findViewById(R.id.textView3);
        relLayout = (RelativeLayout) findViewById(R.id.rel_take);
        linLayout = (LinearLayout) findViewById(R.id.lin_take);
        progressBar = (ProgressBar)findViewById(R.id.progressBar);
        progressBar.setVisibility(View.VISIBLE);
        relativeProgress = (RelativeLayout)findViewById(R.id.rel_progress);
        relativeProgress.setVisibility(View.INVISIBLE);

        buttonTake = (Button) findViewById(R.id.button_take);
        buttonTake.setOnClickListener(this);

        buttonRetake = (Button) findViewById(R.id.button_retake);
        buttonRetake.setOnClickListener(this);

        buttonUse = (Button) findViewById(R.id.button_use);
        buttonUse.setOnClickListener(this);

        buttonBack = (Button) findViewById(R.id.button2);
        buttonBack.setOnClickListener(this);

        buttonUseVolley = (Button)findViewById(R.id.button_volley);
        buttonUseVolley.setOnClickListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (preview.getDrawable() != null) {
            linLayout.setVisibility(View.VISIBLE);
            relLayout.setVisibility(View.INVISIBLE);
            setTitle(R.string.preview);
        } else {
            linLayout.setVisibility(View.INVISIBLE);
            relLayout.setVisibility(View.VISIBLE);
            setTitle(R.string.take_picture);
        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        onBackPressed();
        return true;
    }

    @Override
    public void onClick(View v) {
        if (v == buttonUseVolley) {
            RequestQueue queue = Volley.newRequestQueue(this);
            ImageRequest ir = new ImageRequest(imageUrl,
                    new Response.Listener<Bitmap>() {
                @Override
                public void onResponse(Bitmap response) {
                    preview.setImageBitmap(response);
                }
            }, 0, 0, null, null);
            queue.add(ir);
            queue.start();
        }
        else if (v == buttonTake || v == buttonRetake) {
            Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            startActivityForResult(takePictureIntent, requestCameraCode);
        } else if (v == buttonUse) {
            relativeProgress.setVisibility(View.VISIBLE);
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
                    relativeProgress.setVisibility(View.INVISIBLE);
                }
            }).execute();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == requestCameraCode && resultCode == RESULT_OK) {
            Bitmap photo = (Bitmap) data.getExtras().get("data");
            preview.setImageBitmap(photo);
        }
    }
}
