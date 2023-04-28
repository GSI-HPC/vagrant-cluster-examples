#!/bin/sh

PLAYBOOK="playbook_mxs.yml"

echo "Build ansible playbook: ${PLAYBOOK}"

echo "# ${PLAYBOOK}" > ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/lnet.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/load_modules.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}

cat ansible/server/mxs/mount.yml >> ${PLAYBOOK}
echo "\n" >> ${PLAYBOOK}
