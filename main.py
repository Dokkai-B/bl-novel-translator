import openai
import os
from dotenv import load_dotenv
from novel_scraper import extract_novel_content
from upload_to_s3 import upload_file_to_s3
from datetime import datetime

# Load environment variables from .env file
load_dotenv()

# Get API Key securely
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Ensure API Key exists
if not OPENAI_API_KEY:
    raise ValueError("Missing OpenAI API key. Add it to .env file.")

client = openai.OpenAI(api_key=OPENAI_API_KEY)  # Updated to new API client

def translate_text(text, source_language="Chinese", target_language="English"):
    """
    Function to translate text from source_language to target_language using OpenAI GPT.
    """
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",  # Change the model here
            messages=[
                {"role": "system", "content": f"You are a professional translator. Translate the following {source_language} text to fluent {target_language}."},
                {"role": "user", "content": text}
            ]
        )
        return response.choices[0].message.content  # Updated response format

    except Exception as e:
        return f"Error: {e}"

def read_novel_from_file(file_path):
    """ Reads a text file and returns the content. """
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()

def split_text(text, max_length=4000):
    """ Splits the text into smaller chunks to avoid exceeding token limits. """
    paragraphs = text.split("\n")
    chunks = []
    current_chunk = ""

    for paragraph in paragraphs:
        if len(current_chunk) + len(paragraph) < max_length:
            current_chunk += paragraph + "\n"
        else:
            chunks.append(current_chunk)
            current_chunk = paragraph + "\n"

    if current_chunk:
        chunks.append(current_chunk)

    return chunks

if __name__ == "__main__":
    url = input("Enter the novel chapter URL: ")
    novel_text = extract_novel_content(url)

    # Save the extracted text to a file
    with open("novel.txt", "w", encoding="utf-8") as file:
        file.write(novel_text)

    print("\nExtracted text has been saved to 'novel.txt'")

    # Read the extracted novel
    text_to_translate = read_novel_from_file("novel.txt")

    # Split text into chunks for translation
    text_chunks = split_text(text_to_translate)

    translated_chunks = []
    print("\nTranslating text...")

    for index, chunk in enumerate(text_chunks):
        print(f"Translating chunk {index + 1} of {len(text_chunks)}...")
        translated_text = translate_text(chunk, "Chinese", "English")
        translated_chunks.append(translated_text)

    # Combine all translated chunks
    full_translation = "\n".join(translated_chunks)

    # Save translated text
    translated_path = "translated_novel.txt"
    with open(translated_path, "w", encoding="utf-8") as file:
        file.write(full_translation)

    print(f"\nTranslation completed! Saved to '{translated_path}'")

    # Generate timestamped filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    s3_key = f"library/translated_{timestamp}.txt"

    # Upload to S3
    upload_file_to_s3(translated_path, s3_key)

    print(f"\nUploaded to S3 as '{s3_key}'")