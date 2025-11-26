import os

class Settings:
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db")
    SECRET_KEY: str = os.getenv("SECRET_KEY", "supersecretkey")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

settings = Settings()
