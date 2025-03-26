# Novel Translator

A personal full-stack application that allows users to translate, store, and access BL novel chapters through a clean and intuitive interface.

---

## Features

### Translation
- Accepts raw text input
- Simulated translation (ready for GPT-4o integration)
- Displays translated output in a stylized container

### S3 Cloud Library
- Uploads translated chapters to AWS S3
- Lists available files
- Fetches and displays selected chapter content

### Frontend (Flutter)
- Clean, minimalist UI inspired by Discord
- Morphing central card with animated view switching
- Three core views: Translate, Library, Settings
- Fully responsive layout (Web/Desktop/Android-ready)

### Backend (Python + Flask)
- BeautifulSoup-based chapter scraper
- GPT translation logic (via OpenAI API)
- AWS S3 uploader and file fetcher via `boto3`
- REST API for listing and retrieving chapters

---

## Tech Stack

| Layer      | Tech                         |
|------------|------------------------------|
| Frontend   | Flutter (Dart)               |
| Backend    | Python + Flask               |
| Cloud      | AWS S3 + Boto3               |
| AI/LLM     | OpenAI GPT-4o (via API)      |
| Extras     | Flask-CORS, dotenv, requests |

---

## Folder Structure

```plaintext
BL-Translator/
├── bl-novel-translator/             # Python backend
│   ├── api_server.py
│   ├── upload_to_s3.py
│   ├── requirements.txt
│   └── ...
├── bl_novel_translator_frontend/   # Flutter frontend
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
```

---

## Getting Started

### Backend Setup

1. Install Python 3.11+
2. Create a virtual environment:
```python -m venv venv .\venv\Scripts\activate```
3. Install dependencies:
```pip install -r requirements.txt```
4. Create a '.env' file with AWS credentials:
```AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_REGION=ap-southeast-1```
```AWS_BUCKET_NAME=bl-novel-library-adii```
5. Run the Flask server:
```python api_server.py```

### Frontend Setup (Flutter)

1. [Install Flutter](https://docs.flutter.dev/get-started)
2. Navigate to the frontend directory:
```cd bl_novel_translator_frontend```
3. Get dependencies:
```flutter pub get```
4. Run the app:
```flutter run -d chrome```

## Author

**Dokkai-B**  
[github.com/Dokkai-B](https://github.com/Dokkai-B)

---

## Status

This project is fully functional locally and ready for:
- GPT-4o integration
- Auth features
- Hosting/deployment

PRs and forks welcome.