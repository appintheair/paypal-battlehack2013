package com.empatika.donatenow;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by Quiker on 11/17/13.
 */
public class Donation {
    String donationId;
    int amountRaised;
    String title;
    int voters;
    ArrayList<String> photoUrls;

    public Donation(JSONObject obj) {
        ArrayList<String> urls = new ArrayList<String>();
        try {
            this.donationId = obj.getString("donation_id");
            this.amountRaised = obj.getInt("amountRaised");
            this.title = obj.getString("title");
            this.voters = obj.getInt("numberOfVoters");
            urls.add(obj.getString("photo1_url"));
            urls.add(obj.getString("photo2_url"));
            urls.add(obj.getString("photo3_url"));
            this.photoUrls = urls;
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
