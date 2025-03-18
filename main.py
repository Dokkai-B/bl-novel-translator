import openai
import os
from dotenv import load_dotenv

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

if __name__ == "__main__":
    file_path = "novel.txt"  # Change this if needed
    text_to_translate = read_novel_from_file(file_path)
    translated_text = translate_text(text_to_translate, "Chinese")
    print("\n🔹 Original Text:", text_to_translate[:500])  # Print first 500 characters for preview
    print("✅ Translated Text:", translated_text)
