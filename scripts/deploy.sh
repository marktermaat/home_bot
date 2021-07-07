ssh mark@home << EOF
  cd /docker/home_bot
  docker-compose pull
  docker-compose down
  docker-compose up -d
EOF