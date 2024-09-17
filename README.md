# machineset-for-openshift-ai
The shell script generateCustomMachineset.sh in this repo allows you to dynamically manage the machine compute resources for OpenShift AI. Use it if you can only deploy a cluster initially which is too small to run OpenShift AI. Or you want to add compute resources (instanceType) with GPUs to your cluster.

This utility has been inspired by the work of my colleague @tnscorcoran's https://github.com/tnscorcoran/dynamic-machineset

## Usage
I use generateCustomMachineset.sh to create a values.yaml and a named template file '_sg_subnet.yaml' using the extracted info from the existing machineset of the cluster and execute a Helm chart to generate the manifest for the machineset to add. Each time the shell script is executed, it will replace the 2 files mentioned. Notice that scipt requires you to provide the AWS instanceType, in my case, m5.12xlarge. You could have chosen one with GPUs instead.

All that you need to do is to login to OpenShift using an account with cluster-admin privileges from the command line. From the script folder, issue the command:
<pre>
./generateCustomMachineset.sh m5.12xlarge | oc apply f -
</pre>
Replace m5.12xlarge with any valid AWS instanceType that you desire.
