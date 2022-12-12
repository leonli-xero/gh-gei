FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG ASSEMBLY_VERSION=0.1
WORKDIR /app

COPY ./src/*.sln  ./

# Copy the main source project files
COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && mv $file ${file%.*}/; done

RUN dotnet restore

COPY src .
RUN dotnet publish gei/gei.csproj -c Release -r linux-x64 -p:PublishSingleFile=true -p:PublishTrimmed=true --self-contained true /p:DebugType=None /p:IncludeNativeLibrariesForSelfExtract=true /p:VersionPrefix=$ASSEMBLY_VERSION -o out

FROM ubuntu:22.04 as runtime

RUN mkdir -p /usr/app
WORKDIR /usr/app

# install aws cli
RUN apt-get update && apt-get install curl unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# prepare gei env
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN apt-get install libbsd0 libcurl3-gnutls -y

# Set up application runtime env
COPY --from=build /app/out /usr/bin/
