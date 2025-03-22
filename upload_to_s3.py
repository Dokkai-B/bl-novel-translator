import os
import boto3
from dotenv import load_dotenv
from datetime import datetime

# Load AWS credentials from .env
load_dotenv()

AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
AWS_BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")  # replace with the bucket name

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

if __name__ == "__main__":
    file_to_upload = "translated_novel.txt"  # file to upload
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    s3_object_name = f"library/translated_{timestamp}.txt"
    upload_file_to_s3(file_to_upload, s3_object_name)
