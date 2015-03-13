package epam.com.dropboxapi;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.widget.Toast;


public class SplashScreenActivity extends ActionBarActivity implements DropBoxProviderDelegate {

    private DropBoxProvider provider;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        provider = DropBoxProvider.getInstanse(this);
        provider.startAuth(this);

    }

    @Override
    protected void onResume() {
        super.onResume();

        provider.finishAuth();

    }

    @Override
    public void finishAuth(DropBoxProvider provider, boolean successful) {

        String message = successful ?
                    "Successful" :
                    "Failure";

        Toast.makeText(this, message, Toast.LENGTH_LONG).show();

        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }
}
