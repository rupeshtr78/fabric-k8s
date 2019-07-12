Deploy Hyperledger Fabric Network using Kubernetes 
==================================================
The objective of this post is to implement a basic fabric network on
Kubernetes platform.The indent is to understand the architecture behind
kubernetes deployment of fabric network by going through each step .

We will be deploy one master node , two worker nodes and a NFS server to
share network artifacts and chain code data across the nodes.


![](images/K8S-MASTER.png==100x)

Keeping it simple we will be deploying the Hyperledger Fabric network
consisting of one organization, maintaining one peer node, one orderer
with 'solo' ordering service. We will create a channel , join peer to
the channel , install chaincode on peer and instantiate chaincode on
channel. Also invoke transactions against the deployed chaincode.

**Installation**

Install [Kubernetes
,](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)initialize cluster, add worker nodes to the Kubernetes Cluster.We will mount PersistantVolumes as
NFS.[Configure](https://help.ubuntu.com/lts/serverguide/network-file-system.html)your NFS file server VM and mount the NFS share on all the nodes.

**Generate the Network Artifacts**

Generate the network artifacts using configtx.yaml,
crypto-config.yaml.If you intent to modify the network topology, change
the configuration files (.yaml files) appropriately.

Copy (or use bind) the files from network artifacts , crypto and
chaincode directory to NFS share.

**Deployment Model**

![K8s Deployment
Model](images/FABRIC-K8S.png)

***NameSpace***

1.  *fabrick8s*

***Services***

1.  *Orderer*
2.  *Peer*
3.  *Docker Dind*

***Deployments***

1.  *Orderer*
2.  *Peer*
3.  *Docker Dind ( For ChainCode container Docker in Docker)*
4.  *CLI For executing peer commands (Optional --- create k8s jobs
    instead)*

*Persistent Volume Claim*

*Persistent Volume ( NFS)*

**Start the network**

Now lets start the network by running scripts one by one.

> [cd fabric-k8s/k8s](https://github.com/rupeshtr78/fabric-k8s)
>
> kubectl create -f 1namespace.yaml\
> kubectl create -f 2pv-pvc.yaml\
> kubectl create -f 3orderer0-orgorderer1-deploy.yaml\
> kubectl create -f 4peer0-org1-deploy.yaml\
> kubectl create -f 5docker.yaml\
> kubectl create -f 6docker-volume.yaml\
> kubectl create -f 7org1-cli-deploy.yaml\
>
> Verify the deployments in the dashboard

![Kubernetes
Dashboard](images/b8s-dashboard.jpeg)

**Create , join , Update Channel** 
----------------------------------

> Manually enter into the CLI.\
> kubectl get pods --- all-namespaces\
> kubectl exec -it cli-2XXXXX3 bash --- namespace=fabrick8s\
>
> peer channel create -o orderer0-orgorderer1:32000 -c \$CHANNEL\_NAME
> -f ./channel-artifacts/channel.tx --- outputBlock
> ./channel-artifacts/rtrchannel01.block
>
> peer channel fetch newest -o orderer0-orgorderer1:32000 -c
> \$CHANNEL\_NAME
>
> peer channel join -b \${CHANNEL\_NAME}\_newest.block

![Kubernetes Dashboard Orderer Pod Logs shows new
channel](images/k8s-orderer-logs.jpeg)

**Install ChainCode**

> peer chaincode install -n rtrcc -v 1.0 -p
> github.com/hyperledger/fabric/examples/chaincode/chaincode\_example02/go

![**Install
ChainCode**](images/cc-install.jpeg)

**Instantiate ChainCode**

> peer chaincode instantiate -o orderer0-orgorderer1:32000 -C
> \$CHANNEL\_NAME -n rtrcc -v 1.0 -c
> '{"Args":\["init","a","100\","b","200\"\]}' -P "AND('Org1MSP.member')"

![**Instantiate
ChainCode**](images/cc-Instantiate.jpeg)

**Invoke ChainCode**

> peer chaincode invoke -C \$CHANNEL\_NAME -n rtrcc -c
> '{"Args":\["invoke","a","b","10\"\]}'
>
> peer chaincode query -C \$CHANNEL\_NAME -n rtrcc -c
> '{"Args":\["query","a"\]}'

![Query
Result](images/cc-invoke.jpeg)

You would see that the chain code container is getting started inside
the docker-dind pod as a sidecar container.

**References**

https://applatix.com/case-docker-docker-kubernetes-part-2
