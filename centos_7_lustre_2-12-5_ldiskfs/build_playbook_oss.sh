#!/bin/sh

PLAYBOOK="playbook_oss.yml"

echo "Build ansible playbook: ${PLAYBOOK}"

echo "# ${PLAYBOOK}" > ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/lnet.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/load_modules.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/server/oss/mount.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}
