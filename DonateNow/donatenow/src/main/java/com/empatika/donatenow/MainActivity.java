package com.empatika.donatenow;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.IBinder;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.os.Bundle;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.Menu;
import android.view.View;
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
import org.json.JSONObject;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class MainActivity extends FragmentActivity {

    private static final long SCAN_PERIOD = 3000;

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

    BluetoothAdapter bluetoothAdapter;
    BluetoothDevice bluetoothDevice;

    RBLService bluetoothService;

    private Map<UUID, BluetoothGattCharacteristic> map = new HashMap<UUID, BluetoothGattCharacteristic>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //I need it just because keyboard is not working
//        setUpWifi();

        setUpImageLoader();
        setUpPayPal();

        setUpBLE();
    }

    private void setUpWifi() {
        WifiManager wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        WifiConfiguration wc = new WifiConfiguration();
        wc.SSID = "\"eBayGuest\"";
        wc.preSharedKey = "\"BuyItNow!\"";
        wc.status = WifiConfiguration.Status.ENABLED;
        wc.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
        wc.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
        wc.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
        wc.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
        wc.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
        wc.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
        int netId = wifiManager.addNetwork(wc);
        wifiManager.enableNetwork(netId, true);
        wifiManager.setWifiEnabled(true);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onStop() {
        super.onStop();

//        try {
//            unregisterReceiver(updateReceiver);
//        } catch (Exception e) {
//        }
    }

    private void setUpBLE() {
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, "Ble not supported", Toast.LENGTH_SHORT).show();
            finish();
        }

        bluetoothAdapter = ((BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE)).getAdapter();
        if (bluetoothAdapter == null) {
            Toast.makeText(this, "Ble not supported", Toast.LENGTH_SHORT).show();
            finish();
        }

        scanLeDevice();
    }

    private final ServiceConnection serviceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName,
                                       IBinder service) {
            bluetoothService = ((RBLService.LocalBinder) service).getService();
            if (!bluetoothService.initialize()) {
                Toast.makeText(MainActivity.this, "Service initialization error", Toast.LENGTH_SHORT).show();
                finish();
            }
            bluetoothService.connect(bluetoothDevice.getAddress());
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            bluetoothService = null;
        }
    };

    private final BroadcastReceiver updateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();

            if (RBLService.ACTION_GATT_DISCONNECTED.equals(action)) {
            } else if (RBLService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                getGattService(bluetoothService.getSupportedGattService());
            } else if (RBLService.ACTION_DATA_AVAILABLE.equals(action)) {
                displayData(intent.getByteArrayExtra(RBLService.EXTRA_DATA));
            }
        }
    };

    private void getGattService(BluetoothGattService gattService) {
        if (gattService == null)
            return;

        BluetoothGattCharacteristic characteristic = gattService.getCharacteristic(RBLService.UUID_BLE_SHIELD_TX);
        map.put(characteristic.getUuid(), characteristic);

        BluetoothGattCharacteristic characteristicRx = gattService.getCharacteristic(RBLService.UUID_BLE_SHIELD_RX);
        bluetoothService.setCharacteristicNotification(characteristicRx, true);
        bluetoothService.readCharacteristic(characteristicRx);
    }

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();

        intentFilter.addAction(RBLService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(RBLService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(RBLService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(RBLService.ACTION_DATA_AVAILABLE);

        return intentFilter;
    }

    private void displayData(byte[] byteArray) {
        if (byteArray != null) {
            String data = new String(byteArray);
            Toast.makeText(this, data, Toast.LENGTH_LONG);
        }
    }

    BluetoothAdapter.LeScanCallback scanCallback = new BluetoothAdapter.LeScanCallback() {
        @Override
        public void onLeScan(final BluetoothDevice device, final int rssi, byte[] scanRecord) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (device != null) {
                        if (device.getName() != null && device.getName().contains("Shield")) {
                            bluetoothDevice = device;

                            Intent gattServiceIntent = new Intent(MainActivity.this, RBLService.class);
                            bindService(gattServiceIntent, serviceConnection, BIND_AUTO_CREATE);

                            registerReceiver(updateReceiver, makeGattUpdateIntentFilter());

                            loadDonationDetails(bluetoothDevice.getAddress());
                        }
                    }
                }
            });
        }
    };

    private void scanLeDevice() {
        new Thread() {

            @Override
            public void run() {
                bluetoothAdapter.startLeScan(scanCallback);

                try {
                    Thread.sleep(SCAN_PERIOD);


                    bluetoothAdapter.stopLeScan(scanCallback);

                    if (bluetoothDevice == null) {
                        Thread.sleep(1000);
                        scanLeDevice();
                    }

                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }.start();
    }

    private void setUpImageLoader() {
        if (!ImageLoader.getInstance().isInited()) {
            DisplayImageOptions defaultOptions = new DisplayImageOptions.Builder()
                    .cacheInMemory(true)
                    .cacheOnDisc(true)
                    .build();
            ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(getApplicationContext())
                    .defaultDisplayImageOptions(defaultOptions).build();
            ImageLoader.getInstance().init(config);
        }
    }

    private void setUpPayPal() {
        Intent intent = new Intent(this, PayPalService.class);
        intent.putExtra(PaymentActivity.EXTRA_PAYPAL_ENVIRONMENT, PaymentActivity.ENVIRONMENT_SANDBOX);
        intent.putExtra(PaymentActivity.EXTRA_CLIENT_ID, Globals.PAYPAL_CLIENT);
        startService(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
//        stopService(new Intent(this, PayPalService.class));
//
//        if (bluetoothService != null) {
//            bluetoothService.disconnect();
//            bluetoothService.close();
//        }
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
            HttpGet hget = new HttpGet(Globals.HOST_URL + "getDonationDetails?physical_address=" + strings[0]);

            DefaultHttpClient client = new DefaultHttpClient();
            HttpResponse response;
            try {
                response = client.execute(hget);
                String strResponse = EntityUtils.toString(response.getEntity());
                JSONObject obj = new JSONObject(strResponse);
                return new Donation(obj);
            } catch (Exception e) {
//                e.printStackTrace();
                return null;
            }
        }

        @Override
        protected void onPostExecute(Donation result) {
            if (result != null) {
                setupLayout(result);
                resetLayout();
            }
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
//            if (result) {
                uploadBLEValue(donation.getAmountRaised() + donationAmount);
                Toast.makeText(MainActivity.this, "Successfully donated!", Toast.LENGTH_LONG).show();
                button10.setVisibility(View.INVISIBLE);
                button20.setVisibility(View.INVISIBLE);
                buttonCustom.setVisibility(View.INVISIBLE);
                buttonInvite.setVisibility(View.VISIBLE);
//            } else {
//                Toast.makeText(MainActivity.this, "Something went wrong :(", Toast.LENGTH_LONG).show();
//            }

        }
    }

    private Handler handler = new Handler();

    private void uploadBLEValue(int value) {
        BluetoothGattCharacteristic characteristic = map.get(RBLService.UUID_BLE_SHIELD_TX);
        String k = String.format("%d", value);
        characteristic.setValue(k.getBytes());
        bluetoothService.writeCharacteristic(characteristic);

        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                stopService(new Intent(MainActivity.this, PayPalService.class));
                bluetoothService.disconnect();
                bluetoothService.close();

                unbindService(serviceConnection);

                try {
                    unregisterReceiver(updateReceiver);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }, 5000);
    }

}
