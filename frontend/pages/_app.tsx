import type { AppProps } from "next/app";
import { AuthProvider } from "../hooks/useAuth";
import "../style/globals.css";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <AuthProvider>
      <Component {...pageProps} />
    </AuthProvider>
  );
}
