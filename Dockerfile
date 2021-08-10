FROM python:3.6

ADD . /app
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

EXPOSE 8000

CMD [ "python", "./hello_world.py" ]
