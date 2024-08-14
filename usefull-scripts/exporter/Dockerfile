FROM python:3.11-alpine
# This prevents Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1
# This keeps Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY main.py /app/main.py

EXPOSE 8000

ENTRYPOINT ["python3", "main.py"]
