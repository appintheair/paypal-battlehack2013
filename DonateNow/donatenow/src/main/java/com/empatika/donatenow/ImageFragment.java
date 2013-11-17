package com.empatika.donatenow;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.nostra13.universalimageloader.core.ImageLoader;

/**
 * Created by Quiker on 11/17/13.
 */
public class ImageFragment extends Fragment{
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.item_image, container, false);

        String imageUrl = getArguments().getString("com.empatika.donatenow.imageurl");

        ImageView imageView = (ImageView)rootView.findViewById(R.id.imageViewPicture);

        ImageLoader.getInstance().displayImage(imageUrl, imageView);

        return rootView;
    }
}
