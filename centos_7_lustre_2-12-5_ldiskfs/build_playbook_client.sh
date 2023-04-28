#!/bin/sh

PLAYBOOK="playbook_client.yml"

echo "Build ansible playbook: ${PLAYBOOK}"

echo "# ${PLAYBOOK}" > ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/lnet.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/load_modules.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/client/mount.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}
