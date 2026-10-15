# Linux PDF

> **Description**: Linux PDF: A powerful, full-featured PDF suite for Linux and Windows built with Electron, React, and TypeScript. View, edit, annotate, sign, merge, watermark, and organize pages. Features an offline 300 DPI neural OCR engine with Bradley-Roth adaptive thresholding that embeds invisible selectable text to make scans fully searchable.

---

## 🌟 Key Features

- **Document Viewing**: High-fidelity PDF rendering with hardware acceleration via PDF.js, page thumbnail navigation, bookmarks/outline tree, and full-text document search.
- **Annotation & Markup**: Freehand pen tool, highlighter with blend mode, shapes (rectangles, circles, arrows), and scalable text insertion.
- **Fill & Sign**: Built-in signature canvas with multiple ink colors, official approval stamps (APPROVED, REJECTED, CONFIDENTIAL, DRAFT, FINAL, PAID, etc.).
- **Acrobat-Grade Neural OCR**:
  - Supersampled at **300 DPI** to resolve fine typefaces.
  - Preprocessing pipeline: $Y = (77R + 150G + 29B) \gg 8$ integer luminance grayscale, $3\times 3$ median filter for salt-and-pepper noise removal, and percentile contrast stretching.
  - **Bradley-Roth Adaptive Thresholding** using 2D Integral Images ($O(1)$ query) to handle shadows, gradients, and folds.
  - **Searchable PDF Generation**: Embeds recognized text into the PDF with `opacity: 0` using standard fonts, enabling native cursor selection, text copy, and `Ctrl+F` global search.
  - Batch multi-page recognition and multi-language support (English, Spanish, French, German, Chinese, Japanese, etc.).
- **Page Organization**: Visually drag, reorder, rotate (90° increments), and delete pages.
- **Combine & Merge**: Assemble multiple PDF files into a single publication.
- **Watermarks & Security**: Customizable text watermarks with opacity and diagonal angle controls.
- **Export**: Render and export pages to high-resolution PNG or JPEG (single page or bulk ZIP archive).

---

## 🚀 Running on Linux

### 1. Universal Web Mode (Fastest — Zero Setup)
Runs anywhere without display servers or window managers (compatible with headless servers, WSL, and Docker):

```bash
npm run linux:serve
# or directly:
node electron/main.cjs --web --port 8080
```
This spawns a zero-dependency local server with COOP/COEP headers for multithreaded WASM workers and opens your browser.

### 2. Native Electron Desktop App
```bash
npm start
```
- **Wayland / HiDPI**: Auto-detects Wayland (`--ozone-platform-hint=auto`) and native window decorations.
- **Ubuntu 24.04+ Sandboxing**: Includes automatic fallbacks for unprivileged user namespace restrictions.

### 3. Multi-Distro Automated Installer
We provide an all-in-one installation script for Debian/Ubuntu, Fedora/RHEL, Arch Linux, and openSUSE:

```bash
# System-wide installation (requires sudo):
sudo ./install-linux.sh

# User-level installation (no sudo required):
./install-linux.sh --user
```
The installer installs native dependencies, registers the `linux-pdf` command, integrates the application into your desktop menu under **Office**, and configures PDF MIME associations so double-clicking any `.pdf` opens Linux PDF.

---

## 🪟 Running on Windows

- **Portable Executable**: Run `Linux PDF Portable.exe` (no installation required).
- **Installer**: Run `Linux PDF Installer.exe` for a standard desktop setup with start menu shortcuts.

---

## 📦 Building & Packaging

```bash
# Install dependencies
npm install

# Build web distribution bundle
npm run build

# Package for Linux
npm run pack:appimage    # Standalone AppImage
npm run pack:deb         # Debian/Ubuntu package
npm run pack:tar         # Portable tar.gz
npm run build:linux:all  # All Linux targets

# Package for Windows
npm run build:portable   # Portable single EXE
npm run build:installer  # NSIS installer EXE
```

---

## 🛠️ Technology Stack

- **Framework**: Electron 33, Node.js
- **Frontend**: React 18, TypeScript, Tailwind CSS, Lucide Icons
- **PDF Core**: PDF.js (rendering & text extraction), pdf-lib (binary PDF modification & text layer embedding)
- **OCR Engine**: Tesseract.js (neural LSTM engine) with custom TypedArray preprocessing pipeline
- **Bundler**: Vite 5, Electron-Builder

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
