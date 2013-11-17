package com.empatika.donatenow;

import android.app.Activity;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
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
import android.widget.Toast;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.paypal.android.sdk.payments.PayPalPayment;
import com.paypal.android.sdk.payments.PayPalService;
import com.paypal.android.sdk.payments.PaymentActivity;
import com.paypal.android.sdk.payments.PaymentConfirmation;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;

public class MainActivity extends FragmentActivity {

    ViewPager pager;
    Donation donation;

    int donationAmount;

    TextView tvPeople;
    TextView tvRaised;

    ImageButton button10;
    ImageButton button20;
    ImageButton buttonCustom;
    Button buttonInvite;

    ProgressDialog dialog;

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

        Intent intent = new Intent(this, PayPalService.class);
        intent.putExtra(PaymentActivity.EXTRA_PAYPAL_ENVIRONMENT, PaymentActivity.ENVIRONMENT_SANDBOX);
        intent.putExtra(PaymentActivity.EXTRA_CLIENT_ID, Globals.PAYPAL_CLIENT);
        startService(intent);

        loadDonationDetails("1");
    }

    @Override
    public void onDestroy() {
        stopService(new Intent(this, PayPalService.class));
        super.onDestroy();
    }

    private void loadDonationDetails(String donationId) {
        new DonationDetailsLoader().execute(donationId);
    }

    private void resetLayout() {
        button10.setVisibility(View.VISIBLE);
        button20.setVisibility(View.VISIBLE);
        buttonCustom.setVisibility(View.VISIBLE);
        buttonInvite.setVisibility(View.INVISIBLE);
    }

    private void setupLayout(final Donation donation) {
        this.donation = donation;

        pager = (ViewPager)findViewById(R.id.pager);
        ImagesAdapter imagesAdapter = new ImagesAdapter(getSupportFragmentManager(), donation.getPhotoUrls());
        pager.setAdapter(imagesAdapter);

        TextView tvTitle = (TextView)findViewById(R.id.tvTitle);
        tvTitle.setText(donation.getTitle());

        Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Roboto-Regular.ttf");
        tvTitle.setTypeface(tf);

        tvPeople = (TextView)findViewById(R.id.tvPeople);
        tvPeople.setText(String.format("%d", donation.getVoters()));
        tvPeople.setTypeface(tf);

        tvRaised = (TextView)findViewById(R.id.tvRaised);
        tvRaised.setText(String.format("$%d", donation.getAmountRaised()));
        tvRaised.setTypeface(tf);

        button10 = (ImageButton)findViewById(R.id.buttonAmount10);
        button10.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                payWithAmount(10);
            }
        });

        button20 = (ImageButton)findViewById(R.id.buttonAmount20);
        button20.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                payWithAmount(20);
            }
        });

        buttonCustom = (ImageButton)findViewById(R.id.buttonCustom);
        buttonCustom.setOnClickListener(new View.OnClickListener() {
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

        buttonInvite = (Button)findViewById(R.id.buttonInvite);
        buttonInvite.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);

                emailIntent.setType("plain/text");
                emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, "Donate. Now.");
                emailIntent.putExtra(android.content.Intent.EXTRA_TEXT, "Donate on\n" + donation.getTitle());

                startActivity(Intent.createChooser(emailIntent, "Send mail..."));
            }
        });
    }

    private void payWithAmount(int amount) {
        PayPalPayment payment = new PayPalPayment(new BigDecimal(amount), "USD", donation.getTitle());
        Intent intent = new Intent(this, PaymentActivity.class);
        intent.putExtra(PaymentActivity.EXTRA_PAYPAL_ENVIRONMENT, PaymentActivity.ENVIRONMENT_SANDBOX);
        intent.putExtra(PaymentActivity.EXTRA_CLIENT_ID, Globals.PAYPAL_CLIENT);
        intent.putExtra(PaymentActivity.EXTRA_PAYER_ID, "kinda_unique_id2");
        intent.putExtra(PaymentActivity.EXTRA_RECEIVER_EMAIL, "bayram.annakov-facilitator@gmail.com");
        intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);
        donationAmount = amount;
        startActivityForResult(intent, 0);
    }

    @Override
    protected void onActivityResult (int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            PaymentConfirmation confirm = data.getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
            if (confirm != null) {
                tvPeople.setText(String.format("%d", donation.getVoters()+1));
                tvRaised.setText(String.format("$%d", donation.getAmountRaised()+donationAmount));

                donation.setConfirmation(confirm.toJSONObject().toString());

                dialog = ProgressDialog.show(this, "Verifying your transaction", "It may take a while...");
                new PaymentDetailsSender().execute(donation);
            }
        }
        else if (resultCode == Activity.RESULT_CANCELED) {
            Log.i("paymentExample", "The user canceled.");
        }
        else if (resultCode == PaymentActivity.RESULT_PAYMENT_INVALID) {
            Log.i("paymentExample", "An invalid payment was submitted. Please see the docs.");
        }
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
            resetLayout();
        }
    }

    private class PaymentDetailsSender extends AsyncTask<Donation, Void, Boolean> {

        @Override
        protected Boolean doInBackground(Donation... donations) {
            HttpPost hpost = new HttpPost(Globals.HOST_URL + "getDonationDetails");

            try {
                ArrayList<NameValuePair> pairs = new ArrayList<NameValuePair>();
                pairs.add(new BasicNameValuePair("amount", String.format("%d", donationAmount)));
                pairs.add(new BasicNameValuePair("donation_id", donations[0].getDonationId()));
                pairs.add(new BasicNameValuePair("donator_email", "q.pronin@gmail.com"));
                pairs.add(new BasicNameValuePair("receipt", donations[0].getConfirmation()));
                hpost.setEntity(new UrlEncodedFormEntity(pairs));
                DefaultHttpClient client = new DefaultHttpClient();
                HttpResponse response;

                response = client.execute(hpost);
                String strResponse = EntityUtils.toString(response.getEntity());
                JSONObject obj = new JSONObject(strResponse);
                String error = obj.optString("error");
                return error == null || error.length() == 0;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }

        @Override
        protected void onPostExecute(Boolean result) {
            dialog.dismiss();
            if (result) {
                Toast.makeText(MainActivity.this, "Successfully donated!", Toast.LENGTH_LONG).show();
                button10.setVisibility(View.INVISIBLE);
                button20.setVisibility(View.INVISIBLE);
                buttonCustom.setVisibility(View.INVISIBLE);
                buttonInvite.setVisibility(View.VISIBLE);
            } else {
                Toast.makeText(MainActivity.this, "Something went wrong :(", Toast.LENGTH_LONG).show();
            }

        }
    }

}
