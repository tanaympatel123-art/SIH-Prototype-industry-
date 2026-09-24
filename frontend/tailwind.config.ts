import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./component/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#0A2540", // Primary Navy Blue
          hover: "#0D2E4E",
          light: "#EAF2F8",
        },
        background: {
          DEFAULT: "#F6F9FC", // Background Gray
        },
        success: {
          DEFAULT: "#24B47E", // Success Green
          light: "#EBF9F3",
        },
        warning: {
          DEFAULT: "#E01A2B", // Warning Red
          light: "#FDF2F2",
        },
        accent: {
          DEFAULT: "#635BFF", // Indigo Accent
          light: "#F0F0FF",
        }
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
      },
    },
  },
  plugins: [],
};

export default config;