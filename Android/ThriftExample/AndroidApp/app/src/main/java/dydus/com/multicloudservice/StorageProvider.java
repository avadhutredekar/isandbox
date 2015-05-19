package dydus.com.multicloudservice;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.provider.MediaStore;
import android.util.Log;

import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;

import java.io.File;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dydus.com.multicloudservice.generated.Account;
import dydus.com.multicloudservice.generated.MultiCloudService;

/**
 * Created by Anton Davydov on 4/15/15.
 */
public class StorageProvider {
	public static Context context;
	private static final String TAG = MainActivity.class.getCanonicalName();
	private static StorageProvider instance;


	private TTransport mTransport;
	private TProtocol mProtocol;
	private Object mClient;

	public List<String> images;
	public volatile int loaded = 0;

	public ProviderCallBack listener;

	public synchronized static StorageProvider getInstance() {
		if (instance == null) {
			instance = new StorageProvider();
			//instance.auth();
		}

		return instance;
	}

	public void queryPaths() {
		new AsyncTask() {

			@Override
			protected Object doInBackground(Object[] params) {
				try {
					if (mTransport == null)
						auth();
					mTransport.open();
					images = ((MultiCloudService.Client)mClient).getImagePaths();
					mTransport.close();
				} catch (Exception e) {
					Log.d(TAG, e.toString());
				}
				return null;
			}

			@Override
			protected void onPostExecute(Object o) {
				super.onPostExecute(o);
				for (String i : images) {
					new ImageTask(i).execute();
				}

				if (listener != null)
					listener.updateData();
			}
		}.execute();
	}

	public ViewHolder.State getState(ViewHolder h) {
		String path = h.path;
		if (images == null)
			images = new ArrayList<String>();
		for (String im : images) {
			if (path.contains(im))
				return ViewHolder.State.SYNC_BOTH;
		}

		return ViewHolder.State.SYNC_APP;
	}

	public void auth() {
		try {
			mTransport = new TSocket("10.16.10.236", 30301);
			mProtocol = new TBinaryProtocol(instance.mTransport);
			mClient = new MultiCloudService.Client(instance.mProtocol);

		} catch (Exception e) {
			Log.d(TAG, e.toString());
		}
	}

	public void query() {
		new AsyncTask() {

			@Override
			protected Object doInBackground(Object[] params) {
				try {
					if (mTransport == null)
						auth();
					mTransport.open();
					((MultiCloudService.Client)mClient).ping();
					boolean a = ((MultiCloudService.Client)mClient).addAccount(new Account());
					((MultiCloudService.Client)mClient).createUserByAccount(new Account());
					((MultiCloudService.Client)mClient).getAllImages();
					List<String> images = ((MultiCloudService.Client)mClient).getImagePaths();
					((MultiCloudService.Client)mClient).getUserInfo();
					ByteBuffer bb = ((MultiCloudService.Client) mClient).imageByPath("");
					Bitmap b = BitmapFactory.decodeByteArray(bb.array(), 0, bb.array().length);
					mTransport.close();
				} catch (Exception e) {
					Log.d(TAG, e.toString());
				}
				return null;
			}
		}.execute();
	}

	public List<String> getImagePaths() {
		if (images == null) {
			images = new ArrayList<String>();
			queryPaths();
		}
		return images;
	}

	public Bitmap getImageByPath(String path) {
		Bitmap bitmap = null;
		try {
			if (mTransport == null)
				auth();
			mTransport.open();
			((MultiCloudService.Client)mClient).ping();
			ByteBuffer bb = ((MultiCloudService.Client) mClient).imageByPath(path);
			bitmap = BitmapFactory.decodeByteArray(bb.array(), 0, bb.array().length);
			mTransport.close();
		} catch (Exception e) {
			Log.d(TAG, e.toString());
		}

		return bitmap;
	}

	public void sendImage(Bitmap b) {

	}

	public interface ProviderCallBack {
		public void updateData();
	}

	class ImageTask extends AsyncTask {
		private String path;
		private Bitmap b;
		ImageTask(String path) {
			this.path = path;
		}

		@Override
		protected Object doInBackground(Object[] params) {
			try {
				b = getImageByPath(path);
				File outputDir = context.getCacheDir();
				String fileName = outputDir.getPath() + path;
				MediaStore.Images.Media.insertImage(context.getContentResolver(), b,  fileName, "");
				loaded++;
			} catch (Exception e) {
				Log.d(TAG, e.toString());
			}
			return null;
		}

		@Override
		protected void onPostExecute(Object o) {
			super.onPostExecute(o);
			listener.updateData();
		}
	}
}
