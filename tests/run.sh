#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

logfile="$(mktemp)"

ansible-playbook -i inventory playbook.yml --syntax-check

ansible-playbook -i inventory playbook.yml --connection=local

ansible-playbook -i inventory playbook.yml --connection=local \
  | tee $logfile \
  | grep 'changed=0.*failed=0' > /dev/null \
  && (echo 'Idempotence test: pass' && exit 0) \
  || (cat $logfile && echo 'Idempotence test: fail' && exit 1)

curl -s -k https://localhost/api/ \
  | tee $logfile \
  | grep '"status".*:.*"ok"' > /dev/null \
  && (echo 'Varda API test: pass' && exit 0) \
  || (cat $logfile && echo 'Varda API test: fail' && exit 1)
