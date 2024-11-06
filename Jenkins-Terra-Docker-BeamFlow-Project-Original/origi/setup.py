from setuptools import setup, find_packages

setup(
    name='your-package-name',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'apache-beam==2.50.0',
        'protobuf==4.23.4',
        # additional packages
    ],
)