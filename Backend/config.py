import os
from dotenv import load_dotenv
load_dotenv()

class Config:
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:1881@localhost/NVS"
    SQLALCHEMY_TRACK_MODIFICATIONS = False