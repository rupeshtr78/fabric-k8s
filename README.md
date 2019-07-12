Deploy Hyperledger Fabric Network using Kubernetes 
==================================================
The objective of this post is to implement a basic fabric network on
Kubernetes platform.The indent is to understand the architecture behind
kubernetes deployment of fabric network by going through each step .

We will be deploy one master node , two worker nodes and a NFS server to
share network artifacts and chain code data across the nodes.


![](https://miro.medium.com/max/60/1*i-2Y_PAJL6zT5bHn8dfqJA.png?q=20)

Keeping it simple we will be deploying the Hyperledger Fabric network
consisting of one organization, maintaining one peer node, one orderer
with 'solo' ordering service. We will create a channel , join peer to
the channel , install chaincode on peer and instantiate chaincode on
channel. Also invoke transactions against the deployed chaincode.

**Installation**

Install [Kubernetes
,](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/){.aq
.cc .ia .ib .ic .id}initialize cluster, add worker nodes to the
Kubernetes Cluster.We will mount PersistantVolumes as
NFS.[Configure](https://help.ubuntu.com/lts/serverguide/network-file-system.html){.aq
.cc .ia .ib .ic .id} your NFS file server VM and mount the NFS share on
all the nodes.

**Generate the Network Artifacts**

Generate the network artifacts using configtx.yaml,
crypto-config.yaml.If you intent to modify the network topology, change
the configuration files (.yaml files) appropriately.

Copy (or use bind) the files from network artifacts , crypto and
chaincode directory to NFS share.

**Deployment Model**

![K8s Deployment
Model](https://miro.medium.com/max/60/1*4OIVJZ57t7z-M1zQfkDdaw.png?q=20)

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

> [cd fabric-k8s/k8s](https://github.com/rupeshtr78/fabric-k8s){.aq .cc
> .ia .ib .ic .id}
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
Dashboard](https://miro.medium.com/max/60/1*vtSPqzsMu_9Y7ZwzzIhUlQ.png?q=20)

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
channel](https://miro.medium.com/max/60/1*qWvnKU3q69wKufPSJfQUlg.png?q=20)

**Install ChainCode**

> peer chaincode install -n rtrcc -v 1.0 -p
> github.com/hyperledger/fabric/examples/chaincode/chaincode\_example02/go

![**Install
ChainCode**](https://miro.medium.com/max/60/1*9e5ufsHHFsTVLJ3nUOpTLQ.png?q=20)}

**Instantiate ChainCode**

> peer chaincode instantiate -o orderer0-orgorderer1:32000 -C
> \$CHANNEL\_NAME -n rtrcc -v 1.0 -c
> '{"Args":\["init","a","100\","b","200\"\]}' -P "AND('Org1MSP.member')"

![**Instantiate
ChainCode**](https://miro.medium.com/max/60/1*fiVnD-BgfYXIKYJ7KJb11Q.png?q=20)

**Invoke ChainCode**

> peer chaincode invoke -C \$CHANNEL\_NAME -n rtrcc -c
> '{"Args":\["invoke","a","b","10\"\]}'
>
> peer chaincode query -C \$CHANNEL\_NAME -n rtrcc -c
> '{"Args":\["query","a"\]}'

![Query
Result](https://miro.medium.com/max/60/1*54s934zDR0oVubDT7Lf76Q.png?q=20)

You would see that the chain code container is getting started inside
the docker-dind pod as a sidecar container.

**References**

[](https://applatix.com/case-docker-docker-kubernetes-part-2/)


[](https://medium.com/m/signin?operation=register&redirect=https%3A%2F%2Fmedium.com%2F%40rupeshtr%2Fdeploy-hyperledger-fabric-network-using-kubernetes-5d993f4236df&source=post_sidebar-----5d993f4236df---------------------clap_sidebar-){.aq
