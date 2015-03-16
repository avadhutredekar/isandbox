package epam.com.takephoto;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
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


/**
 *
 */
public class TakePhoto extends ActionBarActivity implements View.OnClickListener {
    private static final String IMAGE_URL = "http://zdorovnavek.ru/wp-content/uploads/2011/11/gates1.jpg";
    private static final Integer REQUEST_CAMERA_CODE = 101;

    private ImageView mPreview;
    private TextView mTakePhotoText;
    private Button mButtonTake;
    private Button mButtonRetake;
    private Button mButtonUse;
    private Button mButtonBack;
    private Button mButtonUseVolley;
    private RelativeLayout mRelLayout;
    private LinearLayout mLinLayout;
    private ProgressBar mProgressBar;
    private RelativeLayout mRelativeProgress;

    private ImageLoader mImageLoader;
    private AsyncLoader mAsyncLoader;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_take_photo);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mPreview = (ImageView) findViewById(R.id.preview);
        mTakePhotoText = (TextView) findViewById(R.id.textView3);
        mRelLayout = (RelativeLayout) findViewById(R.id.rel_take);
        mLinLayout = (LinearLayout) findViewById(R.id.lin_take);
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mProgressBar.setVisibility(View.VISIBLE);
        mRelativeProgress = (RelativeLayout) findViewById(R.id.rel_progress);
        mRelativeProgress.setVisibility(View.INVISIBLE);

        mButtonTake = (Button) findViewById(R.id.button_take);
        mButtonTake.setOnClickListener(this);

        mButtonRetake = (Button) findViewById(R.id.button_retake);
        mButtonRetake.setOnClickListener(this);

        mButtonUse = (Button) findViewById(R.id.button_use);
        mButtonUse.setOnClickListener(this);

        mButtonBack = (Button) findViewById(R.id.button2);
        mButtonBack.setOnClickListener(this);

        mButtonUseVolley = (Button) findViewById(R.id.button_volley);
        mButtonUseVolley.setOnClickListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mPreview.getDrawable() != null) {
            mLinLayout.setVisibility(View.VISIBLE);
            mRelLayout.setVisibility(View.INVISIBLE);
            setTitle(R.string.preview);
        } else {
            mLinLayout.setVisibility(View.INVISIBLE);
            mRelLayout.setVisibility(View.VISIBLE);
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
        if (v == mButtonUseVolley) {
            mImageLoader =  new ImageLoader(this);
            mImageLoader.loadImageByUrl(IMAGE_URL, new ImageLoaderDelegate() {
                @Override
                public void finishLoad(Bitmap result) {
                    mPreview.setImageBitmap(result);
                }
            });
        } else if (v == mButtonTake || v == mButtonRetake) {
            Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            startActivityForResult(takePictureIntent, REQUEST_CAMERA_CODE);
        } else if (v == mButtonUse) {
            mRelativeProgress.setVisibility(View.VISIBLE);
            mAsyncLoader = new AsyncLoader();
            mAsyncLoader.startLoad(new AsyncLoaderDelegate() {
                @Override
                public void finishLoad(Object result) {
                    mRelativeProgress.setVisibility(View.INVISIBLE);
                }
            });
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CAMERA_CODE && resultCode == RESULT_OK) {
            Bitmap photo = (Bitmap) data.getExtras().get("data");
            Bitmap photoFrame = BitmapFactory.decodeResource(getResources(), R.drawable.photo_frame);
			photo = Util.overlayBitmaps(photo, photoFrame);
            mPreview.setImageBitmap(photo);
        }
    }
}
