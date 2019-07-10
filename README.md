# Deploy Basic Hyperledger Fabric Network using Kubernetes

The objective of this post is to implement a basic fabric network on Kubernetes platform.
The indent is to understand the architecture behind kubernetes deployment of fabric network by going through each step.

Keeping it simple we will be deploying the  Hyperledger Fabric network on kubernetes consisting of one organization, maintaining one peer node, one orderer with 'solo' ordering service. We will create a channel , join peer to the channel ,  
install chaincode on peer and instantiate chaincode on channel. Also invoke transactions against the  deployed chaincode.
* Refer the k8s-steps file for the steps followed.


# Refer Medium.com article for more details
* https://medium.com/p/5d993f4236df/edit

References 
* https://applatix.com/case-docker-docker-kubernetes-part-2/
* https://applatix.com/case-docker-docker-kubernetes-part-2/
