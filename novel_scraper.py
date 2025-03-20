import requests
from bs4 import BeautifulSoup
import chardet

def detect_encoding(content):
    """
    Detects the encoding of the webpage content.
    """
    result = chardet.detect(content)
    return result['encoding']

def extract_novel_content(url):
    """
    Dynamically extracts novel text from the given URL.
    """
    try:
        # Fetch the webpage content
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(url, headers=headers)

        if response.status_code != 200:
            return f"Error: Unable to fetch the page (Status Code: {response.status_code})"

        # Detect encoding and decode correctly
        encoding = detect_encoding(response.content)
        html = response.content.decode(encoding, errors="ignore")  # Handle decoding errors

        # Parse the HTML content
        soup = BeautifulSoup(html, "html.parser")

        # Extract title (assuming <h1> or <title> contains the chapter title)
        title = soup.find("h1") or soup.find("title")
        chapter_title = title.text.strip() if title else "Unknown Title"

        # Dynamically find the largest block of text (most likely the novel content)
        all_divs = soup.find_all("div")  # Get all <div> elements
        max_text_div = max(all_divs, key=lambda div: len(div.text.strip()), default=None)

        if not max_text_div or len(max_text_div.text.strip()) < 100:
            return "Error: Could not find chapter content."

        # Extract text and clean it
        chapter_text = "\n".join([p.text.strip() for p in max_text_div.find_all("p")]) if max_text_div.find_all("p") else max_text_div.text.strip()

        return f"📖 {chapter_title}\n\n{chapter_text}"

    except Exception as e:
        return f"Error: {e}"
