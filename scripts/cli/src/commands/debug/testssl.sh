arguments="${args[arguments]}"

log "🔐 Testing TLS/SSL encryption with arguments $arguments"
docker run --quiet --rm -ti  drwetter/testssl.sh $arguments