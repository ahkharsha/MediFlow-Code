import React from "react";
import Head from "next/head";
import toast, { Toaster } from "react-hot-toast";
import { StateContextProvider } from "../Context/index";
import { AnonAadhaarProvider } from "@anon-aadhaar/react";
import { Web3Provider } from "../utils/providers/Web3Provider";
import "../styles/globals.css";

const useTestAadhaar = true; // Change to false for production

export default function App({ Component, pageProps }) {
  return (
    <>
      <Web3Provider>
        <AnonAadhaarProvider _useTestAadhaar={useTestAadhaar}>
          <StateContextProvider>
            <Component {...pageProps} />
            <Toaster />
          </StateContextProvider>
        </AnonAadhaarProvider>
      </Web3Provider>

      {/* Include necessary scripts */}
      <script src="vendor/global/global.min.js"></script>
      <script src="vendor/bootstrap-select/dist/js/bootstrap-select.min.js"></script>
      <script src="vendor/chart.js/chart.bundle.min.js"></script>
      <script src="vendor/owl-carousel/owl.carousel.js"></script>
      <script src="vendor/apexchart/apexchart.js"></script>
      <script src="js/custom.min.js"></script>
      <script src="js/deznav-init.js"></script>
      <script src="js/demo.js"></script>
      <script src="js/styleSwitcher.js"></script>
    </>
  );
}
