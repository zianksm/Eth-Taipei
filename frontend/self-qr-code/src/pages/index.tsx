import Image from "next/image";
import { Geist, Geist_Mono } from "next/font/google";
import { useEffect, useState } from "react";
import SelfQRcodeWrapper, { SelfAppBuilder, SelfApp } from '@selfxyz/qrcode';
import { v4 as uuidv4 } from 'uuid';

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export default function Home() {
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    // Generate a user ID when the component mounts
    setUserId(uuidv4());
  }, []);

  if (!userId) return null;

  // User address??
  const address = "0x0a2Bb7472060C902fcBde763B9b194Db9742Fe0A";

  // Create the SelfApp configuration
  const selfApp = new SelfAppBuilder({
      appName: "Sanction Screening",
      scope: "Sanction-Screening",
      endpoint: "https://6455-111-235-226-130.ngrok-free.app/api/verify",
      // logoBase64: logo,
      userId: address,
      userIdType: "hex",
      devMode: true,
    } as Partial<SelfApp>).build();

    const handleSuccess = async () => {
        console.log('Verification successful');
    };


  return (
    <div className="verification-container">
      <h1>Verify Your Identity</h1>
      <p>Scan this QR code with the Self app to verify your identity</p>
      
      <SelfQRcodeWrapper
        selfApp={selfApp}
        onSuccess={() => {
          // Handle successful verification
          console.log("Verification successful!");
          // Redirect or update UI
        }}
        size={350}
      />
      
      <p className="text-sm text-gray-500">
        User ID: {userId.substring(0, 8)}...
      </p>
    </div>
  );
}
