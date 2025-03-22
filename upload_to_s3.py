import os
import boto3
from dotenv import load_dotenv
from datetime import datetime

# Load AWS credentials from .env
load_dotenv()

AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
AWS_BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")

# Initialize S3 client
s3_client = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=AWS_REGION
)

def upload_file_to_s3(local_file_path, s3_key):
    try:
        s3_client.upload_file(local_file_path, AWS_BUCKET_NAME, s3_key)
        print(f"Uploaded '{local_file_path}' to S3 as '{s3_key}'")
    except Exception as e:
        print(f"Upload failed: {e}")

def list_library_files(prefix="library/"):
    try:
        response = s3_client.list_objects_v2(Bucket=AWS_BUCKET_NAME, Prefix=prefix)
        return [obj["Key"] for obj in response.get("Contents", []) if obj["Key"] != prefix]
    except Exception as e:
        print(f"Error listing files: {e}")
        return []
    
def download_file_from_s3(s3_key, local_path):
    try:
        s3_client.download_file(AWS_BUCKET_NAME, s3_key, local_path)
        print(f"\n📥 Downloaded '{s3_key}' to '{local_path}'\n")
    except Exception as e:
        print(f"Download failed: {e}")

# Optional standalone test
if __name__ == "__main__":
    print("📂 Library files:")
    for key in list_library_files():
        print(" -", key)
