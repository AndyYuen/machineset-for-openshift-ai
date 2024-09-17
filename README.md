# machineset-for-openshift-ai
The shell script in this repo allows you to dynamically manage the machine compute resources for OpenShift AI. It is required if you can only deploy a cluster initially which is too small to run OpenShift AI. Or you want to add compute resources (instanceType) with GPUs to your cluster.

I use a shell script to create a values.yaml and a named template file using the extracted info from the existing machineset of the cluster and execute a Helm chart to generate the manifest for the machineset to add. Notice that all I need to do is to provide the AWS instanceType, in my case, m5.12xlarge. You could have chosen one with GPUs instead.

All that you need to do is to login to OpenShift using an account with cluster-admin privilleges from the command line. From the script folder, issue the command:
<pre>
./generateCustomMachineset.sh m5.12xlarge | oc apply f -
</pre>
Replace m5.12xlarge with any valid AWS instanceType that you desire.
