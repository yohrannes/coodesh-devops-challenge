FROM balenalib/aarch64-alpine
WORKDIR /root
ADD . .

# Installing python and flask

ENV PYTHONUNBUFFERED=1
RUN apk add --update python3 py3-pip
RUN ln -sf python3 /usr/bin/python
RUN apk add py3-flask py3-requests
RUN set FLASK_ENV=development
EXPOSE 5000

# Upgrading pip for security | See more in https://avd.aquasec.com/nvd/cve-2023-5752
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

# Upgrading setup tools for security | See more in https://avd.aquasec.com/nvd/cve-2022-40897
RUN pip3 install --upgrade setuptools

# Upgrading system
RUN apk update
RUN apk upgrade

# Running aplication
