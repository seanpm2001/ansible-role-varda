#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

ansible-playbook -i inventory.yml playbook.yml --syntax-check

ansible-playbook -i inventory.yml playbook.yml --connection=local

ansible-playbook -i inventory.yml playbook.yml --connection=local \
  | grep -q 'changed=0.*failed=0' \
  && (echo 'Idempotence test: pass' && exit 0) \
  || (echo 'Idempotence test: fail' && exit 1)

curl -s -k https://localhost/api/ \
  | grep -q '"status".*:.*"ok"' \
  && (echo 'Varda API test: pass' && exit 0) \
  || (echo 'Varda API test: fail' && exit 1)
