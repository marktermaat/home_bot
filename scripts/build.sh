set -e
docker build -m=1024m -t marktermaat/home_bot -f docker/Dockerfile .
docker tag marktermaat/home_bot marktermaat/home_bot:0.3
docker push marktermaat/home_bot:0.3
docker push marktermaat/home_bot:latest
