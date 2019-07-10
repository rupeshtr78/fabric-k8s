###############################################################################################
#
#   Basic Hyperledger Fabric using Kubernetes
#
#   The objective of this post is to implement a basic fabric network on Kubernetes platform.
#   The indent is to understand the steps needed for deployment through manual steps .
#
################################################################################################

# Configure NFS Share
# For easier maintenance make all NFS exports in single directory
# mount --bind /crypto-config /export/users # Bind Option

sudo apt install nfs-kernel-server
sudo systemctl start nfs-kernel-server.service
sudo nano /etc/exports
/opt/share    *(rw,sync,no_root_squash)

# on Worker Nodes
sudo apt install nfs-common  
mkdir -p ~/opt/share
showmount -e 192.168.1.840
sudo mount 192.168.1.840:/opt/share /opt/share
# sudo umount 192.168.1.840:/opt/share  /opt/share
################################################################################################
# Generate Artifacts
################################################################################################
rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config

cryptogen generate --config=./crypto-config.yaml

configtxgen -profile OneOrgsOrdererGenesis -channelID rtr-sys-channel -outputBlock ./channel-artifacts/genesis.block

export CHANNEL_NAME=rtrchannel01

configtxgen -profile OneOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

configtxgen -profile OneOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

#Copy to NFS share
cp -R  ./channel-artifacts  /opt/share
cp -R  ./crypto-config     /opt/share

################################################################################################
# Start Network
################################################################################################
cd fabric-k8s/k8s

kubectl create -f 1namespace.yaml
kubectl create -f 2pv-pvc.yaml
kubectl create -f 3orderer0-orgorderer1-deploy.yaml
kubectl create -f 4peer0-org1-deploy.yaml
kubectl create -f 5docker.yaml
kubectl create -f 6docker-volume.yaml
kubectl create -f 7org1-cli-deploy.yaml


# Stop Network
kubectl delete -f 7org1-cli-deploy.yaml
kubectl delete -f 6docker-volume.yaml
kubectl delete -f 5docker.yaml
kubectl delete -f 4peer0-org1-deploy.yaml
kubectl delete -f 3orderer0-orgorderer1-deploy.yaml
kubectl delete -f 2pv-pvc.yaml
kubectl delete -f 1namespace.yaml

################################################################################################

kubectl get pods --all-namespaces

kubectl exec -it cli-2XXXXX3-pod bash --namespace=fabrick8s

# kubectl exec -it   -n fabrick8s bash
################################################################################################
#Create join Update Channel
################################################################################################
export CHANNEL_NAME=rtrchannel01

peer channel create -o orderer0-orgorderer1:32000 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --outputBlock ./channel-artifacts/rtrchannel01.block

peer channel fetch newest -o orderer0-orgorderer1:32000 -c $CHANNEL_NAME

peer channel join -b rtrchannel01_newest.block

peer channel update -o orderer0-orgorderer1:32000 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx

# peer channel list
# peer channel fetch newest -c $CHANNEL_NAME
# peer channel getinfo -c $CHANNEL_NAME

################################################################################################################
#Chain Code
################################################################################################################
peer chaincode install -n rtrcc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/chaincode_example02/go

peer chaincode install -n rtrabac01 -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/abac/go

peer chaincode list --installed

peer chaincode instantiate -o orderer0-orgorderer1:32000 -C $CHANNEL_NAME -n rtrcc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND('Org1MSP.member')"

peer chaincode instantiate -o orderer0-orgorderer1:32000 -C $CHANNEL_NAME -n rtrabac01 -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' 

peer chaincode list --instantiated -C $CHANNEL_NAME 

peer chaincode query -C $CHANNEL_NAME -n rtrcc -c '{"Args":["query","a"]}'

peer chaincode invoke -C $CHANNEL_NAME -n rtrcc -c '{"Args":["invoke","a","b","10"]}' 


############################################################################################################################################################
# Verify Chaincode container inside docker-dind pod
kubectl exec -it docker-dind-2XXXXX3-pod sh --namespace=fabrick8s
docker ps -a
############################################################################################################################################################


# export CORE_CHAINCODE_EXECUTETIMEOUT=300s
# export CORE_CHAINCODE_DEPLOYTIMEOUT=300s

# verify on peer
# /var/hyperledger/production/ledgersData/stateLeveldb exists

# docker ps -a --format "{{.Names}}  : {{.ID}}"
# docker ps --format "{{.Names}} : {{.ID}} : {{.Status}}"