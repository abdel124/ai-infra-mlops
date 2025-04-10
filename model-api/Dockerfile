FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app/ app/

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app.main:app"]