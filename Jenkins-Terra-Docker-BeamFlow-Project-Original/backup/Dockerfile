# Use Python 3.8 as the base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /workspace

# Install required system packages
RUN apt-get update -y && \
   apt-get install -y \
       wget \
       unzip \
       gcc \
       python3-dev \
       nano \
       libpng16-16 \
       libfreetype6 \
       libfontconfig1 \
       libde265-0 \
       libnuma1 \
       libx265-199 \
       build-essential \
       curl \
       gnupg \
       lsb-release \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip && \
   unzip terraform_1.0.5_linux_amd64.zip -d /usr/local/bin/ && \
   rm terraform_1.0.5_linux_amd64.zip

# Install Google Cloud SDK 
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
   curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
   apt-get update -y && \
   apt-get install -y google-cloud-cli && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*

# Add Google Cloud SDK to the PATH
ENV PATH $PATH:/workspace/google-cloud-sdk/bin

# Copy requirements files first to leverage Docker cache
COPY requirements.txt /workspace/
COPY setup.py /workspace/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
   pip install --no-cache-dir -e .

# Copy the rest of the application
COPY . /workspace/

# Set environment variable for Google Cloud auth
ARG GOOGLE_APPLICATION_CREDENTIALS
ENV GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-"/workspace/stately-gist-435602-u9-e7d9d76c1b6d.json"}

# Command to run when the container starts
CMD ["sh", "-c", "terraform init && terraform apply -auto-approve && python main_pipeline.py"]