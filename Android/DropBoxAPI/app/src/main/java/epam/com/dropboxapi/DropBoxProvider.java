package epam.com.dropboxapi;

import android.content.Context;
import android.content.SharedPreferences;

import com.dropbox.client2.DropboxAPI;
import com.dropbox.client2.android.AndroidAuthSession;
import com.dropbox.client2.session.AppKeyPair;

/**
 * Created by Anton Davydov on 3/3/15.
 */
public class DropBoxProvider {
    final static private String APP_KEY = "l1ux7pamqby75rq";
    final static private String APP_SECRET = "p27vrjqq9h5uvpt";
    final static private String SHARED_PREFERENCES = "DropBoxProviderPrefences1";
    final static private String SHARED_PREF_KEY = "DropBoxPrefKey1";

    private Context mContext;
    private DropBoxProviderDelegate mDelegate;

    private DropboxAPI<AndroidAuthSession> mDBApi;
    private String mAuthToken;


    private static DropBoxProvider instanse;

    public static DropBoxProvider getInstanse(Context context) {
        instanse = instanse == null ? new DropBoxProvider(context) : instanse;
        return instanse;
    }

    private DropBoxProvider(Context context) {
        this.mContext = context;

        AppKeyPair appKeys = new AppKeyPair(APP_KEY, APP_SECRET);
        AndroidAuthSession session = new AndroidAuthSession(appKeys);
        mDBApi = new DropboxAPI<AndroidAuthSession>(session);
    }

    public void startAuth(DropBoxProviderDelegate delegate) {

        mDelegate = delegate;
        String token = mContext.getSharedPreferences(SHARED_PREFERENCES, 0).getString(SHARED_PREF_KEY, null);

        if (token != null) {
            mDBApi.getSession().setOAuth2AccessToken(token);
            if (mDelegate != null)
                mDelegate.finishAuth(this, true);
        } else
            mDBApi.getSession().startOAuth2Authentication(mContext);
    }

    public void finishAuth() {

        if (mDBApi.getSession().authenticationSuccessful()) {
            try {
                mDBApi.getSession().finishAuthentication();
                mAuthToken =  mDBApi.getSession().getOAuth2AccessToken();

                SharedPreferences.Editor editor = mContext.getSharedPreferences(SHARED_PREFERENCES, 0).edit();
                editor.putString(SHARED_PREF_KEY, mAuthToken);
                editor.commit();

                if (mDelegate != null)
                    mDelegate.finishAuth(this, true);
            } catch(Exception e) {
                mAuthToken = null;

                if (mDelegate != null)
                    mDelegate.finishAuth(this, false);
            }
        }
    }
}


interface DropBoxProviderDelegate {

    void finishAuth(DropBoxProvider provider, boolean successful);

}