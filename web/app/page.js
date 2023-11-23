
import  Navbar  from "./components/Navbar";
import  HeroSection  from "./components/HeroSection";
import  PromotionSection  from "./components/PromotionSection";
import  ScreenshotSection  from "./components/ScreenshotSection";
import  Footer  from "./components/Footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <div className="overflow-y-auto overflow-x-hidden md:mt-auto mt-20">
        <HeroSection />
        <ScreenshotSection />
        <PromotionSection />
        <span className="text-center text-gray-500 text-xs">
          <Footer />
        </span>
      </div>
    </>
  );
}
