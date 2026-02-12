docker pull mcr.microsoft.com/dotnet/samples:aspnetapp

docker image ls

docker run -d -p 8080:8080 mcr.microsoft.com/dotnet/samples:aspnetapp

docker ps

docker container stop 8d8add5ac8a5


docker ps -a


docker image ls

docker image rm mcr.microsoft.com/dotnet/samples:aspnetapp

docker image ls