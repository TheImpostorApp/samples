#!/bin/sh
# Generate a throwaway CA + server + client certs for the mock mTLS endpoint.
# Run by the `certinit` compose service (alpine/openssl); POSIX/busybox-safe.
# Client password: "impostor".
#
# The canonical server set (ca.pem, server.pem, server.key) is COMMITTED to git, so
# normally this is a no-op: certinit reuses the committed certs and the example
# bundle (examples/mock-workspace/.assets/certs/) keeps matching them. Only re-roll
# deliberately — and then re-commit and re-sync the bundle (see below).
#
# Re-roll the whole demo CA:  sh gen-certs.sh --force
set -e
cd "$(dirname "$0")"

if [ -f ca.pem ] && [ "$1" != "--force" ]; then
  echo "certs already present — using committed certs (pass --force to re-roll)"
  exit 0
fi

# Re-rolling: clear the old set so nothing stale is reused.
rm -f ca.* server.* client.* *.csr *.srl san.cnf

PASS=impostor

echo "→ CA"
openssl req -x509 -newkey rsa:2048 -nodes -keyout ca.key -out ca.pem \
  -days 3650 -subj "/CN=Impostor Mock CA"

echo "→ server cert (SAN localhost,127.0.0.1)"
printf "subjectAltName=DNS:localhost,IP:127.0.0.1\n" > san.cnf
openssl req -newkey rsa:2048 -nodes -keyout server.key -out server.csr \
  -subj "/CN=localhost"
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
  -out server.pem -days 3650 -extfile san.cnf

echo "→ client cert"
openssl req -newkey rsa:2048 -nodes -keyout client.key -out client.csr \
  -subj "/CN=impostor-client"
openssl x509 -req -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
  -out client.pem -days 3650

echo "→ client.p12 (password: $PASS)"
openssl pkcs12 -export -inkey client.key -in client.pem -certfile ca.pem \
  -out client.p12 -passout "pass:$PASS"

rm -f *.csr san.cnf ca.srl
echo "✓ certs written to $(pwd)"
echo "  Re-rolled? Re-commit ca.pem/server.pem/server.key and copy the new"
echo "  ca.pem + client.p12 into examples/mock-workspace/.assets/certs/ so the"
echo "  example bundle keeps matching this CA."
