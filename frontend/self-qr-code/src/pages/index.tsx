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
      disclosures: {
        ofac: true
      },
      devMode: true,
    } as Partial<SelfApp>).build();

    return (
      <div style={styles.page}>
        <div style={styles.card}>
          <div style={styles.textCenter}>
            <h1 style={styles.title}>Verify Your Identity</h1>
            <p style={styles.subtitle}>
              Please scan the QR code below using the <strong>Self</strong> app to verify you are not listed on the OFAC Sanctions list.
            </p>
          </div>
  
          <div style={styles.qrContainer}>
            <SelfQRcodeWrapper
              selfApp={selfApp}
              onSuccess={() => {
                console.log("Verification successful!");
              }}
              size={280}
            />
          </div>
  
          <div style={styles.textCenter}>
            <p style={styles.userId}>
              Your User ID: <span style={styles.mono}>{userId.substring(0, 8)}...</span>
            </p>
          </div>
  
          <div style={styles.buttonContainer}>
            <button style={styles.button}>
              I’ve Scanned the Code
            </button>
            <p style={styles.privacyNote}>
              Your information is secure and only used for compliance verification.
            </p>
          </div>
        </div>
      </div>
    );
}

// Inline styles
const styles = {
  page: {
    minHeight: '100vh',
    backgroundColor: '#f9fafb',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '2rem',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: '16px',
    boxShadow: '0 8px 20px rgba(0, 0, 0, 0.08)',
    padding: '2rem',
    width: '100%',
    maxWidth: '400px',
    boxSizing: 'border-box',
  },
  textCenter: {
    textAlign: 'center',
    marginBottom: '1.5rem',
  },
  title: {
    fontSize: '1.75rem',
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: '0.5rem',
  },
  subtitle: {
    fontSize: '1rem',
    color: '#4b5563',
  },
  qrContainer: {
    display: 'flex',
    justifyContent: 'center',
    margin: '2rem 0',
  },
  userId: {
    fontSize: '0.875rem',
    color: '#6b7280',
  },
  mono: {
    fontFamily: 'monospace',
  },
  buttonContainer: {
    marginTop: '2rem',
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#3b82f6',
    color: '#ffffff',
    padding: '0.75rem 1rem',
    borderRadius: '8px',
    border: 'none',
    fontSize: '1rem',
    fontWeight: '600',
    cursor: 'pointer',
    width: '100%',
    marginBottom: '1rem',
    transition: 'background-color 0.3s ease',
  },
  privacyNote: {
    fontSize: '0.75rem',
    color: '#9ca3af',
  },
};