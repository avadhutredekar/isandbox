package dydus.com.multicloudservice;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;

import java.nio.ByteBuffer;
import java.util.List;

import dydus.com.multicloudservice.generated.Account;
import dydus.com.multicloudservice.generated.MultiCloudService;


public class MainActivity extends Activity {
    private static final String TAG = MainActivity.class.getCanonicalName();
	private static final int COUNT_ITEMS_IN_LINE = 3;
    private static final int REQUEST_OPTIONS_CODE = 1111;

	private GalleryRecyclerAdapter mAdapter;
	private RecyclerView mRecyclerView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
		StorageProvider.context = this;
		mRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
		GridLayoutManager glm = new GridLayoutManager(this, COUNT_ITEMS_IN_LINE);
		mRecyclerView.setLayoutManager(glm);
		mAdapter = new GalleryRecyclerAdapter(this);
		mRecyclerView.setAdapter(mAdapter);

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_accounts, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_settings) {

            Intent intent = new Intent(this, AccountsActivity.class);
            startActivityForResult(intent, REQUEST_OPTIONS_CODE);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}