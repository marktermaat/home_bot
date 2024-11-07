ssh mark@192.168.2.8 << EOF
  cd /docker/home_bot
  docker-compose pull
  docker-compose down
  docker-compose up -d
EOF
