FROM ubuntu:18.04

RUN mkdir -p /usr/app
WORKDIR /usr/app


# install aws cli
RUN apt-get update && apt-get install curl unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# prepare gei env
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN apt-get install libbsd0 libcurl3-gnutls -y

# Set up application runtime env
COPY dist/linux-x64/gei /usr/bin/


