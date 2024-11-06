# Use Python 3.8 as the base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /workspace

# ตั้งค่า environment variable สำหรับการรับรองความถูกต้องของ Google Cloud
ENV GOOGLE_APPLICATION_CREDENTIALS="/workspace/focused-evening-397008-aa8085446fa3.json"


# Install Terraform, Google Cloud SDK, and Nano editor
RUN apt-get update -y && \
    apt-get install -y wget unzip gcc python3-dev nano && \
    wget https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip && \
    unzip terraform_1.0.5_linux_amd64.zip -d /usr/local/bin/ && \
    rm terraform_1.0.5_linux_amd64.zip && \
    wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    tar zxvf google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh -q && \
    rm google-cloud-sdk.tar.gz && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add Google Cloud SDK to the PATH
ENV PATH $PATH:/workspace/google-cloud-sdk/bin

# Copy the entire project to /workspace
COPY . /workspace/

# Install dependencies
RUN pip install --no-cache-dir -e . 
RUN pip install --no-cache-dir 'apache-beam[gcp]'==2.50.0 protobuf==4.23.4

# Set the command to be executed when the container is run
CMD ["python", "main_pipeline.py"]
