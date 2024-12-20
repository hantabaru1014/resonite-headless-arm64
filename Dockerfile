# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build-patcher
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["EnginePrePatcher/EnginePrePatcher.csproj", "EnginePrePatcher/"]
RUN dotnet restore "./EnginePrePatcher/EnginePrePatcher.csproj"
COPY ./EnginePrePatcher ./EnginePrePatcher
WORKDIR "/src/EnginePrePatcher"
RUN dotnet publish "./EnginePrePatcher.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/runtime:9.0
ARG TARGETARCH
RUN apt-get update && apt-get install -y --no-install-recommends libassimp5 libfreeimage3 libfreetype6 libopus0 libbrotli1 zlib1g && rm -rf /var/lib/apt/lists/*
USER app
WORKDIR /app
COPY --chown=app:app ./copy-native-libs.sh ./
RUN bash ./copy-native-libs.sh
COPY --from=build-patcher --chown=app:app /app/publish ./bin/prepatch
COPY --chown=app:app ./Resonite/Headless/*.xml ./Resonite/Headless/*.config ./Resonite/Headless/*.json ./Resonite/Headless/*.dll ./Resonite/Headless/RuntimeData/** ./
RUN dotnet ./bin/prepatch/EnginePrePatcher.dll ./
CMD ["dotnet", "Resonite.dll"]