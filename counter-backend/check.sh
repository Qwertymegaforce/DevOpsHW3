for v in single multistage nonroot; do
  echo "=== $v ==="
  docker build -f Dockerfile.$v -t counter:$v . || exit 1
  docker run -d --name c-$v -p 8080:8080 counter:$v
  sleep 3
  echo "GET"
  curl -s -w ' [%{http_code}]\n' localhost:8080/api/counter
  echo "POST"
  curl -s -w ' [%{http_code}]\n' -X POST localhost:8080/api/counter
  echo "GET"
  curl -s -w ' [%{http_code}]\n' localhost:8080/api/counter
  echo "id"
  docker exec c-$v id
  docker rm -f c-$v
done
docker images counter --format 'table {{.Tag}}\t{{.Size}}'
