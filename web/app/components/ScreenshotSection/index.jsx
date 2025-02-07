"use client";
import React from "react";
import Slider from "../Slider";

const ScreenshotSection = () => {
  const imageList = [
    { url: "/product_img_4.jpg" },
    { url: "/product_img_1.jpg" },
    { url: "/product_img_3.jpg" },
    { url: "/product_img_5.jpg" },
    { url: "/product_img_6.jpg" },
    { url: "/product_img_7.jpg" },
  ];

  return (
    <div className="md:relative w-screen flex flex-col h-[900px] justify-center bg-slate-100 my-16 md:bg-[url('/comingsoon-img.jpg')] bg-cover bg-center">
      <div className=" md:bg-white/30  md:backdrop-blur-lg h-full transition-all ease-in">
        <h2 className="font-bold text-2xl md:text-4xl mb-4 md:mt-10 md:text-white text-black p-5">
          Screenshots
        </h2>
        <p className="mb-4 text-base md:text-2xl md:text-white text-black p-5">
          Browse through major features of the App.
        </p>
        <Slider
          imageList={imageList}
          width={300}
          height={500}
          loop={true}
          autoPlay={true}
          autoPlayInterval={3000}
          showArrowControls={true}
          showDotControls={true}
          bgColor="bg-none"
        />
      </div>
    </div>
  );
};

export default ScreenshotSection;
