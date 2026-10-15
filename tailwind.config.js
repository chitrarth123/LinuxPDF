/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        adobe: {
          red: '#EA1D2C',
          redHover: '#D31422',
          redDark: '#A30F19',
          dark: '#1E1E1E',
          panel: '#252526',
          topbar: '#2B2B2B',
          toolbar: '#333333',
          border: '#3E3E42',
          lightBg: '#F3F4F6',
          lightToolbar: '#FFFFFF',
          lightBorder: '#E5E7EB',
          accent: '#0078D4',
          accentHover: '#106EBE'
        }
      },
      fontFamily: {
        sans: ['"Segoe UI"', '-apple-system', 'BlinkMacSystemFont', 'Roboto', '"Helvetica Neue"', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
