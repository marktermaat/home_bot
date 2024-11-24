docker build --target=node_builder -t node_builder_stage -f docker/Dockerfile .
docker create --name static_extractor node_builder_stage
docker cp static_extractor:/priv/static priv/
docker rm static_extractor