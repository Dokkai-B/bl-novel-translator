import os
import openai
from dotenv import load_dotenv
from datetime import datetime
from novel_scraper import extract_novel_content
from upload_to_s3 import upload_file_to_s3, list_library_files

# Load environment variables
load_dotenv()

# Initialize OpenAI
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
client = openai.OpenAI(api_key=OPENAI_API_KEY)

def translate_text(text, source_language="Chinese", target_language="English"):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": f"You are a professional translator. Translate this {source_language} text to fluent {target_language}."},
            {"role": "user", "content": text}
        ]
    )
    return response.choices[0].message.content

def read_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read()

def save_text(file_path, content):
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

def split_text(text, max_length=4000):
    paragraphs = text.split("\n")
    chunks, chunk = [], ""
    for para in paragraphs:
        if len(chunk) + len(para) < max_length:
            chunk += para + "\n"
        else:
            chunks.append(chunk)
            chunk = para + "\n"
    if chunk:
        chunks.append(chunk)
    return chunks

def translate_and_upload(text):
    chunks = split_text(text)
    translated = "\n".join([translate_text(c) for c in chunks])
    save_text("translated_novel.txt", translated)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    s3_key = f"library/translated_{timestamp}.txt"
    upload_file_to_s3("translated_novel.txt", s3_key)

def main_menu():
    print("\n📘 Welcome to BL Translator")
    print("1. Translate a new chapter")
    print("2. Access translated library")
    choice = input("Select an option: ")

    if choice == "1":
        print("\nChoose input method:")
        print("1. URL\n2. Text\n3. File")
        method = input("Input type: ")
        if method == "1":
            url = input("Enter chapter URL: ")
            text = extract_novel_content(url)
        elif method == "2":
            print("Paste the text below (Press Ctrl+D or Ctrl+Z to end):")
            lines = []
            try:
                while True:
                    lines.append(input())
            except EOFError:
                pass
            text = "\n".join(lines)
        elif method == "3":
            file_path = input("Enter file path: ")
            text = read_file(file_path)
        else:
            print("❌ Invalid input method.")
            return
        save_text("novel.txt", text)
        print("🔁 Translating and uploading...")
        translate_and_upload(text)
        print("✅ Done.")
    elif choice == "2":
        print("\n📂 Library Contents:")
        for i, key in enumerate(list_library_files(), 1):
            print(f"{i}. {key}")
    else:
        print("❌ Invalid choice.")

if __name__ == "__main__":
    main_menu()
