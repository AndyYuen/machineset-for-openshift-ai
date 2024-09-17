#! /bin/bash

if [ $#  -ne 1  ]; then
	echo "Usage: $0 instanceType"
	exit 1
fi

oc  get clusterrolebindings  | grep "cluster-admin" > /dev/null 2>&1
if [ $? == 1 ] ; then
  echo "*****************************************************"
  echo "Please login to OpenShift using an account with cluster-admin privileges and rerun command."
  echo "*****************************************************"
  exit 2;
fi


# m5.12xlarge works
INSTANCE_TYPE=$1

FILE=/tmp/worker-machineset-$(uuidgen | cut -d "-" -f5).yaml
VALUES_FILE=./helm-machineset/values.yaml
NAMED_TEMPLATE=./helm-machineset/templates/_sg_subnet.yaml

# save current machineset yaml
CURRENT_MACHINESET_NAME=`oc get machineset -n openshift-machine-api | tail -n -1 | cut -f1 -d ' '`
oc get machineset ${CURRENT_MACHINESET_NAME} -n openshift-machine-api -o yaml > ${FILE}

INFRA_ID=`cat ${FILE} | grep machine.openshift.io/cluster-api-cluster | head -n 1 | tr -d "[:space:]" | cut -f2 -d ':'`
AMI=`cat ${FILE} | grep -A 1 ami: | tail -n 1 | tr -d "[:space:]" | cut -f2 -d ':'`
REGION=`cat ${FILE} | grep region | tr -d "[:space:]" | cut -f2 -d ':'`
AVAIL_ZONE=`cat ${FILE} | grep availabilityZone | tr -d "[:space:]" | cut -f2 -d ':'`

# create valuse.yaml for Helm
cat << EOF > ${VALUES_FILE}
infrastructureId: ${INFRA_ID}

ami: ${AMI}

region: ${REGION}

availabilityZone: ${AVAIL_ZONE}

instanceType: ${INSTANCE_TYPE}
EOF

# generate securityGroups and subnet named template
SG_SUBNET=`sed -n '/securityGroups:/,/tags:/p' ${FILE} | head -n -1 | cut -c 11- `
cat << EOF > ${NAMED_TEMPLATE}
{{ define "sgSubnet" }}
${SG_SUBNET}
{{ end }}
EOF

rm ${FILE}

# render helm chart
helm template ./helm-machineset --values ./helm-machineset/values.yaml