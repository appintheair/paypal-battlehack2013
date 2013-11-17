package com.empatika.donatenow;

import android.app.Activity;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.os.Bundle;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.os.Build;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;

public class MainActivity extends FragmentActivity {

    ViewPager pager;
    Donation donation;

    TextView tvPeople;
    TextView tvRaised;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (!ImageLoader.getInstance().isInited()) {
            DisplayImageOptions defaultOptions = new DisplayImageOptions.Builder()
                    .cacheInMemory(true)
                    .cacheOnDisc(true)
                    .build();
            ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(getApplicationContext())
                    .defaultDisplayImageOptions(defaultOptions).build();
            ImageLoader.getInstance().init(config);
        }

        loadDonationDetails("1");
    }

    private void loadDonationDetails(String donationId) {
        new DonationDetailsLoader().execute(donationId);
    }

    private void setupLayout(Donation donation) {
        this.donation = donation;

        pager = (ViewPager)findViewById(R.id.pager);
        ImagesAdapter imagesAdapter = new ImagesAdapter(getSupportFragmentManager(), donation.photoUrls);
        pager.setAdapter(imagesAdapter);

        TextView tvTitle = (TextView)findViewById(R.id.tvTitle);
        tvTitle.setText(donation.title);

        Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Roboto-Regular.ttf");
        tvTitle.setTypeface(tf);

        tvPeople = (TextView)findViewById(R.id.tvPeople);
        tvPeople.setText(String.format("%d", donation.voters));
        tvPeople.setTypeface(tf);

        tvRaised = (TextView)findViewById(R.id.tvRaised);
        tvRaised.setText(String.format("$%d", donation.amountRaised));
        tvRaised.setTypeface(tf);

        ((ImageButton)findViewById(R.id.buttonAmount10)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                payWithAmount(10);
            }
        });

        ((ImageButton)findViewById(R.id.buttonAmount20)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                payWithAmount(20);
            }
        });

        ((ImageButton)findViewById(R.id.buttonCustom)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                AlertDialog.Builder alert = new AlertDialog.Builder(MainActivity.this);
                alert.setTitle("Enter your amount");
                alert.setMessage("Choose how much you can donate");
                final EditText input = new EditText(MainActivity.this);
                alert.setView(input);

                alert.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        payWithAmount(Integer.parseInt(input.getText().toString()));
                    }
                });

                alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {

                    }
                });
                alert.show();
            }
        });
    }

    private void payWithAmount(int amount) {

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        return false;
    }

    private class ImagesAdapter extends FragmentStatePagerAdapter {
        private ArrayList<String> imageUrls;
        ArrayList<ImageFragment> fragments = new ArrayList<ImageFragment>();

        public ImagesAdapter(FragmentManager fm, ArrayList<String> imageUrls) {
            super(fm);
            this.imageUrls = imageUrls;
            for (String url : imageUrls) {
                ImageFragment fragment = new ImageFragment();
                Bundle bundle = new Bundle();
                bundle.putString("com.empatika.donatenow.imageurl", url);
                fragment.setArguments(bundle);
                fragments.add(fragment);
            }
        }

        @Override
        public Fragment getItem(int i) {
            return fragments.get(i);
        }

        @Override
        public int getCount() {
            return imageUrls.size();
        }

        public ArrayList<String> imageUrls() {
            return imageUrls;
        }
    }


    private class DonationDetailsLoader extends AsyncTask<String, Void, Donation> {

        @Override
        protected Donation doInBackground(String... strings) {
            HttpGet hget = new HttpGet(Globals.HOST_URL + "getDonationDetails?donation_id=" + strings[0]);

            DefaultHttpClient client = new DefaultHttpClient();
            HttpResponse response;
            try {
                response = client.execute(hget);
                String strResponse = EntityUtils.toString(response.getEntity());
                JSONObject obj = new JSONObject(strResponse);
                return new Donation(obj);
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        }

        @Override
        protected void onPostExecute(Donation result) {
            setupLayout(result);
        }
    }

}
