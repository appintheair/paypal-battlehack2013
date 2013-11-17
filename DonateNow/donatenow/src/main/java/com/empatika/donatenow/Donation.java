package com.empatika.donatenow;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by Quiker on 11/17/13.
 */
public class Donation {
    private String donationId;
    private String confirmation;

    public String getConfirmation() {
        return confirmation;
    }

    public void setConfirmation(String confirmation) {
        this.confirmation = confirmation;
    }

    public int getAmountRaised() {
        return amountRaised;
    }

    public void setAmountRaised(int amountRaised) {
        this.amountRaised = amountRaised;
    }

    public String getDonationId() {
        return donationId;
    }

    public void setDonationId(String donationId) {
        this.donationId = donationId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getVoters() {
        return voters;
    }

    public void setVoters(int voters) {
        this.voters = voters;
    }

    public ArrayList<String> getPhotoUrls() {
        return photoUrls;
    }

    public void setPhotoUrls(ArrayList<String> photoUrls) {
        this.photoUrls = photoUrls;
    }

    private int amountRaised;
    private String title;
    private int voters;
    private ArrayList<String> photoUrls;

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
